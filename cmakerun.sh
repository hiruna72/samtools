#!/bin/sh
# creating config.h
samtools_version="1.10-14"
htslib_path="../htslib"
# for armeabi-v7a and arm64-v8a cross compiling
toolchain_file=" set path to /android-sdk-linux/ndk-bundle/build/cmake/android.toolchain.cmake"

# terminate script
die(){
	echo "set htslib_path"
	exit 1
}

autoheader
autoconf -Wno-syntax
chmod +x ./configure
./configure ./configure --without-curses --with-htslib=$htslib_path || die

touch version.h
echo "#define SAMTOOLS_VERSION \"$samtools_version\"" > version.h

# to create a samtools library
sed -i 's/int main(int argc/int init_samtools(int argc/g' bamtk.c
touch interface.h
echo "int init_samtools(int argc, char *argv[]);" > interface.h

mkdir -p build
rm -rf build
mkdir build
cd build

# for architecture x86
 cmake .. -DDEPLOY_PLATFORM=x86
 make -j 8

# # for architecture armeabi-V7a
#cmake .. -G Ninja -DCMAKE_TOOLCHAIN_FILE:STRING=$toolchain_file -DANDROID_PLATFORM=android-21 -DDEPLOY_PLATFORM:STRING="armeabi-v7a" -DANDROID_ABI="armeabi-v7a"
#ninja

# # for architecture arm66-v8a
# cmake .. -G Ninja -DCMAKE_TOOLCHAIN_FILE:STRING=$toolchain_file -DANDROID_PLATFORM=android-21 -DDEPLOY_PLATFORM:STRING="arm64-v8a" -DANDROID_ABI="arm64-v8a"
# ninja