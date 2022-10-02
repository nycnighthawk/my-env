#!/bin/bash
export TOOLCHAIN_PREFIX=/opt/devtool
export SRC_DIR=${HOME}/build/gcc-8.2.0
export BUILD_DIR="build"
export CC=${TOOLCHAIN_PREFIX}/bin/gcc
export CPP=${TOOLCHAIN_PREFIX}/bin/cpp
export CXX=${TOOLCHAIN_PREFIX}/bin/g++
export LD=${TOOLCHAIN_PREFIX}/bin/ld
export AS=${TOOLCHAIN_PREFIX}/bin/as
export NM=${TOOLCHAIN_PREFIX}/bin/nm
export RANLIB=${TOOLCHAIN_PREFIX}/bin/ranlib
export STRIP=${TOOLCHAIN_PREFIX}/bin/strip
export OBJCOPY=${TOOLCHAIN_PREFIX}/bin/objcopy
export OBJDUMP=${TOOLCHAIN_PREFIX}/bin/objdump
export READELF=${TOOLCHAIN_PREFIX}/bin/readelf

export INSTALL_PREFIX=/opt/gcc/v8.2.0

export ENABLE_FLAGS="--enable-multilib \
  --enable-languages=c,c++,lto,objc,obj-c++ \
  --enable-gold=yes \
  --enable-libssp \
  --enable-lto \
  --enable-shared \
  --enable-bootstrap \
"
export CFLAGS="-fpic -fasynchronous-unwind-tables -fuse-ld=gold -g -O2"
export LDFLAGS="-Wl,-z,defs -Wl,-z,now -Wl,-z,origin -Wl,--enable-new-dtags"

export CONFIG_FLAGS="--prefix=${INSTALL_PREFIX} \
  ${ENABLE_FLAGS}"

cd ${SRC_DIR}
if [ -d ${BUILD_DIR} ]
then
  /usr/bin/rm -fr ${BUILD_DIR}
fi

mkdir ${BUILD_DIR} \
  && cd ${BUILD_DIR} \
  && ../configure ${CONFIG_FLAGS}

make -j2 2>&1 | tee make.log
