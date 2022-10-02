#!/bin/bash
export LLVM_INSTALL_PATH=/opt/llvm/clang/v8.0.1
#export TOOLCHAIN_DIR=/opt/gcc-8.2.0
export TOOLCHAIN_DIR=${LLVM_INSTALL_PATH}
export VERBOSE=1
export AR=${TOOLCHAIN_DIR}/bin/llvm-ar
export NM=${TOOLCHAIN_DIR}/bin/llvm-nm
export RANLIB=${TOOLCHAIN_DIR}/bin/llvm-ranlib
export AS=${TOOLCHAIN_DIR}/bin/llvm-as
export STRIP=${TOOLCHAIN_DIR}/bin/llvm-strip
export OBJDUMP=${TOOLCHAIN_DIR}/bin/llvm-objdump
#export LD=${BINUTILS_DIR}/bin/ld
export LD=${TOOLCHAIN_DIR}/bin/lld
#export LDFLAGS="-L${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags"
#export LDFLAGS="-L${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${LLVM_INSTALL_PATH}/lib64 -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags"
#export LDFLAGS="-L${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${LLVM_INSTALL_PATH}/lib64 -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags"
#OLD_PATH=${PATH}
#export PATH=${TOOLCHAIN_DIR}/bin:$PATH
#export CC=${TOOLCHAIN_DIR}/bin/gcc
#export CXX=${TOOLCHAIN_DIR}/bin/g++
#export LLVM_BUILD_DIR=${HOME}/build/llvm/build
export CFLAGS="-fPIC"
export CXXFLAGS=${CFLAGS}
export LDFLAGS="-L${LLVM_INSTALL_PATH}/lib64 -lunwind -Wl,-rpath,${LLVM_INSTALL_PATH}/lib64"
export LDFLAGS="${LDFLAGS} -Wl,-z,origin -Wl,--enable-new-dtags"
OLD_PATH=${PATH}
export PATH=${LLVM_INSTALL_PATH}/bin:${BINUTILS_DIR}/bin:${TOOLCHAIN_DIR}/bin:$PATH
#export CC=${TOOLCHAIN_DIR}/bin/gcc
#export CXX=${TOOLCHAIN_DIR}/bin/g++
export CC=${TOOLCHAIN_DIR}/bin/clang
export CXX=${TOOLCHAIN_DIR}/bin/clang++

export LLVM_BUILD_DIR=${HOME}/build/llvm/build
cmake .. \
  -DCMAKE_INSTALL_PREFIX=${LLVM_INSTALL_PATH} \
  -DLLVM_CONFIG_PATH=${LLVM_INSTALL_PATH}/bin/llvm-config \
  -DLIBCXXABI_LIBCXX_PATH=../../libcxx \
  -DLIBCXXABI_LIBCXX_INCLUDES=../../libcxx/include \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_LIBDIR_SUFFIX=64 \
  -DLIBCXXABI_LIBUNWIND_INCLUDES=../../libunwind/include \
  -DLIBCXXABI_LIBUNWIND_PATH=../../libunwind \
  -DLIBCXXABI_USE_LLVM_UNWINDER=YES \
  -DCMAKE_VERBOSE_MAKEFILE=ON \
  -DLLVM_ENABLE_EH=ON \
  -DLLVM_ENABLE_RTTI=ON \
  -DLIBCXXABI_USE_COMPILER_RT=ON \
  -DLLVM_USE_LINKER=lld \
  2>&1 | tee config.log
  #-DCMAKE_C_FLAGS="-L${LLVM_INSTALL_PATH}/lib64" \
  #-DCMAKE_CXX_FLAGS="-L${LLVM_INSTALL_PATH}/lib64" \
  #-DLLVM_ENABLE_LTO=Thin \
  #-DLLVM_TARGETS_TO_BUILD=X86 \
  #-DLLVM_USE_LINKER=gold \
  #-DCMAKE_CXX_COMPILER=${TOOLCHAIN_DIR}/bin/g++ \
  #-DCMAKE_C_COMPILER=${TOOLCHAIN_DIR}/bin/gcc \

make -j2 2>&1 | tee make.log
export PATH=$OLD_PATH
