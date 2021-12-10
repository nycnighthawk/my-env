#!/bin/bash
source /opt/apps/venv/bin/activate
python /opt/apps/apps/run_automation.py "$@"
deactivate
