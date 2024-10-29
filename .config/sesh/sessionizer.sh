#!/bin/bash
export PATH="$HOME/.cargo/bin:$PATH"
$HOME/go/bin/sesh connect $(
$HOME/go/bin/sesh list -tz --icons | fzf-tmux -p 55%,60% \
  --ansi --no-sort --border-label ' sesh ' --prompt '⚡  ' \
  --header '  ^a all ^t tmux ^g config ^x zoxide ^d tmux kill ^f find ^r rename ^p preview ' \
  --bind 'tab:down,btab:up' \
  --bind 'ctrl-a:change-prompt(⚡  )+reload($HOME/go/bin/sesh list --icons)' \
  --bind 'ctrl-t:change-prompt(🪟 )+reload($HOME/go/bin/sesh list -t --i)' \
  --bind 'ctrl-g:change-prompt(⚙️  )+reload($HOME/go/bin/sesh list -c --icons)' \
  --bind 'ctrl-x:change-prompt(📁  )+reload($HOME/go/bin/sesh list -z --i)' \
  --bind 'ctrl-f:change-prompt(🔎 )+reload(fdfind -H -d 2 -t d -E .Trash . ~)' \
  --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload($HOME/go/bin/sesh list --i)' \
  --bind 'ctrl-r:execute(current=$(tmux display-message -p {2..}); name=$(echo $current | fzf --print-query --prompt="New name (current: $current): ");    tmux rename-session -t {2..} $name )+reload($HOME/go/bin/sesh list --i)' \
  --bind 'ctrl-p:execute(~/.config/sesh/preview.sh)'
)
