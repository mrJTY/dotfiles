#!/bin/sh
# Lint the repo: secrets, shell scripts, file formatting, config syntax, and the
# install.sh/sync.sh rule. Runs every check and exits non-zero if any failed.
#
#   bin/lint.sh          # check everything
#   bin/lint.sh --fix    # first auto-fix what can be (see fix_all), then check
#
# Needs gitleaks, shellcheck, editorconfig-checker and pre-commit: bin/install.sh
# nvim/tmux/python3 checks are skipped if those aren't installed.
set -u

fix=0
case "${1:-}" in
  "") ;;
  --fix) fix=1 ;;
  *) echo "usage: $0 [--fix]" >&2; exit 2 ;;
esac

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "${root}" || exit 1

failed=""

run() {
  name="$1"
  shift
  echo "==> ${name}"
  if "$@"; then
    echo "    ok"
  else
    echo "    FAILED"
    failed="${failed} ${name}"
  fi
}

need() {
  if ! command -v "$1" >/dev/null; then
    echo "    $1 not found — run bin/install.sh"
    return 1
  fi
}

# Top-level config directories: everything except archive/, bin/, and sh/.
config_dirs() {
  for d in */; do
    case "${d}" in
      archive/|bin/|sh/) ;;
      *) echo "${d%/}" ;;
    esac
  done
}

# Shell scripts outside archive/ (its cheatsheets aren't meant to pass lint), and not
# gitignored ones like .venv.
shell_scripts() {
  # shellcheck disable=SC2016 # $1 is for the inner sh
  git ls-files -co --exclude-standard -z | xargs -0 -n1 sh -c \
    'case "$1" in archive/*) ;; *.sh) [ -f "$1" ] && echo "./$1" ;; esac' _
}

# Tracked text files outside archive/.
text_files() {
  # shellcheck disable=SC2016 # $1 is for the inner sh
  git ls-files -z | xargs -0 -n1 sh -c \
    'case "$1" in archive/*) ;; *) [ -f "$1" ] && grep -qI . "$1" && echo "$1" ;; esac' _
}

# Fixes what can be fixed mechanically: CRLF -> LF and a missing final newline
# (editorconfig), a missing #! line on .sh files (assumes sh), a missing install.sh or
# sync.sh stub, the executable bit on those two, and shellcheck's own suggested patches and `read -p` -> `read -rp`. Anything left over shows up in the checks that follow.
fix_all() {
  echo "==> fix"
  cr="$(printf '\r')"
  text_files | while IFS= read -r f; do
    if grep -q "${cr}" "${f}"; then
      tr -d '\r' <"${f}" >"${f}.fix.$$" && cat "${f}.fix.$$" >"${f}" && rm -f "${f}.fix.$$"
      echo "    LF: ${f}"
    fi
    if [ -s "${f}" ] && [ -n "$(tail -c1 "${f}")" ]; then
      echo >>"${f}"
      echo "    final newline: ${f}"
    fi
  done
  # shellcheck disable=SC2046 # word-splitting the file list is intended
  for f in $(shell_scripts); do
    if [ -s "${f}" ] && [ "$(head -c2 "${f}")" != "#!" ]; then
      { echo "#!/bin/sh"; cat "${f}"; } >"${f}.fix.$$" && cat "${f}.fix.$$" >"${f}" && rm -f "${f}.fix.$$"
      echo "    added #!/bin/sh: ${f}"
    fi
  done
  for d in $(config_dirs); do
    for f in install.sh sync.sh; do
      if [ ! -e "${d}/${f}" ]; then
        printf '#!/bin/sh\n# TODO: %s for %s (nothing to do yet).\nset -eu\necho "%s: nothing to do"\n' \
          "${f%.sh}" "${d}" "${d}" >"${d}/${f}"
        echo "    created stub ${d}/${f}"
      fi
      if [ -f "${d}/${f}" ] && [ ! -x "${d}/${f}" ]; then
        chmod +x "${d}/${f}"
        echo "    chmod +x ${d}/${f}"
      fi
    done
  done
  # shellcheck disable=SC2046 # word-splitting the file list is intended
  for f in $(shell_scripts); do
    # SC2162: shellcheck reports it but offers no patch.
    if grep -q '^[[:space:]]*read -p' "${f}"; then
      sed 's/^\([[:space:]]*\)read -p/\1read -rp/' "${f}" >"${f}.fix.$$" && cat "${f}.fix.$$" >"${f}" && rm -f "${f}.fix.$$"
      echo "    read -r: ${f}"
    fi
  done
  if command -v shellcheck >/dev/null; then
    # shellcheck disable=SC2046 # word-splitting the file list is intended
    shellcheck -f diff $(shell_scripts) | git apply 2>/dev/null && echo "    applied shellcheck patches"
  fi
}

