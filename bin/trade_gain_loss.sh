#!/bin/bash

my_trades_venv=${HOME}/projects/trades-result/.venv
source ${my_trades_venv}/bin/activate
python -m my_trades.gain_loss "$@"
