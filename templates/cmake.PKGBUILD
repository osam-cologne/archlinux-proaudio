# Maintainer: OSAMC <https://github.com/osam-cologne/archlinux-proaudio>

pkgname=
pkgver=
pkgrel=1
pkgdesc=''
arch=(aarch64 x86_64)
url=''
license=()
groups=(pro-audio)
depends=()
makedepends=(cmake)
checkdepends=()
optdepends=()
source=()
sha256sums=()

prepare() {
}

build() {
	local cmake_options=(
    -B build-$pkgname
    -S $pkgname-$pkgver
    -W no-dev
    -D CMAKE_BUILD_TYPE=None
    -D CMAKE_INSTALL_PREFIX=/usr
  )
  cmake "${cmake_options[@]}"
  cmake --build build
}

check() {
	ctest --test-dir build-$pkgname --output-on-failure
}

package() {
	DESTDIR="$pkgdir" cmake --install build-$pkgname
}
