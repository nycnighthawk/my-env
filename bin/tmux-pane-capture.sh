#!/bin/bash

tsession=$(tmux list-session | grep \(attached\) | cut -f1 -d:)
twindow=$(tmux list-window | grep \(active\) | cut -f1 -d:)
tpane=$(tmux list-pane | grep \(active\) | cut -f1 -d:)
log_session_lock="${HOME}/.local/tmp/tmux-${tsession}-${twindow}-${tpane}"
if [ ! -f ${log_session_lock} ]
then
  log_file="${HOME}/log/tmux-w${twindow}-${tpane}-"$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w 6 | head -n1)
  cat > ${log_session_lock} <<- END
${log_file}
END
  tmux display "logging to ${log_file} started"
  #tmux pipe-pane -o "${HOME}/bin/stripescape.py >> ${log_file}"
  tmux pipe-pane -o "cat >> ${log_file}"
else
  log_file=$(cat ${log_session_lock})
  rm -f ${log_session_lock}
  tmux display "logging to ${log_file} stopped"
  #tmux pipe-pane -o "${HOME}/bin/stripescape.py >> ${log_file}"
  tmux pipe-pane -o "cat >> ${log_file}"
fi
