# Maintainer: Marcel Huber <marcelhuberfoo at gmail dot com>
# Contributor: Jesus Alvarez <jeezusjr at gmail dot com>
# Contributor: Kyle Fuller <inbox at kylefuller dot co dot uk>

pkgbase=zfsonlinux
pkgname=('spl-utilities' 'spl-kmod-dkms' 'zfs-utilities' 'zfs-kmod-dkms')
pkgver=0.6.2
pkgrel=1
arch=('i686' 'x86_64')
groups=('zfsonlinux')
makedepends=('dkms')
provides=('zfs' 'spl')
conflicts=('zfs' 'spl')
url='http://zfsonlinux.org/'
license=('GPL2')
source=(http://archive.zfsonlinux.org/downloads/zfsonlinux/spl/spl-${pkgver}.tar.gz
        http://archive.zfsonlinux.org/downloads/zfsonlinux/zfs/zfs-${pkgver}.tar.gz
        shrinker.patch
        spl-utilities.install
        spl-kmod-dkms.install
        zfs-utilities.bash-completion
        zfs-utilities.initcpio.install
        zfs-utilities.initcpio.hook
        zfs-utilities.service
        zfs-kmod-dkms.install)
sha256sums=('3c577c7055d6c73179726b9c8a7fd48f9122be0b345c50cd54732e801165daa4'
            '6b8cd79486b3a51204fac07297b8c45aa8702b8dfade58f2098b5734517065a1'
            '596f5bc1ef30e27a214bfd4962f8d3ed319cd7b4fe9f46b73d8d91d36c22b9e3'
            'aa5f3fd025c05078067acf01cbad82af322b4b8542d2d1c6a9103338eff6729d'
            'bb72fcab2fdb88aeba7c8d059a8f27fd2d32730f3d824d9303ca71f967bc2464'
            '15e742477fad0104871fc055b6ce9bf803540070e47fa515ea7ca3c1a401f831'
            '1ea6d2cdd27798680a96c9ebf18e9167b0575d032c7cfc731f16456cd38f2040'
            'ab63abbd7fd8cb0a8293651947fda82a1b41d420cbb8e6c71c0fd3884ab43030'
            'fd0abaf09de5e472cca449439def43f1dbbd13f1c5f4bd0d233f59563de1637a'
            '07dbd4765f2efae16b1a7781ed10edddc1d8112ad87b7cd17b6cc9736efb14de')

prepare() {
  cd "${srcdir}/spl-${pkgver}"
  patch -Np1 < ../shrinker.patch
}

build() {
  ## building spl
  cd "${srcdir}/spl-${pkgver}"

  ./autogen.sh
  if [ $CARCH = 'i686' ]; then
    ./configure --prefix=/usr \
                --libdir=/usr/lib \
                --sbindir=/usr/bin \
                --with-config=user \
                --enable-atomic-spinlocks
  elif [ $CARCH = 'x86_64' ]; then
    ./configure --prefix=/usr \
                --libdir=/usr/lib \
                --sbindir=/usr/bin \
                --with-config=user
  fi
  make

  ## building zfs
  cd "${srcdir}/zfs-${pkgver}"
  ./autogen.sh
  ./configure --prefix=/usr \
              --sysconfdir=/etc \
              --sbindir=/usr/bin \
              --libdir=/usr/lib \
              --datadir=/usr/share \
              --includedir=/usr/include \
              --with-udevdir=/lib/udev \
              --libexecdir=/usr/lib/zfs-${pkgver} \
              --with-config=user
  make
}

package_spl-kmod-dkms() {
  pkgdesc='Solaris Porting Layer kernel modules.'
  license=('GPL2')
  depends=('dkms')
  conflicts=('spl-dkms' 'spl-dkms-therp')
  install=spl-kmod-dkms.install

  cd "${srcdir}/spl-${pkgver}"

  # cleanup source tree
  make distclean

  ./autogen.sh
  scripts/dkms.mkconf -v ${pkgver} -f dkms.conf -n spl

  install -d "${pkgdir}/usr/src/spl-${pkgver}"
  cp -a "${srcdir}/spl-${pkgver}/" "${pkgdir}/usr/src/"
}

package_spl-utilities() {
  pkgdesc='Solaris Porting Layer test utility.'
  license=('GPL2')
  depends=("spl-kmod-dkms=${pkgver}")
  conflicts=('spl-utils' 'spl-utils-therp')
  install=spl-utilities.install

  cd "${srcdir}/spl-${pkgver}"
  make DESTDIR="${pkgdir}" install
}

package_zfs-kmod-dkms() {
  pkgdesc="Kernel modules for the Zettabyte File System."
  license=('CDDL')
  depends=('dkms' "spl-kmod-dkms=${pkgver}")
  conflicts=('zfs-dkms' 'zfs-dkms-therp')
  install=zfs-kmod-dkms.install

  cd "${srcdir}/zfs-${pkgver}"

  # cleanup source tree
  make distclean

  ./autogen.sh
  scripts/dkms.mkconf -v ${pkgver} -f dkms.conf -n zfs

  install -d "${pkgdir}/usr/src/zfs-${pkgver}"
  cp -a "${srcdir}/zfs-${pkgver}/" "${pkgdir}/usr/src/"
}

package_zfs-utilities() {
  pkgdesc="Zettabyte File System management utilities."
  license=('CDDL')
  depends=("zfs-kmod-dkms=${pkgver}")
  optdepends=("spl-utilities=${pkgver}: for executing spl tests")
  conflicts=('zfs-utils' 'zfs-utils-therp')

  cd "${srcdir}/zfs-${pkgver}"
  make DESTDIR="${pkgdir}" install

  # Remove uneeded files
  rm -r "${pkgdir}/etc/init.d"
  rm -r "${pkgdir}/usr/lib/dracut"

  # move module tree /lib -> /usr/lib
  cp -r "${pkgdir}"/{lib,usr}
  rm -r "${pkgdir}/lib"

  # Fixup path
  mv "${pkgdir}/sbin/mount.zfs" "${pkgdir}/usr/bin/"
  rm -r "${pkgdir}/sbin"

  install -D -m644 "${srcdir}/zfs-utilities.initcpio.hook" "${pkgdir}/usr/lib/initcpio/hooks/zfs"
  install -D -m644 "${srcdir}/zfs-utilities.initcpio.install" "${pkgdir}/usr/lib/initcpio/install/zfs"
  install -D -m644 "${srcdir}/zfs-utilities.service" "${pkgdir}/usr/lib/systemd/system/zfs.service"
  install -D -m644 "${srcdir}/zfs-utilities.bash-completion" "${pkgdir}/usr/share/bash-completion/completions/zfs"
}

# vim:set ts=2 sw=2 et:
