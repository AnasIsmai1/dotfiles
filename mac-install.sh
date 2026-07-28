#!/usr/bin/env bash
# Bootstrap a fresh Mac from this dotfiles repo.
#
# Design notes (same conventions as pkg-install.sh):
# - No `set -e`. Every step is wrapped so one failure doesn't abort the rest —
#   a half-installed machine you can inspect beats a script that died on step 3.
# - Idempotent: safe to re-run. Every step checks for "already done" first.
# - Nothing that needs a secret is automated. Those are printed at the end.
#
# Usage:
#   ./mac-install.sh              # do it
#   ./mac-install.sh --dry-run    # print every command, change nothing
#   ./mac-install.sh --skip-brew  # Homebrew already set up

set -u

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=0
SKIP_BREW=0

for arg in "$@"; do
  case "$arg" in
    --dry-run)    DRY_RUN=1 ;;
    --skip-brew)  SKIP_BREW=1 ;;
    --help|-h)    sed -n '2,14p' "$0"; exit 0 ;;
    *) echo "unknown flag: $arg (try --help)" >&2; exit 2 ;;
  esac
done

if [ "$(uname -s)" != "Darwin" ]; then
  echo "ERROR: this script targets macOS. On Debian/Ubuntu use ./pkg-install.sh." >&2
  exit 1
fi

ok=()
failed=()
skipped=()

# run <label> <command...>  — the try/except wrapper everything goes through.
run() {
  local label="$1"; shift
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "  [dry ] $label: $*"
    ok+=("$label")
    return 0
  fi
  local out
  if out=$("$@" 2>&1); then
    echo "  [ ok ] $label"
    ok+=("$label")
  else
    echo "  [fail] $label"
    sed 's/^/         /' <<<"$out" >&2
    failed+=("$label")
  fi
}

have() { command -v "$1" >/dev/null 2>&1; }

note_skip() { echo "  [have] $1"; skipped+=("$1"); }

# ---- 1. Xcode command line tools --------------------------------------------
echo "==> Xcode command line tools"
if xcode-select -p >/dev/null 2>&1; then
  note_skip "xcode-clt"
elif [ "$DRY_RUN" -eq 1 ]; then
  echo "  [dry ] xcode-select --install"
else
  # This opens a GUI dialog and returns immediately, so we poll rather than
  # trusting the exit code. Bounded: if the user dismisses the dialog the loop
  # would otherwise hang forever with no output.
  xcode-select --install >/dev/null 2>&1
  echo "  Accept the Xcode command line tools dialog. Waiting up to 30 min..."
  waited=0
  until xcode-select -p >/dev/null 2>&1 || [ "$waited" -ge 1800 ]; do
    sleep 10
    waited=$((waited + 10))
    [ $((waited % 120)) -eq 0 ] && echo "    still waiting (${waited}s)..."
  done
  if xcode-select -p >/dev/null 2>&1; then
    echo "  [ ok ] xcode-clt"; ok+=("xcode-clt")
  else
    echo "  [fail] xcode-clt — dialog not completed. Run 'xcode-select --install'" >&2
    echo "         by hand, then re-run this script." >&2
    failed+=("xcode-clt")
  fi
fi

# ---- 2. Homebrew -------------------------------------------------------------
echo
echo "==> Homebrew"
# Apple silicon installs to /opt/homebrew, Intel to /usr/local.
if [ -x /opt/homebrew/bin/brew ]; then
  BREW=/opt/homebrew/bin/brew
elif [ -x /usr/local/bin/brew ]; then
  BREW=/usr/local/bin/brew
else
  BREW=""
fi

if [ "$SKIP_BREW" -eq 1 ]; then
  note_skip "homebrew (--skip-brew)"
elif [ -n "$BREW" ]; then
  note_skip "homebrew"
elif [ "$DRY_RUN" -eq 1 ]; then
  echo "  [dry ] install homebrew via the official script"
  BREW=/opt/homebrew/bin/brew
else
  if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
    BREW=$([ -x /opt/homebrew/bin/brew ] && echo /opt/homebrew/bin/brew || echo /usr/local/bin/brew)
    echo "  [ ok ] homebrew"
    ok+=("homebrew")
  else
    echo "  [fail] homebrew — nothing after this will work" >&2
    failed+=("homebrew")
  fi
