#!/bin/sh

# mkdir w
# for d in gh-pages bjam cmake meson premake5 scons xmake ; do git worktree add w/$d ; done
# empty branch:
# git switch --orphan $d

set -e

cd $(realpath $(dirname "$0"))/..

${LUA_BIN:-lua} ./tools/update_worktree.lua
${LUA_BIN:-lua} ./compiler-options.lua generators/list_options.lua --html --categorized --profile > w/gh-pages/index.html

git add output && git commit -m '[output] update' ||:

for d in gh-pages bjam cmake meson premake5 scons xmake ; do
  echo "> $d"
  cd w/$d
  git commit -am "update $d files" ||:
  cd ../..
done

git push --all
