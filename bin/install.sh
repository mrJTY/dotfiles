#!/bin/sh
# Install the tooling bin/lint.sh and bin/promote.sh need: gitleaks, shellcheck,
# editorconfig-checker, rsync, and pre-commit (in .venv, from system python3; enables the
# git hooks). Config dependencies live in each <dir>/install.sh.
#
#   bin/install.sh
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

# gitleaks and editorconfig-checker aren't packaged everywhere (apt/dnf), so outside
# Homebrew and pacman they come from `go install`.
#   go_install <name> <go package> <release page>
go_install() {
  if ! command -v go >/dev/null; then
    echo "Can't install $1: not in this package manager and go isn't installed." >&2
    echo "Install go, or get a release binary from $3" >&2
    exit 1
  fi
  go install "$2@latest"
  echo "Installed $1 to $(go env GOPATH)/bin — make sure that's on PATH"
}

case "$(uname -s)" in
  Darwin) install_pkgs gitleaks shellcheck editorconfig-checker rsync ;;
  Linux)
    if command -v pacman >/dev/null; then
      install_pkgs gitleaks shellcheck editorconfig-checker rsync
    else
      install_pkgs shellcheck rsync
      command -v gitleaks >/dev/null ||
        go_install gitleaks github.com/gitleaks/gitleaks/v8 \
          https://github.com/gitleaks/gitleaks/releases
      command -v editorconfig-checker >/dev/null ||
        go_install editorconfig-checker \
          github.com/editorconfig-checker/editorconfig-checker/v4/cmd/editorconfig-checker \
          https://github.com/editorconfig-checker/editorconfig-checker/releases
    fi ;;
  *) echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac

# pre-commit lives in a repo-local .venv built from the system python3 (no pyenv/pipx).
root="$(cd "$(dirname "$0")/.." && pwd)"
command -v python3 >/dev/null || install_pkgs python3
# Debian/Ubuntu split venv out of python3.
python3 -m venv "${root}/.venv" 2>/dev/null ||
  { command -v apt-get >/dev/null && install_pkgs python3-venv && python3 -m venv "${root}/.venv"; }
"${root}/.venv/bin/pip" install --quiet pre-commit

# Enable the git hooks from .pre-commit-config.yaml (commit: gitleaks/shellcheck/
# editorconfig; push: bin/lint.sh).
(cd "${root}" && .venv/bin/pre-commit install)
