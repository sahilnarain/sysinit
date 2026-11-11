#!/bin/ash

"$(dirname "$0")/tcz-get.sh" fbi || exit 1

echo "fbi loaded. Run '. ~/.ashrc' to enable show() in this shell."
