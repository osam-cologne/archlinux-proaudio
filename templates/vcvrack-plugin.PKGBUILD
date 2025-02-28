# Maintainer: OSAMC <https://github.com/osam-cologne/archlinux-proaudio>

_slug=Example # from plugin.json
_name=example # e.g. repo name
pkgname=vcvrack-example
pkgver=2.0.0
pkgrel=1
pkgdesc='An example description'
arch=(aarch64 x86_64)
url=''
license=(GPL-3.0-or-later) # identifier from https://spdx.org/licenses/
groups=(pro-audio vcvrack-plugins)
depends=(gcc-libs vcvrack)
makedepends=(simde zstd)
checkdepends=()
optdepends=()
source=()
sha256sums=()

prepare() {
  cd $_name-$pkgver
  # optional: remove unnecessary files like common license (GPL etc.) or files not required for running the plugin
  rm LICENSE.txt
}

build() {
  cd $_name-$pkgver
  make SLUG=$_slug VERSION=$pkgver STRIP=: RACK_DIR=/usr/share/vcvrack dist
}

package() {
  cd $_name-$pkgver
  install -d "$pkgdir"/usr/lib/vcvrack/plugins
  cp -va dist/$_slug -t "$pkgdir"/usr/lib/vcvrack/plugins

  # optional: install license if required (BSD etc.)
  install -d "$pkgdir"/usr/share/licenses/$pkgname
  mv -v "$pkgdir"/usr/lib/vcvrack/plugins/$_slug/LICENSE.txt "$pkgdir"/usr/share/licenses/$pkgname
}
