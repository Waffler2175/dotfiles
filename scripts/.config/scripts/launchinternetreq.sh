#!/bin/sh


[ "$#" -eq 0 ] && exit 1

while :; do
    if ping -c 1 -W 2 1.1.1.1 >/dev/null 2>&1; then
        break
    fi
    sleep 1
done


for prog in "$@"; do
    sh -c "$prog" >/dev/null 2>&1 &
done

exit 0