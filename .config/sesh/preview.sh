#!/bin/bash
tmux list-panes -a -F '#S:#I.#P #{pane_current_command}' | \
fzf --prompt="⚡  " \
    --ansi \
    --header="S+up => Scroll-up, S-down => Scroll-down" \
    --preview='tmux capture-pane -p -t {1}' --bind shift-up:preview-up,shift-down:preview-down
