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

Supported options are (in alphabetical order):

<!-- ./compiler-options.lua generators/list_options.lua --color -->
```ini
color = default auto never always
control_flow = default off on branch return allow_bugs
conversion_warnings = on default off sign conversion
coverage = default off on
covered_switch_default_warnings = on default off
cpu = default generic native
debug = default off on line_tables_only gdb lldb sce
diagnostics_format = default fixits patch print_source_range_info
diagnostics_show_template_tree = default off on
elide_type = default off on
exceptions = default off on
fix_compiler_error = on default off
float_sanitizers = default off on
integer_sanitizers = default off on
linker = default bfd gold lld native
lto = default off on fat thin
microsoft_abi_compatibility_warnings = off default on
msvc_isystem = default anglebrackets include_and_caexcludepath external_as_include_system_flag
msvc_isystem_with_template_from_non_external = default off on
noexcept_warnings = default off on
optimization = default 0 g 1 2 3 fast size z
other_sanitizers = default off thread pointer memory
pedantic = on default off as_error
pie = default off on static fpic fPIC fpie fPIE
relro = default off on full
reproducible_build_warnings = default off on
rtti = default off on
sanitizers = default off on
shadow_warnings = off default on local compatible_local all
stack_protector = default off on strong all
stl_debug = default off on allow_broken_abi allow_broken_abi_and_bugs assert_as_exception
stl_fix = on default off
suggestions = default off on
switch_warnings = on default off enum mandatory_default
warnings = on default off strict very_strict
warnings_as_error = default off on basic
whole_program = default off on strip_all
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

