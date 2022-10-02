#!/bin/bash
export LLVM_INSTALL_PATH=/opt/llvm/gcc/v8.0.1
export TOOLCHAIN_DIR=/opt/gcc-8.2.0
export BINUTILS_DIR=/opt/binutils-2.32
export VERBOSE=1
export AR=${TOOLCHAIN_DIR}/bin/gcc-ar
export NM=${TOOLCHAIN_DIR}/bin/gcc-nm
export RANLIB=${TOOLCHAIN_DIR}/bin/gcc-ranlib
export AS=${BINUTILS_DIR}/bin/as
export STRIP=${BINUTILS_DIR}/bin/strip
export OBJDUMP=${BINUTILS_DIR}/bin/objdump
export LD=${BINUTILS_DIR}/bin/ld
#export LD=${LLVM_INSTALL_PATH}/bin/lld
#export LDFLAGS="-L${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags"
#OLD_PATH=${PATH}
#export PATH=${TOOLCHAIN_DIR}/bin:$PATH
#export CC=${TOOLCHAIN_DIR}/bin/gcc
#export CXX=${TOOLCHAIN_DIR}/bin/g++
export LDFLAGS="-L${LLVM_INSTALL_PATH}/lib64 -L${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${LLVM_INSTALL_PATH}/lib64"
export LDFLAGS="${LDFLAGS} -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags"
OLD_PATH=${PATH}
export PATH=${LLVM_INSTALL_PATH}/bin:${TOOLCHAIN_DIR}/bin:$PATH
export CC=${TOOLCHAIN_DIR}/bin/gcc
export CXX=${TOOLCHAIN_DIR}/bin/g++
export LLVM_BUILD_DIR=${HOME}/build/llvm/build
cmake .. \
  -DCMAKE_INSTALL_PREFIX=${LLVM_INSTALL_PATH} \
  -DLLVM_CONFIG_PATH=${LLVM_INSTALL_PATH}/bin/llvm-config \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_LIBDIR_SUFFIX=64 \
  -DCMAKE_CXX_COMPILER=${TOOLCHAIN_DIR}/bin/g++ \
  -DCMAKE_C_COMPILER=${TOOLCHAIN_DIR}/bin/gcc \
  -DCMAKE_VERBOSE_MAKEFILE=ON \
  -DLLVM_ENABLE_EH=ON \
  -DLLVM_ENABLE_RTTI=ON \
  -DLLVM_USE_LINKER=gold \
  -DLLVM_BINUTILS_INCDIR=${BINUTILS_DIR}/include \
  #-DLLVM_ENABLE_LTO=Thin \
  #-DCMAKE_C_FLAGS="-L${LLVM_INSTALL_PATH}/lib64 -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags" \
  ##-DCMAKE_CXX_FLAGS="-L${LLVM_INSTALL_PATH}/lib64 -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags" \

make -j2 2>&1 | tee make.log
export PATH=$OLD_PATH
