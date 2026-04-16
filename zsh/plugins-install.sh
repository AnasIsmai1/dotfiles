#!/usr/bin/env bash
# Clone any missing oh-my-zsh custom plugins.
# Already-installed plugins are skipped (idempotent).
# A single failed clone does not abort the rest.

set -u

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
PLUGINS_DIR="$ZSH_CUSTOM/plugins"

# name|repo_url
PLUGINS=(
  "zsh-autosuggestions|https://github.com/zsh-users/zsh-autosuggestions"
  "zsh-syntax-highlighting|https://github.com/zsh-users/zsh-syntax-highlighting"
  "zsh-vi-mode|https://github.com/jeffreytse/zsh-vi-mode"
  "zsh-histdb|https://github.com/larkery/zsh-histdb"
  "you-should-use|https://github.com/MichaelAquilina/zsh-you-should-use"
  "auto-notify|https://github.com/MichaelAquilina/zsh-auto-notify"
)

ok=()
skipped=()
failed=()

for entry in "${PLUGINS[@]}"; do
  name="${entry%%|*}"
  url="${entry#*|}"
  target="$PLUGINS_DIR/$name"

  if [ -d "$target" ]; then
    echo "  [have] $name"
    skipped+=("$name")
    continue
  fi

  echo "  [ .. ] cloning $name"
  if git clone --depth=1 "$url" "$target" 2>/tmp/plugin-err.$$; then
    echo "  [ ok ] $name"
    ok+=("$name")
  else
    echo "  [fail] $name"
    sed 's/^/         /' /tmp/plugin-err.$$ >&2
    failed+=("$name")
  fi
  rm -f /tmp/plugin-err.$$
done

echo
echo "============== summary =============="
echo "  installed: ${#ok[@]}"
[ "${#ok[@]}" -gt 0 ] && printf '    %s\n' "${ok[@]}"
echo "  already present: ${#skipped[@]}"
echo "  failed: ${#failed[@]}"
[ "${#failed[@]}" -gt 0 ] && printf '    %s\n' "${failed[@]}"
echo "====================================="

echo
echo "Reload your shell to activate:  source ~/.zshrc"

[ "${#failed[@]}" -eq 0 ]
