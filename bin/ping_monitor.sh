#!/bin/bash

# hosts to be ping, separated by space
hosts="10.10.251.13 10.10.251.17"

# file to save the pid for background function
pid_file="ping_script.pids"

#payload size
payload_size=200

#time out in second
wait_time=0.2

#interval in second
interval=0.5

exit_ctrl()
{
    for pid in $(cat ${pid_file})
    do
        /usr/bin/kill -KILL ${pid} > /dev/null 2>&1
    done
    /bin/rm -f ${pid_file}
    exit
}


my_ping() {
    s=0
    while :
    do
        s=$(($s+1))
        result=$(/usr/bin/timeout ${wait_time} ping -c1 $@ | grep from) \
                && echo "$result, seq=${s}" \
                && sleep ${interval} \
                || echo "timeout, seq=${s}"
    done
}

do_ping() {
    my_ping -s ${payload_size} $1 | tee ./host-${1}.log
}

trap exit_ctrl INT

for host in ${hosts}
do
    do_ping ${host} > /dev/null 2>&1 &
    func_pid=$!
    echo "${func_pid}" >> ${pid_file}
done


echo "running ..."
echo "Press Ctrl-C to terminate ..."
# infinite loop but does nothing, waits up every 30 minutes then sleep again
while :
do
    sleep 1800
done
