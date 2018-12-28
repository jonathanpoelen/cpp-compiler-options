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
TMPDIR=${TMPDIR:-/tmp}

if [ -z "$1" ] || [ "$1" = premake5 ]; then
  cd premake5
  test_success 'premake5 | grep Wlogical-op'
  test_success 'premake5 --jln-warnings=off | grep -- -w'
  test_success 'premake5 | grep fsanitize'
  test_failure 'premake5 | grep GLIB'
  test_failure 'premake5 | grep Weverything'
  test_success 'premake5 --cc=gcc | grep Wlogical-op'
  test_success 'premake5 --cc=clang | grep Weverything'
  test_success 'premake5 --cc=gcc --jln-compiler=clang | grep Weverything'
  test_failure 'premake5 --jln-compiler-version=4 | grep Wclass-memaccess'
  test_success 'premake5 --jln-compiler-version=8 | grep Wclass-memaccess'
  test_failure 'premake5 | grep lto'
  test_success 'premake5 --jln-lto=on | grep lto'
fi

if [ -z "$1" ] || [ "$1" = cmake ]; then
  mkdir -p "$TMPDIR"/compgencmake
  cd "$TMPDIR"/compgencmake
  rm -rf CMakeCache.txt CMakeFiles/ cmake_install.cmake Makefile test
  test_success "cmake '$d/cmake' | grep Wlogical-op"
  test_success "cmake '$d/cmake' -DJLN_WARNINGS=off | grep -- -w"
  test_success "cmake '$d/cmake' | grep fsanitize"
  test_failure "cmake '$d/cmake' | grep GLIB"
  test_failure "cmake '$d/cmake' | grep Weverything"
  test_success "cmake '$d/cmake' -DCMAKE_CXX_COMPILER=gcc | grep Wlogical-op"
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
  cd "$TMPDIR"/compgenmeson
  awk 'BEGIN{f="meson_options.txt"}
    /meson.build/{
      f="meson.build"
      print "project('\''test'\'', '\''cpp'\'')">f
    }
    {print > f}' "$d"/../output/meson
  rm -rf b; test_success 'meson b | grep -m1 "Wall.*YES"'
  rm -rf b; test_success 'meson b -Djln_warnings=off | grep -- -w'
  rm -rf b; test_failure 'meson b -Djln_warnings=off  | grep "Wall\|sanitizer"'
  rm -rf b; test_success 'meson b -Djln_sanitizers=on | grep -m1 "sanitize.*YES"'
fi
