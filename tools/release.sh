#!/bin/sh
#
# release.sh <name> <version> <arch> <file.tcz>
#
# Run on a dev machine with the GitHub CLI (gh) authenticated.
# Uploads <file.tcz> to the release "<name>-<version>" as "<name>-<arch>.tcz"
# (creating the release if needed) and prints the line to add to
# .utils/packages.list. Commit that line to make the build installable.
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

TAG=$NAME-$VERSION
ASSET=$NAME-$ARCH.tcz

# Stage under the asset name so gh uploads it with that name.
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
cp "$SRC" "$STAGE/$ASSET"

if ! gh release view "$TAG" > /dev/null 2>&1
then
  gh release create "$TAG" --title "$NAME $VERSION" --notes "$NAME $VERSION for piCore (aarch64, armhf)"
fi

gh release upload "$TAG" "$STAGE/$ASSET" --clobber

SHA256=$(sha256sum "$STAGE/$ASSET" | cut -d ' ' -f 1)

echo
echo "Uploaded $ASSET to $TAG. Add this line to .utils/packages.list:"
echo
printf '%-9s %-8s %-8s %s\n' "$NAME" "$VERSION" "$ARCH" "$SHA256"
