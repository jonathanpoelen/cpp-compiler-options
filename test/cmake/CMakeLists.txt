project(test)
cmake_minimum_required(VERSION 3.2)

include(../../output/cmake)
if ("${TEST_PROFILE}" STREQUAL "on")
  jln_init_flags(AUTO_PROFILE on)
elseif ("${TEST_PROFILE}" STREQUAL "off")
  jln_init_flags(AUTO_PROFILE off)
elseif ("${TEST_PROFILE}" STREQUAL "empty")
  jln_init_flags()
elseif ("${TEST_PROFILE}" STREQUAL "on2")
  jln_init_flags(AUTO_PROFILE on SUGGESTIONS on)
else()
  jln_init_flags(SUGGESTIONS on) # SUGGESTIONS default value is on
endif()

jln_flags(CXX_VAR JLN_CXX_FLAGS LINK_VAR JLN_LINK_FLAGS SANITIZERS on)
message(STATUS "cxx: ${JLN_CXX_FLAGS}")
message(STATUS "link: ${JLN_LINK_FLAGS}")

# jln_target_interface(lib_test)
add_compile_options(${JLN_CXX_FLAGS})
# cmake-3.13
# add_link_options(${JLN_LINK_FLAGS})
SET(CMAKE_EXE_LINKER_FLAGS  "${CMAKE_EXE_LINKER_FLAGS} ${JLN_LINK_FLAGS}")

add_library(lib_test INTERFACE)
jln_target_interface(lib_test INTERFACE DEBUG on DISABLE_OTHERS on)

add_executable(test test.cpp)
target_link_libraries(test INTERFACE $<TARGET_PROPERTY:lib_test,LINK_OPTIONS>)
target_link_libraries(test INTERFACE $<TARGET_PROPERTY:lib_test,COMPILE_OPTIONS>)
