#!/bin/bash
#
prog_name=$(basename $0)

show_usage() {
    help_message=`cat \
<<- EOF
Usage: [NO_SSL_VERIFY=1] ${prog_name} [-h]

This script update the vim plug and Coc

EOF
`
    echo "${help_message}"
}

current_git_ssl_setting=$(git config --global --get http.sslverify)

set_options() {
    if [ "${NO_SSL_VERIFY}" = "1" ]
    then
        export NODE_TLS_REJECT_UNAUTHORIZED=0
        export NPM_CONFIG_STRICT_SSL=false
        git config --global --replace http.sslverify false
    fi
}

restore_options() {
    unset NODE_TLS_REJECT_UNAUTHORIZED
    unset NPM_CONFIG_STRICT_SSL
    if [ -n "${current_git_ssl_setting}" ]
    then
        git config --global --replace http.sslverify ${current_git_ssl_setting}
    fi
}

main() {
    set_options
    vim +PlugUpdate +PlugUpgrade +qall
    vim +CocUpdateSync +qall
    restore_options
}

case $1 in
    -h|--h)
    show_usage
    exit 0
    ;;
esac
main
