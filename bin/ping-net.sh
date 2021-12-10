#!/bin/bash

usage="Usage: $(basename ${0}) ip_prefx

    ip_prefix              ip in prefix format, the prefix must be greater than
                           24, for example, 10.1.2.0/24

"

if [ $# -ne 1 ]
then
    echo "${usage}"
    exit
fi


extract_net_prefix()
{
    ip_net=${1}
    shift
    net_prefix="${1}"
    if [ "${net_prefix}" == "" ]
    then
        net_prefix="32"
    elif [ ${net_prefix} -lt 24 ]
    then
        echo "prefix must be greater than or equal to 24"
        exit
    fi
}

map_prefix_to_count()
{
    case ${net_prefix} in
    32*)
        host_count=1
        ;;
    31*)
        host_count=2
        ;;
    30*)
        host_count=4
        ;;
    29*)
        host_count=8
        ;;
    28*)
        host_count=16
        ;;
    27*)
        host_count=32
        ;;
    26*)
        host_count=64
        ;;
    25*)
        host_count=128
        ;;
    24*)
        host_count=256
        ;;
    esac
}

fix_ip_net() {
    case ${host_count} in
    256*)
        last_octate=0
        ;;
    128*)
        last_octate=$(( last_octate / 128 * 128))
        ;;
    64*)
        last_octate=$(( last_octate / 64 * 64))
        ;;
    32*)
        last_octate=$(( last_octate / 32 * 32))
        ;;
    16*)
        last_octate=$(( last_octate / 16 * 16))
        ;;
    esac
}

ping_count=3
wait_time=0.2
my_ping() {
    for i in "$@"
    do
        :
    done
    host_ip=${i}
    s=0
    while [ ${s} -lt ${ping_count} ]
    do
        result=$(timeout ${wait_time} ping -b -c1 $@ 2>/dev/null | grep from) \
            && s=${ping_count} && result="${host_ip}: alive" \
            || result="${host_ip}: no response"
        s=$((${s} + 1))
    done
    echo ${result}
}

ping_sweep() {
    ping_result="tmp_ping_result$$.txt"
    ip_net_str=${1}
    ip_octate=${2}
    host_count=${3}
    ip_end=$((${ip_octate} + ${host_count}))
    while [ ${ip_octate} -lt ${ip_end} ] 
    do
        host_ip="${ip_net_str}${ip_octate}"
        my_ping $host_ip >> ${ping_result} &
        ip_octate=$((${ip_octate} + 1))
    done
    wait
    cat ${ping_result} | sort -t: -k2,2
    rm -f ${ping_result}
}

ip_net=$(echo ${1} | tr "/" " ")
extract_net_prefix ${ip_net}
last_octate=$(echo ${ip_net} | cut -d. -f4)
map_prefix_to_count

#echo ${host_count} ${last_octate}
fix_ip_net
ip_net_start=$(echo ${ip_net} | sed -e "s/\.[0-9]\+$/./")
#echo ${ip_net_start} ${last_octate} ${host_count}
#my_ping ${ip_net_start}${last_octate}
echo "ping sweep against ${ip_net_start}${last_octate}/${net_prefix}..."
ping_sweep ${ip_net_start} ${last_octate} ${host_count}
