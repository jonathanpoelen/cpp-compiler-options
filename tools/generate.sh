#!/bin/bash

if (( $# > 0 )) ; then
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
mkdir -p "$TMPDIR/$OUTPUT_DIR_NAME"/{c,cpp}/{clang,gcc,msvc,clang-cl,icc,icl}

cd -- "$PROJECT_PATH"

OUTPUT_DIR="$TMPDIR/$OUTPUT_DIR_NAME"
OUTPUT_PROJECT="$OUTPUT_DIR_NAME"

# configure temporary paths
if [[ -z "$LUA" ]]; then
  LUA=$(which luajit-2017 2>/dev/null||:)
  if [[ -z "$LUA" ]]; then
    LUA=$(which luajit 2>/dev/null||:)
    if [[ -n "$LUA" ]]; then
      output=$(luajit -v)
      # luajit 2022-2024 (2023?) takes longer to load than to run the code
      # ok with 2.1.1741730670
      if [[ $output = *202[01234]* ]]; then
        LUA=lua
      fi
    fi
  fi
fi


LANG_OPTS=(-C -c)
LANG_DIRS=(cpp c)


# check options
params=(generators/list_options.lua)

# create files by build system
for ((i=0; $i<2; ++i)) ; do
  suffix=${LANG_DIRS[$i]}
  for g in bjam cmake premake5 meson scons xmake ; do
    params+=(--- ${LANG_OPTS[$i]} "-o$OUTPUT_DIR/$suffix/$g" generators/$g.lua jln-)
  done
done

$LUA ./compiler-options.lua "${params[@]}"



params=()

gencompopt ()
{
  local -i nb_lang=$1 i
  local suffix=$2

  shift 2
  for ((i=0; $i<$nb_lang; ++i)) ; do
    params+=(
      ${LANG_OPTS[$i]}
      "-o$OUTPUT_DIR/${LANG_DIRS[$i]}/$compname/$comp-$suffix"
      generators/compiler.lua
      "$comp"
      "$@"
      ---
    )
  done
}

warn_opts='
  bidi_char_warnings=any
  shadow_warnings=off
  switch_warnings=exhaustive_enum
  windows_abi_compatibility_warnings=off
  pedantic
  warnings
'
# options by compilers
while read comp ; do
  # ignore emscripten
  [[ $comp = 'clang-emcc'* ]] && continue

  compname=${comp%-[0-9]*}
  # C and C++
  gencompopt 2 release                    cpu=native lto optimization=3 ndebug
  gencompopt 2 warnings                   $warn_opts
  gencompopt 2 warnings_with_conversions  $warn_opts conversion_warnings
  gencompopt 2 suggestions                suggest_attributes=common
  gencompopt 2 sanitizers                 symbols=debug sanitizers
  # C++ only
  gencompopt 1 stl_debug                  symbols=debug stl_hardening=debug
  gencompopt 1 stl_debug_broken_abi       symbols=debug stl_hardening=debug_with_broken_abi
  gencompopt 1 template_tree              diagnostics_show_template=tree_without_elided_types
done < <($LUA ./compiler-options.lua generators/compiler.lua)

$LUA ./compiler-options.lua "${params[@]}"



echo $'\nDuplicated and removed:'
for d in ${LANG_DIRS[@]} ; do
  $LUA "$PROJECT_PATH"/tools/merge_generated.lua "$OUTPUT_DIR/$d/" "$OUTPUT_DIR"/$d/*/*
done

echo $'\nEmpty and removed:'
find "$OUTPUT_DIR" -size 0 -delete -print

if [[ -d "$OUTPUT_PROJECT" ]]; then
  rm -r -- "$OUTPUT_PROJECT"/../output/
fi
mv -- "$OUTPUT_DIR" "$OUTPUT_PROJECT"
rm -r -- "$TMPDIR"/../cpp-comp-options
