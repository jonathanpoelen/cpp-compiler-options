```cmake
# launch example: cmake -DJLN_SANITIZERS=on
include(cpp.cmake)

# init default values
# jln_init_flags(
#     [jln-option> <default_value>]...
#     [AUTO_PROFILE on]
#     [VERBOSE on]
#     [BUILD_TYPE type [jln-option> <default_value>]...]...
# )
# AUTO_PROFILE: enables options based on CMAKE_BUILD_TYPE (assumes "Debug" if CMAKE_BUILD_TYPE is empty)
# BUILD_TYPE: enables following options only if ${CMAKE_BUILD_TYPE} has the same value (CMAKE_BUILD_TYPE assumed to Debug if empty)
jln_init_flags(
  SUGGESTIONS on                  # set SUGGESTIONS default value to "on"
  BUILD_TYPE debug SANITIZERS on  # set SANITIZERS default value to "on" only in Debug build
  BUILD_TYPE release LTO on       # set LTO default value to "on" only in Release build
)


# jln_target_interface(
#     <libname> {INTERFACE|PUBLIC|PRIVATE}
#     [<jln-option> <value>]...
#     [DISABLE_OTHERS {on|off}]
#     [BUILD_TYPE type [jln-option> <value>]...]...
# )
jln_target_interface(mytarget1 INTERFACE WARNINGS very_strict) # set WARNINGS to "very_strict"


# jln_flags(
#     CXX_VAR <out-variable>
#     LINK_VAR <out-variable>
#     [<jln-option> <value>]...
#     [DISABLE_OTHERS {on|off}]
#     [BUILD_TYPE type [jln-option> <value>]...]...
# )
jln_flags(CXX_VAR CXX_FLAGS LINK_VAR LINK_FLAGS WARNINGS very_strict)

target_link_libraries(mytarget2 INTERFACE ${LINK_FLAGS})
target_compile_options(mytarget2 INTERFACE ${CXX_FLAGS})

# NOTE: for C, jln_ prefix function becomes jln_c_ and CXX_VAR becomes C_VAR
```


# Options

Supported options are (alphabetically in a category):

<!-- ./compiler-options.lua generators/list_options.lua --color -->
```ini
# Warning:

conversion_warnings = on default off sign conversion
covered_switch_default_warnings = on default off
fix_compiler_error = on default off
microsoft_abi_compatibility_warnings = off default on
noexcept_warnings = default off on
reproducible_build_warnings = default off on
shadow_warnings = off default on local compatible_local all
suggestions = default off on
switch_warnings = on default off exhaustive_enum mandatory_default exhaustive_enum_and_mandatory_default
warnings = on default off strict very_strict
warnings_as_error = default off on basic

# Pedantic:

pedantic = on default off as_error
stl_fix = on default off

# Debug:

control_flow = default off on branch return allow_bugs
debug = default off on line_tables_only gdb lldb sce
float_sanitizers = default off on
integer_sanitizers = default off on
other_sanitizers = default off thread pointer memory
sanitizers = default off on
stl_debug = default off on allow_broken_abi allow_broken_abi_and_bugs assert_as_exception

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
```
<!-- ./compiler-options.lua -->

The value `default` does nothing.

If not specified, `conversion_warnings`, `covered_switch_default_warnings`, `fix_compiler_error`, `pedantic`, `stl_fix`, `switch_warnings` and `warnings` are `on` ; `microsoft_abi_compatibility_warnings` and `shadow_warnings` are `off`.

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

