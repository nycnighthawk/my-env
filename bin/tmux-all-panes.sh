#!/bin/bash
active_window_id=$(/usr/bin/tmux list-windows | grep '(active)' | cut -d: -f1)
active_pane_id=$(/usr/bin/tmux list-pane | grep '(active)' | cut -d: -f1)

for i in $(/usr/bin/tmux list-windows | cut -d: -f1)
do
  for ii in $(/usr/bin/tmux list-pane -t :${i} | cut -d: -f1)
  do
    if [ ${i} -eq ${active_window_id} ] && [ ${ii} -eq ${active_pane_id} ]
    then
      continue
    else
      tmux send-key -t :${i}.${ii} "$*" C-m
    fi
  done
done
