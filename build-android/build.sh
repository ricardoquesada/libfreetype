#!/bin/bash
#
# build_android.sh
# Copyright (c) 2012 Jacek Marchwicki
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if [ "$NDK" = "" ]; then
	echo NDK variable not set, exiting
	echo "Use: export NDK=/your/path/to/android-ndk"
	exit 1
fi

OS=`uname -s | tr '[A-Z]' '[a-z]'`

function build_freetype2
{
	PLATFORM=$NDK/platforms/$PLATFORM_VERSION/arch-$ARCH/
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
	make -j4 install # || exit 1
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
SONAME=libffmpeg.so
PREBUILT=$NDK/toolchains/arm-linux-androideabi-4.4.3/prebuilt/$OS-x86
PLATFORM_VERSION=android-5
build_freetype2

echo "---------------------------- x86 ------------------------------------"

#x86
EABIARCH=i686-linux-android
ARCH=x86
OPTIMIZE_CFLAGS="-m32"
PREFIX=./dist/x86
ADDITIONAL_CONFIGURE_FLAG=--disable-asm
SONAME=libffmpeg.so
PREBUILT=$NDK/toolchains/x86-4.4.3/prebuilt/$OS-x86
PLATFORM_VERSION=android-9
build_freetype2


# #mips
# EABIARCH=mipsel-linux-android
# ARCH=mips
# OPTIMIZE_CFLAGS="-EL -march=mips32 -mips32 -mhard-float"
# PREFIX=./dist/mips
# ADDITIONAL_CONFIGURE_FLAG="--disable-mips32r2"
# SONAME=libffmpeg.so
# PREBUILT=$NDK/toolchains/mipsel-linux-android-4.4.3/prebuilt/$OS-x86
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
SONAME=libffmpeg.so
PREBUILT=$NDK/toolchains/arm-linux-androideabi-4.4.3/prebuilt/$OS-x86
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
# SONAME=libffmpeg-neon.so
# PREBUILT=$NDK/toolchains/arm-linux-androideabi-4.4.3/prebuilt/$OS-x86
# PLATFORM_VERSION=android-9
# build_freetype2

