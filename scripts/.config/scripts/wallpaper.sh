#!/usr/bin/env bash
set -euo pipefail



WALLPAPER_DIR="$HOME/wallpaper"
CACHE_DIR="$HOME/.cache/blurred-wallpaper"
STATE_FILE="$CACHE_DIR/current-wallpaper"
HYPRPAPER_CONF="$HOME/.config/hypr/hyprpaper.conf"


BLUR="50x30"
RESIZE="75%"


command -v hyprpaper >/dev/null 2>&1 || exit 0
command -v magick    >/dev/null 2>&1 || exit 0
command -v matugen   >/dev/null 2>&1 || exit 0   

mkdir -p "$CACHE_DIR"


if [ $# -gt 0 ]; then
    if [[ "$1" = /* ]]; then
        WALLPAPER="$1"
    else
        WALLPAPER="$WALLPAPER_DIR/$1"
    fi

    if [ ! -f "$WALLPAPER" ]; then
        echo "Wallpaper not found: $WALLPAPER" >&2
        exit 1
    fi

    echo "$WALLPAPER" > "$STATE_FILE"

elif [ -f "$STATE_FILE" ]; then
    WALLPAPER="$(cat "$STATE_FILE")"

else
    WALLPAPER="$(find "$WALLPAPER_DIR" -type f \
        \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.webp' \) \
        | shuf -n 1)"
    echo "$WALLPAPER" > "$STATE_FILE"
fi

[ -f "$WALLPAPER" ] || exit 0


echo "Generating colors with matugen…"
matugen --source-color-index 0 image "$WALLPAPER"


HASH="$(sha256sum "$WALLPAPER" | awk '{print $1}')"
BLURRED="$CACHE_DIR/$HASH.png"



cat > "$HYPRPAPER_CONF" <<EOF
preload = $WALLPAPER
wallpaper {
    monitor =
    fit_mode = cover
    path = $WALLPAPER
}
splash=false
EOF


pkill hyprpaper || true
hyprpaper -c "$HYPRPAPER_CONF" & disown


if [ ! -f "$BLURRED" ]; then
    magick "$WALLPAPER" \
        -resize "$RESIZE" \
        -blur "$BLUR" \
        "$BLURRED"
fi


ln -sf "$BLURRED" "$CACHE_DIR/current.png"

~/.config/hypr/waybar-refresh.sh &
