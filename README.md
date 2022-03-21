# archlinux-proaudio
[![Build Status](https://ci.cbix.de/api/badges/osam-cologne/archlinux-proaudio/status.svg)](https://ci.cbix.de/osam-cologne/archlinux-proaudio)

PKGBUILD files for the binary archlinux pro-audio OSAMC repository.

The repository is maintained and tested for both `x86_64` and `aarch64` (Arch Linux ARM) architectures.

Contributions are welcome!

## How to use
Add the repo to your `/etc/pacman.conf`:
```
[proaudio]
Server = https://arch.osamc.de/$repo/$arch
```
Download the current signing key:
```
$ wget https://arch.osamc.de/proaudio/osamc.gpg
```
Import and sign locally:
```
# pacman-key --add osamc.gpg
# pacman-key --lsign-key 762AE5DB2B38786364BD81C4B9141BCC62D38EE5
```
You can now install packages from the repo using `pacman -Sy`.

## Guidelines
This project closely follows the [Arch package guidelines](https://wiki.archlinux.org/title/Arch_package_guidelines).
To support packaging, convenient tools are being maintained in this repo.
- [`.editorconfig`](https://editorconfig.org/) to ensure consistent formatting of PKGBUILDs in your editor (may need a plugin)
- `tools/fmt.sh` to manually format the PKGBUILD files (needs [`shfmt`](https://archlinux.org/packages/community/x86_64/shfmt/) installed)
- An [nvchecker](https://nvchecker.readthedocs.io/en/latest/) config with patterns for all included packages.
- check the CI logs for hints:
  - [`namcap`](https://wiki.archlinux.org/title/Namcap) analysis of PKGBUILD
  - full build of the package in a [clean environment](https://wiki.archlinux.org/title/DeveloperWiki:Building_in_a_clean_chroot#Why)
  - `namcap` analysis of the built package
  - rebuild and basic analysis of [reproducibility](https://reproducible-builds.org/) using [`diffoscope`](https://diffoscope.org/)
