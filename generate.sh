#!/bin/sh

if [ $# -ge 1 ] ; then
  echo 'Maybe you wanted to use compiler-options.lua ?'
  exit 1
fi

set -e

OUTPUT_DIR_NAME=output

TMPDIR="${TMPDIR:-/tmp}/cpp-comp-options"
PROJECT_PATH=$(realpath $(dirname "$0"))

mkdir -p "$TMPDIR/generators" "$TMPDIR/$OUTPUT_DIR_NAME"

cd -- "$PROJECT_PATH"

OUTPUT_DIR="$TMPDIR/$OUTPUT_DIR_NAME"
OUTPUT_PROJECT="$OUTPUT_DIR_NAME"

# configure temporary paths
if [ -z "$LUA_BIN" ]; then
  LUA_BIN=$(which luajit 2>/dev/null||:)
  if [ ! -z "$LUA_BIN" ]; then
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
  out="-o$OUTPUT_DIR/$1"
  f=generators/$2.lua
  shift 2
  $LUA_BIN ./compiler-options.lua "$out" $f "$@"
}

# check options
sgen options

for g in bjam cmake premake5 meson ; do
  gen $g $g jln-
done

sgen compiler | while read comp ; do
  gen $comp-warnings             compiler $comp stl_fix warnings pedantic
  gen $comp-warnings_strict      compiler $comp stl_fix warnings=strict pedantic
  gen $comp-stl_debug_broken_abi compiler $comp stl_fix stl_debug=allow_broken_abi
  gen $comp-sanitizers-pointer   compiler $comp sanitizers_extra=pointer
  gen $comp-template_tree        compiler $comp elide_type=off diagnostics_show_template_tree=on
  for g in suggests stl_debug debug sanitizers ; do
    gen $comp-$g compiler $comp $g
  done
  cat -- "$OUTPUT_DIR"/$comp-stl_debug            "$OUTPUT_DIR"/$comp-debug "$OUTPUT_DIR"/$comp-sanitizers > "$OUTPUT_DIR"/$comp-debug_full
  cat -- "$OUTPUT_DIR"/$comp-stl_debug_broken_abi "$OUTPUT_DIR"/$comp-debug "$OUTPUT_DIR"/$comp-sanitizers > "$OUTPUT_DIR"/$comp-debug_full_broken_abi
done

echo -e "\n"Empty and removed:
find "$OUTPUT_DIR" -size 0 -delete -print

if [ -d "$OUTPUT_PROJECT" ]; then
  rm -f -- "$OUTPUT_PROJECT/"*
  rmdir -- "$OUTPUT_PROJECT"
fi
mv -- "$OUTPUT_DIR" "$OUTPUT_PROJECT"
rm -rf -- "$TMPDIR"
