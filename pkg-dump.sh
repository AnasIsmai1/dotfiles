#!/usr/bin/env bash
# Snapshot every package manager on this machine into packages.lock.
#
# The point: MAC-MIGRATION.md and mac-install.sh contain hand-written package
# lists that go stale the moment you `npm i -g` something. Run this before a
# machine move (or on a schedule) and `git diff packages.lock` shows exactly
# what drifted.
#
# Managers with nothing installed still get a section header saying so — an
# empty section is information ("cargo: none"), a missing one is ambiguity.
#
# Usage:
#   ./pkg-dump.sh              # rewrite packages.lock
#   ./pkg-dump.sh --stdout     # print instead, change nothing
#   ./pkg-dump.sh --brewfile   # ALSO regenerate Brewfile (macOS only, see below)
#
# Why --brewfile is opt-in and macOS-only: `brew bundle dump` on Linux emits no
# casks, so running it here would silently delete the cask and font sections of
# the checked-in Brewfile.

set -u

OUT_MODE=file
DO_BREWFILE=0
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCK="$DOTFILES_DIR/packages.lock"

for arg in "$@"; do
  case "$arg" in
    --stdout)   OUT_MODE=stdout ;;
    --brewfile) DO_BREWFILE=1 ;;
    --help|-h)  sed -n '2,20p' "$0"; exit 0 ;;
    *) echo "unknown flag: $arg (try --help)" >&2; exit 2 ;;
  esac
done

have() { command -v "$1" >/dev/null 2>&1; }

# section <title> <command...> — runs the command, indents its output, and
# prints "(none)" when it produces nothing. Never fails the script.
section() {
  local title="$1"; shift
  echo "## $title"
  local out
  out="$("$@" 2>/dev/null)" || true
  if [ -z "${out//[[:space:]]/}" ]; then
    echo "(none)"
  else
    echo "$out"
  fi
  echo
}

skip_section() {
  printf '## %s\n(not installed)\n\n' "$1"
}

dump() {
  echo "# packages.lock — regenerate with ./pkg-dump.sh"
  echo "# host: $(uname -s) $(uname -m)"
  echo

  if have brew; then
    # --installed-on-request excludes packages pulled in purely as dependencies,
    # which is what you actually want to reinstall elsewhere.
    section "brew (leaves)" brew leaves --installed-on-request
    section "brew (casks)"  brew list --cask -1
  else
    skip_section "brew"
  fi

  if have apt-mark; then
    section "apt (manual)" apt-mark showmanual
  else
    skip_section "apt"
  fi

  # npm's default output is a tree with the lib path and box-drawing characters.
  # --parseable gives one absolute path per line; the first is the prefix itself.
  npm_globals() { npm ls -g --depth=0 --parseable | tail -n +2 | xargs -r -n1 basename; }
  # `uv tool list` interleaves "- <binary>" lines under each tool. Keep the tools.
  uv_tools() { uv tool list | grep -v '^-'; }

  if have npm;  then section "npm (global)"  npm_globals;             else skip_section "npm";  fi
  if have pnpm; then section "pnpm (global)" pnpm ls -g --depth=0;    else skip_section "pnpm"; fi
  if have bun;  then section "bun (global)"  bun pm ls -g;            else skip_section "bun";  fi
  if have pipx; then section "pipx"          pipx list --short;       else skip_section "pipx"; fi
  if have uv;   then section "uv (tools)"    uv_tools;                else skip_section "uv";   fi
  if have gem;  then section "gem"           gem list --no-versions;  else skip_section "gem";  fi

  # Go and Cargo have no "list what I installed" command, so read the bin dirs.
  if have go; then
    section "go (\$GOPATH/bin)" ls -1 "${GOPATH:-$HOME/go}/bin"
  else
    skip_section "go"
  fi
  if have cargo; then
    section "cargo" ls -1 "${CARGO_HOME:-$HOME/.cargo}/bin"
  else
    skip_section "cargo"
  fi

  # Node versions under nvm — nvm is a shell function, so read the dir.
  section "nvm (node versions)" ls -1 "$HOME/.nvm/versions/node"

  section "oh-my-zsh (custom plugins)" ls -1 "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
  section "tmux (tpm plugins)"         ls -1 "$HOME/.tmux/plugins"
}

if [ "$OUT_MODE" = stdout ]; then
  dump
else
  dump > "$LOCK"
  echo "wrote $LOCK"
  if ! git -C "$DOTFILES_DIR" ls-files --error-unmatch packages.lock >/dev/null 2>&1; then
    echo "new file — git add packages.lock"
  elif git -C "$DOTFILES_DIR" diff --quiet -- packages.lock 2>/dev/null; then
    echo "no changes since last dump"
  else
    git -C "$DOTFILES_DIR" --no-pager diff --stat -- packages.lock 2>/dev/null || true
    echo "review with: git -C $DOTFILES_DIR diff packages.lock"
  fi
fi

if [ "$DO_BREWFILE" -eq 1 ]; then
  if [ "$(uname -s)" != "Darwin" ]; then
    echo "refusing --brewfile on $(uname -s): brew bundle dump emits no casks here" >&2
    echo "and would delete the cask/font sections of the checked-in Brewfile." >&2
    exit 1
  fi
  if ! have brew; then
    echo "refusing --brewfile: brew not found" >&2
    exit 1
  fi
  brew bundle dump --file="$DOTFILES_DIR/Brewfile" --force --describe
  echo "rewrote $DOTFILES_DIR/Brewfile"
fi