fi

if [ -n "$BREW" ] && [ "$DRY_RUN" -eq 0 ]; then
  eval "$("$BREW" shellenv)"
fi

# ---- 3. Brewfile -------------------------------------------------------------
echo
echo "==> Brewfile"
if [ -z "$BREW" ]; then
  echo "  [skip] no brew on PATH"
  skipped+=("brewfile")
else
  # brew bundle keeps going past individual failures and reports at the end,
  # which is exactly the behaviour we want here.
  run "brewfile" "$BREW" bundle --file="$DOTFILES_DIR/Brewfile"
fi

# ---- 4. Stow the configs, oh-my-zsh and its plugins --------------------------
# install.sh owns all three: it stows first, then installs oh-my-zsh (so the
# installer finds ~/.zshrc already symlinked and leaves it alone), then clones
# the custom plugins. Don't duplicate that sequence here.
echo
echo "==> Stow dotfiles + oh-my-zsh"
# ~/.ssh must be 700 before anything lands in it, and stow won't set that.
[ "$DRY_RUN" -eq 0 ] && { mkdir -p "$HOME/.ssh"; chmod 700 "$HOME/.ssh"; }
run "stow" "$DOTFILES_DIR/install.sh"

# .wezterm.lua sits at the repo root rather than in a stow package (the WSL
# wezsync helper reads it from there), so link it by hand. On macOS WezTerm
# reads ~/.wezterm.lua directly — no Windows-side copy needed.
if [ "$DRY_RUN" -eq 1 ]; then
  echo "  [dry ] ln -s $DOTFILES_DIR/.wezterm.lua ~/.wezterm.lua"
elif [ -L "$HOME/.wezterm.lua" ]; then
  note_skip "wezterm-config"
else
  [ -e "$HOME/.wezterm.lua" ] && mv "$HOME/.wezterm.lua" "$HOME/.wezterm.lua.bak"
  run "wezterm-config" ln -s "$DOTFILES_DIR/.wezterm.lua" "$HOME/.wezterm.lua"
fi

# Hand-written skills live once in ~/.agents/skills (the agents package) and are
# surfaced to Claude Code by symlink from ~/.claude/skills. Stow only restores
# the store, not those links, so recreate any that are missing.
if [ "$DRY_RUN" -eq 1 ]; then
  echo "  [dry ] link ~/.agents/skills/* into ~/.claude/skills/"
