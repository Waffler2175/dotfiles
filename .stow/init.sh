#!/usr/bin/env bash
# init.sh -- Bootstrap dotfiles with GNU Stow
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

log()  { printf '\e[32m[dotfiles]\e[0m %s\n' "$*"; }
warn() { printf '\e[33m[dotfiles]\e[0m %s\n' "$*"; }
die()  { printf '\e[31m[dotfiles]\e[0m %s\n' "$*" >&2; exit 1; }

# --- Dirs that are NOT stow packages ------------------------------------------
SKIP=(
)

# --- Package dependencies ------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REQUIREMENTS="${SCRIPT_DIR}/requirements.txt"

# --- Detect package manager ----------------------------------------------------
PKG_MANAGER=""
PKG_QUERY=""
PKG_INSTALL=""

detect_pkg_manager() {
  if command -v pacman &>/dev/null; then
    PKG_MANAGER="pacman"
    PKG_QUERY="pacman -Q"
    PKG_INSTALL="sudo pacman -S --needed"
  elif command -v apt &>/dev/null; then
    PKG_MANAGER="apt"
    PKG_QUERY="dpkg -s"
    PKG_INSTALL="sudo apt install -y"
  elif command -v dnf &>/dev/null; then
    PKG_MANAGER="dnf"
    PKG_QUERY="rpm -q"
    PKG_INSTALL="sudo dnf install -y"
  elif command -v zypper &>/dev/null; then
    PKG_MANAGER="zypper"
    PKG_QUERY="rpm -q"
    PKG_INSTALL="sudo zypper install -y"
  elif command -v xbps-install &>/dev/null; then
    PKG_MANAGER="xbps"
    PKG_QUERY="xbps-query"
    PKG_INSTALL="sudo xbps-install -y"
  elif command -v emerge &>/dev/null; then
    PKG_MANAGER="emerge"
    PKG_QUERY="qlist -I"
    PKG_INSTALL="sudo emerge --ask n"
  else
    die "No supported package manager found (pacman, apt, dnf, zypper, xbps, emerge)"
  fi
  log "Detected package manager: $PKG_MANAGER"
}

# --- Helpers -------------------------------------------------------------------
is_skipped() {
  local pkg="$1"
  for skip in "${SKIP[@]}"; do
    [[ "$pkg" == "$skip" ]] && return 0
  done
  return 1
}

is_installed() {
  local pkg="$1"
  $PKG_QUERY "$pkg" &>/dev/null
}

check_packages() {
  log "Checking package dependencies..."

  [[ -f "$REQUIREMENTS" ]] || die "requirements.txt not found: $REQUIREMENTS"

  local missing=()
  while IFS= read -r pkg || [[ -n "$pkg" ]]; do
    [[ -z "$pkg" || "$pkg" == \#* ]] && continue
    is_installed "$pkg" || missing+=("$pkg")
  done < "$REQUIREMENTS"

  if [[ ${#missing[@]} -eq 0 ]]; then
    log "All packages are installed."
    return
  fi

  warn "${#missing[@]} missing package(s):"
  for pkg in "${missing[@]}"; do
    warn "  - $pkg"
  done

  if [[ "$PKG_MANAGER" != "pacman" ]]; then
    warn "Note: requirements.txt uses Arch package names -- some may differ on $PKG_MANAGER."
  fi

  read -rp "[dotfiles] Install missing packages now? [y/N] " yn
  case "$yn" in
    [yY]*)
      $PKG_INSTALL "${missing[@]}"
      ;;
    *)
      warn "Skipping installation -- some configs may not work correctly."
      ;;
  esac
}

stow_pkg() {
  local pkg="$1"

  # Dry-run to find conflicts before touching anything
  local sim_out
  sim_out=$(stow --simulate --target="$HOME" "$pkg" 2>&1 || true)

  # Stow conflict lines look like:
  #   * existing target is not owned by stow: .config/foo/bar
  #   * existing target is neither a link nor a directory: .config/foo/bar
  while IFS= read -r conflict_path; do
    [[ -z "$conflict_path" ]]      && continue
    [[ "$conflict_path" == *..* ]] && continue

    local full_path="${HOME}/${conflict_path}"

    # Only remove if it's a plain file or an empty directory -- never remove a
    # directory that already has content different from what we're symlinking
    if [[ -d "$full_path" ]] && [[ -n "$(ls -A "$full_path")" ]]; then
      warn "Skipping conflict (non-empty directory): ~/$conflict_path"
      continue
    fi

    warn "Removing conflict: ~/$conflict_path"
    rm -rf "$full_path"
  done < <(
    grep -oP '(?<=: )[^\s].*$' <<< "$sim_out" || true
  )

  if ! stow --restow --target="$HOME" "$pkg"; then
    die "Failed to stow $pkg"
  fi
}

# --- Pre-flight ----------------------------------------------------------------
command -v stow &>/dev/null || die "stow is required but not installed"
[[ -d "$DOTFILES_DIR" ]] || die "Dotfiles directory not found: $DOTFILES_DIR"
[[ -f "$REQUIREMENTS" ]] || die "requirements.txt not found: $REQUIREMENTS"

detect_pkg_manager
check_packages

cd "$DOTFILES_DIR" || die "Failed to cd into $DOTFILES_DIR"

# --- Stow all packages ---------------------------------------------------------
for pkg_dir in */; do
  pkg="${pkg_dir%/}"

  if is_skipped "$pkg"; then
    warn "Skipping $pkg"
    continue
  fi

  log "Stowing $pkg..."
  stow_pkg "$pkg"
done

log "Done!"
