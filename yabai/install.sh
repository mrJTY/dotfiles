#!/bin/sh
# Install yabai and skhd. macOS only — on Linux this is a no-op.
set -eu

if [ "$(uname -s)" != "Darwin" ]; then
  echo "yabai/skhd are macOS only, skipping"
  exit 0
fi

brew install koekeishiya/formulae/yabai koekeishiya/formulae/skhd
