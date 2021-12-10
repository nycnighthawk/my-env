#!/bin/bash
usage="$(basename ${0}) [-h] <certfile>

where
     -h        show this help text
     certfile  the filename of the cert, i.e. ./sslcerts/abcdomain.crt
"

while getopts ':h' option;
do
  case "$option" in
    h) echo "$usage"
       exit
       ;;
    \?) printf "illegal option: -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
  esac
done
if [ "$#" -ne 1 ]
then
  echo "$usage"
  exit
fi
certfile=${1}
names=$(openssl x509 -in ${certfile} -noout -text | grep -C1 "Subject Alternative Name" | sed -n '$p'  | sed -ne 's/DNS://gp' | sed -ne 's/^  *//p')
echo $names | grep ',' &> /dev/null
has_comma=$?
if [ $has_comma == 0 ];
then
  names=$(echo $names | sed -ne 's/,/ /gp')
fi
for name in $names; do
  echo $name
done

