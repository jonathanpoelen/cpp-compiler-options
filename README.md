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


# Options

Supported options are listed below by category.
The same option can be found in several categories.

For a full description of options and values,
see [C++ Compiler Options reference](https://jonathanpoelen.github.io/cpp-compiler-options/)
or use the `list_options.lua` generator.

The first value corresponds to the one used by default,
and the value `default` has no associated behavior.

Options with a default value other than `default` are listed below.

<!-- ./compiler-options.lua generators/list_options.lua --color --categorized -->
```ini
# Warning options:

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


# Pedantic options:

pedantic = on default off as_error
stl_fix = on default off


# Debug options:

symbols = default hidden strip_all gc_sections nodebug debug minimal_debug full_debug btf codeview ctf ctf1 ctf2 vms vms1 vms2 vms3 dbx lldb sce dwarf
stl_hardening = default off fast extensive debug debug_with_broken_abi
sanitizers = default off on with_minimal_code_size extra extra_with_minimal_code_size address address_with_minimal_code_size thread undefined undefined_minimal_runtime scudo_hardened_allocator
var_init = default uninitialized pattern zero
emcc_debug = default off on slow
ndebug = with_optimization_1_or_above default off on
optimization = default 0 g 1 2 3 fast size z


# Optimization options:

cpu = default generic native
lto = default off on full thin_or_nothing whole_program whole_program_and_full_lto
optimization = default 0 g 1 2 3 fast size z
optimization_warnings = default off on


# C++ options:

exceptions = default off on
rtti = default off on


# Hardening options:

hardened = default off on all
stl_hardening = default off fast extensive debug debug_with_broken_abi


# Static Analyzer options:

analyzer = default off on with_external_headers
analyzer_too_complex_warning = default off on
analyzer_verbosity = default 0 1 2 3


# Other options:

bidi_char_warnings = any default any_and_ucn unpaired unpaired_and_ucn
color = default auto never always
coverage = default off on
diagnostics_format = default fixits patch print_source_range_info
diagnostics_show_template = default tree without_elided_types tree_without_elided_types
linker = default bfd gold lld mold native
msvc_diagnostics_format = caret default classic column
msvc_isystem = default anglebrackets include_and_caexcludepath external_as_include_system_flag assumed
msvc_isystem_with_template_instantiations_treated_as_non_external = default off on
windows_bigobj = on default
```
<!-- ./compiler-options.lua -->

If not specified:

- `bidi_char_warnings` is `any`
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

## To know

- `msvc_isystem=external_as_include_system_flag` is only available with `cmake`.
- `stl_hardening=debug`
  - msvc: unlike `stl_hardening=debug_with_broken_abi`, STL debugging is not enabled by this option, as it breaks the ABI (only hardening mode is enabled on recent versions). However, as the `_DEBUG` macro can be defined in many different ways, STL debugging can be activated and the ABI broken.


## Sanitizers

Some sanitizers activated at compile time are only realistically active in the presence of a configuration in an environment variable.
`sanitizers=on` does not include these sanitizers, unlike `sanitizers=extra`.
The environment variables to use are as follows:

```sh
# cl (Windows)
ASAN_OPTIONS=detect_stack_use_after_return=1

# gcc / clang (see -fsanitize=pointer-subtract and -fsanitize=pointer-compare)
ASAN_OPTIONS=detect_invalid_pointer_pairs=2

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
A useful pre-set to enable more aggressive diagnostics compared to the default behavior is given below:

```sh
ASAN_OPTIONS=\
strict_string_checks=1:\
detect_stack_use_after_return=1:\
check_initialization_order=1:\
strict_init_order=1:\
alloc_dealloc_mismatch=1
```

## Recommended options

Some of the recommendations here are already made by build systems.
These include `ndebug`, `symbols` and `optimization`.

category | options
---------|---------
debug | `emcc_debug=on` or `slow` (useless if Emscripten is not used)<br>`optimization=g` or `default`<br>`sanitizers=on` or `with_minimal_code_size`<br>`stl_hardening=debug_with_broken_abi` or `debug`<br>`symbols=debug` or `full_debug`<br>`var_init=pattern`
release | `cpu=native`<br>`lto=on`<br>`ndebug=on`<br>`optimization=3`<br>`rtti=off`<br>`symbols=strip_all`
security | `hardened=on`<br>`stl_hardening=fast` or `extensive`
really strict warnings | `pedantic=as_error`<br>`suggest_attributes=common`<br>`warnings=extensive`<br>`conversion_warnings=all`<br>`shadow_warnings=local`<br>`switch_warnings=exhaustive_enum`<br>`windows_abi_compatibility_warnings=on`

