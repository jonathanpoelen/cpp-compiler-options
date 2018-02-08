#!/bin/sh

set -e

cd "$(dirname "$0")"
mkdir -p output

rm output/*

gen ()
{
  f=generators/$1.lua
  shift
  ./compiler-options.lua $f "$@"
}

# check options
gen options

for g in bjam cmake ; do
  gen $g jln- > output/$g
done

gen compiler | while read comp ; do
  gen compiler $comp warnings pedantic > output/$comp-warnings
  gen compiler $comp warnings=strict pedantic > output/$comp-warnings_strict
  gen compiler $comp glibcxx_debug=allow_broken_abi > output/$comp-glibcxx_debug_broken_abi
  for g in suggest glibcxx_debug debug sanitizers ; do
    gen compiler $comp $g > output/$comp-$g
  done
  cat output/$comp-glibcxx_debug            output/$comp-debug output/$comp-sanitizers > output/$comp-debug_full
  cat output/$comp-glibcxx_debug_broken_abi output/$comp-debug output/$comp-sanitizers > output/$comp-debug_full_broken_abi
done

echo "\n"Empty and removed:
find output/ -size 0 -delete -print
