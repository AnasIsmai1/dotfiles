#!/bin/bash
export PATH="$HOME/.cargo/bin:$PATH"
$HOME/go/bin/sesh connect $(
  $HOME/go/bin/sesh list -tz --icons | fzf-tmux -p 75%,65% \
    --ansi --reverse --no-sort --border-label ' sesh ' --prompt='⚡  ' \
    --header '  ^a all ^t tmux ^g config ^x zoxide ^d tmux kill ^f find ^r rename ^p preview ' \
    --pointer=" " --marker=" " --color='pointer:#FF204E,marker:#FF204E' \
    --bind 'tab:down,btab:up' \
    --bind 'ctrl-a:change-prompt(⚡  )+reload($HOME/go/bin/sesh list --icons)' \
    --bind 'ctrl-t:change-prompt(🪟 )+reload($HOME/go/bin/sesh list -t --i)' \
    --bind 'ctrl-g:change-prompt(⚙️  )+reload($HOME/go/bin/sesh list -c --icons)' \
    --bind 'ctrl-x:change-prompt(📁  )+reload($HOME/go/bin/sesh list -z --i)' \
    --bind 'ctrl-f:change-prompt(🔎 )+reload(fdfind -H -d 2 -t d -E .Trash . ~)' \
    --bind 'ctrl-p:execute(~/.config/sesh/preview.sh)' \
    --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload($HOME/go/bin/sesh list --i)' \
    --bind 'ctrl-r:execute(current=$(tmux display-message -p {}); name=$( echo "Input your new Name" | fzf --header "Current Name: $current"  --ansi --reverse --print-query --prompt="New name: ");    tmux rename-session -t {2..} $name )+reload($HOME/go/bin/sesh list --i)'
)
