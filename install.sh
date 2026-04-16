#!/usr/bin/env bash
# Stow each dotfiles package into $HOME.
# - Each package is a top-level dir containing files laid out relative to $HOME
#   (e.g. hypr/.config/hypr/hyprland.conf → ~/.config/hypr/hyprland.conf).
# - If a package fails (conflict, missing dir, etc.) we log and continue, so one
#   bad package doesn't stop the whole install.
# - Live dirs that would conflict are backed up to <path>.bak.<timestamp>.

set -u
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TS="$(date +%Y%m%d-%H%M%S)"

# ---- Packages to stow (in order) ----
# Shell & terminal
PACKAGES=(
  zsh
  tmux
  git
  # Desktop (Hyprland stack)
  hypr
  waybar
  waybar-v2
  walker
  swayosd
  mako
  # Editors & dev tools
  nvim
  lazygit
  mise
  atuin
  gh
  gh-dash
  # System
  fontconfig
  environment.d
  btop
)

# ---- stow install ----
install_stow() {
  echo "Stow not found — installing via apt..."
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update && sudo apt-get install -y stow
  else
    echo "ERROR: apt-get not found. Install GNU Stow manually." >&2
    exit 1
  fi
}

if ! command -v stow >/dev/null 2>&1; then
  install_stow
fi

# ---- Backup live conflicts ----
# stow refuses when a real (non-symlink) file/dir exists at the target path.
# We proactively move those aside so stow can create its symlinks.
backup_conflicts() {
  local pkg="$1"
  # Enumerate every file the package wants to install, expressed as a path under $HOME.
  while IFS= read -r -d '' src; do
    local rel="${src#"$DOTFILES_DIR/$pkg/"}"
    local target="$HOME/$rel"
    # We only care about real (non-symlink) files/dirs at the target.
    if [ -e "$target" ] && [ ! -L "$target" ]; then
      local bak="$target.bak.$TS"
      echo "    backing up $target → $bak"
      mv "$target" "$bak"
    fi
  done < <(find "$DOTFILES_DIR/$pkg" -mindepth 1 -type f -print0 2>/dev/null)
}

# ---- Stow one package ----
stow_pkg() {
  local pkg="$1"
  if [ ! -d "$DOTFILES_DIR/$pkg" ]; then
    echo "  [skip] $pkg (dir not found)"
    return 1
  fi
  backup_conflicts "$pkg"
  if stow --restow --target="$HOME" --dir="$DOTFILES_DIR" "$pkg" 2>/tmp/stow-err.$$; then
    echo "  [ ok ] $pkg"
    rm -f /tmp/stow-err.$$
    return 0
  else
    echo "  [fail] $pkg"
    sed 's/^/         /' /tmp/stow-err.$$ >&2
    rm -f /tmp/stow-err.$$
    return 1
  fi
}

# ---- Main loop ----
ok=()
failed=()
skipped=()

echo "Stowing ${#PACKAGES[@]} packages from $DOTFILES_DIR"
echo
for pkg in "${PACKAGES[@]}"; do
  echo ">> $pkg"
  if [ ! -d "$DOTFILES_DIR/$pkg" ]; then
    skipped+=("$pkg")
    echo "  [skip] $pkg (dir not found)"
    continue
  fi
  if stow_pkg "$pkg"; then
    ok+=("$pkg")
  else
    failed+=("$pkg")
  fi
done

# ---- Summary ----
echo
echo "================ summary ================"
echo "  installed: ${#ok[@]}"
[ "${#ok[@]}" -gt 0 ] && printf '    %s\n' "${ok[@]}"
echo "  failed:    ${#failed[@]}"
[ "${#failed[@]}" -gt 0 ] && printf '    %s\n' "${failed[@]}"
echo "  skipped:   ${#skipped[@]}"
[ "${#skipped[@]}" -gt 0 ] && printf '    %s\n' "${skipped[@]}"
echo "========================================="

# Exit non-zero if anything failed so CI / chained scripts can detect it.
[ "${#failed[@]}" -eq 0 ]
