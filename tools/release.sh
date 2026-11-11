#!/bin/sh
#
# release.sh <name> <version> <arch> <file.tcz>
#
# Run on a dev machine with the GitHub CLI (gh) authenticated.
# Uploads <file.tcz> to the per-app release "<name>" as "<name>-<arch>.tcz",
# creating the release if needed and replacing any previous build for that
# arch. Prints the line to put in .utils/packages.list (replacing the old
# row for <name>/<arch>). Commit it, or Pis will reject the new build.
#
# <version> is only recorded in the manifest; it is not part of the release.
#
# arch: aarch64 | armhf

set -eu

if [ $# -ne 4 ]
then
  echo "usage: $0 <name> <version> <arch> <file.tcz>" >&2
  exit 1
fi

NAME=$1
VERSION=$2
ARCH=$3
SRC=$4

case "$ARCH" in
  aarch64|armhf) ;;
  *) echo "arch must be aarch64 or armhf" >&2; exit 1 ;;
esac

[ -f "$SRC" ] || { echo "no such file: $SRC" >&2; exit 1; }

TAG=$NAME
ASSET=$NAME-$ARCH.tcz

# Stage under the asset name so gh uploads it with that name.
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
cp "$SRC" "$STAGE/$ASSET"

if ! gh release view "$TAG" > /dev/null 2>&1
then
  gh release create "$TAG" --title "$NAME" --latest=false \
    --notes "$NAME for piCore. Install with .utils/tcz-get.sh $NAME, which picks $NAME-aarch64.tcz (64-bit) or $NAME-armhf.tcz (32-bit, ARMv6+) and checks it against .utils/packages.list."
fi

gh release upload "$TAG" "$STAGE/$ASSET" --clobber

SHA256=$(sha256sum "$STAGE/$ASSET" | cut -d ' ' -f 1)

echo
echo "Uploaded $ASSET to release $TAG. Line for .utils/packages.list:"
echo
printf '%-9s %-8s %-8s %s\n' "$NAME" "$VERSION" "$ARCH" "$SHA256"
