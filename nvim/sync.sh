#!/bin/sh
# Link the nvim config into place. Dependencies: install.sh
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

link "${dir}/init.lua" ~/.config/nvim/init.lua
