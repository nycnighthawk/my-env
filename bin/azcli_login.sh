#!/bin/bash
interactive_cli_login=0

_install_tools() {
    _has_kubectl="$(command -v kubectl)"
    _has_kubelogin="$(command -v kubelogin)"
    if [ -z "${_has_kubectl}" ] || [ -z "${_has_kubelogin}" ]
    then
        rm -f ${HOME}/bin/kubectl ${HOME}/bin/kubelogin && az aks install-cli --install-location ${HOME}/bin/kubectl --kubelogin-install-location ${HOME}/bin/kubelogin
    fi
}

_aks_auth() {
    if [ ! -z "${AKS}" ]
    then
        _remaining=${AKS}
        while [ ! -z "${_remaining}" ] && [ ! -z $1 ]
        do
            _var_name=$1
            shift 1
            _var_val=$(echo ${_remaining} | sed 's/\([^:]*\).*/\1/')
            eval "${_var_name}"='${_var_val}'
            _remaining=$(echo ${_remaining} | sed 's/[^:]*:*//')
        done
        az account set -n "${_az_account}"
        az aks get-credentials -g "${_aks_cluster_rg}" -n "${_aks_cluster_name}"
        if [ ! -z "${_aks_cluster_sp}" ] && [ ! -z "${_aks_cluster_sp_secret}" ]
        then
            kubelogin convert-kubeconfig -l spn --client-id ${_aks_cluster_sp} --client-secret ${_aks_cluster_sp_secret}
        else
            kubelogin convert-kubeconfig
        fi
        unset _az_account
        unset _aks_cluster_rg
        unset _aks_cluster_name
        unset _aks_cluster_sp
        unset _aks_cluster_sp_secret
    fi
}

if [ -z "${AZCLI_SP}" ]
then
    interactive_cli_login=1
fi
if [ -z "${AZCLI_SP_SECRET}" ]
then
    interactive_cli_login=1
fi
if [ -z "${AZCLI_SP_TENANT}" ]
then
    interactive_cli_login=1
fi
_install_tools

if [ ${interactive_cli_login} -eq 0 ]
then
    echo "non interactive login with SP"
    az login --service-principal -u "${AZCLI_SP}" -p "${AZCLI_SP_SECRET}" --tenant "${AZCLI_SP_TENANT}" > /dev/null
else
    echo "interactive login"
    az login --use-device-code > /dev/null
fi
_aks_auth _az_account _aks_cluster_rg _aks_cluster_name _aks_cluster_sp _aks_cluster_sp_secret
unset -f _install_tools
unset -f _aks_auth
