cmake_minimum_required(VERSION 3.22.1)
project(imgui_java_android LANGUAGES C CXX)

if(NOT DEFINED IMGUI_JNI_DIR OR NOT EXISTS "${IMGUI_JNI_DIR}")
    message(FATAL_ERROR "IMGUI_JNI_DIR must point to the generated imgui-java JNI source directory")
endif()

file(GLOB_RECURSE IMGUI_JNI_SOURCES CONFIGURE_DEPENDS "${IMGUI_JNI_DIR}/*.cpp")
if(NOT IMGUI_JNI_SOURCES)
    message(FATAL_ERROR "No JNI C++ sources found in ${IMGUI_JNI_DIR}")
endif()

add_library(imgui-java64 SHARED ${IMGUI_JNI_SOURCES})
target_include_directories(imgui-java64 PRIVATE "${IMGUI_JNI_DIR}")
target_compile_features(imgui-java64 PRIVATE cxx_std_17)
target_compile_options(imgui-java64 PRIVATE -fvisibility=hidden)
target_link_libraries(imgui-java64 PRIVATE log)
set_target_properties(imgui-java64 PROPERTIES
    OUTPUT_NAME "imgui-java64"
    CXX_VISIBILITY_PRESET hidden
    VISIBILITY_INLINES_HIDDEN YES
)
