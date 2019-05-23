Compilation options for different versions of Clang, GCC and MSVC. Provided a generator and different file formats (build system and compiler).

The `output` directory contains files for `cmake`, `premake5`, `bjam`/`b2`, `meson` and command-line options for `g++`, `clang++` and `msvc`.

$ `g++ @output/gcc-6.1-warnings -fsyntax-only -x c++ - <<<'int* p = 0;'`

> <stdin>:1:10: warning: zero as null pointer constant \[-Wzero-as-null-pointer-constant]

(`@file` is a special option of gcc/clang)

$ `cmake -DJLN_FAST_MATH=on`

$ `premake5 --jln-fast-math=on`

$ `bjam -s jln_fast_math=on`

$ `meson -Djln_fast_math=on`

(`jln` is a parameterizable prefix: `./compiler-options.lua generators/cmake.lua [prefix]`)

<!-- summary -->
1. [Options](#options)
    1. [Recommended options](#recommended-options)
2. [Use generated files](#use-generated-files)
    1. [Cmake](#cmake)
    2. [Premake5](#premake5)
    3. [Meson](#meson)
    4. [Bjam/B2 (Boost.Build)](#bjamb2-boostbuild)
    5. [Bash alias for gcc/clang](#bash-alias-for-gccclang)
3. [Generators](#generators)
    1. [generators/compiler.lua](#generatorscompilerlua)
    2. [generators/list_options.lua](#generatorslist_optionslua)
    3. [generators/{bjam,cmake,meson,premake5}.lua](#generatorsbjamcmakemesonpremake5lua)
4. [How to add options?](#how-to-add-options)
    1. [Update the options tree](#update-the-options-tree)
        1. [cond_mt](#cond_mt)
<!-- /summary -->

# Options

Supported options are (in alphabetical order):

<!-- ./compiler-options.lua generators/list_options.lua color -->
```ini
color = default auto never always
control_flow = default off on
coverage = default off on
cpu = default generic native
debug = default off on line_tables_only gdb lldb sce
diagnostics_format = default fixits patch print_source_range_info
diagnostics_show_template_tree = default off on
elide_type = default off on
exceptions = default off on
fix_compiler_error = on default off
linker = default bfd gold lld
lto = default off on fat linker_plugin
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
stl_debug = default off on allow_broken_abi allow_broken_abi_and_bugged assert_as_exception
stl_fix = on default off
suggestions = default off on
warnings = on default off strict very_strict
warnings_as_error = default off on
whole_program = default off on strip_all
```
<!-- ./compiler-options.lua -->

The value `default` does nothing.

If not specified, `fix_compiler_error`, `pedantic`, `stl_fix` and `warnings` are `on` ; `shadow_warnings` is `off`.

## Recommended options

category | options
---------|---------
debug | `control_flow=on`<br>`debug=on`<br>`sanitizers=on`<br>`stl_debug=allow_broken_abi` or `on`<br>
release | `cpu=native`<br>`linker=gold`<br>`lto=linker_plugin` or `on`<br>`optimize=release`<br>`rtti=off`<br>`whole_program=strip_all`
security | `control_flow=on`<br>`relro=full`<br>`stack_protector=strong`
really strict warnings | `pedantic=as_error`<br>`shadow_warnings=local`<br>`suggestions=on`<br>`warnings=very_strict`


# Use generated files

## Cmake

```cmake
# include(output/cmake)

# init cache and cli parser
# jln_init_flags([<jln-option> <value>]... [AUTO_PROFILE on] [VERBOSE on])
# AUTO_PROFILE: enables options based on CMAKE_BUILD_TYPE (assumes "Debug" is empty)
# (cmake -DJLN_VERBOSE=on -DJLN_DEBUG=on)
jln_init_flags(SUGGESTIONS on) # set SUGGESTIONS default value to "on"


# jln_target_interface(<libname> {INTERFACE|PUBLIC|PRIVATE} [<jln-option> <value>]... [DISABLE_OTHERS on|off])
jln_target_interface(mytarget1 INTERFACE SANITIZERS on)


# jln_flags(CXX_VAR <out-variable> LINK_VAR <out-variable> [<jln-option> <value>]... [DISABLE_OTHERS on|off])
jln_flags(CXX_VAR CXX_FLAGS LINK_VAR LINK_FLAGS SANITIZERS on)

add_link_options(${LINK_FLAGS})
add_compile_options(${CXX_FLAGS})
```


## Premake5

```lua
-- include "output/premake5"

-- Registers new command-line options (ex jln_newoptions({debug='on'}))
jln_newoptions([default_values])

-- `values`: table. ex: {warnings='on'}
-- `disable_others`: boolean
-- `print_compiler`: boolean
-- `compiler`: string. ex: 'gcc', 'g++', 'clang++', 'clang'
-- `version`: string. ex: '7', '7.2'

-- return {buildoptions=string, linkoptions=string}
jln_getoptions(values[, disable_others[, print_compiler]])
jln_getoptions([compiler[, version[, values[, disable_others[, print_compiler]]]]])

-- use buildoptions and linkoptions then return {buildoptions=string, linkoptions=string}
jln_setoptions(values[, disable_others[, print_compiler]])
jln_setoptions([compiler[, version[, values[, disable_others[, print_compiler]]]]])
```


## Meson

Copy `meson_options.txt` and rename `output/meson` to `meson_jln_flags/meson.build`.

```meson
project('test', 'cpp')

# default value for jln-... cli flags
# jln_default_flags = {'jln_rtti': 'off'}

# flags without jln-... cli
# jln_custom_flags = [
#  {'jln_rtti': 'off', 'jln_optimize': 'on'},
#  {'jln_debug': 'on'},
# ]

subdir('meson_jln_flags')

# my_opti_cpp_flags = jln_custom_cpp_flags[0]
# my_opti_link_flags = jln_custom_link_flags[0]

executable('demo', 'main.cpp', link_args: jln_link_flags, cpp_args: jln_cpp_flags)
```


## Bjam/B2 (Boost.Build)

```jam
# include output/bjam ;

# rule jln_flags ( properties * )

project name : requirements
  <jln-lto-default>on # enable jln-lto
  <jln-relro-default>on
  <conditional>@jln_flags
: default-build release ;

exe test : test.cpp : <jln-relro-incidental>off # incidental version of <jln-relro>off
```


## Bash alias for gcc/clang

The script below adds 2 aliases with `warnings=on`, `pedantic=on` and `color=always`.

- `gw++` for gcc
- `cw++` for clang

```sh
for comp in g++ clang++ ; do
  echo "alias ${comp:0:1}w++='$comp "$(./compiler-options.lua generators/compiler.lua $comp warnings pedantic color=always)\'
done >> ~/.bashrc
```


# Generators

$ `./compiler-options.lua [-o filebase] [-f [-]option_list[,...]] {generator} [options...]`

```bash
./compiler-options.lua -f debug,warning generators/cmake.lua # only with debug and warning
./compiler-options.lua -f -debug,warning generators/cmake.lua # without debug nor warning
```

## generators/compiler.lua

See `./compiler-options.lua generators/compiler.lua -h` for detailed usage information.

## generators/list_options.lua

$ `./compiler-options.lua generators/list_options.lua [--profile] [--color]`

Checks and displays options and their values.

## generators/{bjam,cmake,meson,premake5}.lua

Generators for different build system.

$ `./compiler-options.lua [-o filebase] {generator} [option-prefix]`


# How to add options?

Edit `compiler-options.lua` file.

The variable `G` contains the options tree.

`_incidental` of `Vbase` contains the options that do not impact the executable.

`_opts` of `Vbase` contains the options, their values and the default value (`'default'` if unspecified). `opt_name = {{values...} [,default_value]},`.

## Update the options tree

- `cxx`, `link`, `fl`
```lua
cxx'-Wall'
link'-option'
link'libname' -- alias of link'-llibname'
fl'xxx' -- is a alias of {cxx'xxx',link'xxx'}
```

The following functions implement the metatable `cond_mt`.

- `gcc`, `clang`, `msvc` and `vers`

```lua
gcc { ... } -- for gcc only.
gcc(5) { ... } -- for >= gcc-5
gcc(5, 3) { ... } -- for >= gcc-5.3

gcc(xxx) { ... } -- is a alias of `gcc { vers(xxx) { ... } }`
```

- `Or`

```lua
Or(gcc, clang) { ... } -- gcc or clang
```

- `opt`, `lvl`

```lua
opt'warnings' { -- if warnings is enabled (not `warnings=default`)
  lvl'off' { cxx'-w' } -- for `warnings=off`
}
```

### cond_mt

- `-xxx {...}` for `not xxx`
- `xxx {...} / yyy {...}` for `xxx else yyy`
- `xxx {...} * yyy {...}` for `xxx then yyy`

```lua
-gcc(5,3) { ... } -- < gcc-5.3
opt'warnings' { -lvl'on' { ... } } -- neither warnings=on nor warnings=default
gcc { xxx } * vers(5) { yyy } -- equivalent to `{ gcc { xxx }, gcc(5) { yyy } }`
lvl'on' { xxx } / { yyy } -- equivalent to `{ lvl'on' { xxx }, -lvl'on' { yyy } }`
```
