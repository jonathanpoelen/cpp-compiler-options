project(test)
cmake_minimum_required(VERSION 2.8)

set(JLN_WARNINGS "on" CACHE STRING "")
include(../../output/cmake)

message(STATUS "cxx: ${JLN_CXX_FLAGS}")
message(STATUS "link: ${JLN_LINK_FLAGS}")

add_definitions(${JLN_CXX_FLAGS})
link_libraries(${JLN_LINK_FLAGS})

add_executable(test test.cpp)
