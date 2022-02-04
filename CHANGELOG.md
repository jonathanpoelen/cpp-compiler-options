# ChangeLog

## 2022-02-04

- add `msvc_bigobj` (`on`)
- add `msvc_conformance` (`all`, `all_without_throwing_new`)
- add `msvc_crt_secure_no_warnings` (`on`, `off`)

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
