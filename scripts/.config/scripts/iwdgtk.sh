#!/usr/bin/env bash
#                              __    __
#   ___  __ _  ___ ____  ___  / /__ / /_
#  / _ \/  ' \/ _ `/ _ \/ _ \/ / -_) __/
# /_//_/_/_/_/\_,_/ .__/ .__/_/\__/\__/
#                /_/  /_/
#
if [[ "$1" == "stop" ]]; then
    killall iwgtk
elif [[ "$1" == "toggle" ]]; then
    if pgrep -x "iwgtk" >/dev/null; then
        echo "Running"
        killall iwgtk
    else
        echo "Stopped"
        iwgtk
    fi
else
    iwgtk
fi