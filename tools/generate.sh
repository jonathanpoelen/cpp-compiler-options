#!/bin/bash

if (( $# > 1 )) ; then
  set $1
fi

set -o pipefail
set -e

OUTPUT_DIR_NAME=output

TMPDIR="${TMPDIR:-/tmp}/cpp-comp-options"
PROJECT_PATH=$(realpath $(dirname "$0"))/..

if [[ -d "$TMPDIR/$OUTPUT_DIR_NAME" ]] ; then
  rm -r -- "$TMPDIR/$OUTPUT_DIR_NAME"/../output
fi
mkdir -p "$TMPDIR/generators" "$TMPDIR/$OUTPUT_DIR_NAME"/{c,cpp}/{clang,gcc,msvc,clang-cl,icc,icl}

cd -- "$PROJECT_PATH"

OUTPUT_DIR="$TMPDIR/$OUTPUT_DIR_NAME"
OUTPUT_PROJECT="$OUTPUT_DIR_NAME"

# configure temporary paths
if [[ -z "$LUA" ]]; then
  LUA=$(which luajit 2>/dev/null||:)
  if [[ -z "$LUA" ]]; then
    LUA=lua
  else
    for f in compiler-options.lua generators/* ; do
      $LUA -b "$f" "$TMPDIR/$f"
    done
    cd "$TMPDIR"
    OUTPUT_DIR="$OUTPUT_DIR_NAME"
    OUTPUT_PROJECT="$PROJECT_PATH/$OUTPUT_DIR_NAME"
  fi
fi

sgen ()
{
  $LUA ./compiler-options.lua generators/$1.lua
}

gen ()
{
  local extra_arg=$1
  local out="-o$OUTPUT_DIR/$2"
  local f=generators/$3.lua
  shift 3
  $LUA ./compiler-options.lua $extra_arg "$out" $f "$@"
}

OPT_COMP_GEN=('' -c)
DIR_COMP_GEN=(cpp c)

gencompopt ()
{
  local lang=$1
  local cat=$2
  local compiler=$3

  shift 2
  for ((i=0; $i<$lang; ++i)) ; do
    local out="$OUTPUT_DIR/${DIR_COMP_GEN[$i]}/$compname/$compiler-$cat"
    $LUA ./compiler-options.lua ${OPT_COMP_GEN[$i]} generators/compiler.lua "$@" | sort -u > "$out"
  done
}

# check options
sgen list_options

for ((i=0; $i<2; ++i)) ; do
  suffix=${DIR_COMP_GEN[$i]}
  for g in bjam cmake premake5 meson scons xmake ; do
    gen "${OPT_COMP_GEN[$i]}" $suffix/$g $g jln-
  done
done

sgen compiler | while read comp ; do
  # icx is a clang, ignored
  if [[ $comp =~ ^icx ]]; then
    continue
  fi
  compname=${comp%-[0-9]*}
  gencompopt 2 release                       $comp cpu=native lto optimization=2 linker=native
  gencompopt 2 warnings                      $comp shadow_warnings=off windows_abi_compatibility_warnings=off pedantic warnings
  gencompopt 2 warnings_with_conversions     $comp shadow_warnings=off windows_abi_compatibility_warnings=off pedantic warnings conversion_warnings
  gencompopt 1 stl_debug_broken_abi          $comp stl_fix stl_debug=allow_broken_abi
  gencompopt 1 stl_debug_broken_abi_and_bugs $comp stl_fix stl_debug=allow_broken_abi_and_bugs
  gencompopt 1 sanitizers-pointer            $comp other_sanitizers=pointer
  gencompopt 1 template_tree                 $comp elide_type=off diagnostics_show_template_tree=on
  for g in suggestions stl_debug debug sanitizers ; do
    gencompopt 2 $g $comp $g
  done
done

echo -e "\n"Duplicated and removed:
for d in ${DIR_COMP_GEN[@]} ; do
  $LUA "$PROJECT_PATH"/tools/merge_generated.lua "$OUTPUT_DIR/$d/" "$OUTPUT_DIR"/$d/*/*
done

echo -e "\n"Empty and removed:
find "$OUTPUT_DIR" -size 0 -delete -print

if [[ -d "$OUTPUT_PROJECT" ]]; then
  rm -r -- "$OUTPUT_PROJECT"/../output/
fi
mv -- "$OUTPUT_DIR" "$OUTPUT_PROJECT"
rm -r -- "$TMPDIR"/../cpp-comp-options
