#!/usr/bin/env python
"""Get newest packages from an Arch package database."""

import argparse
import shelve
import pyalpm
from datetime import datetime, timedelta
from operator import attrgetter

PROG = "getnewpackages"
PKG_ATTRS = [
    "arch",
    "backup",
    "base",
    "base64_sig",
    "builddate",
    "checkdepends",
    "conflicts",
    "depends",
    "desc",
    "download_size",
    "filename",
    "files",
    "groups",
    "licenses",
    "makedepends",
    "md5sum",
    "name",
    "optdepends",
    "packager",
    "provides",
    "replaces",
    "sha256sum",
    "size",
    "url",
    "version",
]


def main(args=None):
    ap = argparse.ArgumentParser(prog=PROG, description=__doc__.splitlines()[0])
    ap.add_argument(
        "-d",
        "--db",
        metavar="NAME",
        default="proaudio",
        help="package database name (default: %(default)r)",
    )
    ap.add_argument(
        "-i",
        "--interval",
        type=int,
        default=7,
        help="interval in days (default: %(default)i days)",
    )
    ap.add_argument(
        "-H",
        "--history-file",
        metavar="FILE",
        default="history.db",
        help="history database file name (default: %(default)r)",
    )
    ap.add_argument(
        "-I",
        "--ignore-history",
        action="store_true",
        help="Report new package versions, even when they are already in the history database",
    )
    ap.add_argument(
        "-N",
        "--no-history-update",
        action="store_true",
        help="Do not update history database",
    )
    ap.add_argument(
        "dbpath",
        nargs="?",
        metavar="DIR",
        default="package-db",
        help="database root path (default: %(default)r)",
    )

    args = ap.parse_args(args)

    handle = pyalpm.Handle(".", args.dbpath)
    pkgdb = handle.register_syncdb(args.db, pyalpm.SIG_DATABASE_OPTIONAL)

    hstdb = shelve.open(args.history_file, writeback=True)

    now = datetime.utcnow()
    then = now - timedelta(days=args.interval)

    new = []

    for pkg in pkgdb.search(""):
        versions = hstdb.get(pkg.name, {})
        if datetime.fromtimestamp(pkg.builddate) >= then and (
            args.ignore_history or pkg.version not in versions
        ):
            new.append(pkg)

    # Update history DB
    if not args.no_history_update:
        for pkg in pkgdb.search(""):
            if pkg.name not in hstdb:
                hstdb[pkg.name] = {}

            if (
                pkg.version not in hstdb[pkg.name]
                or hstdb[pkg.name][pkg.version]["builddate"] < pkg.builddate
            ):
                hstdb[pkg.name][pkg.version] = {attr: getattr(pkg, attr) for attr in PKG_ATTRS}

    hstdb.close()

    for pkg in sorted(new, key=attrgetter('builddate')):
        print(f"{pkg.name}, {pkg.version}, {pkg.desc}")


if __name__ == "__main__":
    import sys

    sys.exit(main() or 0)
