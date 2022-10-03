#!/bin/bash
# Example:
# SUDO_ACCESS=1 IGNORE_CERT=1 ./install-my-env.sh

# Environments
# SUDO_ACCESS
#     has sudo access
# IGNORE_CERT
#     ignore cert for the script


cur_dir=$(dirname $(readlink -f ${BASH_SOURCE}))
sudo_pass_supplier="supply_pass.sh"
my_bash_env_git="https://github.com/nycnighthawk/my-bash-env.git"

create_sudo_supplier_script() {
	cat > ${cur_dir}/${sudo_pass_supplier} <<- 'END'
#!/bin/bash

supply_pass() {
    echo "${SUDO_PASS}"
}
supply_pass
END
	chmod +x ${cur_dir}/${sudo_pass_supplier}
}


read_password() {
    stty -echo
    printf "Password: "
    read SUDO_PASS
    stty echo
    printf "\n"
    export SUDO_PASS
}

cleanup_env() {
    unset SUDO_PASS
    git config --global --unset-all http.sslverify
    rm -f ${cur_dir}/${sudo_pass_supplier}
}

export SUDO_ASKPASS=${cur_dir}/supply_pass.sh

install_redhat_main() {
    echo "Not implemented!"
}

git_clone_my_env() {
    if [ -n "${IGNORE_CERT}" ]
    then
        git config --global --unset-all http.sslverify
        git config --global --add http.sslverify false
        git clone ${my_bash_env_git}
    else
        git clone ${my_bash_env_git}
    fi
}

curl_opt='-fsSL'
oh_my_bash_install_url="https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh"
oh_my_zsh_install_url="https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh"

install_debian_main() {
    if [ -n "${IGNORE_CERT}" ] && [ -n "${SUDO_ACCESS}" ]
    then
        update_apt_config
    fi
    if [ -n "${IGNORE_CERT}" ]
    then
        curl_opt='-kfsSL'
    fi
    mkdir -p ~/projects
    cd ~/projects
    git_clone_my_env    
    bash -c "$(curl ${curl_opt} ${oh_my_bash_install_url})"
    update_bashrc
    command -v zsh >/dev/null 2>&1 || install_zsh_using_apt
    command -v zsh && bash -c "$(curl ${curl_opt} ${oh_my_zsh_install_url})"
	[ -s ~/.zshrc ] && update_zshrc
}

create_sym_links() {
	if [ -d ~/.oh-my-bash ]
	then
		cd ~/.oh-my-bash/themes
		ln -s ~/projects/my-bash-env/oh-my-bash/themes/zork_fork ./
	fi
	if [ -d ~/.oh-my-zsh ]
	then
		cd ~/.oh-my-zsh/themes
		ln -s ~/projects/my-bash-env/oh-my-zsh/themes/xiong-chiamiov-plus-fork.zsh-theme ./
	fi
    cd ~/
    ln -s ~/projects/my-bash-env/my_bash ./.my_bash
    ln -s ~/projects/my-bash-env/bin ./
    ln -s ~/projects/my-bash-env/tmux.conf ./.tmux.conf
}

install_zsh_using_apt() {
    if [ -n "${SUDO_ACCESS}" ]
    then
        sudo -A bash -c "apt-get -y update && apt-get -y install zsh"
    fi
}

update_bashrc() {
	if ! [ -d ~/.oh-my-bash ]
	then
		return
	fi
    sed -i 's/^\(OSH_THEME=.*\)/# \1\nOSH_THEME="zork_fork"/' ~/.bashrc
    cat >> ~/.bashrc <<- 'END'
# My own customization
MY_BASH_PROMPT=no
[ -s ~/.my_bash ] && \. ~/.my_bash
END
}

update_zshrc() {
	if ! [ -d ~/.oh-my-zsh ]
	then
		return
	fi
	sed -i 's/^\(ZSH_THEME=.*\)/# \1\nZSH_THEME="xiong-chiamiov-plus-fork"/' ~/.zshrc
    cat >> ~/.zshrc <<- 'END'
# my own customization
my_bash_profile=~/.my_bash
_source_dir=$(dirname $(readlink -f ${my_bash_profile}))
if [ -f ${my_bash_profile} ]
then
    if [ -f ${_source_dir}/my_bash_func ]
        then
        \. ${_source_dir}/my_bash_func
        _my_bash_init
        _init_path
    fi
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
END
}

update_apt_config() {
    if [ -f /etc/apt/apt.conf.d/99-my-customization.conf ]
    then
        return
    fi
    cat <<- 'END' | sudo tee /etc/apt/apt.conf.d/99-my-customization.conf
Acquire::https::Verify-Peer "false";
Acquire::https::Verify-Host "false";
Acquire::https::Verify-Host "false";
Acquire::AllowInsecureRepositories "true";
Acquire::AllowDowngradeToInsecureRepositories "true";
END
}

exit_with() {
    echo "${1}"
    status=${2:-1}
    exit ${status}
}

create_sudo_supplier_script
if [ -n "${SUDO_ACCESS}" ]
then
    read_password
fi
command -v git >/dev/null 2>&1 || exit_with "git is required!"
command -v curl >/dev/null 2>&1 || exit_with "curl is required!"
command -v apt-get >/dev/null 2>&1 && install_debian_main
command -v rpm >/dev/null 2>&1 && install_redhat_main
cleanup_env
