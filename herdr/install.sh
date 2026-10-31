#!/bin/sh
# Install herdr with its official installer (macOS and Linux).
set -eu

if command -v herdr >/dev/null; then
  echo "herdr already installed"
  exit 0
fi

curl -fsSL https://herdr.dev/install.sh | sh
