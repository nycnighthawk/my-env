#!/bin/bash

prog_name=$(basename $0)
my_exec_dir=$(dirname $(readlink -f $0))
env_home_dir=$(dirname ${my_exec_dir})
echo ${prog_name}
echo ${my_exec_dir}
echo ${env_home_dir}

# check if it's the same link
home_bin=$(readlink -e "${HOME}/bin")
if [ "${home_bin}" == "${my_exec_dir}" ]
then
    echo "${HOME}/bin has already been setup"
elif [ ! -e "${HOME}/bin" ]
then
    echo "create link for bin directory"
    ln -s ${my_exec_dir} ${HOME}/bin
else
    if [ ! -L "${HOME}/bin" ] && [ -d "${HOME}/bin" ]
    then
        echo "update links"
        for file in ${my_exec_dir}/*
        do
            file=$(readlink -f ${file})
            file_name=$(basename ${file})
            if [ ! -L ${HOME}/bin/${file_name} ]
            then
                echo "create link for ${file_name}"
                rm -f ${HOME}/bin/${file_name}
                ln -s ${file} ${HOME}/bin/
            elif [ ! "$(readlink -e ${HOME}/bin/${file_name})" == "$(readlink -e ${file})" ]
            then
                echo "fixing invalid link ${file_name}"
                rm -f ${HOME}/bin/${file_name}
                ln -s ${file} ${HOME}/bin/
            fi
        done
    else
        rm -fr ${HOME}/bin
        ln -s ${my_exec_dir} ${HOME}/bin
    fi
fi

# create link for .vim

# create .bashrc file

