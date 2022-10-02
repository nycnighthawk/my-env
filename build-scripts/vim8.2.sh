#!/bin/bash
DESTDIR=/opt/tools
export CFLAGS="-I/usr/include -I/opt/python/3.8/include"
export LDFLAGS="-L/usr/lib64 -L/opt/python/3.8/lib"
export LDFLAGS="${LDFLAGS} -Wl,-z,origin -Wl,--enable-new-dtags"
export LDFLAGS="${LDFLAGS} -Wl,-rpath,XORIGIN/../lib -Wl,-rpath,/usr/lib64 -Wl,-rpath,${DESTDIR}/lib -Wl,-rpath,/opt/python/3.8/lib"
./configure \
    --prefix=${DESTDIR} \
    --enable-luainterp=yes \
    --enable-python3interp=yes \
    --enable-tclinterp=yes \
    --enable-multibyte \
    --with-python3-config-dir=$(/opt/python/3.8/bin/python3.8-config --configdir) \
    --with-lua-prefix=/usr \
    --with-tclsh=tclsh8.6
make -j6 VIMRUNTIMEDIR=/opt/tools/share/vim/vim82