elif [ -d "$HOME/.agents/skills" ]; then
  mkdir -p "$HOME/.claude/skills"
  linked=0
  for s in "$HOME"/.agents/skills/*/; do
    n="$(basename "$s")"
    if [ ! -e "$HOME/.claude/skills/$n" ]; then
      ln -s "../../.agents/skills/$n" "$HOME/.claude/skills/$n" && linked=$((linked + 1))
    fi
  done
  echo "  [ ok ] agent-skill-links ($linked new)"
  ok+=("agent-skill-links")
fi

# ---- 5. Installers that aren't in any package manager ------------------------
echo
echo "==> curl installers"

curl_install() {
  local name="$1" probe="$2" url="$3" shell="${4:-bash}"
  if have "$probe" || [ -d "$HOME/.$name" ]; then
    note_skip "$name"
    return 0
  fi
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "  [dry ] curl -fsSL $url | $shell"
    ok+=("$name")
    return 0
  fi
  local out
  if out=$(curl -fsSL "$url" | "$shell" 2>&1); then
    echo "  [ ok ] $name"; ok+=("$name")
  else
    echo "  [fail] $name"; sed 's/^/         /' <<<"$out" >&2; failed+=("$name")
  fi
}

curl_install bun    bun     https://bun.com/install
curl_install claude claude  https://claude.ai/install.sh
# ~/.composio is provisioned by the Composio MCP integration inside Claude Code
# (`claude mcp add --transport http composio https://connect.composio.dev/mcp`),
# not by a standalone installer — nothing to run here.

# Supabase CLI has a real tap on macOS — no curl-piping needed.
if [ -n "$BREW" ] && ! have supabase; then
  run "supabase" "$BREW" install supabase/tap/supabase
else
  have supabase && note_skip "supabase"
fi

# ---- 6. Language-manager packages --------------------------------------------
echo
echo "==> npm / pipx / uv / nvm packages"

if have npm;  then run "npm-globals" npm install -g docx pnpm; else skipped+=("npm-globals"); fi
if have pipx; then run "pipx-graphifyy" pipx install graphifyy; else skipped+=("pipx-graphifyy"); fi
if have uv;   then run "uv-nano-pdf" uv tool install nano-pdf; else skipped+=("uv-nano-pdf"); fi

# nvm is a shell function, not a binary — source it before use.
NVM_SH="$(brew --prefix nvm 2>/dev/null)/nvm.sh"
if [ -s "$NVM_SH" ]; then
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "  [dry ] nvm install 24.14.0"
  else
    # shellcheck disable=SC1090
    if . "$NVM_SH" && nvm install 24.14.0 >/dev/null 2>&1; then
      echo "  [ ok ] nvm-node-24"; ok+=("nvm-node-24")
    else
      echo "  [fail] nvm-node-24"; failed+=("nvm-node-24")
    fi
  fi
else
  echo "  [skip] nvm (not installed)"; skipped+=("nvm-node-24")
fi

# ---- 7. Default shell --------------------------------------------------------
echo
echo "==> Default shell"
BREW_PREFIX="$(brew --prefix 2>/dev/null)"
BREW_ZSH="${BREW_PREFIX:-/nonexistent}/bin/zsh"
if [ -z "$BREW_PREFIX" ] || [ ! -x "$BREW_ZSH" ]; then
  echo "  [skip] brew zsh not installed; keeping the system zsh"
  skipped+=("chsh")
elif [ "$SHELL" = "$BREW_ZSH" ]; then
  note_skip "chsh"
elif [ "$DRY_RUN" -eq 1 ]; then
  echo "  [dry ] add $BREW_ZSH to /etc/shells and chsh"
else
  grep -qxF "$BREW_ZSH" /etc/shells 2>/dev/null || \
    echo "$BREW_ZSH" | sudo tee -a /etc/shells >/dev/null
  # NOT wrapped in run(): chsh prompts for the login password, and run()
  # swallows stdout/stderr into a variable, so the prompt would be invisible
  # and the script would look hung.
  echo "  chsh will ask for your login password:"
  if chsh -s "$BREW_ZSH"; then
    echo "  [ ok ] chsh"; ok+=("chsh")
  else
    echo "  [fail] chsh"; failed+=("chsh")
  fi
fi

# ---- Summary -----------------------------------------------------------------
echo
echo "================ summary ================"
echo "  done:      ${#ok[@]}"
echo "  already:   ${#skipped[@]}"
echo "  failed:    ${#failed[@]}"
[ "${#failed[@]}" -gt 0 ] && printf '    %s\n' "${failed[@]}"
echo "========================================="

cat <<'MANUAL'

Still to do by hand — these need secrets and cannot be scripted:

  1. SSH keys. Copy github_personal, github_work, id_ed25519 (and any .pem)
     into ~/.ssh out of band, then:
         chmod 700 ~/.ssh && chmod 600 ~/.ssh/github_* ~/.ssh/id_ed25519
     ~/.ssh/config is stowed from this repo and pulls in ~/.ssh/config.local
     for the private hosts — recreate that file, it is deliberately untracked.

  2. ~/.zsh_secrets (chmod 600). Sourced by .zshrc. Needs:
         export NGROK_AUTHTOKEN="..."
         export CLAUDE_CODE_OAUTH_TOKEN="..."

  3. gh auth login   — once per account (AnasIsmai1, AnasSledge).
     ~/.config/gh/hosts.yml is gitignored because it stores live OAuth tokens.

  4. Open tmux and press  prefix + I  to let tpm fetch the plugins.

  5. Open nvim once and let lazy.nvim restore from lazy-lock.json.

  6. macOS fixups in .zshrc / .wezterm.lua — see MAC-MIGRATION.md section 9.

MANUAL

[ "${#failed[@]}" -eq 0 ]
