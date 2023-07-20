#!/usr/bin/env python3
"""Notify of new software versions reported by nvchecker on Matrix chat.

Requires:

* https://pypi.org/project/appdirs/
* https://pypi.org/project/tabulate/
* https://github.com/poljar/matrix-nio

"""

import argparse
import asyncio
import json
import logging
import os
import shutil
import sys
from os.path import exists, isdir, join
from subprocess import CalledProcessError, run

import appdirs
import tabulate
from nio import AsyncClient, LoginResponse

PROG = "nvchecker-notify-matrixchat"
CONFIG_FILENAME = f"{PROG}.json"
STATE_FILENAME = f"{PROG}-seen.json"
USER_CONFIG_DIR = appdirs.user_config_dir("nvchecker")
USER_CACHE_DIR = appdirs.user_cache_dir("nvchecker")
DEFAULT_TABLEFMT = "fancy_grid"
log = logging.getLogger(PROG)


def read_config(fn):
    config_path = join(USER_CONFIG_DIR, fn)

    with open(config_path) as fp:
        config = json.load(fp)

    assert config.get("homeserver"), "'homeserver' not set in config."
    assert config.get("user_id"), "'user_id' not set in config."
    assert config.get("room_id"), "'room_id' not set in config."

    return config


def write_config(fn, config, resp):
    """Write account details to disk for later logins.

    Arguments:
        resp {LoginResponse} -- the successful client login response.
        config -- dictionary of config values

    """
    config_path = join(USER_CONFIG_DIR, fn)
    config_data = config.copy()
    config_data["access_token"] = resp.access_token
    config_data["device_id"] = resp.device_id

    if not isdir(USER_CONFIG_DIR):
        os.makedirs(USER_CONFIG_DIR)

    with open(config_path, "w") as fp:
        json.dump(config_data, fp, sort_keys=True, indent=2)


def read_state(fn):
    state_path = join(USER_CACHE_DIR, fn)

    if exists(state_path):
        with open(state_path) as fp:
            state = json.load(fp)
    else:
        state = {}

    assert isinstance(state, dict)
    return state


def write_state(fn, state):
    assert isinstance(state, dict)
    state_path = join(USER_CACHE_DIR, fn)

    if not isdir(USER_CACHE_DIR):
        os.makedirs(USER_CACHE_DIR)

    with open(state_path, "w") as fp:
        json.dump(state, fp, sort_keys=True, indent=2)


def run_nvcmp():
    try:
        nvcmp = shutil.which("nvcmp")
        if not nvcmp:
            raise OSError("Program not found: nvcmp")

        res = run([nvcmp, "--json"], capture_output=True, check=True)
    except CalledProcessError:
        return []
    else:
        return json.loads(res.stdout) if res.stdout else []


def make_message(versions, template="", fmt="markdown"):
    return template.format(table=tabulate.tabulate(versions, headers="keys", tablefmt=fmt))


async def send_notification(config, message):
    token = config.get("access_token")
    device_id = config.get("device_id")

    if token and device_id:
        client = AsyncClient(config["homeserver"])
        client.user_id = config["user_id"]
        client.access_token = token
        client.device_id = device_id
    else:
        client = AsyncClient(config["homeserver"], config["user_id"])
        log.debug("Created AsyncClient: %r", client)
        log.debug("Trying to log in with password...")
        resp = await client.login(config["password"], device_name=config.get("device_name"))
        log.debug("Response: %r", resp)

        # check that we logged in succesfully
        if isinstance(resp, LoginResponse):
            try:
                write_config(CONFIG_FILENAME, config, resp)
            except OSError:
                pass
        else:
            log.error(f"Failed to log in: {resp}")
            await client.close()
            return

    if isinstance(message, dict):
        message.setdefault("msgtype", "m.notice")
        await client.room_send(config["room_id"], message_type="m.room.message", content=message)
    else:
        await client.room_send(
            config["room_id"],
            message_type="m.room.message",
            content={"msgtype": "m.notice", "body": message},
        )

    await client.close()


def main(args=None):
    ap = argparse.ArgumentParser(prog=PROG, description=__doc__.splitlines()[0])
    ap.add_argument(
        "-c",
        "--config",
        metavar="FILENAME",
        default=CONFIG_FILENAME,
        help="Configuration file name (default: '%(default)s')",
    )
    ap.add_argument(
        "-d",
        "--dry-run",
        action="store_true",
        help="Don't send notification message, only print it.",
    )
    ap.add_argument(
        "-f",
        "--table-format",
        metavar="FMT",
        choices=tabulate.tabulate_formats,
        help="Versions table display format.",
    )
    ap.add_argument(
        "-s",
        "--seen",
        action="store_true",
        default=None,
        help="Ignore record of seen new versions and report them anyway.",
    )
    ap.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        help="Enable debug level logging.",
    )

    args = ap.parse_args(args)

    try:
        config = read_config(args.config)
    except KeyError as exc:
        sys.exit(f"Could not parse configuration: {exc}")

    logging.basicConfig(
        level=getattr(logging, "DEBUG" if args.verbose is not None else config.get("log_level", "INFO")),
        format=config.get("log_format", "%(levelname)s: %(message)s"),
    )

    state = read_state(STATE_FILENAME)
    versions = run_nvcmp()

    if versions:
        if not args.seen:
            unseen = []
            for version in versions:
                if state.get(version["name"]) != version["newver"]:
                    unseen.append(version)
                else:
                    log.debug("%s version %s already seen.", version["name"], version["newver"])
        else:
            unseen = versions

        if unseen:
            tablefmt = args.table_format or config.get("tablefmt", DEFAULT_TABLEFMT)
            message = make_message(unseen, template=config.get("template", "{table}"), fmt=tablefmt)

            if "html" in tablefmt:
                message = {"formatted_body": message}
                message["body"] = make_message(versions, template="{table}", fmt="simple")
                message["format"] = "org.matrix.custom.html"

            if not args.dry_run:
                try:
                    log.debug("Sending notification to Matrix chat...")
                    asyncio.run(send_notification(config, message))
                except KeyboardInterrupt:
                    log.info("Interrupted.")

            else:
                log.info("%s", message)
        else:
            log.info("No unseen versions to report.")

        for version in versions:
            state[version["name"]] = version["newver"]

        log.debug("Writing seen versions state.")
        write_state(STATE_FILENAME, state)
        log.debug("Done.")
    else:
        log.debug("No new versions found.")


if __name__ == "__main__":
    sys.exit(main() or 0)
