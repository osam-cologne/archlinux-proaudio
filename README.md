# archlinux-proaudio
[![Build Status](https://ci.cbix.de/api/badges/osam-cologne/archlinux-proaudio/status.svg)](https://ci.cbix.de/osam-cologne/archlinux-proaudio)

PKGBUILD files for the binary archlinux pro-audio OSAMC repository

## Guidelines
This project closely follows the [Arch package guidelines](https://wiki.archlinux.org/title/Arch_package_guidelines).
To support packaging, convenient tools are being maintained in this repo.
- [`.editorconfig`](https://editorconfig.org/) to ensure consistent formatting of PKGBUILDs in your editor (may need a plugin)
- `tools/fmt.sh` to manually format the PKGBUILD files (needs [`shfmt`](https://archlinux.org/packages/community/x86_64/shfmt/) installed)
- check the CI logs for hints:
  - [`namcap`](https://wiki.archlinux.org/title/Namcap) analysis of PKGBUILD
  - full build of the package in a [clean environment](https://wiki.archlinux.org/title/DeveloperWiki:Building_in_a_clean_chroot#Why)
  - `namcap` analysis of the built package
  - rebuild and basic analysis of [reproducibility](https://reproducible-builds.org/) using [`diffoscope`](https://diffoscope.org/)
