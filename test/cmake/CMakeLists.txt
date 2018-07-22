project(test)
cmake_minimum_required(VERSION 3.2)

include(../../output/cmake)
jln_init_flags(SUGGEST on) # SUGGEST default value is on

jln_flags(CXX_VAR JLN_CXX_FLAGS LINK_VAR JLN_LINK_FLAGS SANITIZERS on)
message(STATUS "cxx: ${JLN_CXX_FLAGS}")
message(STATUS "link: ${JLN_LINK_FLAGS}")

add_library(lib_test INTERFACE)
# jln_target_interface(lib_test)
add_definitions(lib_test)
link_libraries(lib_test)

add_executable(test test.cpp)
#target_link_libraries(test lib_test)
