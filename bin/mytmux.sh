#!/bin/bash
SESS_NAME=$(date +%Y-%m-%d-%H-%M-%S)
NUM_OF_WIN=6

usage="$(basename ${0}) [-h] [-s NAME] [-n NUMBER_OF_WINDOWS]

where
     -h        show this help text
     -s        tmux session name, default to date time in the format of date +%Y-%m-%d-%H-%M-%S
     -n        number of initial windows for the tmux session
               default to 5
"
while getopts ':hs:n:' option;
do
  case "$option" in
    h) echo "$usage"
       exit
       ;;
    s) SESS_NAME=$OPTARG
       ;;
    n) NUM_OF_WIN=$OPTARG
       ;;
    :) printf "missing argument for -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
    \?) printf "illegal option: -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
  esac
done
tmux new-session -d -s ${SESS_NAME} -n 'shell' '/bin/bash' && \
last_window_id=0
NUM_OF_WIN=$(($NUM_OF_WIN - 1))
while [ $NUM_OF_WIN -gt 0 ]
do
  NUM_OF_WIN=$(($NUM_OF_WIN - 1))
  tmux new-window -n 'shell' -t "${SESS_NAME}" '/bin/bash' && \
  tmux split-window -h -t "${SESS_NAME}:${last_window_id}" '/bin/bash' && \
  last_window_id=$(($last_window_id + 1))
done
tmux split-window -h -t "${SESS_NAME}:${last_window_id}" '/bin/bash' && \
tmux split-window -t "${SESS_NAME}:${last_window_id}.1" '/bin/bash' && \
tmux resize-pane -R -t "${SESS_NAME}:${last_window_id}.0" 12 && \
exec tmux -2 attach-session -t ${SESS_NAME}\; select-window -t 0\; select-pane -t 0
