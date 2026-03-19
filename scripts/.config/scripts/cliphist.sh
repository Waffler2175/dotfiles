#!/usr/bin/env bash
launcher=$(cat $HOME/.config/ml4w/settings/launcher)
if [ "$launcher" == "walker" ]; then
    $HOME/.config/walker/launch.sh -m clipboard -N -H
else
    case $1 in
        d)
            cliphist list | rofi -dmenu  | cliphist delete
        ;;
        w)    
            cliphist wipe
        ;;
        *)
            cliphist list | rofi -dmenu  | cliphist decode | wl-copy
        ;;
    esac
fi