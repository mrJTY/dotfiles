#!/bin/sh
# Install nvim and what init.lua needs: ripgrep for Telescope live_grep, make and a C
# compiler for telescope-fzf-native and treesitter parsers. Plugins themselves are
# installed by lazy.nvim on first launch.
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

case "$(uname -s)" in
  Darwin) install_pkgs neovim ripgrep ;;  # make/clang come with Xcode CLT
  *) install_pkgs neovim ripgrep git make gcc ;;
esac
