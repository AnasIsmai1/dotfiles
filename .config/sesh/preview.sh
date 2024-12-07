#!/bin/bash
tmux list-panes -a -F '#S:#I.#P #{pane_current_command}' |
  fzf --prompt="⚡  " \
    --ansi --reverse --no-sort --cycle --tiebreak=index \
    --pointer=" " --marker=" " --color='pointer:#FF204E,marker:#FF204E' \
    --header="S+up => Scroll-up, S-down => Scroll-down, Ctrl-\ => Toggle-hidden" \
    --preview='tmux capture-pane -p -t {1}' \
    --preview-window='bottom:60%' \
    --bind shift-up:preview-up,shift-down:preview-down \
    --bind 'ctrl-\:change-preview-window(hidden|)'
