# Disable in-source builds to prevent source tree corruption.
if(" ${CMAKE_SOURCE_DIR}" STREQUAL " ${CMAKE_BINARY_DIR}")
    message(FATAL_ERROR "FATAL: In-source builds are not allowed.
       You should create a separate directory for build files.")
endif()

# choose the architecture
set(DEPLOY_PLATFORM "unknown" CACHE STRING "choose the instruction set architecture")
set_property(CACHE DEPLOY_PLATFORM PROPERTY STRINGS unknown x86 arm64-v8a armeabi-v7a)
IF (${DEPLOY_PLATFORM} STREQUAL "unknown")
    message(FATAL_ERROR "choose the DEPLOY_PLATFORM")
    return() # This is to stop proceeding further and to stop opencv getting set to the default ANDROID_ABI
ENDIF()


# Set minimum cmake version + cmake settings
cmake_minimum_required (VERSION 3.9)

# Specify the project, and set the use of c++ and c
project(SAMTOOLS LANGUAGES CXX C)

message(STATUS "Configure Samtools")

# Set project name
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g -fPIC -Wall -O2")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g -Wall -O2 -std=c++11")

include_directories(${PROJECT_SOURCE_DIR})
include_directories(${PROJECT_SOURCE_DIR}/3rdparty/include)
include_directories(${PROJECT_SOURCE_DIR}/lz4)

set (bam bam.c)
set (bam2bcf bam2bcf.c)
set (bam2bcf_indel bam2bcf_indel.c)
set (bam2depth bam2depth.c)
set (coverage coverage.c)
set (bam_addrprg bam_addrprg.c)
set (bam_aux bam_aux.c)
set (bam_cat bam_cat.c)
set (bam_color bam_color.c)
set (bam_fastq bam_fastq.c)
set (bam_index bam_index.c)
set (bam_lpileup bam_lpileup.c)
set (bam_mate bam_mate.c)
set (bam_md bam_md.c)
set (bam_plbuf bam_plbuf.c)
set (bam_plcmd bam_plcmd.c)
set (bam_quickcheck bam_quickcheck.c)
set (bam_reheader bam_reheader.c)
set (bam_rmdup bam_rmdup.c)
set (bam_rmdupse bam_rmdupse.c)
set (bam_sort bam_sort.c)
set (bam_split bam_split.c)
set (bam_stat bam_stat.c)
set (bam_tview bam_tview.c)
set (bam_tview_curses bam_tview_curses.c)
set (bam_tview_html bam_tview_html.c)
set (bam_flags bam_flags.c)
set (bamshuf bamshuf.c)
set (bamtk bamtk.c)
set (bedcov bedcov.c)
set (bedidx bedidx.c)
set (cut_target cut_target.c)
set (dict dict.c)
set (faidx faidx.c)
set (padding padding.c)
set (phase phase.c)
set (sam sam.c)
set (sam_opts sam_opts.c)
set (sam_utils sam_utils.c)
set (sam_view sam_view.c)
set (sample sample.c)
set (stats_isize stats_isize.c)
set (stats stats.c)
set (bam_markdup bam_markdup.c)
set (tmp_file tmp_file.c)
set (LZ4 lz4/lz4.c)

# Build a shared lib
add_library(samtoolshared SHARED ${bam} ${bam2bcf} ${bam2bcf_indel} ${bam2depth} ${coverage} ${bam_addrprg} ${bam_aux} ${bam_cat} ${bam_color} ${bam_fastq} ${bam_index} ${bam_lpileup}
        ${bam_mate} ${bam_md} ${bam_plbuf} ${bam_plcmd} ${bam_quickcheck} ${bam_reheader} ${bam_rmdup} ${bam_rmdupse} ${bam_sort} ${bam_split} ${bam_stat} ${bam_tview}
        ${bam_tview_curses} ${bam_tview_html} ${bam_flags} ${bamshuf} ${bamtk} ${bedcov} ${bedidx} ${cut_target} ${dict} ${faidx} ${padding} ${phase}
        ${sam} ${sam_opts} ${sam_utils} ${sam_view} ${sample} ${stats_isize} ${stats} ${bam_markdup} ${tmp_file} ${LZ4})

#add_library(samtoolshared SHARED ${bam})
set (htslib_shared "${PROJECT_SOURCE_DIR}/3rdparty/${DEPLOY_PLATFORM}/libhts.so")

#add_library(hts SHARED IMPORTED)
#set_target_properties(hts PROPERTIES IMPORTED_LOCATION ${PROJECT_SOURCE_DIR}/3rdparty/${DEPLOY_PLATFORM}/libhts.so)


# link with dependencies
IF (${DEPLOY_PLATFORM} STREQUAL "x86")
    target_link_libraries(samtoolshared ${htslib_static2} -lz -ldl -lm -lpthread)
ELSE()
    target_link_libraries(samtoolshared ${htslib_shared} -lz -ldl -lm)
ENDIF()