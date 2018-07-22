Compilation options for different versions of Clang and GCC. Provided a generator and different file formats (`cmake`, `premake5`, `bjam/`b2`, ...).

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
coverage = off on
debug = off on
fast_math = off on
glibcxx_debug = off on allow_broken_abi
lto = off on fat
optimize = default off on size speed full
pedantic = on off
relro = default off on full
report_template = off on
sanitizers = off on
sanitizers_extra = off thread pointer
stack_protector = off on strong all
suggest = off on
warnings = on off strict
warnings_as_error = off on
```

# Cmake Generator

```cmake
set(JLN_DEBUG "on" CACHE STRING "") # set a default value
include(output/cmake)
add_definitions(${JLN_CXX_FLAGS})
link_libraries(${JLN_LINK_FLAGS})
```

```bash
cmake JLN_VERBOSE=on
```

# Premake Generator

```lua
jln_newoptions([options]) -- Registers new command-line options (ex jln_newoptions({debug='on'}))
jln_getoptions([compiler[, version:string]]) -- return {buildoptions=string, linkoptions=string}
jln_setoptions([compiler[, version:string]]) -- return {buildoptions=string, linkoptions=string}
```

# Bjam/B2 Generator

```jam
project name : requirements
  <conditional>@jln_flags
: default-build release ;
```
