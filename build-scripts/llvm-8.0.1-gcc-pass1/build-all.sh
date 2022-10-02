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
OLD_PATH=${PATH}
export PATH=${TOOLCHAIN_DIR}/bin:$PATH
export CC=${TOOLCHAIN_DIR}/bin/gcc
export CXX=${TOOLCHAIN_DIR}/bin/g++
export LIBEDIT_BASE_PATH=/opt/devtool
export LDFLAGS="-L${TOOLCHAIN_DIR}/lib64 -L${LIBEDIT_BASE_PATH}/lib64 -ledit -Wl,-rpath,${TOOL_CHAIN_DIR}/lib64 -Wl,-rpath,${LIBEDIT_BASE_PATH}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags"
cmake ../ \
   -DPYTHON_EXECUTABLE=/opt/python/v3.6.9/bin/python3 \
   -DCMAKE_INSTALL_PREFIX=${LLVM_INSTALL_PATH} \
   -DCMAKE_C_COMPILER=${TOOLCHAIN_DIR}/bin/gcc \
   -DCMAKE_CXX_COMPILER=${TOOLCHAIN_DIR}/bin/g++ \
   -Dlibedit_INCLUDE_DIRS=${LIBEDIT_BASE_PATH}/include \
   -Dlibedit_LIBRARIES=${LIBEDIT_BASE_PATH}/lib64 \
   -DLIBCXXABI_USE_LLVM_UNWINDER=ON \
   -DLIBCXX_CXX_ABI=libcxxabi \
   -DLIBCXXABI_LIBCXX_PATH=../../libcxx \
   -DLIBCXXABI_LIBCXX_INCLUDES=../../libcxx/include \
   -DLIBCXX_CXX_ABI_LIBRARY_PATH=./lib64 \
   -DLIBCXX_CXX_ABI_INCLUDE_PATHS=../../libcxxabi/include \
   -DLLVM_ENABLE_EH=ON \
   -DCMAKE_BUILD_TYPE=Release \
   -DCMAKE_VERBOSE_MAKEFILE=ON \
   -DLLVM_ENABLE_LIBCXX=ON \
   -DLLVM_ENABLE_RTTI=ON \
   -DLLVM_BUILD_LLVM_DYLIB=ON \
   -DLLVM_LIBDIR_SUFFIX=64 \
   -DLLVM_TARGETS_TO_BUILD=X86 \
   -DLLVM_USE_LINKER=gold \
   -DLLVM_ENABLE_PROJECTS="clang;libcxx;libcxxabi;libunwind;lldb;compiler-rt;lld;polly;openmp" \
   -DLLVM_ENABLE_LTO=Off \
   #-DCMAKE_C_LINK_FLAGS="-L${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags" \
   #-DCMAKE_CXX_LINK_FLAGS="-L${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags" \

make -j2 2>&1 | tee make.log
export PATH=${OLD_PATH}
