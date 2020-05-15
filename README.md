Compilation options for different versions of Clang, GCC and MSVC. Provided a generator and different file formats (build system and compiler).

The `output` directory contains files for `cmake`, `premake5`, `bjam`/`b2`, `meson`, `scons` and command-line options for `gcc/g++`, `clang/clang++` and `msvc`. If a version of the compiler is not present, then there is no difference compared to an older version.

```cpp
int main()
{
  int x;
  return x; // used but uninitialized
}
```

$ `g++ main.cpp`

> No output

$ `g++ main.cpp @output/cpp/gcc/gcc-6.1-warnings`

```
main.cpp: In function ‘int main()’:
main.cpp:4:10: warning: ‘x’ is used uninitialized in this function [-Wuninitialized]
    4 |   return x; // used but not initialized
      |          ^
```

(`@file` is a special option of gcc and clang for read command-line options from file.)

$ `cmake -DJLN_SANITIZERS=on`

$ `premake5 --jln-sanitizers=on`

$ `bjam -s jln_sanitizers=on`

$ `meson -Djln_sanitizers=on`

$ `scons jln_sanitizers=on`

(`jln` is a parameterizable prefix: `./compiler-options.lua generators/cmake.lua [prefix]`)

<!-- summary -->
1. [Options](#options)
    1. [Recommended options](#recommended-options)
2. [Use generated files](#use-generated-files)
    1. [Cmake](#cmake)
    2. [Premake5](#premake5)
    3. [Meson](#meson)
    4. [SCons](#scons)
    5. [Bjam/B2 (Boost.Build)](#bjamb2-boostbuild)
    6. [Bash alias for gcc/clang](#bash-alias-for-gccclang)
3. [Generators](#generators)
    1. [generators/compiler.lua](#generatorscompilerlua)
    2. [generators/list_options.lua](#generatorslist_optionslua)
    3. [generators/{bjam,cmake,meson,premake5,scons}.lua](#generatorsbjamcmakemesonpremake5sconslua)
4. [How to add options?](#how-to-add-options)
    1. [Update the options tree](#update-the-options-tree)
        1. [if_mt](#if_mt)
<!-- /summary -->

# Options

Supported options are (in alphabetical order):

<!-- ./compiler-options.lua generators/list_options.lua color -->
```ini
color = default auto never always
control_flow = default off on branch return allow_bugs
coverage = default off on
cpu = default generic native
debug = default off on line_tables_only gdb lldb sce
diagnostics_format = default fixits patch print_source_range_info
diagnostics_show_template_tree = default off on
elide_type = default off on
exceptions = default off on
fix_compiler_error = on default off
linker = default bfd gold lld native
lto = default off on fat thin
optimization = default 0 g 1 2 3 fast size
pedantic = on default off as_error
pie = default off on pic
relro = default off on full
reproducible_build_warnings = default off on
rtti = default off on
sanitizers = default off on
sanitizers_extra = default off thread pointer
shadow_warnings = off default on local compatible_local all
stack_protector = default off on strong all
stl_debug = default off on allow_broken_abi allow_broken_abi_and_bugs assert_as_exception
stl_fix = on default off
suggestions = default off on
warnings = on default off strict very_strict
warnings_as_error = default off on basic
whole_program = default off on strip_all
```
<!-- ./compiler-options.lua -->

The value `default` does nothing.

If not specified, `fix_compiler_error`, `pedantic`, `stl_fix` and `warnings` are `on` ; `shadow_warnings` is `off`.

- `control_flow=allow_bugs`
  - clang: Can crash programs with "illegal hardware instruction" on totally unlikely lines. It can also cause link errors and force `-fvisibility=hidden` and `-flto`.
- `stl_debug=allow_broken_abi_and_bugs`
  - clang: libc++ can crash on dynamic memory releases in the standard classes. This bug is fixed with the library associated with version 8.


## Recommended options

category | options
---------|---------
debug | `control_flow=on`<br>`debug=on`<br>`sanitizers=on`<br>`stl_debug=allow_broken_abi` or `on`<br>
release | `cpu=native`<br>`linker=gold` or `linker=lld` or `linker=native`<br>`lto=linker_plugin` or `on`<br>`optimization=3`<br>`rtti=off`<br>`whole_program=strip_all`
security | `control_flow=on`<br>`relro=full`<br>`stack_protector=strong`
really strict warnings | `pedantic=as_error`<br>`shadow_warnings=local`<br>`suggestions=on`<br>`warnings=very_strict`


# Use generated files

## Cmake

```cmake
# launch example: cmake -DJLN_SANITIZERS=on
include(output/cpp/cmake)

# init default values
# jln_init_flags([<jln-option> <default_value>]... [AUTO_PROFILE on] [VERBOSE on])
# AUTO_PROFILE: enables options based on CMAKE_BUILD_TYPE (assumes "Debug" if CMAKE_BUILD_TYPE is empty)
jln_init_flags(SUGGESTIONS on) # set SUGGESTIONS default value to "on"


# jln_target_interface(<libname> {INTERFACE|PUBLIC|PRIVATE} [<jln-option> <value>]... [DISABLE_OTHERS on|off])
jln_target_interface(mytarget1 INTERFACE WARNINGS very_strict) # set WARNINGS to "very_strict"


# jln_flags(CXX_VAR <out-variable> LINK_VAR <out-variable> [<jln-option> <value>]... [DISABLE_OTHERS on|off])
jln_flags(CXX_VAR CXX_FLAGS LINK_VAR LINK_FLAGS WARNINGS very_strict)

target_link_libraries(mytarget2 INTERFACE ${LINK_FLAGS})
target_compile_options(mytarget2 INTERFACE ${CXX_FLAGS})

# NOTE: for C, jln_ prefix function becomes jln_c_ and CXX_VAR becomes C_VAR
```


## Premake5

```lua
-- launch example: premake5 --jln-sanitizers=on

include "output/cpp/premake5"

-- Registers new command-line options and set default values
jln_newoptions({warnings='very_strict'})

-- jln_getoptions(values, disable_others = nil, print_compiler = nil)
-- jln_getoptions(compiler, version = nil, values = nil, disable_others = nil, print_compiler = nil)
-- `= nil` indicates that the value is optional and can be nil
-- `compiler`: string. ex: 'gcc', 'g++', 'clang++', 'clang'. Or compiler and linker with semicolon separator. ex: 'clang-cl;lld-link'
-- `version`: string. Compiler version. ex: '7', '7.2'
-- `values`: table. ex: {warnings='on'}
-- `disable_others`: boolean
-- `print_compiler`: boolean
-- return {buildoptions=string, linkoptions=string}
local mylib_options = jln_getoptions({elide_type='on'})
buildoptions(mylib_options.buildoptions)
linkoptions(mylib_options.linkoptions)

-- or equivalent
jln_setoptions({elide_type='on'})

-- NOTE: for C, jln_ prefix function becomes jln_c_
```


## Meson

Copy `meson_options.txt` and rename `output/cpp/meson` to `meson_jln_flags/meson.build`.

```meson
# launch example: meson -Djln_sanitizers=on
# note: `meson --warnlevel=0` implies `--Djln_warnings=off`

project('test', 'cpp')

# default value (without prefix)
# optional
jln_default_flags = {'rtti': 'off'}

# optional
jln_custom_flags = [
  {'rtti': 'off', 'optimization': '3'}, # (0) opti flags
  {'debug': 'on'}, # (1) debug flags
  # { ... } # (2)
  # etc
]

# declare jln_link_flags, jln_cpp_flags, jln_custom_cpp_flags and jln_custom_link_flags
subdir('meson_jln_flags')

my_opti_cpp_flags = jln_custom_cpp_flags[0] # (0) opti flags (see above)
my_opti_link_flags = jln_custom_link_flags[0]
my_debug_cpp_flags = jln_custom_cpp_flags[1] # (1) debug flags (see above)
my_debug_link_flags = jln_custom_link_flags[1]
# my_... = jln_custom_cpp_flags[2] # (2)
# my_... = jln_custom_link_flags[2]
# etc

executable('demo', 'main.cpp', link_args: jln_link_flags, cpp_args: jln_cpp_flags)

# NOTE: for C, jln_ prefix becomes jln_c_
```


## SCons

```py
# launch example: scons jln_sanitizers=on

from jln_options import *

# jln_set_global_flags(options, compiler=None, version=None, linker=None)
# version is a string. Ex: '7.2' or '5'
jln_set_global_flags({'rtti': 'off'})

vars = Variables(None, ARGUMENTS)
jln_add_variables(vars, {'debug':'on'}) # default value of debug to on

# {flags=[...], linkflags=[...]}
flags1 = jln_flags(vars)
flags2 = jln_flags({'debug':'on'})
```

## Bjam/B2 (Boost.Build)

```jam
# launch example: bjam -s jln_sanitizers=on

include output/cpp/bjam ;

# rule jln_flags ( properties * )

project name : requirements
  <jln-lto-default>on # enable jln-lto
  <jln-relro-default>on
  <conditional>@jln_flags
: default-build release ;

exe test : test.cpp : <jln-relro-incidental>off # incidental version of <jln-relro>off

# NOTE: for C, jln_flags becomes jln_c_flags
```


## Bash alias for gcc/clang

The scripts below add 4 aliases with `warnings=on`, `pedantic=on` and `color=always`.

- `gw++` for g++
- `cw++` for clang++

```sh
for comp in g++ clang++ ; do
  version=$($comp --version | sed -E '1!d;s/.*([0-9]\.[0-9]\.[0-9]).*/\1/g')
  echo "alias ${comp:0:1}w++='$comp "$(./compiler-options.lua generators/compiler.lua "$comp-$version" warnings pedantic color=always)\'
done >> ~/.bashrc
```

- `gwcc` for gcc
- `cwcc` for clang

```sh
for comp in gcc clang ; do
  version=$($comp --version | sed -E '1!d;s/.*([0-9]\.[0-9]\.[0-9]).*/\1/g')
  echo "alias ${comp:0:1}wcc='$comp "$(./compiler-options.lua -c generators/compiler.lua "$comp-$version" warnings pedantic color=always)\'
done >> ~/.bashrc
```


# Generators

$ `./compiler-options.lua [-h] [-c] [-o filebase] [-f [-]option_list[,...]] {generator} [options...]`

```bash
./compiler-options.lua -f debug,warning generators/cmake.lua # only with debug and warning
./compiler-options.lua -f -debug,warning generators/cmake.lua # without debug nor warning
```

- `-c` for C, default is C++

## generators/compiler.lua

See `./compiler-options.lua generators/compiler.lua -h` for detailed usage information.

## generators/list_options.lua

$ `./compiler-options.lua generators/list_options.lua [--profile] [--color]`

Checks and displays options and their values.

## generators/{bjam,cmake,meson,premake5,scons}.lua

Generators for different build system.

$ `./compiler-options.lua [-o filebase] {generator} [option-prefix]`


# How to add options?

Edit `compiler-options.lua` file.

The variable `G` contains the options tree.

`_incidental` of `Vbase` contains the options that do not impact the executable.

`_opts` of `Vbase` contains the options, their values and the default value (`'default'` if unspecified). `opt_name = {{values...} [,default_value]},`.

## Update the options tree

- `c`, `cxx`, `flag`, `link`, `fl`
```lua
c'-Wall' -- C only
cxx'-Wall' -- C++ only
flag'-Wall' -- C and C++
link'-option'
link'libname' -- alias of link'-llibname'
fl'xxx' -- is a alias of {flag'xxx',link'xxx'}
```

The following functions return the metatable `if_mt`.

- `gcc`, `clang`, `clang_cl`, `clang_like`, `msvc` and `vers`

```lua
gcc { ... } -- for gcc only.
gcc(5) { ... } -- for >= gcc-5
gcc(5, 3) { ... } -- for >= gcc-5.3

gcc(major, minor) { ... } -- is a alias of `gcc { vers(major, minor) { ... } }`
```

- `opt`, `lvl`

```lua
opt'warnings' { -- if warnings is enabled (not `warnings=default`)
  lvl'off' { cxx'-w' } -- for `warnings=off`
}
```

- `Or`, `And`

```lua
Or(gcc(), clang(), msvc()) { ... }
And(gcc(), lvl'off') { ... }
```


### if_mt

- `-xxx {...}` for `not xxx`
- `xxx {...} / yyy {...}` for `xxx else yyy`

```lua
-gcc(5,3) { ... } -- < gcc-5.3
opt'warnings' { -lvl'on' { ... } } -- neither warnings=on nor warnings=default
lvl'on' { xxx } / { yyy } -- equivalent to `{ lvl'on' { xxx }, -lvl'on' { yyy } }`
```

Note: `-opt'name'` isn't allowed
