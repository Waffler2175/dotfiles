#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

for dir in */; do
  pkg="${dir%/}"

  if [[ -d "$pkg/.config/$pkg" ]]; then
    echo "Skipping '$pkg' — .config/$pkg already exists"
    continue
  fi

  echo "Restructuring '$pkg'..."

  if [[ -d "$pkg/.config" ]]; then
    # Collect items before creating target dir
    items=("$pkg/.config"/*)
    mkdir -p "$pkg/.config/$pkg"
    for item in "${items[@]}"; do
      cp -r "$item" "$pkg/.config/$pkg/"
      rm -rf "$item"
    done
  else
    items=("$pkg"/*)
    mkdir -p "$pkg/.config/$pkg"
    for item in "${items[@]}"; do
      mv "$item" "$pkg/.config/$pkg/"
    done
  fi
done

echo "Done!"
