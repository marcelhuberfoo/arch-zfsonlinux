# Maintainer: Marcel Huber <marcelhuberfoo at gmail dot com>
# Contributor: Jesus Alvarez <jeezusjr at gmail dot com>
# Contributor: Kyle Fuller <inbox at kylefuller dot co dot uk>

pkgbase=zfsonlinux
pkgname=('spl-utils' 'spl-dkms')
pkgver=0.6.2
pkgrel=1
arch=('i686' 'x86_64')
url='http://zfsonlinux.org/'
groups=('archzfs')
license=('GPL')
source=(http://archive.zfsonlinux.org/downloads/zfsonlinux/spl/spl-${pkgver}.tar.gz
        shrinker.patch
	spl-utils.install
	spl-dkms.install)
sha256sums=('3c577c7055d6c73179726b9c8a7fd48f9122be0b345c50cd54732e801165daa4'
            '596f5bc1ef30e27a214bfd4962f8d3ed319cd7b4fe9f46b73d8d91d36c22b9e3'
            'c943966808a7cace46824740db4fb1bdff10c5ce08304417fb35a407994a1dbb'
            'bb72fcab2fdb88aeba7c8d059a8f27fd2d32730f3d824d9303ca71f967bc2464')

prepare() {
  cd "$srcdir/spl-${pkgver}"
  patch -Np1 < ../shrinker.patch
}

build() {
  cd "$srcdir/spl-${pkgver}"

  ./autogen.sh
  ./configure --prefix=/usr --libdir=/usr/lib --sbindir=/usr/bin \
              --with-config=user
  make

}

package_spl-utils() {
  pkgdesc='Solaris Porting Layer kernel module support files.'
  install=spl-utils.install

  cd "$srcdir/spl-${pkgver}"
  make DESTDIR=$pkgdir install
}

package_spl-dkms() {
  pkgdesc='Solaris Porting Layer kernel modules.'
  depends=('spl-utils' 'dkms')
  install=spl-dkms.install

  cd "$srcdir/spl-${pkgver}"
  # cleanup source tree
  make distclean
  ./autogen.sh
  scripts/dkms.mkconf -v ${pkgver} -f dkms.conf -n spl
  install -d ${pkgdir}/usr/src/spl-${pkgver}
  cp -a ${srcdir}/spl-${pkgver}/ ${pkgdir}/usr/src/
}
