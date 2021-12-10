#!/bin/sh

function usage
{
  pgn=$(basename $0)
  echo "$pgn [-b\|--build] <srpm url>"
}

filename=""
buildflag=0
url=""

case $1 in
  -b | --build )  shift
                  buildflag=1
                  url=$1
                  ;;
  * )             url=$1
                  ;;
esac

if [ "$url" == "" ]; then
  usage
  exit 0
fi
transform_url=$(echo $url | tr '[:upper:]' '[:lower:]')
echo $fn
if [ $(echo $transform_url | sed -e 's@^\(http\|ftp\)://.*@valid_url@') == "valid_url" ]; then
  filename=$(echo $url | sed -e 's/^.*\/\([^/]\+\)/\1/')
  cd /var/tmp
  wget $url
else
  filename=$url
fi
/bin/rpm -ivh $filename

specfile=$(echo $filename | sed -e 's/\([^-]\+\).*/\1/')

specfile="$specfile"".spec"

if [ $buildflag -eq 1 ]; then
  cd $HOME/rpm/SPECS
  /usr/bin/rpmbuild -ba $specfile --target i686
fi
