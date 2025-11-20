#!/usr/bin/env python3
#
# clean-packages.py
#
# Delete all package related files non-existent in the database

import logging
import os
import re
import tarfile

from os.path import expanduser, join


log = logging.getLogger("clean-packages")

# Initialize environment variables
ROOTDIR = expanduser("~/html")
DEBUG_PKGDIR = "debug-archive"
REPONAME = "proaudio"
DBFILE = "proaudio.db"
EXTENSIONS = (
    ".pkg.tar.xz",
    ".pkg.tar.xz.sig",
    ".pkg.tar.zst",
    ".pkg.tar.zst.sig",
)



def get_packages(arch):
    packages = {}
    with tarfile.open(join(ROOTDIR, REPONAME, arch, DBFILE + ".tar.gz")) as db:
        for pkg in (f for f in db.getnames() if not f.endswith("/desc")):
            m = re.match(r"(?P<pkg>.*)-(?P<ver>.*-\d+)$", pkg)
            packages[m.group("pkg")] = m.group("ver")
    return packages


def clean_packages(pkgdir, arch, packages, dryrun=True):
    files = sorted(f for f in os.listdir(pkgdir) if not f.startswith("."))

    for file in files:
        path = join(pkgdir, file)

        # Skip non-pkg files
        for ext in EXTENSIONS:
            if file.endswith(ext):
                break
        else:
            log.debug("Ignoring file with unknown extension: '%s'.", path)
            continue

        base = re.sub(r"\.pkg\..*", "", file)
        m = re.match(r"^(?P<pkg>.*)(-debug)?-(?P<ver>[^-]+-\d+)" + f"-(?P<arch>[^-]+)", base)
        if not m:
            log.warning("Unrecognized package filename format: '%s'", file)
            continue

        pkg, ver = m.group("pkg", "ver")
        if pkg.endswith("-debug"):
            if m.group("arch") != arch:
                # A debug package can't be 'any' arch, so we can skip the file,
                # if the arch in the filename doesn't match
                continue

            pkg = pkg[:-6]

        log.debug("Checking: %s %s", pkg, ver)
        
        if ver != packages.get(pkg):
            log.info("Cleaning '%s'.", path)

            if not dryrun:
                try:
                    os.unlink(path)
                except OSError as exc:
                    log.error("Could not delete file '%s': %s", path, exc)
        else:
            log.debug("Keeping '%s'.", path)
            
        
if __name__ == '__main__':
    import sys

    # hacky cmdline parsing ;-)
    dryrun = "-f" not in sys.argv[1:]

    if "-d" in sys.argv[1:]:
        level = logging.DEBUG
    elif "-v" in sys.argv[1:]:
        level = logging.INFO
    else:
        level = logging.WARNING

    logging.basicConfig(level=level, format="%(levelname)s:%(message)s")
    
    for arch in ("x86_64", "aarch64"):
        packages = get_packages(arch)
        clean_packages(join(ROOTDIR, REPONAME, arch), arch, packages, dryrun)
        clean_packages(join(ROOTDIR, DEBUG_PKGDIR), arch, packages, dryrun)
