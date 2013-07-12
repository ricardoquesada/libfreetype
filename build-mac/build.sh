#!/bin/sh

#
# 64 bit
#
../configure --without-png --without-bzip2 CFLAGS="-arch x86_64"
make clean; make
cp .libs/libfreetype.a libfreetype-x86_64.a


#
# 32 bit
#
../configure --without-png --without-bzip2 CFLAGS="-arch i386"
make clean; make 
cp .libs/libfreetype.a libfreetype-i386.a


# lib
lipo -create -output libfreetype.a libfreetype-i386.a libfreetype-x86_64.a

# print info
lipo -info libfreetype.a
