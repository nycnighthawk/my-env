#!/bin/bash
export LLVM_INSTALL_PATH=/opt/llvm/clang/v8.0.1
export TOOLCHAIN_DIR=${LLVM_INSTALL_PATH}
export PASS1=/opt/llvm/gcc/v8.0.1
export VERBOSE=1
export AR=${PASS1}/bin/llvm-ar
export AS=${PASS1}/bin/llvm-as
export NM=${PASS1}/bin/llvm-nm
export RANLIB=${PASS1}/bin/llvm-ranlib
export STRIP=${PASS1}/bin/llvm-strip
export OBJDUMP=${PASS1}/bin/llvm-objdump
export LD=${PASS1}/bin/lld
#export LDFLAGS="-fuse-ld=lld -L${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags"
#export LDFLAGS="-fuse-ld=lld -L${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${GCC_DIR}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags"
export CFLAGS="-fPIC"
export CXXFLAGS="-stdlib=libc++ ${CFLAGS}"
export LDFLAGS="--rtlib=compiler-rt -L${TOOLCHAIN_DIR}/lib64 -lc++abi -lc++ -Wl,-rpath,${LLVM_INSTALL_PATH}/lib64 -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags"
OLD_PATH=${PATH}
export PATH=${TOOLCHAIN_DIR}/bin:$PATH
export CC=${TOOLCHAIN_DIR}/bin/clang
export CXX=${TOOLCHAIN_DIR}/bin/clang++

cmake .. \
  -DCMAKE_INSTALL_PREFIX=${LLVM_INSTALL_PATH} \
  -DLLVM_CONFIG_PATH=${LLVM_INSTALL_PATH}/bin/llvm-config \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_LIBDIR_SUFFIX=64 \
  -DCMAKE_CXX_COMPILER=${PASS1}/bin/clang++ \
  -DCMAKE_C_COMPILER=${PASS1}/bin/clang \
  -DCMAKE_VERBOSE_MAKEFILE=ON \
  -DLLVM_ENABLE_EH=ON \
  -DLLVM_ENABLE_RTTI=ON \
  -DLLVM_ENABLE_LIBCXX=ON \
  -DLLVM_USE_LINKER=lld \
  2>&1 | tee config.log
  #-DLLVM_USE_LINKER=lld \
  #-DCMAKE_C_FLAGS="-L${LLVM_INSTALL_PATH}/lib64 -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags" \
  #-DCMAKE_CXX_FLAGS="-L${LLVM_INSTALL_PATH}/lib64 -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags" \

make -j2 2>&1 | tee make.log
export PATH=$OLD_PATH
