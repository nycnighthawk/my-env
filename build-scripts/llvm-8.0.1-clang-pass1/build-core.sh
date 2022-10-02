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
#export LDFLAGS="-L${LLVM_INSTALL_PATH} -L${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${LLVM_INSTALL_PATH}/lib64 -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${GCC_DIR}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags"
#export LDFLAGS="-L${LLVM_INSTALL_PATH} -L${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${LLVM_INSTALL_PATH}/lib64 -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${GCC_DIR}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags"
#export LDFLAGS="--rtlib=compiler-rt -L${LLVM_INSTALL_PATH}/lib64 -lc++abi -lc++ -Wl,-rpath,${LLVM_INSTALL_PATH}/lib64 -Wl,-rpath,${GCC_DIR}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags"
export CFLAGS="-fPIC"
export CXXFLAGS="-fPIC --rtlib=compiler-rt -stdlib=libc++"
export LDFLAGS="--rtlib=compiler-rt -Wl,-rpath,${LLVM_INSTALL_PATH}/lib64 -Wl,-rpath,${GCC_DIR}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags"
OLD_PATH=${PATH}
export PATH=${TOOLCHAIN_DIR}/bin:$PATH
export CC=${TOOLCHAIN_DIR}/bin/clang
export CXX=${TOOLCHAIN_DIR}/bin/clang++
cmake ../ \
   -DPYTHON_EXECUTABLE=/opt/python/v3.6.9/bin/python3 \
   -DCMAKE_INSTALL_PREFIX=${LLVM_INSTALL_PATH} \
   -DCMAKE_C_COMPILER=${TOOLCHAIN_DIR}/bin/clang \
   -DCMAKE_CXX_COMPILER=${TOOLCHAIN_DIR}/bin/clang++ \
   -DCMAKE_BUILD_TYPE=Release \
   -DCMAKE_VERBOSE_MAKEFILE=ON \
   -DLLVM_ENABLE_RTTI=ON \
   -DLLVM_ENABLE_EH=ON \
   -DLLVM_TARGETS_TO_BUILD="X86;BPF" \
   -DLLVM_LIBDIR_SUFFIX=64 \
   -DLLVM_TARGETS_TO_BUILD=X86 \
   -DLLVM_USE_LINKER=lld \
   -DLLVM_ENABLE_LTO=Thin \
   -DLLVM_ENABLE_LIBCXX=ON \
   -DCMAKE_C_LINK_FLAGS="-L${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${LLVM_INSTALL_PATH}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags" \
   -DCMAKE_CXX_LINK_FLAGS="-L${TOOLCHAIN_DIR}/lib64 -lc++abi -lc++ -Wl,-rpath,${LLVM_INSTALL_PATH}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags" \
   -DLLVM_BUILD_LLVM_DYLIB=ON \
   2>&1 | tee config.log
   #-DLIBCXXABI_USE_COMPILER_RT=YES \
   #-DLIBCXX_USE_COMPILER_RT=YES \
   #-DLIBCXXABI_USE_COMPILER_RT=YES \
   #-DBUILD_SHARED_LIBS=ON \
   #-DBUILD_STATIC_LIBS=ON \
   #-DLIBCXX_CXX_ABI=libc++abi \
   #-DLIBCXX_USE_COMPILER_RT=YES \

make -j2 2>&1 | tee make.log
