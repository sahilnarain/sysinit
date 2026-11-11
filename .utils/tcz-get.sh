#!/bin/ash
#
# tcz-get.sh <name>
#
# Fetches the .tcz for <name> that matches this machine's architecture from
# this repo's GitHub releases, verifies it against the sha256 pinned in
# packages.list, and installs it with tce-load.
#
# Release layout: one release per app, tag "<name>", asset "<name>-<arch>.tcz".
# The version in packages.list is informational; the sha256 is what's enforced.
#
# Environment overrides:
#   TCZ_ARCH      force an arch (aarch64 | armhf)
#   TCZ_BASE_URL  base download URL (default: this repo's releases)
#   TCZ_MANIFEST  manifest path (default: packages.list next to this script)
#   TCZ_CACHE     cache directory (default: /tmp/tcz)

####################

TCZ_BASE_URL=${TCZ_BASE_URL:-https://github.com/sahilnarain/sysinit/releases/download}
TCZ_MANIFEST=${TCZ_MANIFEST:-$(dirname "$0")/packages.list}
TCZ_CACHE=${TCZ_CACHE:-/tmp/tcz}

####################

die() {
  echo "tcz-get: $*" >&2
  exit 1
}

detect_arch() {
  if [ -n "$TCZ_ARCH" ]
  then
    echo "$TCZ_ARCH"
    return
  fi

  case `uname -m` in
    aarch64)        echo aarch64 ;;
    armv6l|armv7l)  echo armhf ;;   # ARMv6-compatible builds, also run on ARMv7
    *)              return 1 ;;
  esac
}

# Prints "<version> <sha256>" for the given name and arch.
lookup() {
  while read -r m_name m_version m_arch m_sha256 rest
  do
    case "$m_name" in ''|\#*) continue ;; esac
    if [ "$m_name" = "$1" ] && [ "$m_arch" = "$2" ]
    then
      echo "$m_version $m_sha256"
      return 0
    fi
  done < "$TCZ_MANIFEST"
  return 1
}

# Succeeds only if file $1 exists and its sha256 is $2.
verify() {
  [ -f "$1" ] || return 1
  actual=`sha256sum "$1" | cut -d ' ' -f 1`
  [ "$actual" = "$2" ]
}

# Symlinks libraries from the Debian-style multiarch subdirectory of $1
# into $1 itself, without touching anything that already exists.
link_multiarch() {
  for triplet in aarch64-linux-gnu arm-linux-gnueabihf
  do
    [ -d "$1/$triplet" ] || continue
    ( cd "$1" && find "$triplet" -mindepth 1 ) | while read -r path
    do
      base=`basename "$path"`
      if [ ! -e "$1/$base" ] && [ ! -L "$1/$base" ]
      then
        sudo ln -s "$path" "$1/$base"
      fi
    done
  done
}

####################

NAME=$1
[ -n "$NAME" ] || die "usage: tcz-get.sh <name>"
[ -f "$TCZ_MANIFEST" ] || die "manifest not found: $TCZ_MANIFEST"

ARCH=`detect_arch` || die "unsupported architecture: $(uname -m)"

ENTRY=`lookup "$NAME" "$ARCH"` || die "no $ARCH build of $NAME in $TCZ_MANIFEST yet"
set -- $ENTRY
VERSION=$1
SHA256=$2

FILE=$NAME-$ARCH.tcz
DIR=$TCZ_CACHE/$ARCH
# Saved locally as <name>.tcz: tce-load names the extension after the file,
# so this keeps it "fbcat", not "fbcat-aarch64" (tce.installed markers, tcloop).
TCZ=$DIR/$NAME.tcz
URL=$TCZ_BASE_URL/$NAME/$FILE

mkdir -p "$DIR" || die "cannot create $DIR"

##########

if verify "$TCZ" "$SHA256"
then
  echo "Using cached $FILE"
else
  rm -f "$TCZ"
  echo "Downloading $NAME $VERSION ($ARCH) from $URL"
  wget -O "$TCZ" "$URL" || { rm -f "$TCZ"; die "download failed: $URL"; }

  if ! verify "$TCZ" "$SHA256"
  then
    rm -f "$TCZ"
    die "checksum mismatch for $FILE (expected $SHA256), refusing to install"
  fi
fi

##########

tce-load -i "$TCZ" || die "tce-load failed for $TCZ"

link_multiarch /usr/lib
link_multiarch /lib
