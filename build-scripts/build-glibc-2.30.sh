#!/bin/bash
export TOOLCHAIN_DIR=/opt/gcc-8.2.0
export CC=${TOOLCHAIN_DIR}/bin/gcc
export CXX=${TOOLCHAIN_DIR}/bin/g++
export PREFIX=/usr
export CONFIG_FLAGS="--prefix=${PREFIX} \
                     --with-headers=${HOME}/build/linux-headers/include \
                     --enable-stack-protector=strong --enable-tunables \
                     --enable-systemtap \
                     --enable-bind-now \
                     --enable-kernel=2.6.32"
export CFLAGS="-fPIC -Wp,-D_GLIBCXX_ASSERTIONS -fasynchronous-unwind-tables -fstack-clash-protection -funwind-tables -m32 -m64 -march=i686 -march=x86-64 -O3"
export MAKE="/opt/devtool/bin/make"
../configure ${CONFIG_FLAGS}

make 2>&1 | tee make.log
