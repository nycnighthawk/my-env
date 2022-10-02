#!/bin/bash
#export TOOLCHAIN_DIR=/opt/gcc-8.2.0
export TOOLCHAIN_DIR=/opt/llvm/gcc/v8.0.1
export BINUTILS_DIR=/opt/binutils-2.32
export VERBOSE=1
export AR=${TOOLCHAIN_DIR}/bin/llvm-ar
export NM=${TOOLCHAIN_DIR}/bin/llvm-nm
export RANLIB=${TOOLCHAIN_DIR}/bin/llvm-ranlib
export AS=${BINUTILS_DIR}/bin/llvm-as
export STRIP=${BINUTILS_DIR}/bin/llvm-strip
export OBJDUMP=${BINUTILS_DIR}/bin/llvm-objdump
#export LD=${BINUTILS_DIR}/bin/ld
export LD=${TOOLCHAIN_DIR}/bin/ldd
export LLVM_INSTALL_PATH=/opt/llvm/clang/v8.0.1
#export LDFLAGS="-L${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags"
export CXXFLAGS="-fPIC --rtlib=compiler-rt -stdlib=libc++"
export LDFLAGS="-L${LLVM_INSTALL_PATH}/lib64 -L${TOOLCHAIN_DIR}/lib64 -lc++ -lc++abi -Wl,-rpath,${LLVM_INSTALL_PATH}/lib64"
export LDFLAGS="${LDFLAGS} -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags"
OLD_PATH=${PATH}
export PATH=${TOOLCHAIN_DIR}/bin:${BINUTILS_DIR}/bin:$PATH
export CC=${TOOLCHAIN_DIR}/bin/gcc
export CXX=${TOOLCHAIN_DIR}/bin/g++
export LLVM_BUILD_DIR=${HOME}/build/llvm/build
cmake ../ \
   -DCMAKE_INSTALL_PREFIX=${LLVM_INSTALL_PATH} \
   -DLLVM_BUILD_ROOT=${LLVM_BUILD_DIR} \
   -DLLVM_CONFIG_PATH=${LLVM_INSTALL_PATH}/bin/llvm-config \
   -DCMAKE_C_COMPILER=${TOOLCHAIN_DIR}/bin/clang \
   -DCMAKE_CXX_COMPILER=${TOOLCHAIN_DIR}/bin/clang++ \
   -DCMAKE_BUILD_TYPE=Release \
   -DCMAKE_VERBOSE_MAKEFILE=ON \
   -DLLVM_LIBDIR_SUFFIX=64 \
   -DLLVM_ENABLE_EH=ON \
   -DLLVM_ENABLE_RTTI=ON \
   -DCOMPILER_RT_USE_BUILTINS_LIBRARY=ON \
   -DSANITIZER_CXX_ABI_LIBNAME=libc++ \
   2>&1 | tee config.log
   #-DSANITIZER_CXX_ABI_LIBNAME=libcxxabi \
   #-DLLVM_USE_LINKER=gold \
   #-DCMAKE_C_LINK_FLAGS="-L${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags" \
   #-DCMAKE_CXX_LINK_FLAGS="-L${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags" \
   #-DLLVM_TARGETS_TO_BUILD=X86 \
   #-DLLVM_ENABLE_LTO=Thin \

make -j2 2>&1 | tee make.log

export PATH=$OLDPATH
