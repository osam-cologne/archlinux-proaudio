# archlinux-proaudio
[![Build Status](https://ci.cbix.de/api/badges/osam-cologne/archlinux-proaudio/status.svg)](https://ci.cbix.de/osam-cologne/archlinux-proaudio)
[![x86_64](https://arch.osamc.de/proaudio/x86_64/badge-count.svg)](https://arch.osamc.de/proaudio/x86_64/?P=*.pkg.tar.zst)
[![aarch64](https://arch.osamc.de/proaudio/aarch64/badge-count.svg)](https://arch.osamc.de/proaudio/aarch64/?P=*.pkg.tar.xz)

PKGBUILD files for the binary archlinux pro-audio OSAMC repository.

[**List of packages**](https://arch.osamc.de/#packages)

The repository is maintained and tested for both `x86_64` and `aarch64` (Arch Linux ARM) architectures.

Contributions are welcome!

## How to use
_As we're still working on the setup, this information maybe subject to change without notice!
We try to announce important changes on IRC ([#archlinux-proaudio](https://web.libera.chat/#archlinux-proaudio) on irc.libera.chat)
and reflect the current information on the [Arch Wiki](https://wiki.archlinux.org/title/Unofficial_user_repositories)._

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
