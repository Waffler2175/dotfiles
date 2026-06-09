#!/bin/sh


# Check if an argument was passed
if [ -n "$*" ]; then
  QUERY="$*"
  
  # Use a case statement for instant pattern matching (faster than if/elif)
  case "$QUERY" in
    /*\?\?)
      # Clean the path and open in background
      CLEAN_PATH="${QUERY% \?\?}"
      xdg-open "$CLEAN_PATH" >/dev/null 2>&1 &
      exit 0
      ;;
    /*)
      # Absolute path selected, open in background
      xdg-open "$QUERY" >/dev/null 2>&1 &
      exit 0
      ;;
    \!\!*)
      # Print help menu
      echo "!!-- Type your search query to find files"
      echo "!!-- To search again type !<search_query>"
      echo "!!-- To search parent directories type ?<search_query>"
      echo "!!-- You can print this help by typing !!"
      ;;
    \?*)
      echo "!!-- Type another search query"
      SEARCH="${QUERY#\?}"
      # Stream fd results and append ?? to each line
      fd --type f --hidden --exclude '.*' --case-insensitive "$SEARCH" ~ | while read -r line; do
        echo "$line ??"
      done
      ;;
    *)
      echo "!!-- Type another search query"
      # Standard search (strips leading ! if present)
      SEARCH="${QUERY#!}"
      fd --type f --hidden --exclude '.*' --case-insensitive "$SEARCH" ~
      ;;
  esac
else
  # Default empty state
  echo "!!-- Type your search query to find files"
  echo "!!-- To search again type !<search_query>"
  echo "!!-- To search parent directories type ?<search_query>"
  echo "!!-- You can print this help by typing !!"
fi
