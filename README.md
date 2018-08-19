Compilation options for different versions of Clang and GCC. Provided a generator and different file formats (`cmake`, `premake5`, `bjam`/`b2`, ...).

The `output` directory contains files for `cmake`, `bjam` and command-line options for `gcc` and `clang`.

$ `g++ @output/gcc-6.1-warnings -fsyntax-only -x c++ - <<<'int* p = 0;'`

> <stdin>:1:10: warning: zero as null pointer constant \[-Wzero-as-null-pointer-constant]

$ `cmake -DJLN_FAST_MATH=on`

$ `premake5 --jln-fast-math=on`

$ `bjam jln-fast-math=on`

(`jln-` is a parameterizable prefix, see generate.sh)

Supported options are:

<!-- ./compiler-options.lua generators/options.lua -->
```
color = default auto never always
coverage = off on
debug = off on
fast_math = off on
glibcxx_debug = off on allow_broken_abi
lto = off on fat
optimize = default off on size speed full
pedantic = on off as_error
relro = default off on full
report_template = off on
sanitizers = off on
sanitizers_extra = off thread pointer
stack_protector = off on strong all
suggests = off on
warnings = on off strict
warnings_as_error = off on
```


# Cmake Generator

```cmake
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


# Premake5 Generator

```lua
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

# Bjam/B2 Generator

```jam
project name : requirements
  <jln-lto>on # enable jln-lto
  <conditional>@jln_flags
: default-build release ;
```
