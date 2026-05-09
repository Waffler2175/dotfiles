#!/bin/sh
[ "$#" -eq 0 ] && exit 1

while :; do
    if ping -c 1 -W 2 1.1.1.1 >/dev/null 2>&1; then
        break
    fi
    sleep 1
done
sleep 2

for prog in "$@"; do
    hyprctl dispatch exec "$prog" >/dev/null 2>&1
done

exit 0
