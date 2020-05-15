#!/bin/bash

if [ "$1" = '-x' ]; then
  set -x
  shift
fi

set +o pipefail

test_success()
{
  echo -n "test_success: $@  "
  eval "$@ >/dev/null ; local status=(\${PIPESTATUS[@]})"
  if [ ${status[0]} -ne 0 ]; then
    echo -e "\e[31mbuild command error\e[0m"
    exit 1
  elif [ ${status[1]} -ne 0 ]; then
    echo -e "\e[31mfailure\e[0m"
    exit 1
  fi
  echo -e "\e[32mok\e[0m"
}

test_failure()
{
  echo -n "test_failure: $@  "
  eval "$@ >/dev/null ; local status=(\${PIPESTATUS[@]})"
  if [ ${status[0]} -ne 0 ]; then
    echo -e "\e[31mbuild command error\e[0m"
    exit 1
  elif [ ${status[1]} -eq 0 ]; then
    echo -e "\e[31mfailure\e[0m"
    exit 1
  fi
  echo -e "\e[32mok\e[0m"
}

cd "$(dirname "$0")"
d=$PWD
TMPDIR=${TMPDIR:-/tmp}

if [ -z "$1" ] || [ "$1" = premake5 ]; then
  cd premake5
  test_success 'premake5 --version | grep Wlogical-op'
  test_success 'premake5 --version --jln-warnings=off | grep -- -w'
  test_success 'premake5 --version | grep fsanitize'
  test_failure 'premake5 --version | grep GLIB'
  test_failure 'premake5 --version | grep Weverything'
  test_success 'premake5 --version --cc=gcc | grep Wlogical-op'
  test_success 'premake5 --version --cc=clang | grep Weverything'
  test_success 'premake5 --version --cc=gcc --jln-compiler=clang | grep Weverything'
  test_failure 'premake5 --version --jln-compiler-version=4 | grep Wclass-memaccess'
  test_success 'premake5 --version --jln-compiler-version=8 | grep Wclass-memaccess'
  test_failure 'premake5 --version | grep lto'
  test_success 'premake5 --version --jln-lto=on | grep lto'
fi

if [ -z "$1" ] || [ "$1" = cmake ]; then
  mkdir -p "$TMPDIR"/compgencmake
  cd "$TMPDIR"/compgencmake
  rm -rf CMakeCache.txt CMakeFiles/ cmake_install.cmake Makefile test
  test_success "cmake '$d/cmake' -DJLN_AUTO_PROFILE=on | grep _GLIBCXX_ASSERTIONS"
  test_success "cmake '$d/cmake' | grep _GLIBCXX_ASSERTIONS"
  rm CMakeCache.txt
  test_success "cmake '$d/cmake' -DTEST_PROFILE=on2 | grep _GLIBCXX_ASSERTIONS"
  test_success "cmake '$d/cmake' -DTEST_PROFILE=on2 | grep suggest"
  rm CMakeCache.txt
  test_failure "cmake '$d/cmake' -DTEST_PROFILE=off | grep _GLIBCXX_ASSERTIONS"
  rm CMakeCache.txt
  test_success "cmake '$d/cmake' | grep Wlogical-op"
  test_success "cmake '$d/cmake' | grep suggest"
  test_failure "cmake '$d/cmake' | grep GLIB"
  test_success "cmake '$d/cmake' -DJLN_WARNINGS=off | grep -- -w"
  test_success "cmake '$d/cmake' | grep fsanitize"
  test_failure "cmake '$d/cmake' | grep GLIB"
  test_failure "cmake '$d/cmake' | grep Weverything"
  rm CMakeCache.txt
  test_success "cmake '$d/cmake' -DCMAKE_CXX_COMPILER=gcc | grep Wlogical-op"
  rm CMakeCache.txt
  test_success "cmake '$d/cmake' -DCMAKE_CXX_COMPILER=clang++ | grep Weverything"
  test_failure "cmake '$d/cmake' | grep lto"
  test_success "cmake '$d/cmake' -DJLN_LTO=on | grep lto"
fi

if [ -z "$1" ] || [ "$1" = bjam ]; then
  cd "$d/bjam"
  test_success 'bjam -n --build-dir="$TMPDIR"/compgenbjam | grep Wlogical-op'
  test_success 'bjam -n --build-dir="$TMPDIR"/compgenbjam jln-warnings=off | grep -- -w'
  test_success 'bjam -n --build-dir="$TMPDIR"/compgenbjam | grep fsanitize'
  test_failure 'bjam -n --build-dir="$TMPDIR"/compgenbjam | grep GLIB'
  test_failure 'bjam -n --build-dir="$TMPDIR"/compgenbjam | grep Weverything'
  test_success 'bjam -n --build-dir="$TMPDIR"/compgenbjam toolset=gcc | grep Wlogical-op'
  test_success 'bjam -n --build-dir="$TMPDIR"/compgenbjam toolset=clang | grep Weverything'
  test_failure 'bjam -n --build-dir="$TMPDIR"/compgenbjam | grep lto'
  test_success 'bjam -n --build-dir="$TMPDIR"/compgenbjam jln-lto=on | grep lto'
fi

if [ -z "$1" ] || [ "$1" = meson ]; then
  mkdir -p "$TMPDIR"/compgenmeson
  cp "$d"/../output/cpp/meson_options.txt "$TMPDIR"/compgenmeson
  sed 1i"project('test', 'cpp')" "$d"/../output/cpp/meson > "$TMPDIR"/compgenmeson/meson.build
  cd "$TMPDIR"/compgenmeson
  rm -rf b; test_success 'meson b >/dev/null ; meson configure b | grep -Em1 "^  jln_warnings +on"'
  rm -rf b; test_success 'meson b -Djln_warnings=off >/dev/null ; meson configure b | grep -Em1 "^  jln_warnings +off"'
  rm -rf b; test_success 'meson b >/dev/null ; meson configure b | grep -Em1 "^  jln_sanitizers +default"'
  rm -rf b; test_success 'meson b -Djln_sanitizers=on >/dev/null ; meson configure b | grep -Em1 "^  jln_sanitizers +on"'
fi

if [ -z "$1" ] || [ "$1" = scons ]; then
  mkdir -p "$TMPDIR"/compgenscons
  cp "$d"/scons/SConstruct "$TMPDIR"/compgenscons/
  cp "$d"/../output/cpp/scons "$TMPDIR"/compgenscons/jln_options.py
  cd "$TMPDIR"/compgenscons
  test_success 'scons -Q | grep Wall'
  test_failure 'scons -Q jln_warnings=default | grep Wall'
  test_success 'scons -Q | grep sanitize'
  test_failure 'scons -Q | grep -- -g'
  test_success 'scons -Q jln_debug=on | grep -- -g'
fi
