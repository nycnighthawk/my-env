#!/usr/bin/bash
usage="$(basename ${0}) <src tgz>

where
    src tgz:    source tgz file
"

if [ "$#" -eq 0 ]
then
    echo "$usage" >&2
    exit 2
fi
export TARGET_DIR="/opt/python/3.8"
export CFLAGS="-I/usr/include"
export LDFLAGS="-L/usr/lib64 -Wl,-z,origin -Wl,--enable-new-dtags -Wl,-rpath,XORIGIN/../lib -Wl,-rpath,/usr/lib64 -Wl,-rpath,${TARGET_DIR}/lib"
src_tgz="${1}"
build_dir="build"
mkdir -p "${build_dir}"
tar xvfz "${src_tgz}" -C "${build_dir}" --strip-components 1
cd "${build_dir}"
./configure \
    --enable-shared \
	--prefix=${TARGET_DIR} \
	--with-valgrind \
	--enable-optimizations \
	--with-computed-gotos \
	--with-lto \
	--with-system-ffi \
	--enable-shared \
	--with-system-expat \
	--with-ensurepip=yes
make -j6 | tee mybuild.log
# make install DESTDIR=.
# cd .${TARGET_DIR}/bin
# change-origin.sh ./
cd ..
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
