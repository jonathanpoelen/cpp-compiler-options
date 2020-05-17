#!/bin/sh

# mkdir w
# for d in bjam cmake meson premake5 scons ; do git worktree add w/$d ; done

cd $(realpath $(dirname "$0"))/..

set -e

cp output/c/bjam w/bjam/c.jam
cp output/cpp/bjam w/bjam/cpp.jam

cp output/c/cmake w/cmake/c.cmake
cp output/cpp/cmake w/cmake/cpp.cmake

cp output/c/meson w/meson/c/meson.build
cp output/cpp/meson w/meson/cpp/meson.build
cp output/c/meson_options.txt w/meson/c/
cp output/cpp/meson_options.txt w/meson/cpp/

cp output/c/premake5 w/premake5/c.lua
cp output/cpp/premake5 w/premake5/cpp.lua

cp output/c/scons w/scons/c/SConscript
cp output/cpp/scons w/scons/cpp/SConscript

for d in bjam cmake meson premake5 scons ; do
  echo "> $d"
  cd w/$d
  git commit -am "update $d files" ||:
  cd ../..
done
