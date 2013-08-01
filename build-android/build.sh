#!/bin/bash
#
# This file was copied from libffmpeg library.
#

if [ "$NDK_ROOT" = "" ]; then
	echo NDK variable not set, exiting
	echo "Use: export NDK_ROOT=/your/path/to/android-ndk"
	exit 1
fi

OS=`uname -s | tr '[A-Z]' '[a-z]'`
cpus=$(sysctl hw.ncpu | awk '{print $2}')

function build_freetype2
{
	PLATFORM=$NDK_ROOT/platforms/$PLATFORM_VERSION/arch-$ARCH/
	export PATH=${PATH}:$PREBUILT/bin/
	CROSS_COMPILE=$PREBUILT/bin/$EABIARCH-
	CFLAGS=$OPTIMIZE_CFLAGS
#CFLAGS=" -I$ARM_INC -fpic -DANDROID -fpic -mthumb-interwork -ffunction-sections -funwind-tables -fstack-protector -fno-short-enums -D__ARM_ARCH_5__ -D__ARM_ARCH_5T__ -D__ARM_ARCH_5E__ -D__ARM_ARCH_5TE__  -Wno-psabi -march=armv5te -mtune=xscale -msoft-float -mthumb -Os -fomit-frame-pointer -fno-strict-aliasing -finline-limit=64 -DANDROID  -Wa,--noexecstack -MMD -MP "
	export CPPFLAGS="$CFLAGS"
	export CFLAGS="$CFLAGS"
	export CXXFLAGS="$CFLAGS"
	export CXX="${CROSS_COMPILE}g++ --sysroot=$PLATFORM"
	export CC="${CROSS_COMPILE}gcc --sysroot=$PLATFORM"
	export NM="${CROSS_COMPILE}nm"
	export STRIP="${CROSS_COMPILE}strip"
	export RANLIB="${CROSS_COMPILE}ranlib"
	export AR="${CROSS_COMPILE}ar"
	export LDFLAGS="-Wl,-rpath-link=$PLATFORM/usr/lib -L$PLATFORM/usr/lib  -nostdlib -lc -lm -ldl -llog"

	export PKG_CONFIG_LIBDIR=$(pwd)/$PREFIX/lib/pkgconfig/
	export PKG_CONFIG_PATH=$(pwd)/$PREFIX/lib/pkgconfig/
	../configure \
	    --prefix=$(pwd)/$PREFIX \
	    --host=$ARCH-linux \
	    --disable-dependency-tracking \
	    --disable-shared \
	    --enable-static \
	    --with-pic \
	    $ADDITIONAL_CONFIGURE_FLAG \
	    || exit 1

	make clean || exit 1
	make -j$cpus install # || exit 1
	make clean || exit 1
}

echo "---------------------------- arm v5 ------------------------------------"

#arm v5
EABIARCH=arm-linux-androideabi
ARCH=arm
CPU=armv5
OPTIMIZE_CFLAGS="-marm -march=$CPU"
PREFIX=./dist/armeabi
ADDITIONAL_CONFIGURE_FLAG=
PREBUILT=$NDK_ROOT/toolchains/arm-linux-androideabi-4.4.3/prebuilt/$OS-x86
PLATFORM_VERSION=android-5
build_freetype2

echo "---------------------------- x86 ------------------------------------"

#x86
EABIARCH=i686-linux-android
ARCH=x86
OPTIMIZE_CFLAGS="-m32"
PREFIX=./dist/x86
ADDITIONAL_CONFIGURE_FLAG=--disable-asm
PREBUILT=$NDK_ROOT/toolchains/x86-4.4.3/prebuilt/$OS-x86
PLATFORM_VERSION=android-9
build_freetype2


# #mips
# EABIARCH=mipsel-linux-android
# ARCH=mips
# OPTIMIZE_CFLAGS="-EL -march=mips32 -mips32 -mhard-float"
# PREFIX=./dist/mips
# ADDITIONAL_CONFIGURE_FLAG="--disable-mips32r2"
# PREBUILT=$NDK_ROOT/toolchains/mipsel-linux-android-4.4.3/prebuilt/$OS-x86
# PLATFORM_VERSION=android-9
# build_freetype2

#arm v7vfpv3
EABIARCH=arm-linux-androideabi
ARCH=arm
CPU=armv7-a
OPTIMIZE_CFLAGS="-mfloat-abi=softfp -mfpu=vfpv3-d16 -marm -march=$CPU "
PREFIX=./dist/armeabi-v7a
OUT_LIBRARY=$PREFIX/libffmpeg.so
ADDITIONAL_CONFIGURE_FLAG=
PREBUILT=$NDK_ROOT/toolchains/arm-linux-androideabi-4.4.3/prebuilt/$OS-x86
PLATFORM_VERSION=android-5
build_freetype2

# #arm v7 + neon (neon also include vfpv3-32)
# EABIARCH=arm-linux-androideabi
# ARCH=arm
# CPU=armv7-a
# OPTIMIZE_CFLAGS="-mfloat-abi=softfp -mfpu=neon -marm -march=$CPU -mtune=cortex-a8 -mthumb -D__thumb__ "
# PREFIX=./dist/armeabi-v7a-neon
# OUT_LIBRARY=../ffmpeg-build/armeabi-v7a/libffmpeg-neon.so
# ADDITIONAL_CONFIGURE_FLAG=--enable-neon
# PREBUILT=$NDK_ROOT/toolchains/arm-linux-androideabi-4.4.3/prebuilt/$OS-x86
# PLATFORM_VERSION=android-9
# build_freetype2

