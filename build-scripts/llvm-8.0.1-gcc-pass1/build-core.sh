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
#export CFLAGS='-flto'
#export CXXFLAGS=${CFLAGS}
export LDFLAGS="-L${BINUTILS_DIR}/lib -L${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${LLVM_INSTALL_PATH}/lib64 -Wl,-rpath,${BINUTILS_DIR}/lib -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags"
OLD_PATH=${PATH}
export PATH=${LLVM_INSTALL_PATH}/bin:${BINUTILS_DIR}/bin:${TOOLCHAIN_DIR}/bin:$PATH
export CC=${TOOLCHAIN_DIR}/bin/gcc
export CXX=${TOOLCHAIN_DIR}/bin/g++

cmake ../ \
   -DPYTHON_EXECUTABLE=/opt/python/v3.6.9/bin/python3 \
   -DCMAKE_INSTALL_PREFIX=${LLVM_INSTALL_PATH} \
   -DCMAKE_C_COMPILER=${TOOLCHAIN_DIR}/bin/gcc \
   -DCMAKE_CXX_COMPILER=${TOOLCHAIN_DIR}/bin/g++ \
   -DCMAKE_BUILD_TYPE=Release \
   -DCMAKE_VERBOSE_MAKEFILE=ON \
   -DLLVM_ENABLE_RTTI=ON \
   -DLLVM_ENABLE_EH=ON \
   -DLLVM_BUILD_LLVM_DYLIB=ON \
   -DLLVM_LIBDIR_SUFFIX=64 \
   -DLLVM_TARGETS_TO_BUILD=X86;BPF\
   -DLLVM_ENABLE_LTO=Thin \
   -DLLVM_LINK_LLVM_DYLIB=ON \
   -DLLVM_BINUTILS_INCDIR=${BINUTILS_DIR}/include \
   -DLLVM_USE_LINKER=gold \
   #-DLLVM_ENABLE_LTO=Off \
   #-DCMAKE_C_LINK_FLAGS="-L${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags" \
   #-DCMAKE_CXX_LINK_FLAGS="-L${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags" \

make -j2 2>&1 | tee make.log
