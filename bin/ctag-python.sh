#!/bin/bash
ctags -aR --fields=+l --languages=python --python-kinds=-iv -f ./tags $(python -c "import os, sys; print(' '.join('{}'.format(d) for d in sys.path if os.path.isdir(d)))")
ctags -aR --fields=+l --languages=python --python-kinds=-iv -f ./tags .
