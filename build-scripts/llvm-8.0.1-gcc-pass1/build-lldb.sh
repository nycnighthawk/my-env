#!/bin/bash
export LLVM_BUILD_DIR=${HOME}/build/llvm
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
OLD_PATH=${PATH}
export PATH=${TOOLCHAIN_DIR}/bin:$PATH
export CC=${TOOLCHAIN_DIR}/bin/gcc
export CXX=${TOOLCHAIN_DIR}/bin/g++
export CFLAGS="-I${LIBEDIT_BASE_PATH}/include"
export CXXFLAGS="-I${LIBEDIT_BASE_PATH}/include"
export LDFLAGS="-L${TOOLCHAIN_DIR}/lib64 -L${LIBEDIT_BASE_PATH}/lib64 -ledit -Wl,-rpath,${LLVM_INSTALL_PATH}/lib64 -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${LIBEDIT_BASE_PATH}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags"
cmake ../ \
   -DCMAKE_INSTALL_PREFIX=${LLVM_INSTALL_PATH} \
   -DLLVM_DIR=${LLVM_BUILD_DIR}/lib64/cmake/llvm \
   -DCMAKE_BUILD_TYPE=Release \
   -DLLVM_LIBDIR_SUFFIX=64 \
   -DLLVM_TARGETS_TO_BUILD="X86" \
   -Dlibedit_INCLUDE_DIRS=${LIBEDIT_BASE_PATH}/include \
   -Dlibedit_LIBRARIES=${LIBEDIT_BASE_PATH}/lib64 \
   -DCMAKE_CXX_COMPILER=${TOOLCHAIN_DIR}/bin/g++ \
   -DCMAKE_C_COMPILER=${TOOLCHAIN_DIR}/bin/gcc \
   -DCMAKE_VERBOSE_MAKEFILE=ON \
   -DLLVM_ENABLE_EH=ON \
   -DLLVM_ENABLE_RTTI=ON \
   -DLLVM_USE_LINKER=gold \
   -DLLVM_ENABLE_LTO=Thin \
   #-DCMAKE_C_FLAGS="-I${LIBEDIT_BASE_PATH}/include"
   #-DCMAKE_C_LINK_FLAGS="-L${TOOLCHAIN_DIR}/lib64 -L${LIBEDIT_BASE_PATH}/lib64 -ledit -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${LIBEDIT_BASE_PATH}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags" \
   #-DCMAKE_CXX_FLAGS="-I${LIBEDIT_BASE_PATH}/include"
   #-DCMAKE_CXX_LINK_FLAGS="-L${TOOLCHAIN_DIR}/lib64 -L${LIBEDIT_BASE_PATH}/lib64 -ledit -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${LIBEDIT_BASE_PATH}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags" \

make -j2 2>&1 | tee make.log
cp -r ./lib/python3.6 ./lib64
export PATH=${OLD_PATH}
