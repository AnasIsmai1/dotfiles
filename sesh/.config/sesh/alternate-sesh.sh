#!/bin/bash
export PATH="$HOME/.cargo/bin:$PATH"
$HOME/go/bin/sesh connect $(
  $HOME/go/bin/sesh list --icons | gum filter --limit 1 --no-sort --fuzzy --placeholder 'Pick a sesh' --height 50 --prompt='⚡ '
)
