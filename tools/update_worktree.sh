#!/bin/sh

# mkdir w
# for d in bjam cmake meson premake5 scons xmake ; do git worktree add w/$d ; done
# empty branch:
# git switch --orphan $d

set -e

cd $(realpath $(dirname "$0"))/..

${LUA_BIN:-lua} ./tools/update_worktree.lua

git add output && git commit -m '[output] update' ||:

for d in bjam cmake meson premake5 scons xmake ; do
  echo "> $d"
  cd w/$d
  git commit -am "update $d files" ||:
  cd ../..
done

git push --all
