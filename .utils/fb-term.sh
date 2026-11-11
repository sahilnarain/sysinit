#!/bin/ash

"$(dirname "$0")/tcz-get.sh" fbterm || exit 1

/usr/bin/fbterm --font-name="JetBrains Mono:style=SemiBold" --font-size=12 -- /bin/login
