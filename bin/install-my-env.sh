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
    mkdir -p ~/.local/completion/{bash,zsh}
    cd ~/${install_dir}
    git_clone_my_env    
    echo "Installing ohmybash"
    bash -c "$(curl ${curl_opt} ${oh_my_bash_install_url})"
    update_bashrc
    echo "Installing ohmyzsh"
    command -v zsh && bash -c "$(curl ${curl_opt} ${oh_my_zsh_install_url})"
    update_zshrc
    touch ~/.update
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
    for file in ~/${install_dir}/${my_env_dir}/bin/* ~/${install_dir}/${my_env_dir}/kube-kind/bin/*
    do
        if [ ! -f ~/bin/${file##*/} ]
        then
            ln -s ${file} ~/bin/
        fi
    done
    local _profile_files="my_bash tmux.conf my_alias"
    local _profile_file=
    for _profile_file in $(echo $_profile_files)
    do
        if [ ! -e ~/".${_profile_file}" ]
        then
            echo "creating symbolic link for: ${_profile_file}"
            ln -s ~/${install_dir}/${my_env_dir}/${_profile_file} "./.${_profile_file}"
        fi
    done
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

[ -f ~/.fzf.bash ] && \. ~/.fzf.bash
export FZF_COMPLETION_TRIGGER='~~'
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
        sed -e '/^plugins=(/d' ~/.zshrc > ~/.zshrc.tmp
        mv ~/.zshrc.tmp ~/.zshrc
        sed -e '/^source \$ZSH\/\oh-my-zsh\.sh$/d' ~/.zshrc > ~/.zshrc.tmp
        mv ~/.zshrc.tmp ~/.zshrc
        cat >> ~/.zshrc <<- 'END'
# My own customization
setopt HIST_NO_FUNCTIONS
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_DUPS

my_bash_profile=~/.my_bash
_source_dir=$(dirname $(readlink -f ${my_bash_profile}))
if [ -f ${my_bash_profile} ]
then
    if [ -f ${_source_dir}/my_bash_func ]
        then
        \. ${_source_dir}/my_bash_func
        _my_bash_init
    fi
fi

_my_process_plugin() {
    local my_plugin=$1
    shift
    local my_plugin_cmd=$@
    mkdir -p $ZSH/custom/plugins/${my_plugin}
    if [ -f ~/.update ]
    then
        echo "updating ${my_plugin} plugin"
        eval ${my_plugin_cmd}
    fi
}

# setup custom plugins
command -v podman > /dev/null && \
    _my_process_plugin podman "podman completion zsh -f $ZSH/custom/plugins/podman/_podman"
command -v poetry > /dev/null && \
    _my_process_plugin poetry "poetry completions zsh > $ZSH/custom/plugins/poetry/_poetry"

if [ -f ~/.update ]
then
    rm -f ~/.update
fi
# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

if [ -f $ZSH/custom/plugins/podman/_podman ]
then
    echo "has podman plugin"
    podman_plugin=podman
fi
if [ -f $ZSH/custom/plugins/poetry/_poetry ]
then echo "has poetry plugin"
    poetry_plugin=poetry
fi
plugins=(git $podman_plugin $poetry_plugin)

source $ZSH/oh-my-zsh.sh

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

## setup autocompletion
command -v kubectl >/dev/null && source <(kubectl completion zsh)

## setup fzf keybinding
[ -f ~/.fzf.zsh  ] && \. ~/.fzf.zsh
export FZF_COMPLETION_TRIGGER='~~'
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
