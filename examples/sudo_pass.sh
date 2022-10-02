#!/bin/bash

cur_dir=$(dirname $(readlink -f ${BASH_SOURCE}))
sudo_pass_supplier="supply_pass.sh"

cat > ${cur_dir}/${sudo_pass_supplier} <<- 'END'
#!/bin/bash

supply_pass() {
    echo "${SUDO_PASS}"
}
supply_pass
END

chmod +x ${cur_dir}/${sudo_pass_supplier}

read_password() {
    stty -echo
    printf "Password: "
    read SUDO_PASS
    stty echo
    printf "\n"
}

cleanup_env() {
    SUDO_PASS=
    rm -f ${cur_dir}/${sudo_pass_supplier}
}

export SUDO_PASS
read_password
export SUDO_ASKPASS=${cur_dir}/supply_pass.sh

sudo -A ls -l

cleanup_env
