# Maintainer: Marcel Huber <marcelhuberfoo at gmail dot com>
# Contributor: Jesus Alvarez <jeezusjr at gmail dot com>
# Contributor: Kyle Fuller <inbox at kylefuller dot co dot uk>

pkgbase=zfsonlinux-dkms-git
pkgname=(zfs-kmod-dkms-git zfs-utilities-git)
_pkgsource=zfs
pkgver=0.8.0.rc2.71.gd611989fd
pkgrel=1
arch=(x86_64)
groups=(zfsonlinux)
makedepends=(gcc make autoconf automake git dkms)
provides=(zfs)
url='http://zfsonlinux.org/'
license=(GPL2 CDDL)
source=($_pkgsource::git+git://github.com/zfsonlinux/zfs.git
        zfs-utilities.install
        zfs-kmod-dkms.install
        zfs-utilities.bash-completion
        zfs-utilities.initcpio.install
        zfs-utilities.initcpio.hook
        zfs-utilities.initcpio.zfsencryptssh.install)
sha256sums=('SKIP'
            'aa5f3fd025c05078067acf01cbad82af322b4b8542d2d1c6a9103338eff6729d'
            '07dbd4765f2efae16b1a7781ed10edddc1d8112ad87b7cd17b6cc9736efb14de'
            'b60214f70ffffb62ffe489cbfabd2e069d14ed2a391fac0e36f914238394b540'
            '6bc89af16a6d028cec6237d4159b905b053b05e51fc551b5c906ac9ee1766328'
            '8322441756a8f1b6c039f95eee873f1bcf49a776c393a1e70c2029988ce14aa3'
            '29080a84e5d7e36e63c4412b98646043724621245b36e5288f5fed6914da5b68')

pkgver() {
  cd "$srcdir/$_pkgsource" 2>/dev/null && (
  # update dependent projects revision information
  if GITTAG="$(git describe --abbrev=0 --tags 2>/dev/null)"; then
    local _revs_ahead_tag=$(git rev-list --count ${GITTAG}..)
    local _commit_id_short=$(git log -1 --format=%h)
    echo $(sed -e s/^${pkgbase%%-git}// -e 's/^[-_/a-zA-Z]\+//' -e 's/[-_+]/./g' <<< ${GITTAG}).${_revs_ahead_tag}.g${_commit_id_short}
  else
    echo 0.$(git rev-list --count master).g$(git log -1 --format=%h)
  fi
  ) || echo $pkgver
}

# $1 version, $2 file
_my_replace_META_Version() {
  local _gitver="${1}"
  local _filename="${2}"
  # replace Version: and Release: in META files
  local _version=$(echo $_gitver | sed 's|\.[0-9]*\.[0-9a-fg]*$||')
  local _release=$(echo $_gitver | sed -r 's|^.*\.([0-9]*\.[0-9a-fg]*)$|\1|')
  sed -i -r -e "/^Version:/ { s/^([^0-9]*)[0-9.]+\$/\1$_version/ }" "$_filename"
  sed -i -r -e "/^Release:/ { s/^([^0-9r]*)[0-9a-fgr.]+\$/\1$_release/ }" "$_filename"
}

prepare() {
  cd "$srcdir/$_pkgsource"
  git clean -dxf 2>/dev/null
  git reset --hard 2>/dev/null
  _my_replace_META_Version "$(pkgver)" "$srcdir/$_pkgsource/META"
}

build() {
  cd "$srcdir/$_pkgsource"
  ./autogen.sh
}

package_zfs-kmod-dkms-git() {
  pkgdesc='Kernel modules for the Zettabyte File System.'
  license=(CDDL)
  depends=(dkms lsb-release)
  replaces=(spl-kmod-dkms-git)
  conflicts=(zfs-dkms zfs-dkms-therp zfs-dkms-therp-git zfs-kmod-dkms)
  install=zfs-kmod-dkms.install

  cd "$srcdir/$_pkgsource"
  scripts/dkms.mkconf -v $pkgver -f dkms.conf -n zfs
  install -d "$pkgdir/usr/src/zfs-${pkgver}"
  cp -a -T "$srcdir/$_pkgsource/" "$pkgdir/usr/src/zfs-${pkgver}"
  rm -rf "$pkgdir/usr/src/zfs-${pkgver}/.git"
}

package_zfs-utilities-git() {
  pkgdesc='Zettabyte File System management utilities.'
  license=(CDDL)
  depends=(zfs-kmod-dkms-git=${pkgver} python)
  replaces=(spl-utilities-git)
  conflicts=(zfs-utils zfs-utils-therp zfs-utils-therp-git zfs-utilities)
  install=zfs-utilities.install

  cd "$srcdir/$_pkgsource"
  ./configure --prefix=/usr \
              --sysconfdir=/etc \
              --sbindir=/usr/bin \
              --with-mounthelperdir=/usr/bin \
              --libdir=/usr/lib \
              --datadir=/usr/share \
              --includedir=/usr/include \
              --with-udevdir=/lib/udev \
              --libexecdir=/usr/lib/zfs-${pkgver} \
              --with-config=user \
              --enable-systemd
  make
  make DESTDIR="$pkgdir" install

  # Remove uneeded files
  rm -r "$pkgdir"/etc/init.d
  rm -r "$pkgdir"/usr/lib/dracut

  # move module tree /lib -> /usr/lib
  cp -r "$pkgdir"/{lib,usr}
  rm -r "$pkgdir"/lib

  install -D -m644 "${srcdir}/zfs-utilities.initcpio.hook" "$pkgdir/usr/lib/initcpio/hooks/zfs"
  install -D -m644 "${srcdir}/zfs-utilities.initcpio.install" "$pkgdir/usr/lib/initcpio/install/zfs"
  install -D -m644 "${srcdir}/zfs-utilities.initcpio.zfsencryptssh.install" "$pkgdir/usr/lib/initcpio/install/zfsencryptssh"
  install -D -m644 "${srcdir}/zfs-utilities.bash-completion" "$pkgdir/usr/share/bash-completion/completions/zfs"
}

# vim:set ts=2 sw=2 et:
