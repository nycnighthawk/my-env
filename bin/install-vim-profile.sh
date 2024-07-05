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
vim_profile_dir=$(readlink -f "${source_dir}/../vim")
myvim_settings_dir="my-vim-settings"
myls_config_dir="my-ls-config"
nvim_config_dir="${HOME}/.config/nvim"
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
    echo "vim profile dir: ${vim_profile_dir}"
    # local file_list=$(create_file_list ${vim_profile_dir})
    ln -s "${vim_profile_dir}/vimrc" ~/.vim/
    ln -s ~/.vim/vimrc ~/.vimrc
    ln -s "${vim_profile_dir}/init.lua" "${nvim_config_dir}/"
    ln -s "${vim_profile_dir}/${myvim_settings_dir}" ~/.vim/
    ln -s "${vim_profile_dir}/${myvim_settings_dir}" "${nvim_config_dir}/"
    ln -s "${vim_profile_dir}/coc-settings.json" ~/.vim/
    ln -s "${vim_profile_dir}/coc-settings.json" "${nvim_config_dir}/"
    ln -s "${myls_config_dir}/luarc.json" "${nvim_config_dir}/.luarc.json"
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
    vim -c "call MyvimInstallPlugins()"
    vim -c "call MyvimUpdatePlugins()"
    echo "Updating Coc..."
    vim -c "call MyvimUpdateCoc()"
    command -v nvim && echo "Updating nvim..." && nvim -c "Lazy update" -c "qa"
    command -v nvim && echo "Updating Treesitter parsers..." && nvim -c "TSUpdateSync vimdoc" -c "qa"
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
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim || exit_with "failed to install vim-plug" 1
    if [ -n "${NO_SSL_VERIFY}" ]
    then
        git config --global --unset-all http.sslverify
    fi
}

main_entry() {
    check_requirements
    init_env
    scaffold
    create_symlinks
    install_vim_plug
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
