#!/bin/ash

"$(dirname "$0")/tcz-get.sh" fbcat || exit 1

echo "fbcat loaded. Run '. ~/.ashrc' to enable grab() in this shell."
