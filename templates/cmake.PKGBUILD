# Maintainer: OSAMC <https://github.com/osam-cologne/archlinux-proaudio>

pkgname=example
pkgver=0.0.1
pkgrel=1
pkgdesc='An example description'
arch=(aarch64 x86_64)
url=''
license=(GPL-3.0-or-later) # identifier from https://spdx.org/licenses/
groups=(pro-audio ladspa-plugins lv2-plugins vst-plugins vst3-plugins clap-plugins vcvrack-plugins)
depends=()
makedepends=(cmake)
checkdepends=()
optdepends=('clap-host: for running the CLAP plugin'
            'ladspa-host: for running the LADSPA plugin'
            'lv2-host: for running the LV2 plugin'
            'vst-host: for running the VST plugin'
            'vst3-host: for running the VST3 plugin')
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
  cmake --build build-$pkgname
}

check() {
  ctest --test-dir build-$pkgname --output-on-failure
}

package() {
  DESTDIR="$pkgdir" cmake --install build-$pkgname
}
