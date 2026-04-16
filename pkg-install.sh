#!/usr/bin/env bash
# Install all apt packages that back the configs in this dotfiles repo.
#
# Design notes:
# - Each install is wrapped so a single failure (package not in repo, network
#   hiccup, held dep, etc.) does NOT stop the rest of the script — this is the
#   shell equivalent of a per-package try/except. We don't use `set -e`.
# - `apt-get install -y --no-install-recommends` is used to minimise bloat.
# - Packages with non-obvious apt names are declared explicitly in PACKAGES.
# - Tools that aren't in the default Debian/Ubuntu repos (mise, atuin, ghostty,
#   sesh, gh-dash, walker, starship, yazi, etc.) are listed under UNAVAILABLE
#   with a hint on how to install them. We do NOT silently curl-pipe installers
#   — that surprises users. The hint is printed at the end.
#
# Usage:
#   ./pkg-install.sh              # interactive-ish: prompts for sudo
#   ./pkg-install.sh --yes        # accept everything, no prompts
#   ./pkg-install.sh --dry-run    # show what would run, install nothing

set -u

DRY_RUN=0
APT_Y="-y"
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --yes|-y)  APT_Y="-y" ;;
    --help|-h)
      sed -n '2,20p' "$0"
      exit 0
      ;;
  esac
done

# Require apt. Bail with a clear message otherwise.
if ! command -v apt-get >/dev/null 2>&1; then
  echo "ERROR: apt-get not found. This script targets Debian/Ubuntu." >&2
  exit 1
fi

# ---- Package list ----------------------------------------------------------
# Each entry is "aptname  # comment". Keep alphabetical within a section.
PACKAGES=(
  # Shell & terminal basics
  "stow"
  "zsh"
  "tmux"
  "git"
  "curl"
  "wget"
  "ca-certificates"

  # Editor
  "neovim"

  # System utilities / CLI tools
  "btop"
  "fastfetch"
  "fontconfig"
  "lazygit"

  # Terminal emulators (legacy configs in .config/)
  "alacritty"
  "kitty"

  # Window manager / Wayland stack
  "hyprland"
  "hypridle"
  "hyprlock"
  "hyprpaper"
  "waybar"
  "mako-notifier"       # apt package for mako
  "swayosd"
  "xdg-desktop-portal-hyprland"

  # Input method (referenced by environment.d/fcitx.conf)
  "fcitx5"
  "fcitx5-config-qt"

  # GitHub CLI
  "gh"
)

# ---- Unavailable in default apt repos --------------------------------------
# name | install hint (printed at end)
UNAVAILABLE=(
  "mise|curl https://mise.run | sh"
  "atuin|curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh"
  "starship|curl -sS https://starship.rs/install.sh | sh"
  "sesh|go install github.com/joshmedeski/sesh/v2@latest   (needs Go)"
  "gh-dash|gh extension install dlvhdr/gh-dash"
  "yazi|cargo install --locked yazi-fm yazi-cli   (needs Rust)"
  "walker|see https://github.com/abenz1267/walker (prebuilt .deb or build from source)"
  "ghostty|see https://ghostty.org/docs/install/binary (no official .deb; build or grab release)"
  "omarchy|see https://github.com/basecamp/omarchy (Arch-only upstream; manual port needed on Debian/Ubuntu)"
)

# ---- Run one apt install with soft failure ---------------------------------
installed=()
failed=()
skipped=()

install_one() {
  local pkg="$1"

  if dpkg -s "$pkg" >/dev/null 2>&1; then
    echo "  [have] $pkg"
    installed+=("$pkg")
    return 0
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    echo "  [dry ] apt-get install $APT_Y --no-install-recommends $pkg"
    installed+=("$pkg")
    return 0
  fi

  # The "try/except" bit: capture output, don't exit on failure, classify result.
  local out
  if out=$(sudo apt-get install "$APT_Y" --no-install-recommends "$pkg" 2>&1); then
    echo "  [ ok ] $pkg"
    installed+=("$pkg")
  else
    # Common failure modes we want to distinguish:
    #   "Unable to locate package"   → not in repos (soft skip)
    #   "Has no installation candidate" → same
    #   anything else                → hard failure worth surfacing
    if grep -qE "Unable to locate package|has no installation candidate" <<<"$out"; then
      echo "  [miss] $pkg (not in configured apt sources)"
      skipped+=("$pkg")
    else
      echo "  [fail] $pkg"
      sed 's/^/         /' <<<"$out" >&2
      failed+=("$pkg")
    fi
  fi
}

# ---- Main ------------------------------------------------------------------
echo "Updating apt indexes..."
if [ "$DRY_RUN" -eq 0 ]; then
  sudo apt-get update || echo "WARN: apt-get update failed; continuing anyway."
fi

echo
echo "Installing ${#PACKAGES[@]} packages..."
for pkg in "${PACKAGES[@]}"; do
  install_one "$pkg"
done

# ---- Summary ---------------------------------------------------------------
echo
echo "================ summary ================"
echo "  installed/already-present: ${#installed[@]}"
echo "  not in apt sources:        ${#skipped[@]}"
[ "${#skipped[@]}" -gt 0 ] && printf '    %s\n' "${skipped[@]}"
echo "  failed:                    ${#failed[@]}"
[ "${#failed[@]}" -gt 0 ] && printf '    %s\n' "${failed[@]}"
echo "========================================="

if [ "${#UNAVAILABLE[@]}" -gt 0 ]; then
  echo
  echo "The following tools are NOT in Debian/Ubuntu apt repos. Install manually:"
  for entry in "${UNAVAILABLE[@]}"; do
    name="${entry%%|*}"
    hint="${entry#*|}"
    printf "  %-10s  %s\n" "$name" "$hint"
  done
fi

# Exit 0 if nothing hard-failed; non-zero otherwise.
[ "${#failed[@]}" -eq 0 ]
