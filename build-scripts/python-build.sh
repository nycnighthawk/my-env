#!/usr/bin/bash
NL=$'\n'
usage=$(cat <<- END
Usage: $(basename ${0}) [OPTION]...

Required Arguments
  -s <source tgz file>           specify source tgz file, e.g. '-s python-3.8.tgz'
  -v <version>                   specify the version, e.g '-s 3.8'
  -d <destination directory>     specify the installation directory

Optional Arguments
  -h                             display this help message
  -b <build directory>           specify the build directory, e.g. '-b python-3.8'
                                 default: python-<version> where version is provided by
                                 the argument

END
)

if [ "$#" -eq 0 ]
then
    echo "$usage"
    exit 2
fi


while [ "$#" -ne "0" ]
do
	case "$1" in
		-h)
			echo "$usage"
			exit
			;;
		-v)
			if [ "$2" == "" ]
			then
				echo "missing value: -v <version>"
				echo "$usage"
				exit
			fi
			PYTHON_VER="$2"
			shift 2
			;;
		-s)
			if [ "$2" == "" ]
			then
				echo "missing value: -s <source file>"
				echo "$usage"
				exit
			fi
			PYTHON_SOURCE="$2"
			shift 2
			;;
		-b)
			if [ "$2" == "" ]
			then
				echo "missing value: -b <build directory>"
				echo "$usage"
				exit
			fi
			BUILD_DIR="$2"
			shift 2
			;;
		-d)
			if [ "$2" == "" ]
			then
				echo "missing value: -d <destination directory>"
				echo "$usage"
				exit
			fi
			DEST_DIR="$2"
			shift 2
			;;
	esac
done

if [ "${PYTHON_VER}" == "" ]
then
	echo "missing required parameter: -v <version>"
	echo "$usage"
	exit
fi

if [ "${PYTHON_SOURCE}" == "" ]
then
	echo "missing required parameter: -s <python source file>"
	echo "$usage"
fi

if [ "${DEST_DIR}" == "" ]
then
	echo "missing required parameter: -d <destination dir>"
	echo "$usage"
fi

if [ "${BUILD_DIR}" == "" ]
then
    BUILD_DIR="python-${PYTHON_VER}"
fi
export DEST_DIR
export CFLAGS="-I/usr/include"
export LDFLAGS="-L/usr/lib64 -Wl,-z,origin -Wl,--enable-new-dtags -Wl,-rpath,XORIGIN/../lib -Wl,-rpath,/usr/lib64 -Wl,-rpath,${DEST_DIR}/lib"
mkdir -p "${BUILD_DIR}"
tar xvfz "${PYTHON_SOURCE}" -C "${BUILD_DIR}" --strip-components 1
cd "${BUILD_DIR}"
./configure \
    --enable-shared \
	--prefix=${DEST_DIR} \
	--with-valgrind \
	--enable-optimizations \
	--with-computed-gotos \
	--with-lto \
	--with-system-ffi \
	--enable-shared \
	--with-system-expat \
	--with-ensurepip=yes
make -j6 | tee mybuild.log

change-origin.sh ./
make install DESTDIR="./"
set -x
cat > requirements << END
flake8
black
greenlet
isort
jedi
neovim
pylint
requests
pynvim
python-jsonrpc-server
python-language-server
pyaml
pytest
END

requirements="$(pwd)/requirements"

hash -r
cd "./${DEST_DIR}/bin"
"./python${PYTHON_VER}" -m pip install --upgrade pip wheel setuptools
"./python${PYTHON_VER}" -m pip install -r ${requirements}
