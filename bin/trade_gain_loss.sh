#!/bin/bash

my_trades_venv=${HOME}/projects/my_trades/.venv
source ${my_trades_venv}/bin/activate
python -m my_trades.gain_loss "$@"
