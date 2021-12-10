#!/bin/bash
file_name="$1"
if [ -z "$file_name" ]
then
  echo "usage: $0 <file name>"
  echo ""
  echo "Positional Arguments:"
  echo "    file name          file name that list the file to change rpath"
else
  for file in $(cat ${file_name})
  do
    orig_runpath=$(readelf -d ${file} | grep -i runpath | awk '{print $5}')
    if [ -z "${orig_runpath}" ]
    then
      echo "${file} has no rpath"
    else
      echo ${orig_runpath} | grep -q 'XORIGIN/'
      if [ $? -eq 0 ]
      then
        echo "${file} has rpath ${orig_runpath}"
        new_rpath=$(echo ${orig_runpath} | sed 's/\[\(.*\)\]/\1/' | sed 's/XORIGIN/$ORIGIN/g')
        echo "changine ${file} rpath to ${new_rpath}"
        chrpath -r ${new_rpath} ${file}
      fi
    fi
  done
fi
