```meson
# launch example: meson -Djln_sanitizers=on
# note: `meson --warnlevel=0` implies `--Djln_warnings=off`

project('test', 'cpp')

# default value (without prefix)
# optional
jln_default_flags = {'rtti': 'off'}

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

Supported options are (in alphabetical order):

<!-- ./compiler-options.lua generators/list_options.lua --color -->
```ini
color = default auto never always
control_flow = default off on branch return allow_bugs
coverage = default off on
cpu = default generic native
debug = default off on line_tables_only gdb lldb sce
diagnostics_format = default fixits patch print_source_range_info
diagnostics_show_template_tree = default off on
elide_type = default off on
exceptions = default off on
fix_compiler_error = on default off
linker = default bfd gold lld native
lto = default off on fat thin
msvc_isystem = default anglebrackets include_and_caexcludepath
msvc_isystem_with_template_from_non_external = default off on
optimization = default 0 g 1 2 3 fast size
pedantic = on default off as_error
pie = default off on pic
relro = default off on full
reproducible_build_warnings = default off on
rtti = default off on
sanitizers = default off on
sanitizers_extra = default off thread pointer
shadow_warnings = off default on local compatible_local all
stack_protector = default off on strong all
stl_debug = default off on allow_broken_abi allow_broken_abi_and_bugs assert_as_exception
stl_fix = on default off
suggestions = default off on
warnings = on default off strict very_strict
warnings_as_error = default off on basic
whole_program = default off on strip_all
```
<!-- ./compiler-options.lua -->

The value `default` does nothing.

If not specified, `fix_compiler_error`, `pedantic`, `stl_fix` and `warnings` are `on` ; `shadow_warnings` is `off`.

- `control_flow=allow_bugs`
  - clang: Can crash programs with "illegal hardware instruction" on totally unlikely lines. It can also cause link errors and force `-fvisibility=hidden` and `-flto`.
- `stl_debug=allow_broken_abi_and_bugs`
  - clang: libc++ can crash on dynamic memory releases in the standard classes. This bug is fixed with the library associated with version 8.


## Recommended options

category | options
---------|---------
debug | `control_flow=on`<br>`debug=on`<br>`sanitizers=on`<br>`stl_debug=allow_broken_abi` or `on`<br>
release | `cpu=native`<br>`linker=gold`, `lld` or `native`<br>`lto=on` or `thin`<br>`optimization=3`<br>`rtti=off`<br>`whole_program=strip_all`
security | `control_flow=on`<br>`relro=full`<br>`stack_protector=strong`
really strict warnings | `pedantic=as_error`<br>`shadow_warnings=local`<br>`suggestions=on`<br>`warnings=very_strict`

