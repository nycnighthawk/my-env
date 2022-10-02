#!/bin/bash
export LLVM_INSTALL_PATH=/opt/llvm/clang/v8.0.1
export TOOLCHAIN_DIR=${LLVM_INSTALL_PATH}
export VERBOSE=1
export AR=${TOOLCHAIN_DIR}/bin/llvm-ar
export AS=${TOOLCHAIN_DIR}/bin/llvm-as
export NM=${TOOLCHAIN_DIR}/bin/llvm-nm
export RANLIB=${TOOLCHAIN_DIR}/bin/llvm-ranlib
export STRIP=${TOOLCHAIN_DIR}/bin/llvm-strip
export OBJDUMP=${TOOLCHAIN_DIR}/bin/llvm-objdump
export LD=${TOOLCHAIN_DIR}/bin/lld
#export LDFLAGS="-fuse-ld=lld -L${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags"
export CFLAGS="-fPIC"
export CXXFLAGS="-stdlib=libc++ ${CFLAGS}"
#export LDFLAGS="-L${LLVM_INSTALL_PATH}/lib64 -lc++abi -lc++ -L${GCC_DIR}/lib64 -L${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${LLVM_INSTALL_PATH}/lib64 -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${GCC_DIR}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags"
#export LDFLAGS="--rtlib=compiler-rt -L${TOOLCHAIN_DIR}/lib64 -lc++abi -lc++ -Wl,-rpath,${LLVM_INSTALL_PATH}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags"
OLD_PATH=${PATH}
export PATH=${LLVM_INSTALL_PATH}/bin:${TOOLCHAIN_DIR}/bin:$PATH
export CC=${TOOLCHAIN_DIR}/bin/clang
export CXX=${TOOLCHAIN_DIR}/bin/clang++
cmake ../ \
   -DPYTHON_EXECUTABLE=/opt/python/v3.6.9/bin/python3 \
   -DCMAKE_INSTALL_PREFIX=${LLVM_INSTALL_PATH} \
   -DCMAKE_BUILD_TYPE=Release \
   -DLLVM_LIBDIR_SUFFIX=64 \
   -DLLVM_TARGETS_TO_BUILD="X86" \
   -DCMAKE_C_COMPILER=${TOOLCHAIN_DIR}/bin/clang \
   -DCMAKE_CXX_COMPILER=${TOOLCHAIN_DIR}/bin/clang++ \
   -DCMAKE_VERBOSE_MAKEFILE=ON \
   -DLLVM_ENABLE_EH=ON \
   -DLLVM_ENABLE_RTTI=ON \
   -DLLVM_ENABLE_LIBCXX=ON \
   -DLLVM_USE_LINKER=lld \
   -DCMAKE_C_LINK_FLAGS="--rtlib=compiler-rt -L${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags" \
   -DCMAKE_CXX_LINK_FLAGS="--rtlib=compiler-rt -L${TOOLCHAIN_DIR}/lib64 -lc++ -lc++abi -Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-z,origin -Wl,--enable-new-dtags" \
   -DLLVM_ENABLE_LTO=Thin \
   -DCLANG_DEFAULT_RTLIB=compiler-rt \
   -DCLANG_DEFAULT_CXX_STDLIB=libc++ \
   -DCLANG_LIBDIR_SUFFIX=64 \
   2>&1 | tee config.log
   #-DLLVM_CONFIG_PATH=${LLVM_INSTALL_PATH}/bin/llvm-config \
   #-DLLVM_ENABLE_LTO=ON \
   #-DUSE_SHARED_LLVM=ON \
   #-DLIBCXX_CXX_ABI=libc++abi \
   #-DLLVM_USE_LINKER=lld
   #-DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra" \
   #-DLIBCXXABI_USE_LLVM_UNWINDER=ON \
   #-DLIBCXXABI_LIBUNWIND_INCLUDES=../../libunwind/include \
   #-DLIBCXXABI_LIBUNWIND_PATH=../../libunwind \

make -j1 2>&1 | tee make.log
export PATH=${OLD_PATH}
