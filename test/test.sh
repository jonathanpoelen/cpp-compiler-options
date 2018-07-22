#!/bin/bash

test_success()
{
  echo -n "test_success: $@  "
  eval "$@ >/dev/null" || {
    echo -e "\e[31mfailure\e[0m"
    exit 1
  }
  echo -e "\e[32mok\e[0m"
}

test_failure()
{
  echo -n "test_failure: $@  "
  eval "$@ >/dev/null" && {
    echo -e "\e[31mfailure\e[0m"
    exit 1
  }
  echo -e "\e[32mok\e[0m"
}

cd "$(dirname "$0")"
d=$PWD

if [ -z "$1" ] || [ "$1" = premake5 ]; then
  cd premake5
  test_success 'premake5 | grep Wlogical-op'
  test_failure 'premake5 | grep Weverything'
  test_success 'premake5 --cc=gcc | grep Wlogical-op'
  test_success 'premake5 --cc=clang | grep Weverything'
  test_failure 'premake5 | grep lto'
  test_success 'premake5 --jln-lto=on | grep lto'
fi

if [ -z "$1" ] || [ "$1" = cmake ]; then
  mkdir -p /tmp/compgencmake
  cd /tmp/compgencmake
  rm -rf CMakeCache.txt CMakeFiles/ cmake_install.cmake Makefile test
  test_success "cmake '$d/cmake' | grep Wlogical-op"
  test_failure "cmake '$d/cmake' | grep Weverything"
  test_success "cmake '$d/cmake' -DCMAKE_CXX_COMPILER=gcc | grep Wlogical-op"
  test_success "cmake '$d/cmake' -DCMAKE_CXX_COMPILER=clang++ | grep Weverything"
  test_failure "cmake '$d/cmake' | grep lto"
  test_success "cmake '$d/cmake' -DJLN_LTO=on | grep lto"
fi

if [ -z "$1" ] || [ "$1" = bjam ]; then
  cd "$d/bjam"
  test_success 'bjam -n --build-dir=/tmp/compgenbjam | grep Wlogical-op'
  test_failure 'bjam -n --build-dir=/tmp/compgenbjam | grep Weverything'
  test_success 'bjam -n --build-dir=/tmp/compgenbjam toolset=gcc | grep Wlogical-op'
  test_success 'bjam -n --build-dir=/tmp/compgenbjam toolset=clang | grep Weverything'
  test_failure 'bjam -n --build-dir=/tmp/compgenbjam | grep lto'
  test_success 'bjam -n --build-dir=/tmp/compgenbjam jln-lto=on | grep lto'
fi
