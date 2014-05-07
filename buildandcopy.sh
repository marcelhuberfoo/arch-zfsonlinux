#!/bin/sh

thedirs="spl-kmod-dkms spl-utilities zfs-kmod-dkms zfs-utilities"
set -e
echo "Start updating from git (y*|n)?"
read v
if [ "$v" = "n" -o "$v" = "N" ]; then false; fi
for n in $thedirs; do ( cd $n && updpkgsums ;  makepkg --force --noprogressbar --nodeps --nobuild ); done

echo "Start building (y*|n)?"
read v
if [ "$v" = "n" -o "$v" = "N" ]; then false; fi
for n in $thedirs; do ( cd $n && updpkgsums ;  makepkg --force --noprogressbar --nodeps ); done

repodir=/home/own-repo

echo "Install to $repodir (y*|n)?"
read v
if [ "$v" = "n" -o "$v" = "N" ]; then false; fi
for pkgdir in `find . -name '*.tar.xz' -printf "%h\n" | sort | uniq`; do cpfn=`ls -tc1 $pkgdir/*.tar.xz | head -1`; echo "copy [$cpfn]? (y*|n)"; read v; if [ ! "$v" = "n" -a ! "$v" = "N" ]; then sudo sh -c "cp $cpfn $repodir && repo-add -f -d -n ${repodir}/ownrepo.db.tar.gz $repodir/`basename $cpfn`"; fi; done

