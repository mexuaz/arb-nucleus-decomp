cmake_minimum_required(VERSION 3.25)

project(encodings VERSION 0.1 LANGUAGES CXX)

add_library(decoders
    byte_pd_amortized.cc
    byte_pd.cc
    byte.cc
    decoders.h) 

set_target_properties(decoders PROPERTIES
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS OFF
)

target_compile_options(decoders PRIVATE
    -Wall
    -Wextra
    -march=native
    -Wno-unused-parameter
    $<$<CONFIG:Debug>:-O0>
    $<$<CONFIG:Release>:-O3>
)

set(DECODERS_HEADER_INCLUDES
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/../..
    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/parlaylib/include/
)

target_include_directories(decoders 
    PUBLIC ${DECODERS_HEADER_INCLUDES})