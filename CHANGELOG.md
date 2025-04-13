# ChangeLog

- remove `warnings=strict` and `warnings=very_strict`
- add `warnings=essential` and `warnings=extensive`
- add `conversion_warnings=all`
- add `conversion_warnings=float`
- add `msvc_isystem=assumed`

## 2024-04-06

- remove `stl_debug` (replaced by `stl_hardening`)
- add `stl_hardening` (default off fast extensive debug debug_with_broken_abi)
- remove `analyzer=taint`

## 2024-03-23

- remove `stl_debug=assert_as_exception`
- add `stl_debug=extensive`
- add `stl_debug=debug`
- remove `debug=line_tables_only`
- add `debug=gdb`
- add `debug=vms`
- add `debug=dbx`
- add `debug=sce`
- add `debug_level` (`0`, `1`, `2`, `3`, `line_tables_only`, `line_directives_only`)
- add `linker=mold`

## 2023-09-30

- add `unsafe_buffer_usage_warnings` (`on`, `off`).

## 2023-09-19

- add `msvc_diagnostics_format` (`caret`, `classic`, `column`), default is `caret`
- `switch_warnings` and `covered_switch_default_warnings` are now separated from `warnings`

## 2022-11-19

- add `var_init=uninitialized` and `var_init=zero`

## 2022-06-20

- add emscripten compiler

## 2022-06-12

- add `var_init=pattern`

## 2022-06-07

- meson: add `jln_buildtype_flags` (options for specific buildtype)

## 2022-06-06

- xmake: new API

## 2022-02-20

- scons: new API

## 2022-02-14

- add icc, icl and icx compilers
- fix C compiler version checking with CMake

## 2022-02-06

- rename `microsoft_abi_compatibility_warnings` to `windows_abi_compatibility_warnings`
- add `windows_bigobj` (`on`), default is `on`
- add `msvc_conformance` (`all`, `all_without_throwing_new`), default is `all`
- add `msvc_crt_secure_no_warnings` (`on`, `off`), default is `on`

## 2021-10-29

- add `switch_warnings=exhaustive_enum_and_mandatory_default`

## 2021-10-28

- rename `switch_warnings=enum` to `switch_warnings=exhaustive_enum`

## 2021-10-24

- rename `microsoft_abi_compatibility_warning` to `microsoft_abi_compatibility_warnings`
- rename `warnings_covered_switch_default` to `covered_switch_default_warnings`
- rename `sanitizers_extra` to `other_sanitizers`
- rename `warnings_switch` to `switch_warnings`
- rename `pie=pic` to `pie=fpic`
- add `memory` value with `other_sanitizers`
- add `static`, `fPIC`, `fpie` and `fPIE` values with `pie`
- add `float_sanitizers` (`on`, `off`)
- add `integer_sanitizers` (`on`, `off`)
- add `noexcept_warnings` (`on`, `off`)
