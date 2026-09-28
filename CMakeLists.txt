cmake_minimum_required(VERSION 3.22.1)
project("starblast")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include_directories(
    src
    src/audio
    src/input
    src/platform/android
)

add_library(starblast SHARED
    # Platform Layer
    src/platform/android/android_native_app_glue.c
    src/platform/android/main_android.cpp

    # Input Layer
    src/input/virtual_pad.cpp

    # Audio Layer
    src/audio/audio_engine.cpp

)

find_library(log-lib log)
find_library(android-lib android)
find_library(egl-lib EGL)
find_library(gles3-lib GLESv3)
find_library(sles-lib OpenSLES)
find_library(z-lib z)

target_link_libraries(starblast
    ${log-lib}
    ${android-lib}
    ${egl-lib}
    ${gles3-lib}
    ${sles-lib}
    ${z-lib}
)