check_gitleaks_history() {
  need gitleaks && gitleaks git --no-banner --redact .
}

# Catches secrets in uncommitted and untracked files, which the history scan can't see.
check_gitleaks_worktree() {
  need gitleaks && gitleaks dir --no-banner --redact .
}

check_shellcheck() {
  need shellcheck || return 1
  # shellcheck disable=SC2046 # word-splitting the file list is intended
  shellcheck $(shell_scripts)
}

check_editorconfig() {
  need editorconfig-checker || return 1
  editorconfig-checker -exclude '^(archive|\.venv)/'
}

check_install_sync() {
  ok=0
  for d in $(config_dirs); do
    for f in install.sh sync.sh; do
      if [ ! -f "${d}/${f}" ]; then
        echo "    ${d}/${f} missing"
        ok=1
      elif [ ! -x "${d}/${f}" ]; then
        echo "    ${d}/${f} not executable"
        ok=1
      fi
    done
  done
  return "${ok}"
}

check_nvim() {
  if ! command -v nvim >/dev/null; then
    echo "    nvim not installed, skipping"
    return 0
  fi
  # loadfile compiles without running, so no plugins get installed.
  nvim --headless --clean \
    -c 'lua local ok, err = loadfile("nvim/init.lua"); if not ok then io.stderr:write(err .. "\n"); vim.cmd("cquit") end' \
    -c 'qa'
}

check_tmux() {
  if ! command -v tmux >/dev/null; then
    echo "    tmux not installed, skipping"
    return 0
  fi
  # Applied to a throwaway server (own socket) so unknown options are caught too —
  # `source-file -n` only checks syntax. Never touches a running tmux.
  tmux -L "check-$$" -f /dev/null start-server \; source-file tmux/.tmux.conf
  status=$?
  tmux -L "check-$$" kill-server 2>/dev/null
  return "${status}"
}

check_herdr_toml() {
  if ! command -v python3 >/dev/null; then
    echo "    python3 not installed, skipping"
    return 0
  fi
  python3 -c 'import sys, tomllib; tomllib.load(open(sys.argv[1], "rb"))' herdr/config.toml
}

check_precommit_config() {
  [ -x .venv/bin/pre-commit ] || { echo "    .venv/bin/pre-commit not found — run bin/install.sh"; return 1; }
  .venv/bin/pre-commit validate-config .pre-commit-config.yaml
}

[ "${fix}" = 1 ] && fix_all

run "gitleaks (history)" check_gitleaks_history
run "gitleaks (working tree)" check_gitleaks_worktree
run "shellcheck" check_shellcheck
run "editorconfig" check_editorconfig
run "install.sh + sync.sh in every config dir" check_install_sync
run "pre-commit config" check_precommit_config
run "nvim init.lua syntax" check_nvim
run "tmux.conf syntax" check_tmux
run "herdr config.toml syntax" check_herdr_toml

echo
if [ -n "${failed}" ]; then
  echo "Failed:${failed}"
  exit 1
fi
echo "All checks passed"
