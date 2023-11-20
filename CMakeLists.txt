cmake_minimum_required(VERSION 3.25)

project(arb-nucleus VERSION 0.1 LANGUAGES CXX)

#============== gbbs ==============

add_library(gbbs gbbs/graph_io.cc gbbs/io.cc)

set_target_properties(gbbs PROPERTIES
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS OFF
)

target_compile_options(gbbs PRIVATE
    -Wall
    -Wextra
    -march=native
    $<$<CONFIG:Debug>:-O0>
    $<$<CONFIG:Release>:-O3>
)

set(GBBS_HEADER_INCLUDES
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/gbbs/
    ${CMAKE_CURRENT_SOURCE_DIR}/external/parlaylib/include/
)

target_include_directories(gbbs PUBLIC ${GBBS_HEADER_INCLUDES})

#============== projects ==============
add_subdirectory(gbbs/encodings)
add_subdirectory(benchmarks/NucleusDecomposition)
