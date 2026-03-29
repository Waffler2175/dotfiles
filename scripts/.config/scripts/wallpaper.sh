#!/usr/bin/env bash
set -euo pipefail

WALLPAPER_DIR="$HOME/wallpaper"
CACHE_DIR="$HOME/.cache/blurred-wallpaper"
CURRENT_LINK="$WALLPAPER_DIR/wallpaper.png"
HYPRPAPER_CONF="$HOME/.config/hypr/hyprpaper.conf"
BLUR="50x30"
RESIZE="75%"

command -v hyprpaper >/dev/null 2>&1 || exit 0
command -v magick    >/dev/null 2>&1 || exit 0
command -v matugen   >/dev/null 2>&1 || exit 0

mkdir -p "$CACHE_DIR"

if [ -L "$CURRENT_LINK" ]; then
    WALLPAPER="$(readlink -f "$CURRENT_LINK")"
else
    WALLPAPER="$(find "$WALLPAPER_DIR" -type f \
        \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.webp' \) \
        ! -name 'wallpaper.png' \
        | shuf -n 1)"
    ln -sf "$WALLPAPER" "$CURRENT_LINK"
fi

[ -f "$WALLPAPER" ] || exit 0

# Wait for Hyprland to report at least one monitor
MONITORS=""
for i in $(seq 1 10); do
    MONITORS=$(hyprctl monitors 2>/dev/null | awk '/Monitor/{print $2}')
    [ -n "$MONITORS" ] && break
    sleep 0.01
done
[ -z "$MONITORS" ] && exit 1

# Run matugen and blur in parallel while hyprpaper restarts
matugen --source-color-index 0 image "$WALLPAPER" &
MATUGEN_PID=$!

HASH="$(sha256sum "$WALLPAPER" | awk '{print $1}')"
BLURRED="$CACHE_DIR/$HASH.png"
if [ ! -f "$BLURRED" ]; then
    magick "$WALLPAPER" -resize "$RESIZE" -blur "$BLUR" "$BLURRED" &
fi

WALLPAPER_LINES=""
for MON in $MONITORS; do
    WALLPAPER_LINES+="wallpaper = $MON,$WALLPAPER"$'\n'
done

cat > "$HYPRPAPER_CONF" <<EOF
preload = $WALLPAPER
$WALLPAPER_LINES
splash = false
EOF

pkill hyprpaper || true
hyprpaper -c "$HYPRPAPER_CONF" & disown

# Wait for hyprpaper to finish loading the wallpaper
for i in $(seq 1 10); do
    hyprctl hyprpaper listloaded 2>/dev/null | grep -q "$WALLPAPER" && break
    sleep 0.01
done

for MON in $MONITORS; do
    hyprctl hyprpaper wallpaper "$MON,$WALLPAPER"
done

ln -sf "$BLURRED" "$CACHE_DIR/current.png"
wait $MATUGEN_PID
~/.config/hypr/waybar-refresh.sh &
exit 0
