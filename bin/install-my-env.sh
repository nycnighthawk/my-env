#!/bin/bash

# environments
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
        git config --global --unset-all http.sslverify
    else
        git clone ${my_bash_env_git}
    fi
}

curl_opt='-fsSL'
oh_my_bash_install_url="https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh"

install_debian_main() {
    if [ -n "${IGNORE_CERT}" ] && [ -n "${SUDO_ACCESS}" ]
    then
        update_apt_config
        curl_opt='-kfsSL'
    fi
    mkdir -p ~/projects
    cd ~/projects
    git_clone_my_env    
    bash -c $(curl ${curl_opt} ${oh_my_bash_install_url})
    update_bashrc
    cd ~/
    ln -s ~/projects/my-bash-env/my_bash ./.my_bash
    cd ~/.oh-my-bash/themes
    ln -s ~/projects/my-bash-env/oh-my-bash/themes/zork_fork ./
    cd ~/
    ln -s ~/projects/my-bash-env/bin ./
}

update_bashrc() {
    sed -i 's/^\(OSH_THEME=.*\)/# \1\nOSH_THEME="zork_fork"/' ~/.bashrc
    cat >> ~/.bashrc <<- 'END'
# My own customization
MY_BASH_PROMPT=no
[ -f ~/.my_bash ] && \. ~/.my_bash
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
