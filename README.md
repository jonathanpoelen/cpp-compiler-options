Compilation options for different versions of Clang and GCC. Provided a generator and different file formats (`bjam`, `cmake`, ...).

The `output` directory contains files for `cmake`, `bjam` and command-line options for `gcc` and `clang`.

$ `g++ @output/gcc-6.1-warnings -fsyntax-only -x c++ - <<<'int* p = 0;'`

> <stdin>:1:10: warning: zero as null pointer constant \[-Wzero-as-null-pointer-constant]

$ `bjam jln-fast-math=on`

$ `cmake jln-fast-math=on`

(The `jln-` is a parameterizable prefix, see generate.sh)

Supported options are:

<!-- ./compiler-options.lua generators/options.lua -->
```
lto = off on fat
coverage = off on
debug = on off
fast_math = off on
optimize = default off on size speed full
pedantic = on off
stack_protector = off on strong all
relro = default off on full
suggest = off on
glibcxx_debug = off on allow_broken_abi
warnings = on off strict
sanitizers = off on
warnings_as_error = off on
report_template = off on
```
