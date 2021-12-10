#!/bin/bash
if [ "$1" == "all" ]
then
    for i in $(ls *.pid)
    do
        for line in $(cat $i)
        do
            kill -9 $line
        done
        /bin/rm $i
    done
elif [ -f "$1.pid" ]
then
    for line in $(cat ${1}.pid)
    do
        kill -9 $line 
    done
    /bin/rm -f "$1.pid"
else
    echo "cannot find $1.pid, please stop the process manually"
fi
