export TOOLCHAIN_DIR=/opt/devtool/bin
export SRC_DIR=${HOME}/build/systemtap-3.2
export BUILD_DIR=build
cd ${SRC_DIR}
if [ -d ${BUILD_DIR} ]
then
	/usr/bin/rm -fr ${BUILD_DIR}
fi
mkdir ${BUILD_DIR} && cd ${BUILD_DIR}
INSTALL_PREFIX=/usr
export CONFIG_FLAGS="--prefix=${INSTALL_PREFIX} \
  --libdir=${INSTALL_PREFIX}/lib64 \
  --with-python3-probe \
  --without-python2 \
  --with-python3 \
  --enable-sqlite"

export CC=${TOOLCHAIN_DIR}/bin/gcc
export CPP=${TOOLCHAIN_DIR}/bin/cpp
export CFLAGS="-fPIC sqlite3_CFLAGS=-I/opt/devtool/include"
export PKG_CONFIG_PATH=${TOOLCHAIN_DIR}/lib64/pkgconfig 
export LD=${TOOLCHAIN_DIR}/bin/ld
export LDFLAGS="-Wl,-rpath,${TOOLCHAIN_DIR}/lib64 -Wl,-rpath,XORIGIN -Wl,-z,origin -Wl,--enable-new-dtags"
export MAKE=${TOOLCHAIN_DIR}/make
export PYTHON=${TOOLCHAIN_DIR}/bin/python3

../configure ${CONFIG_FLAGS}
make 2>&1 | tee make.log
