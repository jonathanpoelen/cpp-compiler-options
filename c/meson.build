#  ```meson
#  # launch example: meson -Djln_sanitizers=on
#  # note: `meson --warnlevel=0` implies `--Djln_warnings=off`
#  
#  project('test', 'cpp')
#  
#  # default value (without prefix)
#  # optional
#  jln_default_flags = {'rtti': 'off'}
#  
#  # optional
#  jln_custom_flags = [
#    {'rtti': 'off', 'optimization': '3'}, # (0) opti flags
#    {'debug': 'on'}, # (1) debug flags
#    # { ... } # (2)
#    # etc
#  ]
#  
#  # declare jln_link_flags, jln_cpp_flags, jln_custom_cpp_flags and jln_custom_link_flags
#  subdir('meson_jln_flags')
#  
#  my_opti_cpp_flags = jln_custom_cpp_flags[0] # (0) opti flags (see above)
#  my_opti_link_flags = jln_custom_link_flags[0]
#  my_debug_cpp_flags = jln_custom_cpp_flags[1] # (1) debug flags (see above)
#  my_debug_link_flags = jln_custom_link_flags[1]
#  # my_... = jln_custom_cpp_flags[2] # (2)
#  # my_... = jln_custom_link_flags[2]
#  # etc
#  
#  executable('demo', 'main.cpp', link_args: jln_link_flags, cpp_args: jln_cpp_flags)
#  
#  # NOTE: for C, jln_ prefix becomes jln_c_
#  ```
#  
#  
#  # Options
#  
#  Supported options are (alphabetically in a category):
#  
#  <!-- ./compiler-options.lua generators/list_options.lua --color -->
#  ```ini
#  Warning:
#  
#  conversion_warnings = on default off sign conversion
#  covered_switch_default_warnings = on default off
#  fix_compiler_error = on default off
#  microsoft_abi_compatibility_warnings = off default on
#  noexcept_warnings = default off on
#  reproducible_build_warnings = default off on
#  shadow_warnings = off default on local compatible_local all
#  suggestions = default off on
#  switch_warnings = on default off enum mandatory_default
#  warnings = on default off strict very_strict
#  warnings_as_error = default off on basic
#  
#  Pedantic:
#  
#  pedantic = on default off as_error
#  stl_fix = on default off
#  
#  Debug:
#  
#  control_flow = default off on branch return allow_bugs
#  debug = default off on line_tables_only gdb lldb sce
#  float_sanitizers = default off on
#  integer_sanitizers = default off on
#  other_sanitizers = default off thread pointer memory
#  sanitizers = default off on
#  stl_debug = default off on allow_broken_abi allow_broken_abi_and_bugs assert_as_exception
#  
#  Optimization:
#  
#  cpu = default generic native
#  linker = default bfd gold lld native
#  lto = default off on fat thin
#  optimization = default 0 g 1 2 3 fast size z
#  whole_program = default off on strip_all
#  
#  C++:
#  
#  exceptions = default off on
#  rtti = default off on
#  
#  Hardening:
#  
#  relro = default off on full
#  stack_protector = default off on strong all
#  
#  Other:
#  
#  color = default auto never always
#  coverage = default off on
#  diagnostics_format = default fixits patch print_source_range_info
#  diagnostics_show_template_tree = default off on
#  elide_type = default off on
#  msvc_isystem = default anglebrackets include_and_caexcludepath external_as_include_system_flag
#  msvc_isystem_with_template_from_non_external = default off on
#  pie = default off on static fpic fPIC fpie fPIE
#  ```
#  <!-- ./compiler-options.lua -->
#  
#  The value `default` does nothing.
#  
#  If not specified, `conversion_warnings`, `covered_switch_default_warnings`, `fix_compiler_error`, `pedantic`, `stl_fix`, `switch_warnings` and `warnings` are `on` ; `microsoft_abi_compatibility_warnings` and `shadow_warnings` are `off`.
#  
#  - `control_flow=allow_bugs`
#    - clang: Can crash programs with "illegal hardware instruction" on totally unlikely lines. It can also cause link errors and force `-fvisibility=hidden` and `-flto`.
#  - `stl_debug=allow_broken_abi_and_bugs`
#    - clang: libc++ can crash on dynamic memory releases in the standard classes. This bug is fixed with the library associated with version 8.
#  - `msvc_isystem=external_as_include_system_flag` is only available with `cmake`.
#  
#  
#  ## Recommended options
#  
#  category | options
#  ---------|---------
#  debug | `control_flow=on`<br>`debug=on`<br>`sanitizers=on`<br>`stl_debug=allow_broken_abi` or `on`<br>
#  release | `cpu=native`<br>`linker=gold`, `lld` or `native`<br>`lto=on` or `thin`<br>`optimization=3`<br>`rtti=off`<br>`whole_program=strip_all`
#  security | `control_flow=on`<br>`relro=full`<br>`stack_protector=strong`<br>`pie=PIE`
#  really strict warnings | `pedantic=as_error`<br>`shadow_warnings=local`<br>`suggestions=on`<br>`warnings=very_strict`
#  
#  

# File generated with https://github.com/jonathanpoelen/cpp-compiler-options

___jln_c_default_flags = get_variable('jln_c_default_flags', {})
if get_option('warning_level') == '0'
  ___jln_c_warnings = 'off'
else
  ___jln_c_warnings = ___jln_c_default_flags.get('warnings', get_option('jln_warnings'))
