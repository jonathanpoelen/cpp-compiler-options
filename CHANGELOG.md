# ChangeLog

## 2025-05-13

- remove `control_flow`
- remove `pie`
- remove `relro`
- remove `sanitizers=kernel`
- remove `sanitizers=kernel_extra`
- remove `sanitizers=kernel_address`
- remove `stack_protector`
- add `emcc_debug` (`off`, `on`, `slow`)
- add `hardened` (`off`, `on`, `all`)
- add `sanitizers=with_minimal_code_size`
- add `sanitizers=extra_with_minimal_code_size`
- add `sanitizers=address_with_minimal_code_size`

## 2025-05-09

- remove `debug` and `debug_level` (replaced by `symbols`)
- remove `fix_compiler_error` (merged with `pedantic`)
- remove `float_sanitizers`, `integer_sanitizers` and `other_sanitizers`
- remove `lto=normal` (replaced with `lto=full`)
- remove `lto=fat`
- remove `suggestions` (replaced by `suggest_attributes`)
- remove `whole_program` (replaced by `lto` and `symbols=strip_all` / `symbols=gc_sections`)
- rename `msvc_isystem_with_template_from_non_external` to `msvc_isystem_with_template_instantiations_treated_as_non_external`
- add `analyzer=with_external_headers`
- add `lto=full`
- add `lto=thin_or_nothing`
- add `lto=whole_program`
- add `lto=whole_program_and_full_lto`
- add `sanitizers=extra`
- add `sanitizers=address`
- add `sanitizers=kernel`
- add `sanitizers=kernel_extra`
- add `sanitizers=kernel_address`
- add `sanitizers=thread`
- add `sanitizers=undefined`
- add `sanitizers=undefined_minimal_runtime`
- add `sanitizers=scudo_hardened_allocator`
- add `suggest_attributes` (`on`, `off`, `common`, `analysis`, `unity`, `all`)
- add `symbols` (`hidden`, `strip_all`, `gc_sections`, `nodebug`, `debug`, `minimal_debug`, `full_debug`, `btf`, `ctf`, `ctf1`, `ctf2`, `vms`, `vms1`, `vms2`, `vms3`, `codeview`, `dbx`, `lldb`, `sce`, `dwarf`)

## 2025-04-14

- remove `warnings=strict` and `warnings=very_strict`
- add `warnings=essential` and `warnings=extensive`
- add `conversion_warnings=all`
- add `conversion_warnings=float`
- add `msvc_isystem=assumed`

## 2025-04-06

- remove `stl_debug` (replaced by `stl_hardening`)
- add `stl_hardening` (`off`, `fast`, `extensive`, `debug`, `debug_with_broken_abi`)
- remove `analyzer=taint`

## 2025-03-23

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
