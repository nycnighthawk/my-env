#!/bin/bash
export TOOLCHAIN_DIR=/opt/gcc-8.2.0
export BINUTILS_DIR=/opt/binutils-2.32
export VERBOSE=1
export AR=${TOOLCHAIN_DIR}/bin/gcc-ar
export NM=${TOOLCHAIN_DIR}/bin/gcc-nm
export RANLIB=${TOOLCHAIN_DIR}/bin/gcc-ranlib
export AS=${BINUTILS_DIR}/bin/as
export STRIP=${BINUTILS_DIR}/bin/strip
export OBJDUMP=${BINUTILS_DIR}/bin/objdump
export LD=${BINUTILS_DIR}/bin/ld.gold
export LLVM_INSTALL_PATH=/opt/llvm/gcc/v8.0.1
export LDFLAGS="-L${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags"
OLD_PATH=${PATH}
export PATH=${TOOLCHAIN_DIR}/bin:$PATH
export CC=${TOOLCHAIN_DIR}/bin/gcc
export CXX=${TOOLCHAIN_DIR}/bin/g++
cmake ../ \
   -DPYTHON_EXECUTABLE=/opt/python/v3.6.9/bin/python3 \
   -DLLVM_TOOLS_BINARY_DIR=${LLVM_INSTALL_PATH}/bin \
   -DCMAKE_INSTALL_PREFIX=${LLVM_INSTALL_PATH} \
   -DLLVM_INCLUDE_DIRS=${LLVM_INSTALL_PATH}/include \
   -DCMAKE_BUILD_TYPE=Release \
   -DLLVM_LIBDIR_SUFFIX=64 \
   -DLLVM_TARGETS_TO_BUILD="X86" \
   -DCMAKE_CXX_COMPILER=${TOOLCHAIN_DIR}/bin/g++ \
   -DCMAKE_C_COMPILER=${TOOLCHAIN_DIR}/bin/gcc \
   -DCMAKE_VERBOSE_MAKEFILE=ON \
   -DLLVM_ENABLE_EH=ON \
   -DLLVM_ENABLE_RTTI=ON \
   -DLLVM_USE_LINKER=gold
   #-DCMAKE_C_LINK_FLAGS="-L${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags" \
   #-DCMAKE_CXX_LINK_FLAGS="-L${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags" \
   #-DLLVM_ENABLE_PROJECTS="polly"
   #-DCMAKE_VERBOSE_MAKEFILE=ON \
make -j2 2>&1 | tee make.log
export PATH=${OLD_PATH}
