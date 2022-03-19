#!/usr/bin/env python3
"""Notify of new software versions reported by nvchecker on Rocket Chat.

Requires:

* https://pypi.org/project/appdirs/
* https://pypi.org/project/tabulate/
* https://pypi.org/project/rocket-python/

"""

import argparse
import configparser
import json
import shutil
import sys
from os.path import join
from subprocess import CalledProcessError, run
from textwrap import dedent

import appdirs
import tabulate
from rocketchat.api import RocketChatAPI

CONFIG = "nvchecker-notify-rocketchat.ini"
USER_CONFIG_DIR = appdirs.user_config_dir("nvchecker")


def get_config(fn):
    config_path = join(USER_CONFIG_DIR, fn)
    cp = configparser.ConfigParser()
    cp.read(config_path)
    return cp["notify-rocketchat"]


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


def main(args=None):
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument(
        "-c",
        "--config",
        metavar="FILENAME",
        default=CONFIG,
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
        default="fancy_grid",
        choices=tabulate.tabulate_formats,
        help="Versions table display format.",
    )

    args = ap.parse_args(args)

    try:
        config = get_config(args.config)
    except KeyError as exc:
        sys.exit(f"Could not parse configuration. Section {exc} not found.")

    versions = run_nvcmp()

    if versions:
        message = make_message(
            versions, config.get("template", "{table}"), config.get("tablefmt", args.table_format)
        )

        if args.dry_run:
            print(message)
            return

        api = RocketChatAPI(
            settings={
                "username": config.get("username"),
                "password": config.get("password"),
                "domain": config.get("server_url"),
            }
        )

        private_rooms = {r["name"]: r["id"] for r in api.get_private_rooms()}
        room_id = private_rooms.get(config.get("room"))

        if room_id:
            res = api.send_message(message, room_id)

            if not res.get("success"):
                print(f"Failed to deliver message.", file=sys.stderr)
        else:
            print("Room {} not found.".format(config.get("room")), file=sys.stderr)


if __name__ == "__main__":
    sys.exit(main() or 0)
