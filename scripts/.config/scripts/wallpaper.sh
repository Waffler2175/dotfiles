#!/usr/bin/env bash
set -euo pipefail

# Directories
WALLPAPER_DIR="$HOME/wallpaper"
CACHE_DIR="$HOME/.cache/blurred-wallpaper"
CURRENT_LINK="$WALLPAPER_DIR/wallpaper.png"
MATUGEN_JSON="$HOME/.config/matugen/colors.json"
ROFI_RASI_DIR="$HOME/.cache/ml4w/hyprland-dotfiles"   # ADD
BLUR="50x30"
RESIZE="75%"

# ── Dependency Check ──────────────────────────────────────────────────────────
for cmd in awww magick matugen pywalfox; do
    command -v "$cmd" >/dev/null 2>&1 || { echo "$cmd not found"; exit 1; }
done

mkdir -p "$CACHE_DIR"
mkdir -p "$ROFI_RASI_DIR"   # ADD

# ── Daemon ────────────────────────────────────────────────────────────────────
if ! pgrep -x "awww-daemon" > /dev/null; then
    swww-daemon &
    sleep 1
fi

# ── Wallpaper Selection ───────────────────────────────────────────────────────
if [ -L "$CURRENT_LINK" ] && [ -e "$CURRENT_LINK" ]; then
    WALLPAPER="$(readlink -f "$CURRENT_LINK")"
else
    WALLPAPER="$(find "$WALLPAPER_DIR" -type f \
        \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.webp' \) \
        ! -name 'wallpaper.png' | shuf -n 1)"
    ln -sf "$WALLPAPER" "$CURRENT_LINK"
fi

# ── Rofi Wallpaper RASI ───────────────────────────────────────────────────────
# ADD: write current wallpaper path into a rasi variable for rofi themes
cat > "$ROFI_RASI_DIR/current_wallpaper.rasi" <<EOF
* {
    current-image: url("$WALLPAPER", width);
}
EOF

# ── Matugen ───────────────────────────────────────────────────────────────────
matugen image "$WALLPAPER" --source-color-index 0

# ── GTK3 Reload ───────────────────────────────────────────────────────────────
_gtk3_reload() {
    local current
    current=$(gsettings get org.gnome.desktop.interface gtk-theme | tr -d "'")
    gsettings set org.gnome.desktop.interface gtk-theme "default"
    sleep 0.05
    gsettings set org.gnome.desktop.interface gtk-theme "$current"
}
_gtk3_reload &

# ── GTK4 / libadwaita Reload ──────────────────────────────────────────────────
_gtk4_reload() {
    local current
    current=$(gsettings get org.gnome.desktop.interface color-scheme | tr -d "'")
    local opposite
    [[ "$current" == "prefer-dark" ]] && opposite="prefer-light" || opposite="prefer-dark"
    gsettings set org.gnome.desktop.interface color-scheme "$opposite"
    sleep 0.05
    gsettings set org.gnome.desktop.interface color-scheme "$current"
}
_gtk4_reload &

# ── Firefox (pywalfox) ────────────────────────────────────────────────────────
if command -v pywalfox >/dev/null 2>&1; then
    pywalfox update
fi

# ── Neovim ────────────────────────────────────────────────────────────────────
if [ -f "$MATUGEN_JSON" ]; then
    touch "$MATUGEN_JSON"
fi

# ── Blurred Wallpaper (background) ───────────────────────────────────────────
HASH="$(sha256sum "$WALLPAPER" | awk '{print $1}')"
BLURRED="$CACHE_DIR/$HASH.png"

ln -sf "$WALLPAPER" "$CACHE_DIR/currentnb"

if [ ! -f "$BLURRED" ]; then
    (
        magick "$WALLPAPER" -resize "$RESIZE" -blur "$BLUR" "$BLURRED"
        ln -sf "$BLURRED" "$CACHE_DIR/current.png"
    ) &
else
    ln -sf "$BLURRED" "$CACHE_DIR/current.png"
fi

# ── Apply Wallpaper ───────────────────────────────────────────────────────────
awww img "$WALLPAPER" --transition-type simple --transition-step 50

# ── Reload UI ─────────────────────────────────────────────────────────────────
~/.config/hypr/waybar-refresh.sh &
