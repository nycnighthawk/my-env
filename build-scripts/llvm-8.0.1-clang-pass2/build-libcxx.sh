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
export LD=${TOOLCHAIN_DIR}/bin/lld
#export LDFLAGS="-L${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags"
#export LDFLAGS="-L${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${LLVM_INSTALL_PATH}/lib64 -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags"
#export LDFLAGS="-L${BINUTILS_DIR}/lib -L${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${LLVM_INSTALL_PATH}/lib64 -Wl,-rpath,${BINUTILS_DIR}/lib -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags"
#OLD_PATH=${PATH}
#export PATH=${TOOLCHAIN_DIR}/bin:$PATH
#export CC=${TOOLCHAIN_DIR}/bin/gcc
#export CXX=${TOOLCHAIN_DIR}/bin/g++
#export LLVM_BUILD_DIR=${HOME}/build/llvm/build
export CFLAGS='-fPIC'
export CXXFLAGS=${CFLAGS}
export LDFLAGS="-L${LLVM_INSTALL_PATH}/lib64 -lunwind -lc++abi -Wl,-rpath,${LLVM_INSTALL_PATH}/lib64"
export LDFLAGS="${LDFLAGS} -Wl,-z,origin -Wl,--enable-new-dtags"
OLD_PATH=${PATH}
export PATH=${TOOLCHAIN_DIR}/bin:${BINUTILS_DIR}/bin:$PATH
export CC=${TOOLCHAIN_DIR}/bin/clang
export CXX=${TOOLCHAIN_DIR}/bin/clang++
export LLVM_BUILD_DIR=${HOME}/build/llvm/build
cmake .. \
  -DCMAKE_INSTALL_PREFIX=${LLVM_INSTALL_PATH} \
  -DLLVM_CONFIG_PATH=${LLVM_INSTALL_PATH}/bin/llvm-config \
  -DLIBCXX_CXX_ABI=libcxxabi \
  -DLIBCXX_CXX_ABI_INCLUDE_PATHS=../../libcxxabi/include \
  -DLIBCXX_CXX_ABI_LIBRARY_PATH=${LLVM_INSTALL_PATH}/lib64 \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_LIBDIR_SUFFIX=64 \
  -DCMAKE_CXX_COMPILER=${TOOLCHAIN_DIR}/bin/clang++ \
  -DCMAKE_C_COMPILER=${TOOLCHAIN_DIR}/bin/clang \
  -DLIBCXXABI_USE_LLVM_UNWINDER=ON \
  -DLIBCXX_USE_COMPILER_RT=ON \
  -DCMAKE_VERBOSE_MAKEFILE=ON \
  -DLLVM_ENABLE_EH=ON \
  -DLLVM_ENABLE_RTTI=ON \
  -DLIBCXXABI_USE_LLVM_UNWINDER=ON \
  -DLLVM_USE_LINKER=lld \
  2>&1 | tee config.log
  #-DCMAKE_C_FLAGS="-L${LLVM_INSTALL_PATH}/lib64" \
  #-DCMAKE_CXX_FLAGS="-L${LLVM_INSTALL_PATH}/lib64" \
  #-DLLVM_USE_LINKER=gold \
  #-DLLVM_ENABLE_LTO=Thin \
  #-DLLVM_BUILD_ROOT=${LLVM_BUILD_DIR} \

make -j2 2>&1 | tee make.log
export PATH=${OLD_PATH}
