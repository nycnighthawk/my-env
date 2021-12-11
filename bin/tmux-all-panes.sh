#!/bin/bash
active_window_id=$(tmux list-windows | grep '(active)' | cut -d: -f1)
active_pane_id=$(tmux list-pane | grep '(active)' | cut -d: -f1)

for i in $(tmux list-windows | cut -d: -f1)
do
  for ii in $(tmux list-pane -t :${i} | cut -d: -f1)
  do
    if [ ${i} -eq ${active_window_id} ] && [ ${ii} -eq ${active_pane_id} ]
    then
      continue
    else
      tmux send-key -t :${i}.${ii} "$*" C-m
    fi
  done
done
