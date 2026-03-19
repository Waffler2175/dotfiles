#!/usr/bin/env bash
# init.sh — Bootstrap dotfiles with GNU Stow

set -uo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

log()  { printf '\e[32m[dotfiles]\e[0m %s\n' "$*"; }
warn() { printf '\e[33m[dotfiles]\e[0m %s\n' "$*"; }
die()  { printf '\e[31m[dotfiles]\e[0m %s\n' "$*" >&2; exit 1; }

command -v stow &>/dev/null || die "stow is required but not installed"
[[ -d "$DOTFILES_DIR" ]] || die "Dotfiles directory not found: $DOTFILES_DIR"

cd "$DOTFILES_DIR"

for pkg_dir in */; do
  pkg="${pkg_dir%/}"
  log "Stowing $pkg..."

  # Find conflicts and remove them
  while IFS= read -r conflict; do
    warn "Removing conflict: ~/$conflict"
    rm -rf "$HOME/$conflict"
  done < <(stow --simulate --target="$HOME" "$pkg" 2>&1 \
    | grep -oP '(?<=over existing target ).*(?= since neither)' || true)

  # Stow and show any real errors
  if ! stow --restow --target="$HOME" "$pkg"; then
    die "Failed to stow $pkg"
  fi
done

log "Done!"
