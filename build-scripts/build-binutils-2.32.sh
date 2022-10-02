#!/bin/bash
export SRC_DIR=${HOME}/build/binutils-2.32
export BUILD_DIR=build
export TOOLCHAIN_DIR=/opt/devtool
export CC=${TOOLCHAIN_DIR}/bin/gcc
export CXX=${TOOLCHAIN_DIR}/bin/g++
export LD=${TOOLCHAIN_DIR}/bin/ld
#AS=/opt/binutils-2.32/bin/as \
#NM=/opt/binutils-2.32/bin/nm \
#RANLIB=/opt/binutils-2.32/bin/ranlib \
#STRIP=/opt/binutils-2.32/bin/strip \
#OBJCOPY=/opt/binutils-2.32/bin/objcopy \
#OBJDUMP=/opt/binutils-2.32/bin/objdump \
#READELF=/opt/binutils-2.32/bin/readelf \
OLD_PATH=${PATH}
export INSTALL_PREFIX=/opt/devtool
export PATH=${TOOLCHAIN_DIR}/bin:${PATH}
export CFLAGS="-L${INSTALL_PREFIX}/lib64 -L${INSTALL_PREFIX}/lib -fuse-ld=gold"
export LDFLAGS="-Wl,-rpath,${INSTALL_PREFIX}/lib64"
export LDFLAGS="${LDFLAGS} -Wl,-rpath,${TOOLCHAIN_DIR}/lib -Wl,-z,origin -Wl,--enable-new-dtags"
export ENABLE_OPTIONS="--enable-gold \
  --enable-multilib \
  --enable-plugins \
  --enable-shared \
  --enable-64-bit-bfd \
  --enable-libssp \
  --enable-ssp \
  --enable-lto"
export CONFIG_FLAGS="--prefix=${INSTALL_PREFIX} \
  ${ENABLE_OPTIONS}"

cd ${SRC_DIR}
if [ -d ${BUILD_DIR} ]
then
  /usr/bin/rm -fr ${BUILD_DIR}
fi
mkdir ${BUILD_DIR} && cd ${BUILD_DIR} \
  && ../configure ${CONFIG_FLAGS}

make -j2 2>&1 | tee make.log
export PATH=${OLD_PATH}

# create bfd-plugins directory
# mkdir ${PREFIX}/lib/bfd-plugins
