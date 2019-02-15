Compilation options for different versions of Clang and GCC. Provided a generator and different file formats (build system and compiler).

The `output` directory contains files for `cmake`, `premake5`, `bjam`/`b2`, `meson` and command-line options for `g++` and `clang++`.

$ `g++ @output/gcc-6.1-warnings -fsyntax-only -x c++ - <<<'int* p = 0;'`

> <stdin>:1:10: warning: zero as null pointer constant \[-Wzero-as-null-pointer-constant]

(`@file` is a special option of gcc/clang)

$ `cmake -DJLN_FAST_MATH=on`

$ `premake5 --jln-fast-math=on`

$ `bjam jln-fast-math=on`

$ `meson -Djln_fast_math=on`

(`jln-` is a parameterizable prefix: `./compiler-options.lua generators/meson.lua [prefix]`)

<!-- summary -->
1. [Options](#options)
2. [Use generated files](#use-generated-files)
    1. [Cmake](#cmake)
    2. [Premake5](#premake5)
    3. [Meson](#meson)
    4. [Bjam/B2 (Boost.Build)](#bjamb2-boostbuild)
    5. [Bash alias for gcc/clang](#bash-alias-for-gccclang)
3. [Generators](#generators)
    1. [generators/compiler.lua](#generatorscompilerlua)
    2. [generators/options.lua](#generatorsoptionslua)
    3. [generators/{bjam,cmake,meson,premake5}.lua](#generatorsbjamcmakemesonpremake5lua)
4. [How to add options?](#how-to-add-options)
    1. [Update the options tree](#update-the-options-tree)
        1. [cond_mt](#cond_mt)
<!-- /summary -->

# Options

Supported options are:

<!-- ./compiler-options.lua generators/options.lua color -->
```ini
color = default auto never always
control_flow = default off on
coverage = default off on
debug = default off on line_tables_only gdb lldb sce
diagnostics_format = default fixits patch print_source_range_info
diagnostics_show_template_tree = default off on
elide_type = default off on
exceptions = default off on
fast_math = default off on
lto = default off on fat
optimize = default off on size speed native whole_program
pedantic = on default off as_error
pie = default off on pic
relro = default off on full
reproducible_build_warnings = default off on
rtti = default off on
sanitizers = default off on
sanitizers_extra = default off thread pointer
shadow = off default on local compatible-local local-or-compatible-local global-or-local global-or-compatible-local
stack_protector = default off on strong all
stl_debug = default off on allow_broken_abi assert_as_exception
stl_fix = on default off
suggests = default off on
warnings = on default off strict very-strict
warnings_as_error = default off on
```
<!-- ./compiler-options.lua -->

The value `default` does nothing.

If not specified, the values of `warnings`, `stl_fix` and `pedantic` are `on`.


# Use generated files

## Cmake

```cmake
# include(output/cmake)

# init cache and cli parser
# jln_init_flags([<jln-option> <value>]... [VERBOSE on|1])
# (cmake -DJLN_VERBOSE=on -DJLN_DEBUG=on)
jln_init_flags(DEBUG on) # set DEBUG default value to "on"


add_library(lib_project INTERFACE)
# jln_target_interface(<libname> [<jln-option> <value>]... [DISABLE_OTHERS on|off])
jln_target_interface(lib_project)

add_executable(test test.cpp)
target_link_libraries(test lib_project)


# jln_flags(CXX_VAR <out-variable> LINK_VAR <out-variable> [<jln-option> <value>]... [DISABLE_OTHERS on|off])
jln_flags(CXX_VAR CXX_FLAGS LINK_VAR LINK_FLAGS SANITIZERS on)

add_library(lib_project2 INTERFACE)
target_link_libraries(lib_project2 INTERFACE ${LINK_FLAGS})
target_compile_options(lib_project2 INTERFACE ${CXX_FLAGS})

add_definitions(lib_project2)
link_libraries(lib_project2)
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

Copy `meson_options.txt` and rename `output/meson` to `something/meson.build`.

```meson
project('test', 'cpp')

subdir('something/meson.build')

executable('demo', 'main.cpp', link_args: jln_link_flags, cpp_args: jln_cpp_flags)
```


## Bjam/B2 (Boost.Build)

```jam
# include output/bjam ;

# rule jln_flags ( properties * )

project name : requirements
  <jln-lto>on # enable jln-lto
  <jln-incidental-relro>on # incidental version of jln-relro
  <conditional>@jln_flags
: default-build release ;
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

$ `./compiler-options.lua [-o filebase] {generator} [options...]`

## generators/compiler.lua

See `./compiler-options.lua generators/compiler.lua -h` for detailed usage information.

## generators/options.lua

Checks and displays options and their values. Put a parameter adds color.

## generators/{bjam,cmake,meson,premake5}.lua

Generators for different build system.


# How to add options?

Edit `compiler-options.lua` file.

The variable `G` contains the options tree.

`_incidental` of `Vbase` contains the options that do not impact the executable.

`_opts` of `Vbase` contains the options, their values and the default value (`'default'` if unspecified). `opt_name = {{values...} [,default_value]},`.

## Update the options tree

- `cxx`, `def`, `link`, `fl`
```lua
cxx'-Wall'
def'NAME=3'
link'-option'
link'libname'
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
