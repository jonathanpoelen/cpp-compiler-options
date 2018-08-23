#!/bin/sh

OUTPUT_DIR=output/

set -e

cd "$(dirname "$0")"
mkdir -p "$OUTPUT_DIR"
rm -f "$OUTPUT_DIR"/*

gen ()
{
  f=generators/$1.lua
  shift
  $LUA_BIN ./compiler-options.lua $f "$@"
}

# check options
gen options

for g in bjam cmake premake5 ; do
  gen $g jln- > "$OUTPUT_DIR"/$g
done

gen compiler | while read comp ; do
  gen compiler $comp warnings pedantic > "$OUTPUT_DIR"/$comp-warnings
  gen compiler $comp warnings=strict pedantic > "$OUTPUT_DIR"/$comp-warnings_strict
  gen compiler $comp libcxx_debug=allow_broken_abi > "$OUTPUT_DIR"/$comp-libcxx_debug_broken_abi
  gen compiler $comp sanitizers_extra=pointer > "$OUTPUT_DIR"/$comp-sanitizers-pointer
  for g in suggests libcxx_debug debug sanitizers report_template ; do
    gen compiler $comp $g > "$OUTPUT_DIR"/$comp-$g
  done
  cat "$OUTPUT_DIR"/$comp-libcxx_debug            "$OUTPUT_DIR"/$comp-debug output/$comp-sanitizers > "$OUTPUT_DIR"/$comp-debug_full
  cat "$OUTPUT_DIR"/$comp-libcxx_debug_broken_abi "$OUTPUT_DIR"/$comp-debug output/$comp-sanitizers > "$OUTPUT_DIR"/$comp-debug_full_broken_abi
done

echo -e "\n"Empty and removed:
find "$OUTPUT_DIR" -size 0 -delete -print
