#!/bin/bash
VIM_VERSION="7.4"
PREFIX="/opt/vim${VIM_VERSION}"
LDFLAGS=-Wl,-rpath=${PREFIX}/lib ./configure --with-features=huge \
    --enable-multibyte \
    --enable-rubyinterp=yes \
    --enable-pythoninterp=yes \
    --with-python-config-dir=/opt/python-2.7.15/lib/python2.7/config \
    --enable-python3interp=yes \
    --with-python3-config-dir=/opt/python-3.6.6/lib/python3.6/config-3.6m-x86_64-linux-gnu \
    --enable-perlinterp=yes \
    --enable-luainterp=yes \
    --with-lua-prefix=/opt/lua-5.3.5 \
    --enable-gui=gtk2 \
    --enable-cscope \
    --prefix=${PREFIX}
make
make VIMRUNTIMEDIR=/opt/vim7.4/share/vim/vim74
