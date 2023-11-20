cmake_minimum_required(VERSION 3.25)

project(NucleusDecomposition VERSION 0.1 LANGUAGES CXX)

# ======================== CommonTable ========================
add_library(CommonTable commontable.cc commontable.h)

set_target_properties(CommonTable PROPERTIES
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS OFF
)

target_compile_options(CommonTable PRIVATE
    -Wall
    -Wextra
)

set(HEADER_INCLUDES
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/../
    ${CMAKE_CURRENT_SOURCE_DIR}/../..
    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/PAM/include/
    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/parlaylib/include/
)

target_include_directories(CommonTable 
    PUBLIC ${HEADER_INCLUDES})

# ======================== NucleusDecomposition ========================

add_executable(NucleusDecomposition 
    NucleusDecomposition.cc
    NucleusDecomposition.h
    TwoThreeNucleusDecomposition.h
    NucleusDecomposition_common.h
    )

set_target_properties(NucleusDecomposition PROPERTIES
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS OFF
)

target_compile_options(NucleusDecomposition PRIVATE
    -Wall
    -Wextra
    -march=native
    -Wno-unused-parameter
    $<$<CONFIG:Debug>:-O0>
    $<$<CONFIG:Release>:-O3>
)

target_include_directories(NucleusDecomposition 
    PUBLIC ${HEADER_INCLUDES})

target_link_libraries(NucleusDecomposition PRIVATE
    CommonTable
    gbbs
    decoders
)

find_package(Threads REQUIRED)
target_link_libraries(NucleusDecomposition PRIVATE Threads::Threads)
