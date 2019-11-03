#!/bin/bash

if [ $# -ge 1 ] ; then
  echo 'Maybe you wanted to use compiler-options.lua ?'
  exit 1
fi

set -o pipefail
set -e

OUTPUT_DIR_NAME=output

TMPDIR="${TMPDIR:-/tmp}/cpp-comp-options"
PROJECT_PATH=$(realpath $(dirname "$0"))/..

if [ -d "$TMPDIR/$OUTPUT_DIR_NAME" ] ; then
  rm -r -- "$TMPDIR/$OUTPUT_DIR_NAME"/../output
fi
mkdir -p "$TMPDIR/generators" "$TMPDIR/$OUTPUT_DIR_NAME"/{,clang,gcc,msvc}

cd -- "$PROJECT_PATH"

OUTPUT_DIR="$TMPDIR/$OUTPUT_DIR_NAME"
OUTPUT_PROJECT="$OUTPUT_DIR_NAME"

# configure temporary paths
if [ -z "$LUA_BIN" ]; then
  LUA_BIN=$(which luajit 2>/dev/null||:)
  if [ -z "$LUA_BIN" ]; then
    LUA_BIN=lua
  else
    for f in compiler-options.lua generators/* ; do
      $LUA_BIN -b "$f" "$TMPDIR/$f"
    done
    cd "$TMPDIR"
    OUTPUT_DIR="$OUTPUT_DIR_NAME"
    OUTPUT_PROJECT="$PROJECT_PATH/$OUTPUT_DIR_NAME"
  fi
fi

sgen ()
{
  $LUA_BIN ./compiler-options.lua generators/$1.lua
}

gen ()
{
  local extra_arg=$1
  local out="-o$OUTPUT_DIR/$2"
  local f=generators/$3.lua
  shift 3
  $LUA_BIN ./compiler-options.lua $extra_arg "$out" $f "$@"
}

gencompopt ()
{
  local extra_arg=$1
  local out="$OUTPUT_DIR/$compname/$3-$2"
  shift 2
  $LUA_BIN ./compiler-options.lua $extra_arg generators/compiler.lua "$@" | sort -u > "$out"
}

# check options
sgen list_options

for c_opt in '' '-c' ; do
  suffix=
  [ ! -z "$c_opt" ] && suffix=c_
  for g in bjam cmake premake5 meson ; do
    gen "$c_opt" $suffix$g $g jln-
  done
done

sgen compiler | while read comp ; do
  compname=${comp/-*}
  gencompopt ''   release                       $comp cpu=native lto optimization=2 linker=gold
  gencompopt ''   warnings                      $comp shadow_warnings=off stl_fix warnings pedantic
  gencompopt ''   warnings_strict               $comp shadow_warnings=off stl_fix warnings=strict pedantic
  gencompopt '-c' c_warnings                    $comp shadow_warnings=off warnings pedantic
  gencompopt '-c' c_warnings_strict             $comp shadow_warnings=off warnings=strict pedantic
  gencompopt ''   stl_debug_broken_abi          $comp stl_fix stl_debug=allow_broken_abi
  gencompopt ''   stl_debug_broken_abi_and_bugs $comp stl_fix stl_debug=allow_broken_abi_and_bugs
  gencompopt ''   sanitizers-pointer            $comp sanitizers_extra=pointer
  gencompopt ''   template_tree                 $comp elide_type=off diagnostics_show_template_tree=on
  for g in suggestions stl_debug debug sanitizers ; do
    gencompopt '' $g $comp $g
  done
done

echo -e "\n"Duplicated and removed:
$LUA_BIN "$PROJECT_PATH"/tools/merge_generated.lua "$OUTPUT_DIR/" "$OUTPUT_DIR"/{gcc,clang,msvc}/*

echo -e "\n"Empty and removed:
find "$OUTPUT_DIR" -size 0 -delete -print

if [ -d "$OUTPUT_PROJECT" ]; then
  rm -r -- "$OUTPUT_PROJECT"/../output/
fi
mv -- "$OUTPUT_DIR" "$OUTPUT_PROJECT"
rm -r -- "$TMPDIR"/../cpp-comp-options
