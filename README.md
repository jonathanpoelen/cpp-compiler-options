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


# Options

Supported options are (alphabetically in a category):

<!-- ./compiler-options.lua generators/list_options.lua --color -->
```ini
# Warning:

analyzer = default off on taint
analyzer_too_complex_warning = default off on
analyzer_verbosity = default 0 1 2 3
conversion_warnings = on default off sign conversion
covered_switch_default_warnings = on default off
fix_compiler_error = on default off
msvc_crt_secure_no_warnings = on default off
noexcept_warnings = default off on
reproducible_build_warnings = default off on
shadow_warnings = off default on local compatible_local all
suggestions = default off on
switch_warnings = on default off exhaustive_enum mandatory_default exhaustive_enum_and_mandatory_default
warnings = on default off strict very_strict
warnings_as_error = default off on basic
windows_abi_compatibility_warnings = off default on

# Pedantic:

msvc_conformance = all default all_without_throwing_new
pedantic = on default off as_error
stl_fix = on default off

# Debug:

debug = default off on line_tables_only gdb lldb sce
float_sanitizers = default off on
integer_sanitizers = default off on
ndebug = with_optimization_1_or_above default off on
other_sanitizers = default off thread pointer memory
sanitizers = default off on
stl_debug = default off on allow_broken_abi allow_broken_abi_and_bugs assert_as_exception
var_init = default pattern

# Optimization:

cpu = default generic native
linker = default bfd gold lld native
lto = default off on fat thin
optimization = default 0 g 1 2 3 fast size z
whole_program = default off on strip_all

# C++:

exceptions = default off on
rtti = default off on

# Hardening:

control_flow = default off on branch return allow_bugs
relro = default off on full
stack_protector = default off on strong all

# Other:

color = default auto never always
coverage = default off on
diagnostics_format = default fixits patch print_source_range_info
diagnostics_show_template_tree = default off on
elide_type = default off on
msvc_isystem = default anglebrackets include_and_caexcludepath external_as_include_system_flag
msvc_isystem_with_template_from_non_external = default off on
pie = default off on static fpic fPIC fpie fPIE
windows_bigobj = on default
```
<!-- ./compiler-options.lua -->

The value `default` does nothing.

If not specified, `conversion_warnings`, `covered_switch_default_warnings`, `fix_compiler_error`, `msvc_crt_secure_no_warnings`, `pedantic`, `stl_fix`, `switch_warnings`, `warnings` and `windows_bigobj` are `on` ; `msvc_conformance` is `all` ; `ndebug` is `with_optimization_1_or_above` ; `shadow_warnings` and `windows_abi_compatibility_warnings` is `off`.

- `control_flow=allow_bugs`
  - clang: Can crash programs with "illegal hardware instruction" on totally unlikely lines. It can also cause link errors and force `-fvisibility=hidden` and `-flto`.
- `stl_debug=allow_broken_abi_and_bugs`
  - clang: libc++ can crash on dynamic memory releases in the standard classes. This bug is fixed with the library associated with version 8.
- `msvc_isystem=external_as_include_system_flag` is only available with `cmake`.


## Recommended options

category | options
---------|---------
debug | `control_flow=on`<br>`debug=on`<br>`sanitizers=on`<br>`stl_debug=allow_broken_abi` or `on`<br>
release | `cpu=native`<br>`linker=gold`, `lld` or `native`<br>`lto=on` or `thin`<br>`optimization=3`<br>`rtti=off`<br>`whole_program=strip_all`
security | `control_flow=on`<br>`relro=full`<br>`stack_protector=strong`<br>`pie=PIE`
really strict warnings | `pedantic=as_error`<br>`shadow_warnings=local`<br>`suggestions=on`<br>`warnings=very_strict`

