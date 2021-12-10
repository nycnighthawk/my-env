#!/bin/bash
if [ "${CONDA_EXE}" = "" ]
then
    echo "cona is required for this script"
    exit 1
else
    python_version="3.7"
    if [ "${1}" != "" ]
    then
        python_version="${1}"
    fi
    conda_path=$(dirname ${CONDA_EXE})
    echo "setting up python ${python_version} virtual environment"
    conda create -k -y -p ./venv python=${python_version}
    source ${conda_path}/activate ./venv
    python -m pip install --upgrade pip wheel
    python -m pip install -r ~/.config/myscaffold/python/py3_requires/dev.txt
    cp -f ~/.config/myscaffold/python/gitignore .gitignore 1> /dev/null
fi
