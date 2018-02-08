#!/bin/sh

set -e

cd "$(dirname "$0")"
mkdir -p output

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
  gen compiler $comp warnings=strict pedantic > output/$comp-warnings-strict
  for g in suggest glibcxx_debug debug sanitizers ; do
    gen compiler $comp $g > output/$comp-$g
  done
  cat output/$comp-glibcxx_debug output/$comp-debug output/$comp-sanitizers > output/$comp-debug-full
done
