#!/bin/bash
#CFLAGS="-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=4 -m64 -mtune=native" \
#CFLAGS="-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=4" \
#  ../configure --build=x86_64-redhat-linux \
#  --prefix=/opt/gcc-4.8.5 \
#  --disable-nls \
#  --enable-bootstrap \
#  --enable-shared \
#  --enable-threads=posix \
#  --with-system-zlib \
#  --enable-__cxa_atexit \
#  --disable-libunwind-exceptions \
#  --enable-gnu-unique-object \
#  --enable-linker-build-id \
#  --with-linker-hash-style=gnu \
#  --enable-languages=c,c++,objc,obj-c++,java,fortran,go,lto \
#  --enable-languages=c,c++,lto \
#  --enable-plugin \
#  --enable-initfini-array \
#  --enable-java-awt=gtk \
#  --with-java-home=/opt/gcc-4.8.5/lib/jvm/java-1.5.0-gcj-1.5.0.0/jre \
#  --enable-libgcj-multifile \
#  --disable-libjava-multilib \
#  --disable-dssi

CFLAGS="-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=4" \
  ../configure --build=x86_64-redhat-linux \
  --prefix=/opt/gcc-4.8.5 \
  --disable-nls \
  --enable-bootstrap \
  --enable-shared \
  --enable-threads=posix \
  --with-system-zlib \
  --enable-__cxa_atexit \
  --disable-libunwind-exceptions \
  --enable-gnu-unique-object \
  --enable-linker-build-id \
  --with-linker-hash-style=gnu \
  --enable-languages=c,c++,lto \
  --enable-plugin \
  --enable-initfini-array \
  --disable-dssi
