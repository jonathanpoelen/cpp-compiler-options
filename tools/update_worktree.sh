#!/bin/sh

# mkdir w
# for d in bjam cmake meson premake5 scons ; do git worktree add w/$d ; done

set -e

cd $(realpath $(dirname "$0"))/..

${LUA_BIN:-lua} ./tools/update_worktree.lua

git add output && git commit -m '[output] update' ||:

for d in bjam cmake meson premake5 scons ; do
  echo "> $d"
  cd w/$d
  git commit -am "update $d files" ||:
  cd ../..
done

git push --all
