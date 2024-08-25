#!/bin/bash
# Example:
# SUDO_ACCESS=1 IGNORE_CERT=1 ./install-my-env.sh

# Environments
# SUDO_ACCESS
#     has sudo access
# IGNORE_CERT
#     ignore cert for the script


script_dir=$(dirname $(readlink -f ${0}))
sudo_pass_supplier="supply_pass.sh"
install_dir="projects"
my_env_dir="my-env"
my_bash_env_git="https://github.com/nycnighthawk/${my_env_dir}.git"

create_sudo_supplier_script() {
	cat > ${script_dir}/${sudo_pass_supplier} <<- 'END'
#!/bin/bash

supply_pass() {
    echo "${SUDO_PASS}"
}
supply_pass
END
	chmod +x ${script_dir}/${sudo_pass_supplier}
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
    rm -f ${script_dir}/${sudo_pass_supplier}
}

export SUDO_ASKPASS=${script_dir}/supply_pass.sh

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
    fi
    if [ ! -d ${my_env_dir} ]
    then
        git clone ${my_bash_env_git}
    else
        pushd ${my_env_dir}
        git pull
        popd
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
        if [ -f ~/bin/${file##*/} ]
        then
            rm -f ~/bin/${file##*/}
        fi
        ln -s ${file} ~/bin/
    done
    local _profile_files="my_bash tmux.conf my_alias my_zsh"
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
        cat > ~/.bashrc <<- 'END'
[ -s ~/.my_bash ] && \. ~/.my_bash
END
    fi
}

update_zshrc() {
    if [ -f ~/.zshrc ]
    then
        echo "backing up .zshrc"
        [ -f ~/.zshrc ] && cp ~/.zshrc ~/.zshrc\.$(date +%Y%m%d-%H%M%S)
        echo "updating .zshrc"
#        grep -qE '^ZSH_THEME="xiong-chiamiov-plus-fork"' ~/.zshrc \
#            || sed -e 's/^\(ZSH_THEME=.*\)/# \1\nZSH_THEME="xiong-chiamiov-plus-fork"/' ~/.zshrc > ~/.zshrc.tmp
#        mv ~/.zshrc.tmp ~/.zshrc
#        sed -e '/^# My own customization/,$d' ~/.zshrc > ~/.zshrc.tmp
#        mv ~/.zshrc.tmp ~/.zshrc
#        sed -e '/^plugins=(/d' ~/.zshrc > ~/.zshrc.tmp
#        mv ~/.zshrc.tmp ~/.zshrc
#        sed -e '/^source \$ZSH\/\oh-my-zsh\.sh$/d' ~/.zshrc > ~/.zshrc.tmp
#        mv ~/.zshrc.tmp ~/.zshrc
        cat > ~/.zshrc <<- 'END'
# My own customization
[ -f ~/.my_zsh ] && \. ~/.my_zsh
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
