#!/bin/bash
set -e

# ====== 配置 ======
NDK_VERSION=android-ndk-r27d
DROPBEAR_VERSION=2025.88
API=33

echo "Using Android API Level: $API"

# ====== 下载 Android NDK ======
echo "Downloading Android NDK..."
wget -q https://dl.google.com/android/repository/${NDK_VERSION}-linux.zip
unzip -q ${NDK_VERSION}-linux.zip
export NDK=$PWD/${NDK_VERSION}

# ====== 下载 Dropbear ======
echo "Downloading Dropbear..."
wget -q https://matt.ucc.asn.au/dropbear/releases/dropbear-${DROPBEAR_VERSION}.tar.bz2
tar xf dropbear-${DROPBEAR_VERSION}.tar.bz2
cd dropbear-${DROPBEAR_VERSION}

# ====== 配置 NDK Toolchain ======
export TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/linux-x86_64
export CC="$TOOLCHAIN/bin/aarch64-linux-android${API}-clang"
export CXX="$TOOLCHAIN/bin/aarch64-linux-android${API}-clang++"
export AR="$TOOLCHAIN/bin/llvm-ar"
export RANLIB="$TOOLCHAIN/bin/llvm-ranlib"
export LD="$TOOLCHAIN/bin/ld.lld"
export STRIP="$TOOLCHAIN/bin/llvm-strip"

echo "Compiler: $CC"

export CFLAGS="-DDROPBEAR_SVR_PASSWORD_AUTH=0 -DDROPBEAR_CLIENT_PASSWORD_AUTH=0"

./configure --host=aarch64-linux-android \
            --disable-zlib \
            --enable-static \
            --disable-lastlog \
            --disable-utmp \
            --disable-wtmp

# ====== 编译 ======
echo "Building Dropbear..."
make PROGRAMS="dropbear dropbearkey scp" -j8

# ====== 裁剪 ======
$STRIP dropbear dropbearkey scp

# ====== 输出 ======
cd ..
mkdir -p output
cp dropbear-${DROPBEAR_VERSION}/dropbear output/
cp dropbear-${DROPBEAR_VERSION}/dropbearkey output/
cp dropbear-${DROPBEAR_VERSION}/scp output/

echo "Build complete! Files saved in ./output"
