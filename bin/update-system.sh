#!/bin/bash

apt_get_options='-o "Acquire::https::Verify-Peer=false"'
apt_get_options=${apt_get_options}' -o "Acquire::https::Verify-Host=false"'
apt_get_options=${apt_get_options}' -o "APT::Get::AllowUnauthenticated=true"'
apt_get_options=${apt_get_options}' -o "Acquire::AllowInsecureRepositories=true"'
apt_get_options=${apt_get_options}' -o "Acquire::AllowDowngradeToInsecureRepositories=true"'
apt_get_options=${apt_get_options}' --allow-unauthenticated'

if [ -z ${APT_GET_INSECURE} ]
then
    apt_get_options=
fi

update_with_apt_get() {
    local apt_get_options=$1
    echo "apt_get_options: ${apt_get_options}"
    apt-get -y ${apt_get_options} update && \
    apt-get -y ${apt_get_options} upgrade && \
    apt-get -y ${apt_get_options} dist-upgrade && \
    apt-get -y autoremove
}

command -v apt &> /dev/null && \
if [ "$?" == "0" ]
then
    sudo bash -c "$(declare -f update_with_apt_get); update_with_apt_get ${apt_get_options}"
else
    command -v yum &> /dev/null && \
        sudo bash -c "yum -y update"
fi
