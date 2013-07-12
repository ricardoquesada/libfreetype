#!/bin/sh


MIN_IOS_VERSION=4.3

SDK_PATH=`xcrun -sdk iphoneos --show-sdk-path`

CC=`xcrun -sdk iphoneos -find clang`
LD=`xcrun -sdk iphoneos -find ld`
AR=`xcrun -sdk iphoneos -find ar`
LIPO="xcrun -sdk iphoneos lipo"
cpus=$(sysctl hw.ncpu | awk '{print $2}')

#
# 32 bit
#
../configure --without-png --without-bzip2 CFLAGS="-arch i386"
make clean
make -j$cpus
cp .libs/libfreetype.a libfreetype-i386.a

#
# armv7
#
../configure --host=arm-apple-darwin --enable-static=yes --enable-shared=no --without-png --without-bzip2 \
	CPPFLAGS="-arch armv7 -fpascal-strings -Os -fmessage-length=0 -fvisibility=hidden -miphoneos-version-min=$MIN_IOS_VERSION -I$SDK_PATH/usr/include/libxml2 -isysroot $SDK_PATH" \
	CFLAGS="-arch armv7 -fpascal-strings -Os -fmessage-length=0 -fvisibility=hidden -miphoneos-version-min=$MIN_IOS_VERSION -I$SDK_PATH/usr/include/libxml2 -isysroot $SDK_PATH" \
	LDFLAGS="-arch armv7 -isysroot $SDK_PATH -miphoneos-version-min=$MIN_IOS_VERSION"

make clean
make -j$cpus
cp .libs/libfreetype.a libfreetype-armv7.a

#
# armv7s
#
../configure --host=arm-apple-darwin --enable-static=yes --enable-shared=no --without-png --without-bzip2 \
	CPPFLAGS="-arch armv7s -fpascal-strings -Os -fmessage-length=0 -fvisibility=hidden -miphoneos-version-min=$MIN_IOS_VERSION -I$SDK_PATH/usr/include/libxml2 -isysroot $SDK_PATH" \
	CFLAGS="-arch armv7s -fpascal-strings -Os -fmessage-length=0 -fvisibility=hidden -miphoneos-version-min=$MIN_IOS_VERSION -I$SDK_PATH/usr/include/libxml2 -isysroot $SDK_PATH" \
	LDFLAGS="-arch armv7s -isysroot $SDK_PATH -miphoneos-version-min=$MIN_IOS_VERSION"

make clean
make -j$cpus
cp .libs/libfreetype.a libfreetype-armv7s.a
#
#
# lib
lipo -create -output libfreetype.a libfreetype-i386.a libfreetype-armv7.a libfreetype-armv7s.a

# print info
lipo -info libfreetype.a
