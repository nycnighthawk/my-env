#!/bin/sh

usage="$(basename ${0}) -h -v <PYTHON VERSION>

where
    -h      display this help text
    -v      PYTHON VERSION for the virtual environment, for example -v 3.8
"
current_dir=$(pwd)
python_version="3.7"
while getopts ':hv:' options
do
    case "${options}" in
        h)  echo "${usage}"
            exit
            ;;
        v)  python_version=${OPTARG}
            ;;
        :)  printf "missing argument for -%s\n" "${OPTARG}" >&2
            echo "${usage}"
            exit 1
            ;;
        \?) printf "illegal options: -%s\n" "${OPTARG}" >&2
            echo "${usage}"
            exit 1
            ;;
    esac
done

base_requirements=$(cat <<END
neovim
pylint
pynvim
jedi
flake8
black
python-jsonrpc-server
python-language-server
isort
msgpack
END
)

if [ "${CONDA_EXE}" = "" ]
then
    echo "cona is required for this script"
    exit 1
else
    conda_path=$(dirname ${CONDA_EXE})
    pushd ${current_dir}
    conda create -k -y -p ./venv python=${python_version}
    source ${conda_path}/activate ./venv
    if [ ! -f "requirements.txt" ]
    then
        echo "${base_requirements}" > requirements.txt
        pip install -r requirements.txt
    fi
    if [ -f "setup.py" ]
    then
        pip install -e .[testing,dev]
    fi
    popd
fi
