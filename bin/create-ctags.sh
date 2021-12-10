#!/bin/bash
ctags -R --fields=+l --languages=python --python-kinds=-iv -f ./tags $(python -c "import os, sys; print(' '.join('{}'.format(d) for d in sys.path if os.path.isdir(d)))")
ctags -R --fields=+l --languages=python --python-kinds=-iv -a -f ./tags
