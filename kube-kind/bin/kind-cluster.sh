#!/bin/bash

prog_name=$(basename $0)
script_path=$(readlink -f $0)
script_dir=$(dirname "${script_path}")
script_dir="${script_dir}/.."

display-help() {
    cat \
<<- EOF
Usage: ${prog_name} [-h] [up|down] [default|calico]
Create or destroy Kind cluster

    -h          Display this help message

Action:

    up          Bring up the cluster, default
    down        Delete the cluster

Cluster type:
    default     Default kind cluster
    calico      Calico cluster
EOF
    exit 0
}

help_wanted=0
cluster_up=1
cluster_kind="default"

process_args() {
    if [ $# -eq 0 ]
    then
        help_wanted=1
    fi
    while [ $# -ne 0 ]
    do
        case $1 in
        
            -h|--help)
            help_wanted=1
            shift
            ;;
            up)
            if [ "x$2" = "x" ]
            then
                shift 1
            else
                cluster_kind=$2
                shift 2
            fi
            ;;
            down)
            cluster_up=0
            if [ "x$2" = "x" ]
            then
                shift 1
            else
                cluster_kind=$2
                shift 2
            fi
            ;;
            *)
            echo "invalid option: $1"
            display-help
            ;;
        esac
    done
}

process_args $@
if [ ${help_wanted} -eq 1 ]
then
    display-help
fi

case "${cluster_kind}" in
    default)
    cluster_config="default-cluster.yaml"
    ;;
    calico)
    cluster_config="calico-cluster.yaml"
    additional_manifest="calico-install.yaml"
    ;;
    *)
    echo "invalid cluster: ${cluster_kind}"
    display-help
    ;;
esac

image="kindest/node:v1.26.0"

create-cluster() {
    echo "creating cluster: $1"
    kind create cluster --image "${image}" --config "${script_dir}/config/${cluster_config}"
    for manifest in $(echo "${additional_manifest}")
    do
        kubectl apply -f "${script_dir}/config/${manifest}"
    done
}

delete-cluster() {
    echo "deleting cluster: $1"
    kind delete clusters -A
}

if [ ${cluster_up} -eq 1 ]
then
    cluster_action=create-cluster
else
    cluster_action=delete-cluster
fi

$cluster_action ${cluster_kind}