endif
___jln_c_flags = {
  'color': ___jln_c_default_flags.get('color', get_option('jln_color')),
  'control_flow': ___jln_c_default_flags.get('control_flow', get_option('jln_control_flow')),
  'conversion_warnings': ___jln_c_default_flags.get('conversion_warnings', get_option('jln_conversion_warnings')),
  'coverage': ___jln_c_default_flags.get('coverage', get_option('jln_coverage')),
  'covered_switch_default_warnings': ___jln_c_default_flags.get('covered_switch_default_warnings', get_option('jln_covered_switch_default_warnings')),
  'cpu': ___jln_c_default_flags.get('cpu', get_option('jln_cpu')),
  'debug': ___jln_c_default_flags.get('debug', get_option('jln_debug')),
  'diagnostics_format': ___jln_c_default_flags.get('diagnostics_format', get_option('jln_diagnostics_format')),
  'diagnostics_show_template_tree': ___jln_c_default_flags.get('diagnostics_show_template_tree', get_option('jln_diagnostics_show_template_tree')),
  'elide_type': ___jln_c_default_flags.get('elide_type', get_option('jln_elide_type')),
  'exceptions': ___jln_c_default_flags.get('exceptions', get_option('jln_exceptions')),
  'fix_compiler_error': ___jln_c_default_flags.get('fix_compiler_error', get_option('jln_fix_compiler_error')),
  'float_sanitizers': ___jln_c_default_flags.get('float_sanitizers', get_option('jln_float_sanitizers')),
  'integer_sanitizers': ___jln_c_default_flags.get('integer_sanitizers', get_option('jln_integer_sanitizers')),
  'linker': ___jln_c_default_flags.get('linker', get_option('jln_linker')),
  'lto': ___jln_c_default_flags.get('lto', get_option('jln_lto')),
  'microsoft_abi_compatibility_warnings': ___jln_c_default_flags.get('microsoft_abi_compatibility_warnings', get_option('jln_microsoft_abi_compatibility_warnings')),
  'msvc_isystem': ___jln_c_default_flags.get('msvc_isystem', get_option('jln_msvc_isystem')),
  'msvc_isystem_with_template_from_non_external': ___jln_c_default_flags.get('msvc_isystem_with_template_from_non_external', get_option('jln_msvc_isystem_with_template_from_non_external')),
  'noexcept_warnings': ___jln_c_default_flags.get('noexcept_warnings', get_option('jln_noexcept_warnings')),
  'optimization': ___jln_c_default_flags.get('optimization', get_option('jln_optimization')),
  'other_sanitizers': ___jln_c_default_flags.get('other_sanitizers', get_option('jln_other_sanitizers')),
  'pedantic': ___jln_c_default_flags.get('pedantic', get_option('jln_pedantic')),
  'pie': ___jln_c_default_flags.get('pie', get_option('jln_pie')),
  'relro': ___jln_c_default_flags.get('relro', get_option('jln_relro')),
  'reproducible_build_warnings': ___jln_c_default_flags.get('reproducible_build_warnings', get_option('jln_reproducible_build_warnings')),
  'rtti': ___jln_c_default_flags.get('rtti', get_option('jln_rtti')),
  'sanitizers': ___jln_c_default_flags.get('sanitizers', get_option('jln_sanitizers')),
  'shadow_warnings': ___jln_c_default_flags.get('shadow_warnings', get_option('jln_shadow_warnings')),
  'stack_protector': ___jln_c_default_flags.get('stack_protector', get_option('jln_stack_protector')),
  'stl_debug': ___jln_c_default_flags.get('stl_debug', get_option('jln_stl_debug')),
  'stl_fix': ___jln_c_default_flags.get('stl_fix', get_option('jln_stl_fix')),
  'suggestions': ___jln_c_default_flags.get('suggestions', get_option('jln_suggestions')),
  'switch_warnings': ___jln_c_default_flags.get('switch_warnings', get_option('jln_switch_warnings')),
  'warnings': ___jln_c_warnings,
  'warnings_as_error': ___jln_c_default_flags.get('warnings_as_error', get_option('jln_warnings_as_error')),
  'whole_program': ___jln_c_default_flags.get('whole_program', get_option('jln_whole_program')),
}

jln_c_custom_c_flags = []
jln_c_custom_link_flags = []

___jln_c_compiler = meson.get_compiler('c')
___jln_c_compiler_id = ___jln_c_compiler.get_id()
___jln_c_compiler_version = ___jln_c_compiler.version()
___jln_c_linker_id = ___jln_c_compiler.get_linker_id()

___jln_c_custom_flags = get_variable('jln_c_custom_flags', []) + [___jln_c_flags]

