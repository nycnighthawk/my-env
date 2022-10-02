#!/bin/bash
export LLVM_INSTALL_PATH=/opt/llvm/clang/v8.0.1
#export TOOLCHAIN_DIR=/opt/gcc-8.2.0
export PASS1=${LLVM_INSTALL_PATH}
export TOOLCHAIN_DIR=${PASS1}
export VERBOSE=1
export AR=${TOOLCHAIN_DIR}/bin/llvm-ar
export NM=${TOOLCHAIN_DIR}/bin/llvm-nm
export RANLIB=${TOOLCHAIN_DIR}/bin/llvm-ranlib
export AS=${BINUTILS_DIR}/bin/llvm-as
export STRIP=${BINUTILS_DIR}/bin/llvm-strip
export OBJDUMP=${BINUTILS_DIR}/bin/llvm-objdump
#export LD=${BINUTILS_DIR}/bin/ld
export LD=${PASS1}/bin/ldd
#export LDFLAGS="-L${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags"
#export LDFLAGS="-L${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${LLVM_INSTALL_PATH}/lib64 -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags"
#export CFLAGS='-flto'
#export CXXFLAGS=${CFLAGS}
#export LDFLAGS="-L${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${LLVM_INSTALL_PATH}/lib64 -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags"
#OLD_PATH=${PATH}
#export PATH=${TOOLCHAIN_DIR}/bin:$PATH
#export CC=${TOOLCHAIN_DIR}/bin/gcc
#export CXX=${TOOLCHAIN_DIR}/bin/g++
#export LLVM_BUILD_DIR=${HOME}/build/llvm/build
#export CFLAGS='-flto'
export CFLAGS="-fPIC"
export CXXFLAGS="-fPIC -stdlib=libc++"
export LDFLAGS="--rtlib=compiler-rt -L${LLVM_INSTALL_PATH}/lib64 -Wl,-rpath,${LLVM_INSTALL_PATH}/lib64"
export LDFLAGS="${LDFLAGS} -Wl,-z,origin -Wl,--enable-new-dtags"
OLD_PATH=${PATH}
export PATH=${LLVM_INSTALL_PATH}/bin:${PASS1}/bin:$PATH
export CC=${TOOLCHAIN_DIR}/bin/clang
export CXX=${TOOLCHAIN_DIR}/bin/clang++

cmake ../ \
  -DLLVM_CONFIG_PATH=${LLVM_INSTALL_PATH}/bin/llvm-config \
  -DCMAKE_INSTALL_PREFIX=${LLVM_INSTALL_PATH} \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_LIBDIR_SUFFIX=64 \
  -DCMAKE_CXX_COMPILER=${TOOLCHAIN_DIR}/bin/clang++ \
  -DCMAKE_C_COMPILER=${TOOLCHAIN_DIR}/bin/clang \
  -DCMAKE_VERBOSE_MAKEFILE=ON \
  -DLLVM_ENABLE_EH=ON \
  -DLLVM_ENABLE_RTTI=ON \
  -DLLVM_ENABLE_LIBCXX=ON \
  -DLIBUNWIND_ENABLE_STATIC=ON \
  -DLIBUNWIND_ENABLE_SHARED=ON \
  -DLIBUNWIND_USE_COMPILER_RT=YES \
  -DLLVM_USE_LINKER=lld \
  2>&1 | tee config.log
  #-DLLVM_USE_LINKER=gold \
  #-DLLVM_ENABLE_LTO=Thin \

make -j2 2>&1 | tee make.log
export PATH=${OLD_PATH}
