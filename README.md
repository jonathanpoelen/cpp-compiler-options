
Compilation options for different versions of Clang, GCC, MSVC, Emscripten, ICC and ICX. Provided a generator and different file formats (build system and compiler).

The `output` directory contains files for `cmake`, `xmake`, `premake5`, `meson`, `bjam`/`b2`, `scons` and command-line options for `gcc`/`g++`, `clang`/`clang++` and `msvc`. If a version of the compiler is not present, then there is no difference compared to an older version.

Each build system also has a branch with only the files it needs.

Here is an example with gcc:

```cpp
int main()
{
  int x;
  return x; // used but uninitialized
}
```

$ `g++ main.cpp`

> No output

$ `g++ main.cpp @cpp-compiler-options/output/cpp/gcc/gcc-6.1-warnings`

```
main.cpp: In function ‘int main()’:
main.cpp:4:10: warning: ‘x’ is used uninitialized in this function [-Wuninitialized]
    4 |   return x; // used but not initialized
      |          ^
```

(`@file` is a special option of gcc and clang for read command-line options from file.)


<!-- toc -->
1. [Options](#options)
    1. [Recommended options](#recommended-options)
2. [Use generated files](#use-generated-files)
    1. [CMake](#cmake)
    2. [xmake](#xmake)
    3. [Meson](#meson)
    4. [Premake5](#premake5)
    5. [Bjam/B2 (Boost.Build)](#bjamb2-boostbuild)
    6. [SCons](#scons)
    7. [Bash alias for gcc/clang](#bash-alias-for-gccclang)
3. [Generators](#generators)
    1. [generators/compiler.lua](#generatorscompilerlua)
    2. [generators/list_options.lua](#generatorslist_optionslua)
    3. [generators/{cmake,xmake,meson,premake5,bjam,scons}.lua](#generatorscmakexmakemesonpremake5bjamsconslua)
4. [How to add or modify options?](#how-to-add-or-modify-options)
    1. [Flags](#flags)
    2. [Compilers and linkers](#compilers-and-linkers)
    3. [Platform](#platform)
    4. [Options and levels](#options-and-levels)
    5. [Conditions](#conditions)
    6. [if_mt](#if_mt)
<!-- /toc -->

# Options

Supported options are listed below by category.
The same option can be found in several categories.

The first value corresponds to the one used by default,
and the value `default` has no associated behavior.

Options with a default value other than `default` are listed below.

<!-- ./compiler-options.lua generators/list_options.lua --color --categorized -->
```ini
# Warning:

warnings = on default off essential extensive
warnings_as_error = default off on basic
conversion_warnings = on default off sign float conversion all
covered_switch_default_warnings = on default off
msvc_crt_secure_no_warnings = on default off
noexcept_warnings = default off on
reproducible_build_warnings = default off on
shadow_warnings = off default on local compatible_local all
suggest_attributes = on default off common analysis unity all
switch_warnings = on default off exhaustive_enum mandatory_default exhaustive_enum_and_mandatory_default
unsafe_buffer_usage_warnings = default on off
windows_abi_compatibility_warnings = off default on

# Pedantic:

pedantic = on default off as_error
stl_fix = on default off

# Debug:

symbols = default hidden strip_all gc_sections nodebug debug minimal_debug full_debug btf codeview ctf ctf1 ctf2 vms vms1 vms2 vms3 dbx lldb sce dwarf
stl_hardening = default off fast extensive debug debug_with_broken_abi
control_flow = default off on branch return allow_bugs
sanitizers = default off on extra address kernel kernel_extra kernel_extra kernel_address thread undefined undefined_minimal_runtime scudo_hardened_allocator
var_init = default uninitialized pattern zero
ndebug = with_optimization_1_or_above default off on
optimization = default 0 g 1 2 3 fast size z

# Optimization:

cpu = default generic native
lto = default off on full thin_or_nothing whole_program whole_program_and_full_lto
optimization = default 0 g 1 2 3 fast size z
optimization_warnings = default off on

# C++:

exceptions = default off on
rtti = default off on

# Hardening:

control_flow = default off on branch return allow_bugs
relro = default off on full
stack_protector = default off on strong all
stl_hardening = default off fast extensive debug debug_with_broken_abi

# Analyzer:

analyzer = default off on with_external_headers
analyzer_too_complex_warning = default off on
analyzer_verbosity = default 0 1 2 3

# Other:

color = default auto never always
coverage = default off on
diagnostics_format = default fixits patch print_source_range_info
diagnostics_show_template = default tree without_elided_types tree_without_elided_types
linker = default bfd gold lld mold native
msvc_diagnostics_format = caret default classic column
msvc_isystem = default anglebrackets include_and_caexcludepath external_as_include_system_flag assumed
msvc_isystem_with_template_instantiations_treated_as_non_external = default off on
pie = default off on static fpic fPIC fpie fPIE
windows_bigobj = on default
```
<!-- ./compiler-options.lua -->

If not specified:

- `msvc_diagnostics_format` is `caret`
- `ndebug` is `with_optimization_1_or_above`
- The following values are `off`:
  - `shadow_warnings`
  - `windows_abi_compatibility_warnings`
- The following values are `on`:
  - `conversion_warnings`
  - `covered_switch_default_warnings`
  - `msvc_crt_secure_no_warnings`
  - `pedantic`
  - `stl_fix`
  - `suggest_attributes`
  - `switch_warnings`
  - `warnings`
  - `windows_bigobj`

<!-- enddefault -->

### To know

- `control_flow=allow_bugs`
  - clang: Can crash programs with "illegal hardware instruction" on totally unlikely lines. It can also cause link errors and force `-fvisibility=hidden` and `-flto`.
- `msvc_isystem=external_as_include_system_flag` is only available with `cmake`.
- `stl_hardening=debug`
  - msvc: unlike `stl_hardening=debug_with_broken_abi`, STL debugging is not enabled by this option, as it breaks the ABI (only hardening mode is enabled on recent versions). However, as the `_DEBUG` macro can be defined in many different ways, STL debugging can be activated and the ABI broken.


### Sanitizers

Some sanitizers activated at compile time are only realistically active in the presence of a configuration in an environment variable.
`sanitizers=on` does not include these sanitizers, unlike `sanitizers=extra`.
The environment variables to use are as follows:

```sh
# cl (Windows)
ASAN_OPTIONS=detect_stack_use_after_return=1

# gcc
ASAN_OPTIONS=detect_invalid_pointer_pairs=2  # see -fsanitize=pointer-subtract and -fsanitize=pointer-compare

# macOS
ASAN_OPTIONS=detect_leaks=1
```

See
[AddressSanitizer](https://github.com/google/sanitizers/wiki/AddressSanitizer),
[UndefinedBehaviorSanitizer](https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html),
[-fsanitize=pointer-compare](https://gcc.gnu.org/onlinedocs/gcc/Instrumentation-Options.html#index-fsanitize_003dpointer-compare) with GCC and
[-fsanitize-address-use-after-return](https://learn.microsoft.com/en-us/cpp/sanitizers/asan-building#fsanitize-address-use-after-return-compiler-option-experimental) with cl compiler
for more details.

See [AddressSanitizer Flags](https://github.com/google/sanitizers/wiki/AddressSanitizerFlags#run-time-flags)
for a list of supported options.


## Recommended options

category | options
---------|---------
debug | `var_init=pattern`<br>`control_flow=on`<br>`symbols=debug` or `full_debug`<br>`sanitizers=on`<br>`stl_hardening=debug_with_broken_abi` or `debug`<br>`optimization=g` or `default`
release | `cpu=native`<br>`lto=on`<br>`optimization=3`<br>`rtti=off`<br>`symbols=strip_all`
security | `control_flow=on`<br>`relro=full`<br>`stack_protector=strong`<br>`pie=fPIE`<br>`stl_hardening=fast` or `extensive`
really strict warnings | `pedantic=as_error`<br>`suggest_attributes=common`<br>`warnings=extensive`<br>`conversion_warnings=all`<br>`switch_warnings=exhaustive_enum`<br>`shadow_warnings=local`<br>`windows_abi_compatibility_warnings=on`


# Use generated files

This is what enabled of sanitizers looks like with the different build systems available:

$ `cmake -DJLN_SANITIZERS=on`

$ `xmake f --jln-sanitizers=on`

$ `premake5 --jln-sanitizers=on`

$ `meson -Djln_sanitizers=on`

$ `bjam -s jln_sanitizers=on`

$ `scons jln_sanitizers=on`

(`jln` is a parameterizable prefix: `./compiler-options.lua generators/cmake.lua [prefix]`)


## CMake

```cmake
# launch example: cmake -DJLN_SANITIZERS=on
include(output/cpp/cmake)

# init default values
# jln_init_flags(
#     [<jln-option> <default_value>]...
#     [AUTO_PROFILE on]
#     [VERBOSE on]
#     [BUILD_TYPE type [<jln-option> <default_value>]...]...
# )
# AUTO_PROFILE: enables options based on CMAKE_BUILD_TYPE
#               (assumes "Debug" if CMAKE_BUILD_TYPE is empty)
# BUILD_TYPE: enables following options only if ${CMAKE_BUILD_TYPE}
#             has the same value (CMAKE_BUILD_TYPE assumed to Debug if empty)
jln_init_flags(
  SUGGESTIONS on      # set SUGGESTIONS default value to "on"
  BUILD_TYPE debug
    SANITIZERS on     # set SANITIZERS default value to "on" only in Debug build
  BUILD_TYPE release
    LTO on            # set LTO default value to "on" only in Release build
)


# jln_target_interface(
#     <libname> {INTERFACE|PUBLIC|PRIVATE}
#     [<jln-option> <value>]...
#     [DISABLE_OTHERS {on|off}]
#     [BUILD_TYPE type [<jln-option> <value>]...]...
# )
jln_target_interface(mytarget1 INTERFACE WARNINGS very_strict) # set WARNINGS to "very_strict"


# jln_flags(
#     CXX_VAR <out-variable>
#     LINK_VAR <out-variable>
#     [<jln-option> <value>]...
#     [DISABLE_OTHERS {on|off}]
#     [BUILD_TYPE type [<jln-option> <value>]...]...
# )
jln_flags(CXX_VAR CXX_FLAGS LINK_VAR LINK_FLAGS WARNINGS very_strict)

target_link_libraries(mytarget2 INTERFACE ${LINK_FLAGS})
target_compile_options(mytarget2 INTERFACE ${CXX_FLAGS})

# NOTE: for C, jln_ prefix function becomes jln_c_ and CXX_VAR becomes C_VAR
```


## xmake

Copy `output/cpp/xmake_options.lua` to `myproj/cpp/xmake.lua` and `output/cpp/xmake` to `myproj/cpp/flags.lua`. `cpp` is an arbitrary directory name, this can be changed.

```lua
-- launch example: xmake f --jln-sanitizers=on

includes'cpp'

-- Registers new command-line options and set default values
jln_cxx_init_options({warnings='very_strict', warnings_as_error='basic'})

-- Set options for a specific mode (see also jln_cxx_rule())
-- When the first parameter is nil or unspecified, a default configuration is used.
jln_cxx_init_modes({
  debug={
    stl_hardening='debug_with_broken_abi',
  },
  release={
    function() ... end, -- callback for release mode
    lto='on',
  },
  -- ...
})

target('hello1')
  set_kind('binary')
  add_files('src/hello.cpp')



-- Create a new rule. Options are added to the current configuration
jln_cxx_rule('custom_rule', {warnings_as_error='on'})

target('hello2')
  set_kind('binary')
  add_rules('custom_rule')
  add_files('src/hello.cpp')



target('hello3')
  set_kind('binary')
  -- Custom configuration when jln_cxx_rule() or jln_cxx_modes() are not enough
  on_load(function(target)
    import'cpp.flags'
    -- see also get_flags() and create_options()
    local flags = flags.set_flags(target, {elide_type='on'})
    print(flags)
  end)
  add_files('src/hello.cpp')


-- NOTE: for C, jln_cxx_ prefix become jln_c_
```


## Meson

Copy `output/cpp/meson_options.txt` and rename `output/cpp/meson` to `meson_jln_flags/meson.build`.

```meson
# launch example: meson -Djln_sanitizers=on
# note: `meson --warnlevel=0` implies `--Djln_warnings=off`

project('test', 'cpp')

# default options (without prefix)
# optional
jln_default_flags = {'rtti': 'off'}

# options for specific buildtype (added to default options)
# optional.
jln_buildtype_flags = {
  'debug': {'rtti': 'on'},
}

# Use a default configuration when jln_buildtype_flags is unspecified.
# optional.
jln_use_profile_buildtype = true

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


## Premake5

```lua
-- launch example: premake5 --jln-sanitizers=on

include "output/cpp/premake5"

-- Registers new command-line options and set default values
jln_newoptions({warnings='very_strict'})

    -- getoptions(values = {}, disable_others = false, print_compiler = false)
    -- `values`: table. ex: {warnings='on'}
    -- `values` can have 3 additional fields:
    --  - `cxx`: compiler name (otherwise deducted from --cxx and --toolchain)
    --  - `cxx_version` (otherwise deducted from cxx)
    --  - `ld`: linker name
    -- `disable_others`: boolean
    -- `print_compiler`: boolean
    -- return {cxxflags=table, ldflags=table}
    -- Note: with C language, cxxflags, cxx and cxx_version become cflags, cc and cc_version
    local options = flags.getoptions({elide_type='on'})
    for _,opt in ipairs(options.cxxflags) do target:add('cxxflags', opt, {force=true}) end
    for _,opt in ipairs(options.ldflags) do target:add('ldflags', opt, {force=true}) end

    -- or equivalent (return also options)
    flags.setoptions(target, {elide_type='on'})

    -- return the merge of the default values and new value table
    local values = flags.tovalues({elide_type='on'}, --[[disable_others:bool]])
    print(values)

-- jln_getoptions(values = {}, disable_others = false, print_compiler = false)
-- `values`: table. ex: {warnings='on'}
-- `values` can have 3 additional fields:
--  - `cxx`: compiler name
--  - `cxx_version` (otherwise deducted from cxx)
--  - `ld`: linker name
-- `disable_others`: boolean
-- `print_compiler`: boolean
-- return {buildoptions=table, linkoptions=table}
-- Note: with C language, cxx and cxx_version become cc and cc_version
local mylib_options = jln_getoptions({elide_type='on'})
buildoptions(mylib_options.buildoptions)
linkoptions(mylib_options.linkoptions)

-- or equivalent
jln_setoptions({elide_type='on'})

-- returns the merge of the default values and new value table
local values = jln_tovalues({elide_type='on'}, --[[disable_others:bool]])
print(values)

-- NOTE: for C, jln_ prefix function becomes jln_c_
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


## SCons

```py
# launch example: scons jln_sanitizers=on

import jln_options as jln

jln.set_global_flags({'rtti': 'off'})

vars = Variables(None, ARGUMENTS)
jln.add_variables(vars, {'debug':'on'}) # default value of debug to on

# get_flags(variables[, env]) -> {flags=[...], linkflags=[...]}
flags1 = jln.get_flags(vars)
flags2 = jln.get_flags({'debug':'on'})
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

Usage:

```
./compiler-options.lua [-h] [-p] [-c] [-o outfilebase]
                       [-t [-]{platform|compiler|linker}=name[,...]]
                       [-f [-]{option_name[=value_name][,...]}]
                       [-d option_name=value_name[,...]]
                       {generator} [options...]
```

```bash
./compiler-options.lua -f debug,warning generators/cmake.lua # only with debug and warning
./compiler-options.lua -f -debug,warning generators/cmake.lua # without debug nor warning
```

- `-p` Print an AST.
- `-c` for C, default is C++.
- `-t` Restrict to a list of platform, compiler or linker. When the list is prefixed with '-', values are removed from current AST.
- `-f` Restrict to a list of option/value. When the list is prefixed with `-`, options/values are removed.
- `-d` Set new default value. An empty string for `value_name` is equivalent to `default`.

## generators/compiler.lua

See `./compiler-options.lua generators/compiler.lua -h` for detailed usage information.

## generators/list_options.lua

$ `./compiler-options.lua generators/list_options.lua [--profile] [--color]`

Checks and displays options and their values.

## generators/{cmake,xmake,meson,premake5,bjam,scons}.lua

Generators for different build system.

$ `./compiler-options.lua [-o filebase] {generator} [option-prefix]`


# How to add or modify options?

Edit `compiler-options.lua` file.

The `MakeAST` function contains the options tree.

`_koptions` of `Vbase` contains the list of available options.
`_opts_by_category` a categorization of these options.


## Flags

- `c`, `cxx`, `flag`, `link`, `fl`

```lua
c'-Wall' -- C only
cxx'-Wall' -- C++ only
flag'-Wall' -- C and C++
link'-flto' -- Link option
fl'xxx' -- is a alias of {flag'xxx',link'xxx'}
```


## Compilers and linkers

- `gcc` for gcc or g++
- `clang` for clang or clang++
- `clang_cl` for clang-cl
- `clang_emcc` refers to the version of clang used by emcc
- `clang_like` refers to `clang`, `clang_cl` and `clang_emcc`
- `msvc` for cl
- `icc`
- `icl`
- `lld_link` for lld-link
- `ld64`

`icx`, `icpx`, `dpcpp` are equivalent to `clang`.

With `mingw`, the compiler is `gcc`.

version can be specified with `vers` or a compiler name and a parameter of the form `{operator}{major}.{minor}`.

```lua
gcc { ... } -- for gcc only
gcc'>=5' { ... } -- for >= gcc-5
gcc'>=5.3' { ... } -- for >= gcc-5.3
gcc'<5.3' { ... } -- for < gcc-5.3

gcc'>=5.3' { ... } -- equivalent to `gcc { vers'>=5.3' { ... } }`
```

## Platform

- `linux`
- `windows`
- `macos`
- `mingw` with `gcc` as compiler


## Options and levels

- `opt'name' { ... }`
- `lvl'name' { ... }`

```lua
opt'warnings' { -- if warnings is enabled (not `warnings=default`)
  lvl'off' { cxx'-w' } -- for `warnings=off`
}
```

- `has_opt'name' { ... }`

```lua
opt'warnings' {
  has_opt'symbols' { -- if symbols is enabled (not `symbols=default`)
    lvl'off' { cxx'-w' } -- for `warnings=off`
  }
}

has_opt'debug':with('gdb', 'on') { -- if debug is 'on' or 'gdb'
  ...
}
has_opt'debug':without('gdb', 'on') { -- if debug is not 'default', 'on' or 'gdb'
  ...
}
```

- `reset_opt'name'` for disabled an option

```lua
vers'<8' {
  reset_opt'lto' -- disable lto option when version < 8
}
```

## Conditions

- `Or(...)`
- `And(...)`

```lua
Or(gcc, clang, msvc) { ... }
And(gcc, lvl'off') { ... }
```

## if_mt

Compilers, linkers, platforms and condition returns a `if_mt`.

- `-xxx {...}` for `not xxx`
- `xxx {...} / yyy {...}` for `xxx or else yyy`

```lua
opt'warnings' { -lvl'on' { ... } } -- neither warnings=on nor warnings=default
lvl'on' { xxx } / { yyy } -- equivalent to `{ lvl'on' { xxx }, -lvl'on' { yyy } }`
```

Note: `-opt'name'` isn't allowed

## Others

- `if_else(cond, f)` = `cond { f(true) } / f()`
- `match(a,b,c,...)` = `a / b / c / ...`
- `act(data)` for a specific action hardcoded into a generator
  - cmake: `data` must be a table which can contain the keys:
    - `cxx`: add the value in `CMAKE_CXX_FLAGS` / `CMAKE_C_FLAGS`
    - `system_flag`: add the value in `CMAKE_INCLUDE_SYSTEM_FLAG_CXX` / `CMAKE_INCLUDE_SYSTEM_FLAG_C`.
