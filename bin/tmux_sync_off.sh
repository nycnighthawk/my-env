#!/bin/bash
W=$(tmux list-windows | cut -d: -f1)
for i in ${W}
do
  $(tmux set-window-option -t :${i} synchronize-panes off)
done
