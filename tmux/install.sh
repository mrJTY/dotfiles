#!/bin/sh
# Install tmux.
set -eu

install_pkgs() {
  case "$(uname -s)" in
    Darwin) brew install "$@" ;;
    Linux)
      if command -v pacman >/dev/null; then sudo pacman -S --needed --noconfirm "$@"
      elif command -v apt-get >/dev/null; then sudo apt-get install -y "$@"
      elif command -v dnf >/dev/null; then sudo dnf install -y "$@"
      else echo "No supported package manager (pacman, apt-get, dnf)" >&2; exit 1
      fi ;;
    *) echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
  esac
}

install_pkgs tmux
