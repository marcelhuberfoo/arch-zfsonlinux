#!/bin/sh

thedirs="spl-kmod-dkms spl-utilities zfs-kmod-dkms zfs-utilities"
repodir=/home/own-repo

thingsToDo=(
  'for n in $thedirs; do ( cd $n && updpkgsums ;  makepkg --force --noprogressbar --nodeps --nobuild ); done'
  'git diff --quiet --no-ext-diff --exit-code || git diff -b -w && git add -p && git commit'
  'for n in $thedirs; do ( cd $n && updpkgsums ;  makepkg --force --noprogressbar --nodeps ); done'
  'test -d "$repodir" && for pkgdir in $(find $thedirs -name ''*.tar.xz'' -printf "%h\n" | sort | uniq); do cpfn=$(ls -tc1 $pkgdir/*.tar.xz | head -1); echo "copy [$cpfn]? (y*|n)"; read v; if [ ! "$v" = "n" -a ! "$v" = "N" ]; then sudo sh -c "cp --interactive --preserve --update $cpfn $repodir && repo-add --files --new --quiet ${repodir}/ownrepo.db.tar.gz $repodir/$(basename $cpfn)"; fi; done'
)

set -e

for n in "${thingsToDo[@]}"; do
  echo "Continue with [$n] (y*|n)?"
  read v
  if [ "$v" = "n" -o "$v" = "N" ]; then
    echo "..command skipped..";
  else
    eval "$n";
  fi
done

