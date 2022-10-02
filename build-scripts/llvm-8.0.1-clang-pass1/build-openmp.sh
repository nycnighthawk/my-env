#!/bin/bash
export TOOLCHAIN_DIR='/opt/llvm/gcc/v8.0.1'
export GCC_DIR='/opt/gcc-8.2.0'
export VERBOSE=1
export AR=${TOOLCHAIN_DIR}/bin/llvm-ar
export AS=${TOOLCHAIN_DIR}/bin/llvm-as
export NM=${TOOLCHAIN_DIR}/bin/llvm-nm
export RANLIB=${TOOLCHAIN_DIR}/bin/llvm-ranlib
export STRIP=${TOOLCHAIN_DIR}/bin/llvm-strip
export OBJDUMP=${TOOLCHAIN_DIR}/bin/llvm-objdump
export LD=${TOOLCHAIN_DIR}/bin/lld
export LLVM_INSTALL_PATH=/opt/llvm/clang/v8.0.1
#export LDFLAGS="-fuse-ld=lld -L${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags"
export LDFLAGS="-fuse-ld=lld -L${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${GCC_DIR}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags"
OLD_PATH=${PATH}
export PATH=${TOOLCHAIN_DIR}/bin:$PATH
export CC=${TOOLCHAIN_DIR}/bin/clang
export CXX=${TOOLCHAIN_DIR}/bin/clang++

cmake ../ \
   -DPYTHON_EXECUTABLE=/opt/python/v3.6.9/bin/python3 \
   -DGCC_INSTALL_PREFIX=${HOST_GCC} \
   -DLLVM_TOOLS_BINARY_DIR=${LLVM_INSTALL_PATH}/bin \
   -DCMAKE_INSTALL_PREFIX=${LLVM_INSTALL_PATH} \
   -DLLVM_INCLUDE_DIRS=${LLVM_INSTALL_PATH}/include \
   -DCMAKE_BUILD_TYPE=Release \
   -DOPENMP_LIBDIR_SUFFIX=64 \
   -DCMAKE_CXX_COMPILER=${TOOLCHAIN_DIR}/bin/clang++ \
   -DCMAKE_C_COMPILER=${TOOLCHAIN_DIR}/bin/clang \
   -DCMAKE_VERBOSE_MAKEFILE=ON \
   -DLLVM_ENABLE_EH=ON \
   -DLLVM_ENABLE_RTTI=ON \
   -DLLVM_ENABLE_LIBCXX=ON \
   -DLLVM_USE_LINKER=lld 
   #-DLLVM_ENABLE_PROJECTS="polly"
   #-DCMAKE_C_LINK_FLAGS="-L${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags" \
   #-DCMAKE_CXX_LINK_FLAGS="-L${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags" \
make -j2 2>&1 | tee make.log
export PATH=${OLD_PATH}
