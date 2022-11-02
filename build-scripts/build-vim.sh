#!/bin/bash

prog_name=$(basename $0)

display_usage() {
    message=$(cat \
<<- END
Usage: ${prog_name} -v <vim version> -d <install directory> -b <vim source directory> [--py3 <python3 executable>] [-h]

    -v         vim version
    -d         install directory root
    -b         vim source directory
    -h         display this help
    --py3      python3 executable

Example: ${prog_name} -v 9.0 -d /opt/tools -b ~/build/vim --py3 /opt/python/3.10/bin/python
END
)
    echo "$message"
}

error_message() {
    echo "$1"
    exit 1
}

_PYTHON3=python3

process_args() {
    while [ "$#" -ne "0" ]
    do
        case "$1" in
        -h|--help)
            display_usage
            exit 0
        ;;
        -v)
            if [ "$2" == "" ]
            then
                error_message "Missing value: -v <vim version>"
            fi
            _VIM_VERSION=$2
            shift 2
        ;;
        -d)
            if [ "$2" == "" ]
            then
                error_message "Missing value: -d <installation directory>"
            fi
            _VIM_DEST_DIR=$2
            shift 2
        ;;
        -b)
            if [ "$2" == "" ]
            then
                error_message "Missing value: -b <vim source directory>"
            fi
            _VIM_SOURCE_DIR=$2
            shift 2
        ;;
        --py3)
            if [ "$2" == "" ]
            then
                error_message "Missing value: --py3 <python executable>"
            fi
            _PYTHON3=$2
            shift 2
        ;;
        *)
            error_message "Unknown argument(s): $*"
        ;;
        esac
    done
    if [ "${_VIM_SOURCE_DIR}" == "" ]
    then
        _VIM_SOURCE_DIR=./
    fi
    if [ "${_VIM_DEST_DIR}" == "" ]
    then
        error_message "Missing required argument: -d <installation directory>"
    fi
}

prepare_variables() {
    _PYTHON3_PREFIX=$($_PYTHON3 -c "import sys; print(sys.base_prefix)")

    local _vim_ver="${_VIM_VERSION}0"
    _vim_ver=$(echo "${_vim_ver}" | tr -d .)
    _vim_ver=${_vim_ver:0:2}
    _VIM_VERSION=${_vim_ver}
    _VIM_DEST_DIR=${_VIM_DEST_DIR}/${_VIM_VERSION}
    echo "python3 prefix: ${_PYTHON3_PREFIX}"
    echo "vim version: ${_VIM_VERSION}"
    echo "dest dir: ${_VIM_DEST_DIR}"
    echo "vim source directory: ${_VIM_SOURCE_DIR}"
}

prepare_gcc_flags() {
    DESTDIR=${_VIM_DEST_DIR}
    #export CFLAGS="-I/usr/include -I${_PYTHON3_PREFIX}/include"
    #export LDFLAGS="-L/usr/lib64 -L${_PYTHON3_PREFIX}/lib"
    export LDFLAGS="${LDFLAGS} -Wl,-z,origin -Wl,--enable-new-dtags"
    #export LDFLAGS="${LDFLAGS} -Wl,-rpath,XORIGIN/../lib -Wl,-rpath,/usr/lib64 -Wl,-rpath,${DESTDIR}/lib -Wl,-rpath,${_PYTHON3_PREFIX}/lib"
    export LDFLAGS="${LDFLAGS} -Wl,-rpath,XORIGIN/../lib -Wl,-rpath,/usr/lib64 -Wl,-rpath,${DESTDIR}/lib"
}

configure_and_compile() {
    local _number_of_processors=$(cat /proc/cpuinfo | grep processor | wc -l)
    local _number_of_threads=$((${_number_of_processors} - 2))
    echo "number of threads: ${_number_of_threads}"
    cd ${_VIM_SOURCE_DIR}

    # ./configure \
    #     --prefix=${DESTDIR} \
    #     --enable-luainterp=yes \
    #     --enable-python3interp=yes \
    #     --enable-tclinterp=yes \
    #     --enable-multibyte \
    #     --with-lua-prefix=/usr \
    #     --with-tclsh=tclsh8.6
    ./configure \
        --prefix=${_VIM_DEST_DIR} \
        --enable-luainterp=yes \
        --enable-python3interp=yes \
        --with-python3-command=${_PYTHON3} \
        --with-lua-prefix=/usr \
        --enable-multibyte \
        --with-luajit

    make -j${_number_of_threads} VIMRUNTIMEDIR="${_VIM_DEST_DIR}/share/vim/vim${_VIM_VERSION}"
}

if [ "$#" -eq "0" ]
then
    display_usage
    exit 0
fi

process_args $*

prepare_variables

prepare_gcc_flags

configure_and_compile

# DESTDIR=${_VIM_DEST_DIR}
# export CFLAGS="-I/usr/include -I/opt/python/3.10/include"
# export LDFLAGS="-L/usr/lib64 -L/opt/python/3.10/lib"
# export LDFLAGS="${LDFLAGS} -Wl,-z,origin -Wl,--enable-new-dtags"
# export LDFLAGS="${LDFLAGS} -Wl,-rpath,XORIGIN/../lib -Wl,-rpath,/usr/lib64 -Wl,-rpath,${DESTDIR}/lib -Wl,-rpath,/opt/python/3.10/lib"
# make -j6 VIMRUNTIMEDIR=/opt/tools/share/vim/vim90
