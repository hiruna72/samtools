#!/bin/sh
# creating config.h
samtools_version="1.10-14"
htslib_path="../htslib"
# for armeabi-v7a and arm64-v8a cross compiling
toolchain_file="set path to /android-sdk-linux/ndk-bundle/build/cmake/android.toolchain.cmake"

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

touch samtoolmisc.h
echo "#include <sys/resource.h>
#include <sys/time.h>

static inline double realtime(void) {
    struct timeval tp;
    struct timezone tzp;
    gettimeofday(&tp, &tzp);
    return tp.tv_sec + tp.tv_usec * 1e-6;
}

// taken from minimap2/misc
static inline double cputime(void) {
    struct rusage r;
    getrusage(RUSAGE_SELF, &r);
    return r.ru_utime.tv_sec + r.ru_stime.tv_sec +
           1e-6 * (r.ru_utime.tv_usec + r.ru_stime.tv_usec);
}

//taken from minimap2
static inline long peakrss(void)
{
    struct rusage r;
    getrusage(RUSAGE_SELF, &r);
#ifdef __linux__
    return r.ru_maxrss * 1024;
#else
    return r.ru_maxrss;
#endif
}" > samtoolmisc.h


# to create a samtools library
cp bamtk.c tempbamtk
# sed -i 's/int main(int argc/int init_samtools(int argc/g' bamtk.c
sed -i ':a;N;$!ba;s/int main(int argc, char \*argv\[\])\n{/int init_samtools(int argc, char *argv[])\n{\n\tdouble realtime0 = realtime();/g' bamtk.c
sed -i 's+return ret;+fprintf("[%s] Real time: %.3f sec; CPU time: %.3f sec; Peak RAM: %.3f GB\\n\\n",\n\t\t__func__, realtime() - realtime0, cputime(),peakrss() / 1024.0 / 1024.0 / 1024.0);\n\treturn ret;+g' bamtk.c
sed -i 's/#include "version.h"/#include "version.h"\n#include "samtoolmisc.h"/g' bamtk.c

touch interface.h
echo "int init_samtools(int argc, char *argv[]);" > interface.h

mkdir -p build
rm -rf build
mkdir build
cd build

# for architecture x86
 # cmake .. -DDEPLOY_PLATFORM=x86
 # make -j 8

# # for architecture armeabi-V7a
# cmake .. -G Ninja -DCMAKE_TOOLCHAIN_FILE:STRING=$toolchain_file -DANDROID_PLATFORM=android-21 -DDEPLOY_PLATFORM:STRING="armeabi-v7a" -DANDROID_ABI="armeabi-v7a"

# # for architecture arm66-v8a
cmake .. -G Ninja -DCMAKE_TOOLCHAIN_FILE:STRING=$toolchain_file -DANDROID_PLATFORM=android-21 -DDEPLOY_PLATFORM:STRING="arm64-v8a" -DANDROID_ABI="arm64-v8a"

ninja
cd -
mv tempbamtk bamtk.c