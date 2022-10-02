#!/bin/bash
export TOOLCHAIN_DIR='/opt/llvm/gcc/v8.0.1'
export GCC_DIR='/opt/gcc-8.2.0'
export LIBEDIT_BASE_PATH=/opt/devtool
export VERBOSE=1
export AR=${TOOLCHAIN_DIR}/bin/llvm-ar
export AS=${TOOLCHAIN_DIR}/bin/llvm-as
export NM=${TOOLCHAIN_DIR}/bin/llvm-nm
export RANLIB=${TOOLCHAIN_DIR}/bin/llvm-ranlib
export STRIP=${TOOLCHAIN_DIR}/bin/llvm-strip
export OBJDUMP=${TOOLCHAIN_DIR}/bin/llvm-objdump
export LD=${TOOLCHAIN_DIR}/bin/lld
export LLVM_INSTALL_PATH=/opt/llvm/clang/v8.0.1
export LDFLAGS="-fuse-ld=lld -L${TOOLCHAIN_DIR}/lib64 -L${LIBEDIT_BASE_PATH}/lib64 -ledit -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${GCC_DIR}/lib64 -Wl,-rpath,${LIBEDIT_BASE_PATH}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags"
OLD_PATH=${PATH}
export PATH=${TOOLCHAIN_DIR}/bin:$PATH
export CC=${TOOLCHAIN_DIR}/bin/clang
export CXX=${TOOLCHAIN_DIR}/bin/clang++
export LLVM_BUILD_DIR=${HOME}/build/llvm/build

cmake ../ \
   -DCMAKE_INSTALL_PREFIX=${LLVM_INSTALL_PATH} \
   --DLLVM_DIR=${LLVM_BUILD_DIR}/lib64/cmake/llvm \
   -DCMAKE_BUILD_TYPE=Release \
   -DLLVM_LIBDIR_SUFFIX=64 \
   -DLLVM_TARGETS_TO_BUILD="X86" \
   -Dlibedit_INCLUDE_DIRS=${LIBEDIT_BASE_PATH}/include \
   -Dlibedit_LIBRARIES=${LIBEDIT_BASE_PATH}/lib64 \
   -DCMAKE_CXX_COMPILER=${HOST_GCC}/bin/g++ \
   -DCMAKE_C_COMPILER=${HOST_GCC}/bin/gcc \
   -DCMAKE_VERBOSE_MAKEFILE=ON \
   -DLLVM_ENABLE_EH=ON \
   -DLLVM_ENABLE_RTTI=ON \
   -DLLVM_ENABLE_LIBCXX=ON \
   -DLLVM_USE_LINKER=lld
   #-DCMAKE_C_FLAGS="-I${LIBEDIT_BASE_PATH}/include"
   #-DCMAKE_C_LINK_FLAGS="-L${HOST_GCC}/lib64 -L${LIBEDIT_BASE_PATH}/lib64 -ledit -Wl,-rpath,/opt/gcc-8.2.0/lib64 -Wl,-rpath,${LIBEDIT_BASE_PATH}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags" \
   #-DCMAKE_CXX_FLAGS="-I${LIBEDIT_BASE_PATH}/include"
   #-DCMAKE_CXX_LINK_FLAGS="-L${HOST_GCC}/lib64 -L${LIBEDIT_BASE_PATH}/lib64 -ledit -Wl,-rpath,/opt/gcc-8.2.0/lib64 -Wl,-rpath,${LIBEDIT_BASE_PATH}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags" \

make -j2 2>&1 | tee make.log
cp -r ./lib/python3.6 ./lib64
export PATH=${OLD_PATH}
