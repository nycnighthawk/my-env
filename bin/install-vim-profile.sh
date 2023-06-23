#!/bin/bash

prog_name=$(basename $0)

show_usage() {
    help_message=`cat \
<<- EOF
Usage: [NO_SSL_VERIFY=1] ${prog_name} [-h]

This script setups the vim profile in user's home directory

EOF
`
    echo "${help_message}"
}

source_dir=$(dirname $(readlink -f ${BASH_SOURCE}))
vim_profile_dir="${source_dir}/../vim"
echo "source dir: ${source_dir}"

scaffold() {
    echo "scaffolding .vim directory..."
    mkdir -p ~/.vim/view
    mkdir -p ~/.config/nvim
}

init_env() {
    export NODE_TLS_REJECT_UNAUTHORIZED=0
    export NPM_CONFIG_STRICT_SSL=false
}

cleanup_env() {
    unset NODE_TLS_REJECT_UNAUTHORIZED
    unset NPM_CONFIG_STRICT_SSL
}

create_symlinks() {
    echo "creating symbolic links..."
    echo "vim proifle dir: ${vim_profile_dir}"
    local file_list=$(create_file_list ${vim_profile_dir})
    ln -s "${vim_profile_dir}" ~/.vim
    cd ~
    ln -s ~/.vim/vimrc ./.vimrc
    cd ~/.config/nvim
    nvim_init_vim=$(readlink -f ${vim_profile_dir}/init.vim)
    ln -s ${nvim_init_vim} ./
}

create_file_list() {
    local vim_profile_dir=$1
    local file_list=""
    for vim_file in ${vim_profile_dir}/myvim*.vim \
        ${vim_profile_dir}/vimrc \
        ${vim_profile_dir}/coc-settings.json
    do
        if [ -n "${file_list}" ]
        then
            file_list="${file_list} \"$(readlink -f ${vim_file})\""
        else
            file_list="\"$(readlink -f ${vim_file})\""
        fi
    done
    echo ${file_list}
}

update_vim() {
    echo "Install vim plugins..."
    vim -c :PlugInstall +qall
    echo "Updating Coc..."
    vim -c :CocUpdateSync +qall
}

check_requirements() {
    echo "checking requirements..."
    command -v curl || exit_with "curl must be installed!" 1
    command -v git || exit_with "git must be installed!" 1
}

exit_with() {
    echo "${1}"
    status=${2:-1}
    exit ${status}
}

install_vim_plug() {
    curl_opts="-fLo"
    if [ -n "${NO_SSL_VERIFY}" ]
    then
        git config --global --add http.sslverify false
        curl_opts="-kfLo"
    fi

    echo "installing vim plug..."
    curl ${curl_opts} ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    if [ -n "${NO_SSL_VERIFY}" ]
    then
        git config --global --unset-all http.sslverify
    fi
}

main_entry() {
    check_requirements
    init_env
    ln -s "${vim_profile_dir}" ~/.vim
    install_vim_plug
    # scaffold
    # create_symlinks ${source_dir} ${vim_profile_dir}
    update_vim
    cleanup_env
}

case $1 in
    -h|--h)
    show_usage
    exit 0
    ;;
esac
main_entry
