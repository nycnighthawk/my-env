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
install_dir="projects"
my_env_dir="my-bash-env"
my_bash_env_git="https://github.com/nycnighthawk/${my_env_dir}.git"

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

curl_opt='-fsSL'
if [ -n "${IGNORE_CERT}" ]
then
    curl_opt='-kfsSL'
fi

install_redhat_main() {
    echo "configuring in redhat based distro..."
    if [ -n "${SUDO_ACCESS}" ]
    then
        command -v zsh >/dev/null 2>&1 || install_zsh_using_yum
    fi
    install_and_config_my_env
    cleanup_env
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


oh_my_bash_install_url="https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh"
oh_my_zsh_install_url="https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh"

install_and_config_my_env() {
    mkdir -p ~/${install_dir}
    cd ~/${install_dir}
    git_clone_my_env    
    echo "Installing ohmybash"
    bash -c "$(curl ${curl_opt} ${oh_my_bash_install_url})"
    update_bashrc
    echo "Installing ohmyzsh"
    command -v zsh && bash -c "$(curl ${curl_opt} ${oh_my_zsh_install_url})"
    update_zshrc
    [ ! -d ~/bin ] && mkdir ~/bin
    create_sym_links
}

install_macos_main() {
    echo "configuring in DarwinOS..."
    install_and_config_my_env
    cleanup_env
    exit 0
}

install_debian_main() {
    echo "configuring in debian based distro..."
    if [ -n "${IGNORE_CERT}" ] && [ -n "${SUDO_ACCESS}" ]
    then
        update_apt_config
    fi
    if [ -n "${SUDO_ACCESS}" ]
    then
        command -v zsh >/dev/null 2>&1 || install_zsh_using_apt
    fi
    install_and_config_my_env
    cleanup_env
}

create_sym_links() {
    if [ -d ~/.oh-my-bash/themes ] && [ ! -e ~/.oh-my-bash/themes/zork_fork ]
    then
        cd ~/.oh-my-bash/themes
        ln -s ~/${install_dir}/${my_env_dir}/oh-my-bash/themes/zork_fork ./
    fi
    if [ -d ~/.oh-my-zsh/themes ] && [ ! -e ~/.oh-my-zsh/themes/xiong-chiamiov-plus-fork.zsh-theme ]
    then
        cd ~/.oh-my-zsh/themes
        ln -s ~/${install_dir}/${my_env_dir}/oh-my-zsh/themes/xiong-chiamiov-plus-fork.zsh-theme ./
    fi
    cd ~/
    if [ ! -e ~/.my_bash ]
    then
        ln -s ~/${install_dir}/${my_env_dir}/my_bash ./.my_bash
    fi
    for file in ~/${install_dir}/${my_env_dir}/bin/*
    do
        if [ ! -f ~/bin/${file##*/} ]
        then
            ln -s ${file} ~/bin/
        fi
    done
    if [ ! -f ~/.tmux.conf ]
    then
        ln -s ~/${install_dir}/${my_env_dir}/tmux.conf ./.tmux.conf
    fi
}

install_zsh_using_apt() {
    if [ -n "${SUDO_ACCESS}" ]
    then
        sudo -A bash -c "apt-get -y update && apt-get -y install zsh"
    fi
}

install_zsh_using_yum() {
    if [ -n "${SUDO_ACCESS}" ]
    then
        sudo -A bash -c "yum -y install zsh"
    fi
}

update_bashrc() {
    if [ -f ~/.bashrc ]
    then
        echo "updating ~/.bashrc"
        cp ~/.bashrc ~/.bashrc\.$(date +%Y%m%d-%H%M%S)
        grep -qE '^OSH_THEME="zork_fork"' ~/.bashrc \
            || sed -e 's/^\(OSH_THEME=.*\)/# \1\nOSH_THEME="zork_fork"/' ~/.bashrc > ~/.bashrc.tmp
        mv ~/.bashrc.tmp ~/.bashrc
        sed -e '/^# My own customization/,$d' ~/.bashrc > ~/.bashrc.tmp
        mv ~/.bashrc.tmp ~/.bashrc
        cat >> ~/.bashrc <<- 'END'
# My own customization

if [ -d /opt/homebrew/bin ]
then
    export PATH=/opt/homebrew/bin:${PATH}
fi

## setup to use docker ucp if ucp-bundle directory is there
ucp_bundle=${HOME}/ucp-bundle
if [ -f ${ucp_bundle}/env.sh ]
then
    . ${ucp_bundle}/env.sh
    export DOCKER_CERT_PATH=${ucp_bundle}
fi
MY_BASH_PROMPT=no
[ -s ~/.my_bash ] && \. ~/.my_bash
command -v kubectl && source <(kubectl completion bash)
END
    fi
}

update_zshrc() {
    if [ -f ~/.zshrc ]
    then
        echo "updating .zshrc"
        cp ~/.zshrc ~/.zshrc\.$(date +%Y%m%d-%H%M%S)
        grep -qE '^ZSH_THEME="xiong-chiamiov-plus-fork"' ~/.zshrc \
            || sed -e 's/^\(ZSH_THEME=.*\)/# \1\nZSH_THEME="xiong-chiamiov-plus-fork"/' ~/.zshrc > ~/.zshrc.tmp
        mv ~/.zshrc.tmp ~/.zshrc
        sed -e '/^# My own customization/,$d' ~/.zshrc > ~/.zshrc.tmp
        mv ~/.zshrc.tmp ~/.zshrc
        cat >> ~/.zshrc <<- 'END'
# My own customization
if [ -d /opt/homebrew/bin ]
then
    export PATH=/opt/homebrew/bin:${PATH}
fi
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

## setup to use docker ucp if ucp-bundle directory is there
ucp_bundle=${HOME}/ucp-bundle
if [ -f ${ucp_bundle}/env.sh ]
then
    . ${ucp_bundle}/env.sh
    export DOCKER_CERT_PATH=${ucp_bundle}
fi

## setup to use nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

## enable autocomplete for kubectl
command -v kubectl && source <(kubectl completion zsh)
END
    fi
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

check_macos() {
    uname -a | grep -qi darwin
    local _status=$?
    return $_status
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
check_macos && install_macos_main