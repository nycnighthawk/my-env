#!/bin/bash
usage="$(basename ${0}) <DIR ...>

where
    DIR ...       one or more directories
"

if [ "$#" -eq 0 ]
then
    echo "$usage" >&2
    exit 2    
fi
export PATH="/usr/sbin:/usr/bin:${PATH}"
while [ $# -gt 0 ]
do
    CUR_DIR=$1
    for i in $(find ${CUR_DIR} -executable -type f)
    do
	file ${i} | grep ELF | grep -q dynamic
	if [ $? -eq 0 ]
	then
            echo "changing ${i} RPATH XORIGIN TO \$ORIGIN"
            chrpath -r $(readelf -d ${i} | grep RUNPATH | sed 's/.*\(\[.*\]\)/\1/' | sed 's/\[//' | sed 's/\]//' | sed 's/XORIGIN/$ORIGIN/') ${i}
	fi
    done
    shift
done
