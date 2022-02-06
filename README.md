```py
# launch example: scons jln_sanitizers=on

from jln_options import *

# jln_set_global_flags(options, compiler=None, version=None, linker=None)
# version is a string. Ex: '7.2' or '5'
jln_set_global_flags({'rtti': 'off'})

vars = Variables(None, ARGUMENTS)
jln_add_variables(vars, {'debug':'on'}) # default value of debug to on

# {flags=[...], linkflags=[...]}
flags1 = jln_flags(vars)
flags2 = jln_flags({'debug':'on'})
```


# Options

Supported options are (alphabetically in a category):

<!-- ./compiler-options.lua generators/list_options.lua --color -->
```ini
# Warning:

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

control_flow = default off on branch return allow_bugs
relro = default off on full
stack_protector = default off on strong all

# Other:

windows_bigobj = on default

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

If not specified, `conversion_warnings`, `covered_switch_default_warnings`, `fix_compiler_error`, `msvc_crt_secure_no_warnings`, `pedantic`, `stl_fix`, `switch_warnings`, `warnings` and `windows_bigobj` are `on` ; `msvc_conformance` are `all` ; `shadow_warnings` and `windows_abi_compatibility_warnings` are `off`.

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