foreach ___jln_c_flags : ___jln_c_custom_flags
  jln_c_c_flags = []
  jln_c_link_flags = []


  if (  ( (___jln_c_compiler_id == 'gcc') or (___jln_c_compiler_id == 'clang') or (___jln_c_compiler_id == 'clang-cl') ) )
    if (  not ( (___jln_c_flags.get('warnings', 'default') == 'default')) )
      if (  (___jln_c_flags.get('warnings', 'default') == 'off') )
        jln_c_c_flags += ['-w', ]
      else
        if (  (___jln_c_compiler_id == 'gcc') )
            jln_c_c_flags += ['-Wall', '-Wextra', '-Wcast-align', '-Wcast-qual', '-Wdisabled-optimization', '-Wfloat-equal', '-Wformat-security', '-Wformat=2', '-Wmissing-include-dirs', '-Wpacked', '-Wredundant-decls', '-Wundef', '-Wunused-macros', '-Winvalid-pch', '-Wpointer-arith', '-Wbad-function-cast', '-Winit-self', '-Wjump-misses-init', '-Wnested-externs', '-Wold-style-definition', '-Wstrict-prototypes', '-Wwrite-strings', ]
          if (  not ( (___jln_c_flags.get('switch_warnings', 'default') == 'default')) )
            if (  (___jln_c_flags.get('switch_warnings', 'default') == 'on') )
              jln_c_c_flags += ['-Wswitch', ]
            else
              if (  (___jln_c_flags.get('switch_warnings', 'default') == 'enum') )
                jln_c_c_flags += ['-Wswitch-enum', ]
              else
                if (  (___jln_c_flags.get('switch_warnings', 'default') == 'mandatory_default') )
                  jln_c_c_flags += ['-Wswitch-default', ]
                else
                  jln_c_c_flags += ['-Wno-switch', ]
                endif
              endif
            endif
          endif
          if (  not ( ___jln_c_compiler_version.version_compare('<4.7') ) )
            jln_c_c_flags += ['-Wsuggest-attribute=noreturn', '-Wlogical-op', '-Wvector-operation-performance', '-Wdouble-promotion', '-Wtrampolines', ]
            if (  not ( ___jln_c_compiler_version.version_compare('<4.8') ) )
              if (  not ( ___jln_c_compiler_version.version_compare('<4.9') ) )
                jln_c_c_flags += ['-Wfloat-conversion', ]
                if (  not ( ___jln_c_compiler_version.version_compare('<5.1') ) )
                  jln_c_c_flags += ['-Wformat-signedness', '-Warray-bounds=2', ]
                  if (  not ( ___jln_c_compiler_version.version_compare('<6.1') ) )
                    jln_c_c_flags += ['-Wduplicated-cond', '-Wnull-dereference', ]
                    if (  not ( ___jln_c_compiler_version.version_compare('<7.0') ) )
                      if (  not ( ___jln_c_compiler_version.version_compare('<7.1') ) )
                        jln_c_c_flags += ['-Walloc-zero', '-Walloca', '-Wformat-overflow=2', '-Wduplicated-branches', ]
                      endif
                    endif
                  endif
                endif
              endif
            endif
          endif
        else
          if (  ( (___jln_c_compiler_id == 'clang') or (___jln_c_compiler_id == 'clang-cl') ) )
              jln_c_c_flags += ['-Weverything', '-Wno-documentation', '-Wno-documentation-unknown-command', '-Wno-newline-eof', '-Wno-padded', '-Wno-global-constructors', ]
            if (  not ( (___jln_c_flags.get('switch_warnings', 'default') == 'default')) )
              if (  (___jln_c_flags.get('switch_warnings', 'default') == 'on') )
                jln_c_c_flags += ['-Wno-switch-enum', ]
              else
                if (  (___jln_c_flags.get('switch_warnings', 'default') == 'enum') )
                  jln_c_c_flags += ['-Wswitch-enum', ]
                else
                  if (  (___jln_c_flags.get('switch_warnings', 'default') == 'off') )
                    jln_c_c_flags += ['-Wno-switch', '-Wno-switch-enum', ]
                  endif
                endif
              endif
            else
              jln_c_c_flags += ['-Wno-switch', '-Wno-switch-enum', ]
            endif
            if (  not ( (___jln_c_flags.get('covered_switch_default_warnings', 'default') == 'default')) )
              if (  (___jln_c_flags.get('covered_switch_default_warnings', 'default') == 'off') )
                jln_c_c_flags += ['-Wno-covered-switch-default', ]
              endif
            endif
          endif
        endif
        if (  ( (___jln_c_flags.get('warnings', 'default') == 'strict') or (___jln_c_flags.get('warnings', 'default') == 'very_strict') ) )
          if (  ( (___jln_c_compiler_id == 'gcc') and not ( ___jln_c_compiler_version.version_compare('<8.0') ) ) )
            jln_c_c_flags += ['-Wcast-align=strict', ]
          endif
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('conversion_warnings', 'default') == 'default')) )
      if (  (___jln_c_flags.get('conversion_warnings', 'default') == 'on') )
        jln_c_c_flags += ['-Wconversion', '-Wsign-compare', '-Wsign-conversion', ]
      else
        if (  (___jln_c_flags.get('conversion_warnings', 'default') == 'conversion') )
          jln_c_c_flags += ['-Wconversion', ]
        else
          if (  (___jln_c_flags.get('conversion_warnings', 'default') == 'sign') )
            jln_c_c_flags += ['-Wsign-compare', '-Wsign-conversion', ]
          else
            jln_c_c_flags += ['-Wno-conversion', '-Wno-sign-compare', '-Wno-sign-conversion', ]
          endif
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('warnings_as_error', 'default') == 'default')) )
      if (  (___jln_c_flags.get('warnings_as_error', 'default') == 'on') )
        jln_c_c_flags += ['-Werror', ]
      else
        if (  (___jln_c_flags.get('warnings_as_error', 'default') == 'basic') )
          jln_c_c_flags += ['-Werror=return-type', '-Werror=init-self', ]
          if (  (___jln_c_compiler_id == 'gcc') )
            jln_c_c_flags += ['-Werror=div-by-zero', ]
            if (  not ( ___jln_c_compiler_version.version_compare('<5.1') ) )
              jln_c_c_flags += ['-Werror=array-bounds', '-Werror=logical-op', '-Werror=logical-not-parentheses', ]
            endif
          else
            if (  ( (___jln_c_compiler_id == 'clang') or (___jln_c_compiler_id == 'clang-cl') ) )
              jln_c_c_flags += ['-Werror=array-bounds', '-Werror=division-by-zero', ]
              if (  not ( ___jln_c_compiler_version.version_compare('<3.4') ) )
                jln_c_c_flags += ['-Werror=logical-not-parentheses', ]
              endif
            endif
          endif
        else
          jln_c_c_flags += ['-Wno-error', ]
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('suggestions', 'default') == 'default')) )
      if (  not ( (___jln_c_flags.get('suggestions', 'default') == 'off') ) )
        if (  (___jln_c_compiler_id == 'gcc') )
          jln_c_c_flags += ['-Wsuggest-attribute=pure', '-Wsuggest-attribute=const', ]
          if (  not ( ___jln_c_compiler_version.version_compare('<5.0') ) )
            if (  not ( ___jln_c_compiler_version.version_compare('<5.1') ) )
              jln_c_c_flags += ['-Wnoexcept', ]
            endif
          endif
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('sanitizers', 'default') == 'default')) )
      if (  (___jln_c_flags.get('sanitizers', 'default') == 'off') )
        jln_c_c_flags += ['-fno-sanitize=all', ]
        jln_c_link_flags += ['-fno-sanitize=all', ]
      else
        if (  (___jln_c_compiler_id == 'clang-cl') )
          jln_c_c_flags += ['-fsanitize=undefined', '-fsanitize=address', '-fsanitize-address-use-after-scope', ]
        else
          if (  (___jln_c_compiler_id == 'clang') )
            if (  not ( ___jln_c_compiler_version.version_compare('<3.1') ) )
              jln_c_c_flags += ['-fsanitize=undefined', '-fsanitize=address', '-fsanitize-address-use-after-scope', '-fno-omit-frame-pointer', '-fno-optimize-sibling-calls', ]
              jln_c_link_flags += ['-fsanitize=undefined', '-fsanitize=address', ]
              if (  not ( ___jln_c_compiler_version.version_compare('<3.4') ) )
                jln_c_c_flags += ['-fsanitize=leak', ]
                jln_c_link_flags += ['-fsanitize=leak', ]
              endif
              if (  not ( ___jln_c_compiler_version.version_compare('<6.0') ) )
                if (  not ( (___jln_c_flags.get('stack_protector', 'default') == 'default')) )
                  if (  not ( (___jln_c_flags.get('stack_protector', 'default') == 'off') ) )
                    jln_c_c_flags += ['-fsanitize-minimal-runtime', ]
                  endif
                endif
              endif
            endif
          else
            if (  (___jln_c_compiler_id == 'gcc') )
              if (  not ( ___jln_c_compiler_version.version_compare('<4.8') ) )
                jln_c_c_flags += ['-fsanitize=address', '-fno-omit-frame-pointer', '-fno-optimize-sibling-calls', ]
                jln_c_link_flags += ['-fsanitize=address', ]
                if (  not ( ___jln_c_compiler_version.version_compare('<4.9') ) )
                  jln_c_c_flags += ['-fsanitize=undefined', '-fsanitize=leak', ]
                  jln_c_link_flags += ['-fsanitize=undefined', '-fsanitize=leak', ]
                endif
              endif
            endif
          endif
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('control_flow', 'default') == 'default')) )
      if (  (___jln_c_flags.get('control_flow', 'default') == 'off') )
        if (  ( (___jln_c_compiler_id == 'gcc') and not ( ___jln_c_compiler_version.version_compare('<8.0') ) ) )
          jln_c_c_flags += ['-fcf-protection=none', ]
        else
          if (  (___jln_c_compiler_id == 'clang-cl') )
            jln_c_c_flags += ['-fcf-protection=none', '-fno-sanitize-cfi-cross-dso', ]
          endif
        endif
        if (  (___jln_c_compiler_id == 'clang') )
          jln_c_c_flags += ['-fno-sanitize=cfi', ]
          jln_c_link_flags += ['-fno-sanitize=cfi', ]
        endif
      else
        if (  ( ( (___jln_c_compiler_id == 'gcc') and not ( ___jln_c_compiler_version.version_compare('<8.0') ) ) or (___jln_c_compiler_id == 'clang-cl') ) )
          if (  (___jln_c_flags.get('control_flow', 'default') == 'branch') )
            jln_c_c_flags += ['-fcf-protection=branch', ]
          else
            if (  (___jln_c_flags.get('control_flow', 'default') == 'return') )
              jln_c_c_flags += ['-fcf-protection=return', ]
            else
              jln_c_c_flags += ['-fcf-protection=full', ]
            endif
          endif
        else
          if (  ( (___jln_c_flags.get('control_flow', 'default') == 'allow_bugs') and (___jln_c_compiler_id == 'clang') ) )
            jln_c_c_flags += ['-fsanitize=cfi', '-fvisibility=hidden', '-flto', ]
            jln_c_link_flags += ['-fsanitize=cfi', '-flto', ]
          endif
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('color', 'default') == 'default')) )
      if (  ( ( (___jln_c_compiler_id == 'gcc') and not ( ___jln_c_compiler_version.version_compare('<4.9') ) ) or (___jln_c_compiler_id == 'clang') or (___jln_c_compiler_id == 'clang-cl') ) )
        if (  (___jln_c_flags.get('color', 'default') == 'auto') )
          jln_c_c_flags += ['-fdiagnostics-color=auto', ]
        else
          if (  (___jln_c_flags.get('color', 'default') == 'never') )
            jln_c_c_flags += ['-fdiagnostics-color=never', ]
          else
            if (  (___jln_c_flags.get('color', 'default') == 'always') )
              jln_c_c_flags += ['-fdiagnostics-color=always', ]
            endif
          endif
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('reproducible_build_warnings', 'default') == 'default')) )
      if (  ( (___jln_c_compiler_id == 'gcc') and not ( ___jln_c_compiler_version.version_compare('<4.9') ) ) )
        if (  (___jln_c_flags.get('reproducible_build_warnings', 'default') == 'on') )
          jln_c_c_flags += ['-Wdate-time', ]
        else
          jln_c_c_flags += ['-Wno-date-time', ]
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('diagnostics_format', 'default') == 'default')) )
      if (  (___jln_c_flags.get('diagnostics_format', 'default') == 'fixits') )
        if (  ( ( (___jln_c_compiler_id == 'gcc') and not ( ___jln_c_compiler_version.version_compare('<7.0') ) ) or ( (___jln_c_compiler_id == 'clang') and not ( ___jln_c_compiler_version.version_compare('<5.0') ) ) or ( (___jln_c_compiler_id == 'clang-cl') and not ( ___jln_c_compiler_version.version_compare('<5.0') ) ) ) )
          jln_c_c_flags += ['-fdiagnostics-parseable-fixits', ]
        endif
      else
        if (  (___jln_c_flags.get('diagnostics_format', 'default') == 'patch') )
          if (  ( (___jln_c_compiler_id == 'gcc') and not ( ___jln_c_compiler_version.version_compare('<7.0') ) ) )
            jln_c_c_flags += ['-fdiagnostics-generate-patch', ]
          endif
        else
          if (  (___jln_c_flags.get('diagnostics_format', 'default') == 'print_source_range_info') )
            if (  (___jln_c_compiler_id == 'clang') )
              jln_c_c_flags += ['-fdiagnostics-print-source-range-info', ]
            endif
          endif
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('fix_compiler_error', 'default') == 'default')) )
      if (  (___jln_c_flags.get('fix_compiler_error', 'default') == 'on') )
        jln_c_c_flags += ['-Werror=write-strings', ]
      else
        if (  ( (___jln_c_compiler_id == 'clang') or (___jln_c_compiler_id == 'clang-cl') ) )
          jln_c_c_flags += ['-Wno-error=c++11-narrowing', '-Wno-reserved-user-defined-literal', ]
        endif
      endif
    endif
  endif
  if (  ( (___jln_c_compiler_id == 'gcc') or (___jln_c_compiler_id == 'clang') ) )
    if (  not ( (___jln_c_flags.get('coverage', 'default') == 'default')) )
      if (  (___jln_c_flags.get('coverage', 'default') == 'on') )
        jln_c_c_flags += ['--coverage', ]
        jln_c_link_flags += ['--coverage', ]
        if (  (___jln_c_compiler_id == 'clang') )
          jln_c_link_flags += ['-lprofile_rt', ]
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('debug', 'default') == 'default')) )
      if (  (___jln_c_flags.get('debug', 'default') == 'off') )
        jln_c_c_flags += ['-g0', ]
      else
        if (  (___jln_c_flags.get('debug', 'default') == 'gdb') )
          jln_c_c_flags += ['-ggdb', ]
        else
          if (  (___jln_c_compiler_id == 'clang') )
            if (  (___jln_c_flags.get('debug', 'default') == 'line_tables_only') )
              jln_c_c_flags += ['-gline-tables-only', ]
            endif
            if (  (___jln_c_flags.get('debug', 'default') == 'lldb') )
              jln_c_c_flags += ['-glldb', ]
            else
              if (  (___jln_c_flags.get('debug', 'default') == 'sce') )
                jln_c_c_flags += ['-gsce', ]
              else
                jln_c_c_flags += ['-g', ]
              endif
            endif
          else
            jln_c_c_flags += ['-g', ]
          endif
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('linker', 'default') == 'default')) )
      if (  (___jln_c_flags.get('linker', 'default') == 'native') )
        if (  (___jln_c_compiler_id == 'gcc') )
          jln_c_link_flags += ['-fuse-ld=gold', ]
        else
          jln_c_link_flags += ['-fuse-ld=lld', ]
        endif
      else
        if (  (___jln_c_flags.get('linker', 'default') == 'bfd') )
          jln_c_link_flags += ['-fuse-ld=bfd', ]
        else
          if (  ( (___jln_c_flags.get('linker', 'default') == 'gold') or ( (___jln_c_compiler_id == 'gcc') and not ( not ( ___jln_c_compiler_version.version_compare('<9.0') ) ) ) ) )
            jln_c_link_flags += ['-fuse-ld=gold', ]
          else
            if (  not ( (___jln_c_flags.get('lto', 'default') == 'default')) )
              if (  ( not ( (___jln_c_flags.get('lto', 'default') == 'off') ) and (___jln_c_compiler_id == 'gcc') ) )
                jln_c_link_flags += ['-fuse-ld=gold', ]
              else
                jln_c_link_flags += ['-fuse-ld=lld', ]
              endif
            else
              jln_c_link_flags += ['-fuse-ld=lld', ]
            endif
          endif
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('lto', 'default') == 'default')) )
      if (  (___jln_c_flags.get('lto', 'default') == 'off') )
        jln_c_c_flags += ['-fno-lto', ]
        jln_c_link_flags += ['-fno-lto', ]
      else
        if (  (___jln_c_compiler_id == 'gcc') )
          jln_c_c_flags += ['-flto', ]
          jln_c_link_flags += ['-flto', ]
          if (  not ( ___jln_c_compiler_version.version_compare('<5.0') ) )
            if (  not ( (___jln_c_flags.get('warnings', 'default') == 'default')) )
              if (  not ( (___jln_c_flags.get('warnings', 'default') == 'off') ) )
                jln_c_c_flags += ['-flto-odr-type-merging', ]
                jln_c_link_flags += ['-flto-odr-type-merging', ]
              endif
            endif
            if (  (___jln_c_flags.get('lto', 'default') == 'fat') )
              jln_c_c_flags += ['-ffat-lto-objects', ]
            else
              if (  (___jln_c_flags.get('lto', 'default') == 'thin') )
                jln_c_link_flags += ['-fuse-linker-plugin', ]
              endif
            endif
          endif
        else
          if (  ( (___jln_c_flags.get('lto', 'default') == 'thin') and (___jln_c_compiler_id == 'clang') and not ( ___jln_c_compiler_version.version_compare('<6.0') ) ) )
            jln_c_c_flags += ['-flto=thin', ]
            jln_c_link_flags += ['-flto=thin', ]
          else
            jln_c_c_flags += ['-flto', ]
            jln_c_link_flags += ['-flto', ]
          endif
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('optimization', 'default') == 'default')) )
      if (  (___jln_c_flags.get('optimization', 'default') == '0') )
        jln_c_c_flags += ['-O0', ]
        jln_c_link_flags += ['-O0', ]
      else
        if (  (___jln_c_flags.get('optimization', 'default') == 'g') )
          jln_c_c_flags += ['-Og', ]
          jln_c_link_flags += ['-Og', ]
        else
          jln_c_c_flags += ['-DNDEBUG', ]
          jln_c_link_flags += ['-Wl,-O1', ]
          if (  (___jln_c_flags.get('optimization', 'default') == 'size') )
            jln_c_c_flags += ['-Os', ]
            jln_c_link_flags += ['-Os', ]
          else
            if (  (___jln_c_flags.get('optimization', 'default') == 'z') )
              if (  ( (___jln_c_compiler_id == 'clang') or (___jln_c_compiler_id == 'clang-cl') ) )
                jln_c_c_flags += ['-Oz', ]
                jln_c_link_flags += ['-Oz', ]
              else
                jln_c_c_flags += ['-Os', ]
                jln_c_link_flags += ['-Os', ]
              endif
            else
              if (  (___jln_c_flags.get('optimization', 'default') == 'fast') )
                jln_c_c_flags += ['-Ofast', ]
                jln_c_link_flags += ['-Ofast', ]
              else
                if (  (___jln_c_flags.get('optimization', 'default') == '1') )
                  jln_c_c_flags += ['-O1', ]
                  jln_c_link_flags += ['-O1', ]
                else
                  if (  (___jln_c_flags.get('optimization', 'default') == '2') )
                    jln_c_c_flags += ['-O2', ]
                    jln_c_link_flags += ['-O2', ]
                  else
                    if (  (___jln_c_flags.get('optimization', 'default') == '3') )
                      jln_c_c_flags += ['-O3', ]
                      jln_c_link_flags += ['-O3', ]
                    endif
                  endif
                endif
              endif
            endif
          endif
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('cpu', 'default') == 'default')) )
      if (  (___jln_c_flags.get('cpu', 'default') == 'generic') )
        jln_c_c_flags += ['-mtune=generic', ]
        jln_c_link_flags += ['-mtune=generic', ]
      else
        jln_c_c_flags += ['-march=native', '-mtune=native', ]
        jln_c_link_flags += ['-march=native', '-mtune=native', ]
      endif
    endif
    if (  not ( (___jln_c_flags.get('whole_program', 'default') == 'default')) )
      if (  (___jln_c_flags.get('whole_program', 'default') == 'off') )
        jln_c_c_flags += ['-fno-whole-program', ]
        if (  ( (___jln_c_compiler_id == 'clang') and not ( ___jln_c_compiler_version.version_compare('<3.9') ) ) )
          jln_c_c_flags += ['-fno-whole-program-vtables', ]
          jln_c_link_flags += ['-fno-whole-program-vtables', ]
        endif
      else
        if (  (___jln_c_linker_id == 'ld64') )
          jln_c_link_flags += ['-Wl,-dead_strip', '-Wl,-S', ]
        else
          jln_c_link_flags += ['-s', ]
          if (  (___jln_c_flags.get('whole_program', 'default') == 'strip_all') )
            jln_c_link_flags += ['-Wl,--gc-sections', '-Wl,--strip-all', ]
          endif
        endif
        if (  (___jln_c_compiler_id == 'gcc') )
          jln_c_c_flags += ['-fwhole-program', ]
          jln_c_link_flags += ['-fwhole-program', ]
        else
          if (  (___jln_c_compiler_id == 'clang') )
            if (  not ( ___jln_c_compiler_version.version_compare('<3.9') ) )
              if (  not ( (___jln_c_flags.get('lto', 'default') == 'default')) )
                if (  not ( (___jln_c_flags.get('lto', 'default') == 'off') ) )
                  jln_c_c_flags += ['-fwhole-program-vtables', ]
                  jln_c_link_flags += ['-fwhole-program-vtables', ]
                endif
              endif
              if (  not ( ___jln_c_compiler_version.version_compare('<7.0') ) )
                jln_c_c_flags += ['-fforce-emit-vtables', ]
                jln_c_link_flags += ['-fforce-emit-vtables', ]
              endif
            endif
          endif
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('pedantic', 'default') == 'default')) )
      if (  not ( (___jln_c_flags.get('pedantic', 'default') == 'off') ) )
        jln_c_c_flags += ['-pedantic', ]
        if (  (___jln_c_flags.get('pedantic', 'default') == 'as_error') )
          jln_c_c_flags += ['-pedantic-errors', ]
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('stack_protector', 'default') == 'default')) )
      if (  (___jln_c_flags.get('stack_protector', 'default') == 'off') )
        jln_c_c_flags += ['-Wno-stack-protector', '-U_FORTIFY_SOURCE', ]
        jln_c_link_flags += ['-Wno-stack-protector', ]
      else
        jln_c_c_flags += ['-D_FORTIFY_SOURCE=2', '-Wstack-protector', ]
        if (  (___jln_c_flags.get('stack_protector', 'default') == 'strong') )
          if (  (___jln_c_compiler_id == 'gcc') )
            if (  not ( ___jln_c_compiler_version.version_compare('<4.9') ) )
              jln_c_c_flags += ['-fstack-protector-strong', ]
              jln_c_link_flags += ['-fstack-protector-strong', ]
              if (  not ( ___jln_c_compiler_version.version_compare('<8.0') ) )
                jln_c_c_flags += ['-fstack-clash-protection', ]
                jln_c_link_flags += ['-fstack-clash-protection', ]
              endif
            endif
          else
            if (  (___jln_c_compiler_id == 'clang') )
              jln_c_c_flags += ['-fstack-protector-strong', '-fsanitize=safe-stack', ]
              jln_c_link_flags += ['-fstack-protector-strong', '-fsanitize=safe-stack', ]
              if (  not ( ___jln_c_compiler_version.version_compare('<11.0') ) )
                jln_c_c_flags += ['-fstack-clash-protection', ]
                jln_c_link_flags += ['-fstack-clash-protection', ]
              endif
            endif
          endif
        else
          if (  (___jln_c_flags.get('stack_protector', 'default') == 'all') )
            jln_c_c_flags += ['-fstack-protector-all', ]
            jln_c_link_flags += ['-fstack-protector-all', ]
            if (  ( (___jln_c_compiler_id == 'gcc') and not ( ___jln_c_compiler_version.version_compare('<8.0') ) ) )
              jln_c_c_flags += ['-fstack-clash-protection', ]
              jln_c_link_flags += ['-fstack-clash-protection', ]
            else
              if (  (___jln_c_compiler_id == 'clang') )
                jln_c_c_flags += ['-fsanitize=safe-stack', ]
                jln_c_link_flags += ['-fsanitize=safe-stack', ]
                if (  not ( ___jln_c_compiler_version.version_compare('<11.0') ) )
                  jln_c_c_flags += ['-fstack-clash-protection', ]
                  jln_c_link_flags += ['-fstack-clash-protection', ]
                endif
              endif
            endif
          else
            jln_c_c_flags += ['-fstack-protector', ]
            jln_c_link_flags += ['-fstack-protector', ]
          endif
        endif
        if (  (___jln_c_compiler_id == 'clang') )
          jln_c_c_flags += ['-fsanitize=shadow-call-stack', ]
          jln_c_link_flags += ['-fsanitize=shadow-call-stack', ]
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('relro', 'default') == 'default')) )
      if (  (___jln_c_flags.get('relro', 'default') == 'off') )
        jln_c_link_flags += ['-Wl,-z,norelro', ]
      else
        if (  (___jln_c_flags.get('relro', 'default') == 'on') )
          jln_c_link_flags += ['-Wl,-z,relro', ]
        else
          if (  (___jln_c_flags.get('relro', 'default') == 'full') )
            jln_c_link_flags += ['-Wl,-z,relro,-z,now', ]
          endif
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('pie', 'default') == 'default')) )
      if (  (___jln_c_flags.get('pie', 'default') == 'off') )
        jln_c_link_flags += ['-no-pic', ]
      else
        if (  (___jln_c_flags.get('pie', 'default') == 'on') )
          jln_c_link_flags += ['-pie', ]
        else
          if (  (___jln_c_flags.get('pie', 'default') == 'static') )
            jln_c_link_flags += ['-static-pie', ]
          else
            if (  (___jln_c_flags.get('pie', 'default') == 'fpie') )
              jln_c_c_flags += ['-fpie', ]
            else
              if (  (___jln_c_flags.get('pie', 'default') == 'fpic') )
                jln_c_c_flags += ['-fpic', ]
              else
                if (  (___jln_c_flags.get('pie', 'default') == 'fPIE') )
                  jln_c_c_flags += ['-fPIE', ]
                else
                  if (  (___jln_c_flags.get('pie', 'default') == 'fPIC') )
                    jln_c_c_flags += ['-fPIC', ]
                  endif
                endif
              endif
            endif
          endif
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('shadow_warnings', 'default') == 'default')) )
      if (  (___jln_c_flags.get('shadow_warnings', 'default') == 'off') )
        jln_c_c_flags += ['-Wno-shadow', ]
        if (  ( (___jln_c_compiler_id == 'clang') and not ( ___jln_c_compiler_version.version_compare('<8.0') ) ) )
          jln_c_c_flags += ['-Wno-shadow-field', ]
        endif
      else
        if (  (___jln_c_flags.get('shadow_warnings', 'default') == 'on') )
          jln_c_c_flags += ['-Wshadow', ]
        else
          if (  (___jln_c_flags.get('shadow_warnings', 'default') == 'all') )
            if (  (___jln_c_compiler_id == 'clang') )
              jln_c_c_flags += ['-Wshadow-all', ]
            else
              jln_c_c_flags += ['-Wshadow', ]
            endif
          else
            if (  ( (___jln_c_compiler_id == 'gcc') and not ( ___jln_c_compiler_version.version_compare('<7.1') ) ) )
              if (  (___jln_c_flags.get('shadow_warnings', 'default') == 'local') )
                jln_c_c_flags += ['-Wshadow=local', ]
              else
                if (  (___jln_c_flags.get('shadow_warnings', 'default') == 'compatible_local') )
                  jln_c_c_flags += ['-Wshadow=compatible-local', ]
                endif
              endif
            endif
          endif
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('exceptions', 'default') == 'default')) )
      if (  (___jln_c_flags.get('exceptions', 'default') == 'on') )
        jln_c_c_flags += ['-fexceptions', ]
      else
        jln_c_c_flags += ['-fno-exceptions', ]
      endif
    endif
    if (  not ( (___jln_c_flags.get('other_sanitizers', 'default') == 'default')) )
      if (  (___jln_c_flags.get('other_sanitizers', 'default') == 'thread') )
        jln_c_c_flags += ['-fsanitize=thread', ]
      else
        if (  (___jln_c_flags.get('other_sanitizers', 'default') == 'memory') )
          if (  ( (___jln_c_compiler_id == 'clang') and not ( ___jln_c_compiler_version.version_compare('<5.0') ) ) )
            jln_c_c_flags += ['-fsanitize=memory', ]
          endif
        else
          if (  (___jln_c_flags.get('other_sanitizers', 'default') == 'pointer') )
            if (  ( (___jln_c_compiler_id == 'gcc') and not ( ___jln_c_compiler_version.version_compare('<8.0') ) ) )
              jln_c_c_flags += ['-fsanitize=pointer-compare', '-fsanitize=pointer-subtract', ]
            endif
          endif
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('float_sanitizers', 'default') == 'default')) )
      if (  ( ( (___jln_c_compiler_id == 'gcc') and not ( ___jln_c_compiler_version.version_compare('<5.0') ) ) or ( (___jln_c_compiler_id == 'clang') and not ( ___jln_c_compiler_version.version_compare('<5.0') ) ) ) )
        if (  (___jln_c_flags.get('float_sanitizers', 'default') == 'on') )
          jln_c_c_flags += ['-fsanitize=float-divide-by-zero', '-fsanitize=float-cast-overflow', ]
        else
          jln_c_c_flags += ['-fno-sanitize=float-divide-by-zero', '-fno-sanitize=float-cast-overflow', ]
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('integer_sanitizers', 'default') == 'default')) )
      if (  (___jln_c_flags.get('integer_sanitizers', 'default') == 'on') )
        if (  ( (___jln_c_compiler_id == 'gcc') and not ( ___jln_c_compiler_version.version_compare('<4.9') ) ) )
          jln_c_c_flags += ['-ftrapv', '-fsanitize=undefined', ]
        endif
        if (  ( (___jln_c_compiler_id == 'clang') and not ( ___jln_c_compiler_version.version_compare('<5.0') ) ) )
          jln_c_c_flags += ['-fsanitize=integer', ]
        endif
      else
        if (  ( (___jln_c_compiler_id == 'clang') and not ( ___jln_c_compiler_version.version_compare('<5.0') ) ) )
          jln_c_c_flags += ['-fno-sanitize=integer', ]
        endif
      endif
    endif
  endif
  if (  (___jln_c_linker_id == 'lld-link') )
    if (  not ( (___jln_c_flags.get('lto', 'default') == 'default')) )
      if (  (___jln_c_flags.get('lto', 'default') == 'off') )
        jln_c_c_flags += ['-fno-lto', ]
      else
        if (  (___jln_c_flags.get('lto', 'default') == 'thin') )
          jln_c_c_flags += ['-flto=thin', ]
        else
          jln_c_c_flags += ['-flto', ]
          jln_c_link_flags += ['-flto', ]
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('whole_program', 'default') == 'default')) )
      if (  (___jln_c_flags.get('whole_program', 'default') == 'off') )
        jln_c_c_flags += ['-fno-whole-program', ]
      else
        if (  not ( (___jln_c_flags.get('lto', 'default') == 'default')) )
          if (  not ( (___jln_c_flags.get('lto', 'default') == 'off') ) )
            jln_c_c_flags += ['-fwhole-program-vtables', ]
            jln_c_link_flags += ['-fwhole-program-vtables', ]
          endif
        endif
      endif
    endif
  endif
  if (  ( (___jln_c_compiler_id == 'msvc') or (___jln_c_compiler_id == 'clang-cl') ) )
    if (  not ( (___jln_c_flags.get('stl_fix', 'default') == 'default')) )
      if (  (___jln_c_flags.get('stl_fix', 'default') == 'on') )
        jln_c_c_flags += ['/DNOMINMAX', ]
      endif
    endif
    if (  not ( (___jln_c_flags.get('debug', 'default') == 'default')) )
      if (  (___jln_c_flags.get('debug', 'default') == 'off') )
        jln_c_c_flags += ['/DEBUG:NONE', ]
      else
        jln_c_c_flags += ['/RTC1', '/Od', ]
        if (  (___jln_c_flags.get('debug', 'default') == 'on') )
          jln_c_c_flags += ['/DEBUG', ]
        else
          if (  (___jln_c_flags.get('debug', 'default') == 'line_tables_only') )
            jln_c_c_flags += ['/DEBUG:FASTLINK', ]
          endif
        endif
        if (  not ( (___jln_c_flags.get('optimization', 'default') == 'default')) )
          if (  (___jln_c_flags.get('optimization', 'default') == 'g') )
            jln_c_c_flags += ['/Zi', ]
          else
            if (  not ( (___jln_c_flags.get('whole_program', 'default') == 'default')) )
              if (  (___jln_c_flags.get('whole_program', 'default') == 'off') )
                jln_c_c_flags += ['/ZI', ]
              else
                jln_c_c_flags += ['/Zi', ]
              endif
            else
              jln_c_c_flags += ['/ZI', ]
            endif
          endif
        else
          if (  not ( (___jln_c_flags.get('whole_program', 'default') == 'default')) )
            if (  (___jln_c_flags.get('whole_program', 'default') == 'off') )
              jln_c_c_flags += ['/ZI', ]
            else
              jln_c_c_flags += ['/Zi', ]
            endif
          else
            jln_c_c_flags += ['/ZI', ]
          endif
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('exceptions', 'default') == 'default')) )
      if (  (___jln_c_flags.get('exceptions', 'default') == 'on') )
        jln_c_c_flags += ['/EHsc', '/D_HAS_EXCEPTIONS=1', ]
      else
        jln_c_c_flags += ['/EHs-', '/D_HAS_EXCEPTIONS=0', ]
      endif
    endif
    if (  not ( (___jln_c_flags.get('optimization', 'default') == 'default')) )
      if (  (___jln_c_flags.get('optimization', 'default') == '0') )
        jln_c_c_flags += ['/Ob0', '/Od', '/Oi-', '/Oy-', ]
      else
        if (  (___jln_c_flags.get('optimization', 'default') == 'g') )
          jln_c_c_flags += ['/Ob1', ]
        else
          jln_c_c_flags += ['/DNDEBUG', ]
          if (  (___jln_c_flags.get('optimization', 'default') == '1') )
            jln_c_c_flags += ['/O1', ]
          else
            if (  (___jln_c_flags.get('optimization', 'default') == '2') )
              jln_c_c_flags += ['/O2', ]
            else
              if (  (___jln_c_flags.get('optimization', 'default') == '3') )
                jln_c_c_flags += ['/O2', ]
              else
                if (  ( (___jln_c_flags.get('optimization', 'default') == 'size') or (___jln_c_flags.get('optimization', 'default') == 'z') ) )
                  jln_c_c_flags += ['/O1', '/GL', '/Gw', ]
                else
                  if (  (___jln_c_flags.get('optimization', 'default') == 'fast') )
                    jln_c_c_flags += ['/O2', '/fp:fast', ]
                  endif
                endif
              endif
            endif
          endif
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('whole_program', 'default') == 'default')) )
      if (  (___jln_c_flags.get('whole_program', 'default') == 'off') )
        jln_c_c_flags += ['/GL-', ]
      else
        jln_c_c_flags += ['/GL', '/Gw', ]
        jln_c_link_flags += ['/LTCG', ]
        if (  (___jln_c_flags.get('whole_program', 'default') == 'strip_all') )
          jln_c_link_flags += ['/OPT:REF', ]
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('pedantic', 'default') == 'default')) )
      if (  not ( (___jln_c_flags.get('pedantic', 'default') == 'off') ) )
        jln_c_c_flags += ['/permissive-', ]
      endif
    endif
    if (  not ( (___jln_c_flags.get('rtti', 'default') == 'default')) )
      if (  (___jln_c_flags.get('rtti', 'default') == 'on') )
        jln_c_c_flags += ['/GR', ]
      else
        jln_c_c_flags += ['/GR-', ]
      endif
    endif
    if (  not ( (___jln_c_flags.get('stl_debug', 'default') == 'default')) )
      if (  (___jln_c_flags.get('stl_debug', 'default') == 'off') )
        jln_c_c_flags += ['/D_HAS_ITERATOR_DEBUGGING=0', ]
      else
        jln_c_c_flags += ['/D_DEBUG', '/D_HAS_ITERATOR_DEBUGGING=1', ]
      endif
    endif
    if (  not ( (___jln_c_flags.get('control_flow', 'default') == 'default')) )
      if (  (___jln_c_flags.get('control_flow', 'default') == 'off') )
        jln_c_c_flags += ['/guard:cf-', ]
      else
        jln_c_c_flags += ['/guard:cf', ]
      endif
    endif
    if (  not ( (___jln_c_flags.get('stack_protector', 'default') == 'default')) )
      if (  (___jln_c_flags.get('stack_protector', 'default') == 'off') )
        jln_c_c_flags += ['/GS-', ]
      else
        jln_c_c_flags += ['/GS', '/sdl', ]
        if (  (___jln_c_flags.get('stack_protector', 'default') == 'strong') )
          jln_c_c_flags += ['/RTC1', ]
          if (  ( (___jln_c_compiler_id == 'msvc') and not ( ___jln_c_compiler_version.version_compare('<16.7') ) ) )
            jln_c_c_flags += ['/guard:ehcont', ]
            jln_c_link_flags += ['/CETCOMPAT', ]
          endif
        else
          if (  (___jln_c_flags.get('stack_protector', 'default') == 'all') )
            jln_c_c_flags += ['/RTC1', '/RTCc', ]
          endif
        endif
      endif
    endif
  endif
  if (  (___jln_c_compiler_id == 'msvc') )
    if (  not ( (___jln_c_flags.get('msvc_isystem', 'default') == 'default')) )
      if (  (___jln_c_flags.get('msvc_isystem', 'default') == 'external_as_include_system_flag') )
        # unimplementable
      else
        jln_c_c_flags += ['/experimental:external', '/external:W0', ]
        if (  (___jln_c_flags.get('msvc_isystem', 'default') == 'anglebrackets') )
          jln_c_c_flags += ['/external:anglebrackets', ]
        else
          jln_c_c_flags += ['/external:env:INCLUDE', '/external:env:CAExcludePath', ]
        endif
      endif
      if (  not ( (___jln_c_flags.get('msvc_isystem_with_template_from_non_external', 'default') == 'default')) )
        if (  (___jln_c_flags.get('msvc_isystem_with_template_from_non_external', 'default') == 'off') )
          jln_c_c_flags += ['/external:template', ]
        else
          jln_c_c_flags += ['/external:template-', ]
        endif
      endif
      if (  not ( (___jln_c_flags.get('warnings', 'default') == 'default')) )
        if (  (___jln_c_flags.get('warnings', 'default') == 'off') )
          jln_c_c_flags += ['/W0', ]
        else
          jln_c_c_flags += ['/wd4710', '/wd4711', ]
          if (  not ( not ( ___jln_c_compiler_version.version_compare('<19.21') ) ) )
            jln_c_c_flags += ['/wd4774', ]
          endif
          if (  (___jln_c_flags.get('warnings', 'default') == 'on') )
            jln_c_c_flags += ['/W4', '/wd4514', ]
          else
            jln_c_c_flags += ['/Wall', '/wd4514', '/wd4571', '/wd4355', '/wd4548', '/wd4577', '/wd4820', '/wd5039', '/wd4464', '/wd4868', '/wd5045', ]
            if (  (___jln_c_flags.get('warnings', 'default') == 'strict') )
              jln_c_c_flags += ['/wd4583', '/wd4619', ]
            endif
          endif
        endif
      endif
      if (  not ( (___jln_c_flags.get('switch_warnings', 'default') == 'default')) )
        if (  (___jln_c_flags.get('switch_warnings', 'default') == 'on') )
          jln_c_c_flags += ['/we4061', ]
        else
          if (  (___jln_c_flags.get('switch_warnings', 'default') == 'enum') )
            jln_c_c_flags += ['/we4062', ]
          else
            if (  (___jln_c_flags.get('switch_warnings', 'default') == 'off') )
              jln_c_c_flags += ['/wd4061', '/wd4062', ]
            endif
          endif
        endif
      endif
    else
      if (  not ( (___jln_c_flags.get('warnings', 'default') == 'default')) )
        if (  (___jln_c_flags.get('warnings', 'default') == 'off') )
          jln_c_c_flags += ['/W0', ]
        else
          if (  (___jln_c_flags.get('warnings', 'default') == 'on') )
            jln_c_c_flags += ['/W4', '/wd4514', '/wd4711', ]
          else
            jln_c_c_flags += ['/Wall', '/wd4355', '/wd4514', '/wd4548', '/wd4571', '/wd4577', '/wd4625', '/wd4626', '/wd4668', '/wd4710', '/wd4711', ]
            if (  not ( not ( ___jln_c_compiler_version.version_compare('<19.21') ) ) )
              jln_c_c_flags += ['/wd4774', ]
            endif
            jln_c_c_flags += ['/wd4820', '/wd5026', '/wd5027', '/wd5039', '/wd4464', '/wd4868', '/wd5045', ]
            if (  (___jln_c_flags.get('warnings', 'default') == 'strict') )
              jln_c_c_flags += ['/wd4061', '/wd4266', '/wd4583', '/wd4619', '/wd4623', '/wd5204', ]
            endif
          endif
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('conversion_warnings', 'default') == 'default')) )
      if (  (___jln_c_flags.get('conversion_warnings', 'default') == 'on') )
        jln_c_c_flags += ['/w14244', '/w14245', '/w14388', '/w14365', ]
      else
        if (  (___jln_c_flags.get('conversion_warnings', 'default') == 'conversion') )
          jln_c_c_flags += ['/w14244', '/w14365', ]
        else
          if (  (___jln_c_flags.get('conversion_warnings', 'default') == 'sign') )
            jln_c_c_flags += ['/w14388', '/w14245', ]
          else
            jln_c_c_flags += ['/wd4244', '/wd4365', '/wd4388', '/wd4245', ]
          endif
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('shadow_warnings', 'default') == 'default')) )
      if (  (___jln_c_flags.get('shadow_warnings', 'default') == 'off') )
        jln_c_c_flags += ['/wd4456', '/wd4459', ]
      else
        if (  ( (___jln_c_flags.get('shadow_warnings', 'default') == 'on') or (___jln_c_flags.get('shadow_warnings', 'default') == 'all') ) )
          jln_c_c_flags += ['/w4456', '/w4459', ]
        else
          if (  (___jln_c_flags.get('shadow_warnings', 'default') == 'local') )
            jln_c_c_flags += ['/w4456', '/wd4459', ]
          endif
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('warnings_as_error', 'default') == 'default')) )
      if (  (___jln_c_flags.get('warnings_as_error', 'default') == 'on') )
        jln_c_c_flags += ['/WX', ]
        jln_c_link_flags += ['/WX', ]
      else
        if (  (___jln_c_flags.get('warnings_as_error', 'default') == 'off') )
          jln_c_c_flags += ['/WX-', ]
        else
          jln_c_c_flags += ['/we4716', '/we2124', ]
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('lto', 'default') == 'default')) )
      if (  (___jln_c_flags.get('lto', 'default') == 'off') )
        jln_c_c_flags += ['/LTCG:OFF', ]
      else
        jln_c_c_flags += ['/GL', ]
        jln_c_link_flags += ['/LTCG', ]
      endif
    endif
    if (  not ( (___jln_c_flags.get('sanitizers', 'default') == 'default')) )
      if (  not ( ___jln_c_compiler_version.version_compare('<16.9') ) )
        jln_c_c_flags += ['/fsanitize=address', '/fsanitize-address-use-after-return', ]
      else
        if (  (___jln_c_flags.get('sanitizers', 'default') == 'on') )
          jln_c_c_flags += ['/sdl', ]
        else
          if (  not ( (___jln_c_flags.get('stack_protector', 'default') == 'default')) )
            if (  not ( (___jln_c_flags.get('stack_protector', 'default') == 'off') ) )
              jln_c_c_flags += ['/sdl-', ]
            endif
          endif
        endif
      endif
    endif
  endif

  jln_c_custom_c_flags += [jln_c_c_flags]
  jln_c_custom_link_flags += [jln_c_link_flags]
endforeach
