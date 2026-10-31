#!/bin/sh
# Link the yabai and skhd configs into place and restart both. Dependencies: install.sh
set -eu
dir="$(cd "$(dirname "$0")" && pwd)"

link() {
  mkdir -p "$(dirname "$2")"
  if [ -e "$2" ] && [ ! -L "$2" ]; then
    mv "$2" "$2.bak.$(date +%Y%m%d%H%M%S)"
    echo "Backed up existing $2"
  fi
  ln -sfn "$1" "$2"
  echo "Linked $2 -> $1"
}

link "${dir}/skhdrc" ~/.config/skhd/skhdrc
link "${dir}/yabairc" ~/.config/yabai/yabairc

# Pick up the new config if the services are already installed.
if command -v skhd >/dev/null; then skhd --restart-service; fi
if command -v yabai >/dev/null; then yabai --restart-service; fi
