```cmake
# launch example: cmake -DJLN_SANITIZERS=on
include(cpp.cmake)

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
fix_compiler_error = on default off
msvc_crt_secure_no_warnings = on default off
noexcept_warnings = default off on
reproducible_build_warnings = default off on
shadow_warnings = off default on local compatible_local all
suggestions = default off on
switch_warnings = on default off exhaustive_enum mandatory_default exhaustive_enum_and_mandatory_default
unsafe_buffer_usage_warnings = default on off
windows_abi_compatibility_warnings = off default on

# Pedantic:

msvc_conformance = all default all_without_throwing_new
pedantic = on default off as_error
stl_fix = on default off

# Debug:

debug = default off on gdb lldb vms codeview dbx sce
debug_level = default 0 1 2 3 line_tables_only line_directives_only
stl_hardening = default off fast extensive debug debug_with_broken_abi
control_flow = default off on branch return allow_bugs
sanitizers = default off on
float_sanitizers = default off on
integer_sanitizers = default off on
other_sanitizers = default off thread pointer memory
var_init = default uninitialized pattern zero
ndebug = with_optimization_1_or_above default off on
optimization = default 0 g 1 2 3 fast size z

# Optimization:

cpu = default generic native
linker = default bfd gold lld mold native
lto = default off on normal fat thin
optimization = default 0 g 1 2 3 fast size z
whole_program = default off on strip_all

# C++:

exceptions = default off on
rtti = default off on

# Hardening:

control_flow = default off on branch return allow_bugs
relro = default off on full
stack_protector = default off on strong all
stl_hardening = default off fast extensive debug debug_with_broken_abi

# Analyzer:

analyzer = default off on
analyzer_too_complex_warning = default off on
analyzer_verbosity = default 0 1 2 3

# Other:

color = default auto never always
coverage = default off on
diagnostics_format = default fixits patch print_source_range_info
diagnostics_show_template_tree = default off on
elide_type = default off on
msvc_diagnostics_format = caret default classic column
msvc_isystem = default anglebrackets include_and_caexcludepath external_as_include_system_flag assumed
msvc_isystem_with_template_from_non_external = default off on
pie = default off on static fpic fPIC fpie fPIE
windows_bigobj = on default
```
<!-- ./compiler-options.lua -->

If not specified:

- `msvc_conformance` is `all`
- `msvc_diagnostics_format` is `caret`
- `ndebug` is `with_optimization_1_or_above`
- The following values are `off`:
  - `shadow_warnings`
  - `windows_abi_compatibility_warnings`
- The following values are `on`:
  - `conversion_warnings`
  - `covered_switch_default_warnings`
  - `fix_compiler_error`
  - `msvc_crt_secure_no_warnings`
  - `pedantic`
  - `stl_fix`
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


## Recommended options

category | options
---------|---------
debug | `control_flow=on`<br>`debug=on`<br>`sanitizers=on`<br>`stl_hardening=debug_with_broken_abi` or `debug`<br>`optimization=g` or `optimization=0` + `debug_level=3`
release | `cpu=native`<br>`lto=on` or `thin`<br>`optimization=3`<br>`rtti=off`<br>`whole_program=strip_all`
security | `control_flow=on`<br>`relro=full`<br>`stack_protector=strong`<br>`pie=fPIE`<br>`stl_hardening=fast` or `extensive`
really strict warnings | `pedantic=as_error`<br>`shadow_warnings=local`<br>`suggestions=on`<br>`warnings=extensive`

