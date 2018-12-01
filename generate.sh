#!/bin/sh

set -e

OUTPUT_DIR_NAME=output

TMPDIR="${TMPDIR:-/tmp}/cpp-comp-options"
PROJECT_PATH=$(realpath $(dirname "$0"))

mkdir -p "$TMPDIR/generators" "$TMPDIR/$OUTPUT_DIR_NAME"

cd "$PROJECT_PATH"

# configure temporary paths
LUA_BIN=$(which luajit 2>/dev/null||:)
if [ ! -z "$LUA_BIN" ]; then
  for f in compiler-options.lua generators/* ; do
    $LUA_BIN -b "$f" "$TMPDIR/$f"
  done
  cd "$TMPDIR"
  OUTPUT_DIR="$OUTPUT_DIR_NAME"
  OUTPUT_PROJECT="$PROJECT_PATH/$OUTPUT_DIR_NAME"
else
  OUTPUT_DIR="$TMPDIR/$OUTPUT_DIR_NAME"
  OUTPUT_PROJECT="$OUTPUT_DIR_NAME"
fi

gen ()
{
  f=generators/$1.lua
  shift
  $LUA_BIN ./compiler-options.lua $f "$@"
}

# check options
gen options

for g in bjam cmake premake5 meson ; do
  gen $g jln- > "$OUTPUT_DIR"/$g
done

gen compiler | while read comp ; do
  gen compiler $comp warnings pedantic > "$OUTPUT_DIR"/$comp-warnings
  gen compiler $comp warnings=strict pedantic > "$OUTPUT_DIR"/$comp-warnings_strict
  gen compiler $comp stl_debug=allow_broken_abi > "$OUTPUT_DIR"/$comp-stl_debug_broken_abi
  gen compiler $comp sanitizers_extra=pointer > "$OUTPUT_DIR"/$comp-sanitizers-pointer
  gen compiler $comp elide_type=off diagnostics_show_template_tree=on > "$OUTPUT_DIR"/$comp-template_tree
  for g in suggests stl_debug debug sanitizers ; do
    gen compiler $comp $g > "$OUTPUT_DIR"/$comp-$g
  done
  cat -- "$OUTPUT_DIR"/$comp-stl_debug            "$OUTPUT_DIR"/$comp-debug "$OUTPUT_DIR"/$comp-sanitizers > "$OUTPUT_DIR"/$comp-debug_full
  cat -- "$OUTPUT_DIR"/$comp-stl_debug_broken_abi "$OUTPUT_DIR"/$comp-debug "$OUTPUT_DIR"/$comp-sanitizers > "$OUTPUT_DIR"/$comp-debug_full_broken_abi
done

echo -e "\n"Empty and removed:
find "$OUTPUT_DIR" -size 0 -delete -print

if [ -d "$OUTPUT_PROJECT" ]; then
  rm -f "$OUTPUT_PROJECT/"*
  rmdir "$OUTPUT_PROJECT"
fi
mv "$OUTPUT_DIR" "$OUTPUT_PROJECT"
rm -rf "$TMPDIR"
