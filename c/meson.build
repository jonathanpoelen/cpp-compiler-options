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
#  Supported options are (in alphabetical order):
#  
#  <!-- ./compiler-options.lua generators/list_options.lua --color -->
#  ```ini
#  color = default auto never always
#  control_flow = default off on branch return allow_bugs
#  coverage = default off on
#  cpu = default generic native
#  debug = default off on line_tables_only gdb lldb sce
#  diagnostics_format = default fixits patch print_source_range_info
#  diagnostics_show_template_tree = default off on
#  elide_type = default off on
#  exceptions = default off on
#  fix_compiler_error = on default off
#  linker = default bfd gold lld native
#  lto = default off on fat thin
#  microsoft_abi_compatibility_warning = off default on
#  msvc_isystem = default anglebrackets include_and_caexcludepath
#  msvc_isystem_with_template_from_non_external = default off on
#  optimization = default 0 g 1 2 3 fast size
#  pedantic = on default off as_error
#  pie = default off on pic
#  relro = default off on full
#  reproducible_build_warnings = default off on
#  rtti = default off on
#  sanitizers = default off on
#  sanitizers_extra = default off thread pointer
#  shadow_warnings = off default on local compatible_local all
#  stack_protector = default off on strong all
#  stl_debug = default off on allow_broken_abi allow_broken_abi_and_bugs assert_as_exception
#  stl_fix = on default off
#  suggestions = default off on
#  warnings = on default off strict very_strict
#  warnings_as_error = default off on basic
#  whole_program = default off on strip_all
#  ```
#  <!-- ./compiler-options.lua -->
#  
#  The value `default` does nothing.
#  
#  If not specified, `fix_compiler_error`, `pedantic`, `stl_fix` and `warnings` are `on` ; `microsoft_abi_compatibility_warning` and `shadow_warnings` are `off`.
#  
#  - `control_flow=allow_bugs`
#    - clang: Can crash programs with "illegal hardware instruction" on totally unlikely lines. It can also cause link errors and force `-fvisibility=hidden` and `-flto`.
#  - `stl_debug=allow_broken_abi_and_bugs`
#    - clang: libc++ can crash on dynamic memory releases in the standard classes. This bug is fixed with the library associated with version 8.
#  
#  
#  ## Recommended options
#  
#  category | options
#  ---------|---------
#  debug | `control_flow=on`<br>`debug=on`<br>`sanitizers=on`<br>`stl_debug=allow_broken_abi` or `on`<br>
#  release | `cpu=native`<br>`linker=gold`, `lld` or `native`<br>`lto=on` or `thin`<br>`optimization=3`<br>`rtti=off`<br>`whole_program=strip_all`
#  security | `control_flow=on`<br>`relro=full`<br>`stack_protector=strong`
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
  'coverage': ___jln_c_default_flags.get('coverage', get_option('jln_coverage')),
  'cpu': ___jln_c_default_flags.get('cpu', get_option('jln_cpu')),
  'debug': ___jln_c_default_flags.get('debug', get_option('jln_debug')),
  'diagnostics_format': ___jln_c_default_flags.get('diagnostics_format', get_option('jln_diagnostics_format')),
  'diagnostics_show_template_tree': ___jln_c_default_flags.get('diagnostics_show_template_tree', get_option('jln_diagnostics_show_template_tree')),
  'elide_type': ___jln_c_default_flags.get('elide_type', get_option('jln_elide_type')),
  'exceptions': ___jln_c_default_flags.get('exceptions', get_option('jln_exceptions')),
  'fix_compiler_error': ___jln_c_default_flags.get('fix_compiler_error', get_option('jln_fix_compiler_error')),
  'linker': ___jln_c_default_flags.get('linker', get_option('jln_linker')),
  'lto': ___jln_c_default_flags.get('lto', get_option('jln_lto')),
  'microsoft_abi_compatibility_warning': ___jln_c_default_flags.get('microsoft_abi_compatibility_warning', get_option('jln_microsoft_abi_compatibility_warning')),
  'msvc_isystem': ___jln_c_default_flags.get('msvc_isystem', get_option('jln_msvc_isystem')),
  'msvc_isystem_with_template_from_non_external': ___jln_c_default_flags.get('msvc_isystem_with_template_from_non_external', get_option('jln_msvc_isystem_with_template_from_non_external')),
  'optimization': ___jln_c_default_flags.get('optimization', get_option('jln_optimization')),
  'pedantic': ___jln_c_default_flags.get('pedantic', get_option('jln_pedantic')),
  'pie': ___jln_c_default_flags.get('pie', get_option('jln_pie')),
  'relro': ___jln_c_default_flags.get('relro', get_option('jln_relro')),
  'reproducible_build_warnings': ___jln_c_default_flags.get('reproducible_build_warnings', get_option('jln_reproducible_build_warnings')),
  'rtti': ___jln_c_default_flags.get('rtti', get_option('jln_rtti')),
  'sanitizers': ___jln_c_default_flags.get('sanitizers', get_option('jln_sanitizers')),
  'sanitizers_extra': ___jln_c_default_flags.get('sanitizers_extra', get_option('jln_sanitizers_extra')),
  'shadow_warnings': ___jln_c_default_flags.get('shadow_warnings', get_option('jln_shadow_warnings')),
  'stack_protector': ___jln_c_default_flags.get('stack_protector', get_option('jln_stack_protector')),
  'stl_debug': ___jln_c_default_flags.get('stl_debug', get_option('jln_stl_debug')),
  'stl_fix': ___jln_c_default_flags.get('stl_fix', get_option('jln_stl_fix')),
  'suggestions': ___jln_c_default_flags.get('suggestions', get_option('jln_suggestions')),
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
'-w',       else
        if (  (___jln_c_compiler_id == 'gcc') )
'-Wall', '-Wextra', '-Wcast-align', '-Wcast-qual', '-Wdisabled-optimization', '-Wfloat-equal', '-Wformat-security', '-Wformat=2', '-Wmissing-include-dirs', '-Wpacked', '-Wredundant-decls', '-Wundef', '-Wunused-macros', '-Winvalid-pch', '-Wpointer-arith', '-Wbad-function-cast', '-Winit-self', '-Wjump-misses-init', '-Wnested-externs', '-Wold-style-definition', '-Wstrict-prototypes', '-Wwrite-strings',           if (  not ( ___jln_c_compiler_version.version_compare('<4.7') ) )
'-Wsuggest-attribute=noreturn', '-Wlogical-op', '-Wvector-operation-performance', '-Wdouble-promotion', '-Wtrampolines',             if (  not ( ___jln_c_compiler_version.version_compare('<4.8') ) )
              if (  not ( ___jln_c_compiler_version.version_compare('<4.9') ) )
'-Wfloat-conversion',                 if (  not ( ___jln_c_compiler_version.version_compare('<5.1') ) )
'-Wformat-signedness', '-Warray-bounds=2',                   if (  not ( ___jln_c_compiler_version.version_compare('<6.1') ) )
'-Wduplicated-cond', '-Wnull-dereference',                     if (  not ( ___jln_c_compiler_version.version_compare('<7.0') ) )
                      if (  not ( ___jln_c_compiler_version.version_compare('<7.1') ) )
'-Walloc-zero', '-Walloca', '-Wformat-overflow=2', '-Wduplicated-branches',                       endif
                    endif
                  endif
                endif
              endif
            endif
          endif
        else
          if (  ( (___jln_c_compiler_id == 'clang') or (___jln_c_compiler_id == 'clang-cl') ) )
'-Weverything', '-Wno-documentation', '-Wno-documentation-unknown-command', '-Wno-newline-eof', '-Wno-padded', '-Wno-global-constructors', '-Wno-covered-switch-default', '-Wno-switch-default', '-Wno-switch-enum',           endif
        endif
        if (  ( (___jln_c_flags.get('warnings', 'default') == 'strict') or (___jln_c_flags.get('warnings', 'default') == 'very_strict') ) )
'-Wconversion',           if (  ( (___jln_c_compiler_id == 'gcc') and not ( ___jln_c_compiler_version.version_compare('<8.0') ) ) )
'-Wcast-align=strict',           endif
        else
          if (  ( (___jln_c_compiler_id == 'clang') or (___jln_c_compiler_id == 'clang-cl') ) )
'-Wno-conversion', '-Wno-sign-conversion',           endif
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('warnings_as_error', 'default') == 'default')) )
      if (  (___jln_c_flags.get('warnings_as_error', 'default') == 'on') )
'-Werror',       else
        if (  (___jln_c_flags.get('warnings_as_error', 'default') == 'basic') )
'-Werror=return-type', '-Werror=init-self',           if (  ( (___jln_c_compiler_id == 'gcc') and not ( ___jln_c_compiler_version.version_compare('<5.1') ) ) )
'-Werror=array-bounds', '-Werror=logical-op', '-Werror=logical-not-parentheses',           else
            if (  ( (___jln_c_compiler_id == 'clang') or (___jln_c_compiler_id == 'clang-cl') ) )
'-Werror=array-bounds', '-Werror=division-by-zero',               if (  not ( ___jln_c_compiler_version.version_compare('<3.4') ) )
'-Werror=logical-not-parentheses',               endif
            endif
          endif
        else
'-Wno-error',         endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('suggestions', 'default') == 'default')) )
      if (  not ( (___jln_c_flags.get('suggestions', 'default') == 'off') ) )
        if (  (___jln_c_compiler_id == 'gcc') )
'-Wsuggest-attribute=pure', '-Wsuggest-attribute=const',           if (  not ( ___jln_c_compiler_version.version_compare('<5.0') ) )
            if (  not ( ___jln_c_compiler_version.version_compare('<5.1') ) )
'-Wnoexcept',             endif
          endif
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('sanitizers', 'default') == 'default')) )
      if (  (___jln_c_flags.get('sanitizers', 'default') == 'off') )
'-fno-sanitize=all', '-fno-sanitize=all',       else
        if (  (___jln_c_compiler_id == 'clang-cl') )
'-fsanitize=undefined', '-fsanitize=address', '-fsanitize-address-use-after-scope',         else
          if (  (___jln_c_compiler_id == 'clang') )
            if (  not ( ___jln_c_compiler_version.version_compare('<3.1') ) )
'-fsanitize=undefined', '-fsanitize=address', '-fsanitize-address-use-after-scope', '-fno-omit-frame-pointer', '-fno-optimize-sibling-calls', '-fsanitize=undefined', '-fsanitize=address',               if (  not ( ___jln_c_compiler_version.version_compare('<3.4') ) )
'-fsanitize=leak', '-fsanitize=leak',               endif
            endif
          else
            if (  (___jln_c_compiler_id == 'gcc') )
              if (  not ( ___jln_c_compiler_version.version_compare('<4.8') ) )
'-fsanitize=address', '-fno-omit-frame-pointer', '-fno-optimize-sibling-calls', '-fsanitize=address',                 if (  not ( ___jln_c_compiler_version.version_compare('<4.9') ) )
'-fsanitize=undefined', '-fsanitize=leak', '-fsanitize=undefined', '-fsanitize=leak',                 endif
              endif
            endif
          endif
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('control_flow', 'default') == 'default')) )
      if (  (___jln_c_flags.get('control_flow', 'default') == 'off') )
        if (  ( (___jln_c_compiler_id == 'gcc') and not ( ___jln_c_compiler_version.version_compare('<8.0') ) ) )
'-fcf-protection=none',         else
          if (  (___jln_c_compiler_id == 'clang-cl') )
'-fcf-protection=none', '-fno-sanitize-cfi-cross-dso',           endif
        endif
        if (  (___jln_c_compiler_id == 'clang') )
'-fno-sanitize=cfi', '-fno-sanitize=cfi',         endif
      else
        if (  ( ( (___jln_c_compiler_id == 'gcc') and not ( ___jln_c_compiler_version.version_compare('<8.0') ) ) or (___jln_c_compiler_id == 'clang-cl') ) )
          if (  (___jln_c_flags.get('control_flow', 'default') == 'branch') )
'-fcf-protection=branch',           else
            if (  (___jln_c_flags.get('control_flow', 'default') == 'return') )
'-fcf-protection=return',             else
'-fcf-protection=full',             endif
          endif
        else
          if (  ( (___jln_c_flags.get('control_flow', 'default') == 'allow_bugs') and (___jln_c_compiler_id == 'clang') ) )
'-fsanitize=cfi', '-fvisibility=hidden', '-flto', '-fsanitize=cfi', '-flto',           endif
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('color', 'default') == 'default')) )
      if (  ( ( (___jln_c_compiler_id == 'gcc') and not ( ___jln_c_compiler_version.version_compare('<4.9') ) ) or (___jln_c_compiler_id == 'clang') or (___jln_c_compiler_id == 'clang-cl') ) )
        if (  (___jln_c_flags.get('color', 'default') == 'auto') )
'-fdiagnostics-color=auto',         else
          if (  (___jln_c_flags.get('color', 'default') == 'never') )
'-fdiagnostics-color=never',           else
            if (  (___jln_c_flags.get('color', 'default') == 'always') )
'-fdiagnostics-color=always',             endif
          endif
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('reproducible_build_warnings', 'default') == 'default')) )
      if (  ( (___jln_c_compiler_id == 'gcc') and not ( ___jln_c_compiler_version.version_compare('<4.9') ) ) )
        if (  (___jln_c_flags.get('reproducible_build_warnings', 'default') == 'on') )
'-Wdate-time',         else
'-Wno-date-time',         endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('diagnostics_format', 'default') == 'default')) )
      if (  (___jln_c_flags.get('diagnostics_format', 'default') == 'fixits') )
        if (  ( ( (___jln_c_compiler_id == 'gcc') and not ( ___jln_c_compiler_version.version_compare('<7.0') ) ) or ( (___jln_c_compiler_id == 'clang') and not ( ___jln_c_compiler_version.version_compare('<5.0') ) ) or ( (___jln_c_compiler_id == 'clang-cl') and not ( ___jln_c_compiler_version.version_compare('<5.0') ) ) ) )
'-fdiagnostics-parseable-fixits',         endif
      else
        if (  (___jln_c_flags.get('diagnostics_format', 'default') == 'patch') )
          if (  ( (___jln_c_compiler_id == 'gcc') and not ( ___jln_c_compiler_version.version_compare('<7.0') ) ) )
'-fdiagnostics-generate-patch',           endif
        else
          if (  (___jln_c_flags.get('diagnostics_format', 'default') == 'print_source_range_info') )
            if (  (___jln_c_compiler_id == 'clang') )
'-fdiagnostics-print-source-range-info',             endif
          endif
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('fix_compiler_error', 'default') == 'default')) )
      if (  (___jln_c_flags.get('fix_compiler_error', 'default') == 'on') )
'-Werror=write-strings',       else
        if (  ( (___jln_c_compiler_id == 'clang') or (___jln_c_compiler_id == 'clang-cl') ) )
'-Wno-error=c++11-narrowing', '-Wno-reserved-user-defined-literal',         endif
      endif
    endif
  endif
  if (  ( (___jln_c_compiler_id == 'gcc') or (___jln_c_compiler_id == 'clang') ) )
    if (  not ( (___jln_c_flags.get('coverage', 'default') == 'default')) )
      if (  (___jln_c_flags.get('coverage', 'default') == 'on') )
'--coverage', '--coverage',         if (  (___jln_c_compiler_id == 'clang') )
'-lprofile_rt',         endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('debug', 'default') == 'default')) )
      if (  (___jln_c_flags.get('debug', 'default') == 'off') )
'-g0',       else
        if (  (___jln_c_flags.get('debug', 'default') == 'gdb') )
'-ggdb',         else
          if (  (___jln_c_compiler_id == 'clang') )
            if (  (___jln_c_flags.get('debug', 'default') == 'line_tables_only') )
'-gline-tables-only',             endif
            if (  (___jln_c_flags.get('debug', 'default') == 'lldb') )
'-glldb',             else
              if (  (___jln_c_flags.get('debug', 'default') == 'sce') )
'-gsce',               else
'-g',               endif
            endif
          else
'-g',           endif
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('linker', 'default') == 'default')) )
      if (  (___jln_c_flags.get('linker', 'default') == 'native') )
        if (  (___jln_c_compiler_id == 'gcc') )
'-fuse-ld=gold',         else
'-fuse-ld=lld',         endif
      else
        if (  (___jln_c_flags.get('linker', 'default') == 'bfd') )
'-fuse-ld=bfd',         else
          if (  ( (___jln_c_flags.get('linker', 'default') == 'gold') or ( (___jln_c_compiler_id == 'gcc') and not ( not ( ___jln_c_compiler_version.version_compare('<9.0') ) ) ) ) )
'-fuse-ld=gold',           else
            if (  not ( (___jln_c_flags.get('lto', 'default') == 'default')) )
              if (  ( not ( (___jln_c_flags.get('lto', 'default') == 'off') ) and (___jln_c_compiler_id == 'gcc') ) )
'-fuse-ld=gold',               else
'-fuse-ld=lld',               endif
            else
'-fuse-ld=lld',             endif
          endif
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('lto', 'default') == 'default')) )
      if (  (___jln_c_flags.get('lto', 'default') == 'off') )
'-fno-lto', '-fno-lto',       else
        if (  (___jln_c_compiler_id == 'gcc') )
'-flto', '-flto',           if (  not ( ___jln_c_compiler_version.version_compare('<5.0') ) )
            if (  not ( (___jln_c_flags.get('warnings', 'default') == 'default')) )
              if (  not ( (___jln_c_flags.get('warnings', 'default') == 'off') ) )
'-flto-odr-type-merging', '-flto-odr-type-merging',               endif
            endif
            if (  (___jln_c_flags.get('lto', 'default') == 'fat') )
'-ffat-lto-objects',             else
              if (  (___jln_c_flags.get('lto', 'default') == 'thin') )
'-fuse-linker-plugin',               endif
            endif
          endif
        else
          if (  ( (___jln_c_flags.get('lto', 'default') == 'thin') and (___jln_c_compiler_id == 'clang') and not ( ___jln_c_compiler_version.version_compare('<6.0') ) ) )
'-flto=thin', '-flto=thin',           else
'-flto', '-flto',           endif
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('optimization', 'default') == 'default')) )
      if (  (___jln_c_flags.get('optimization', 'default') == '0') )
'-O0', '-O0',       else
        if (  (___jln_c_flags.get('optimization', 'default') == 'g') )
'-Og', '-Og',         else
'-DNDEBUG', '-Wl,-O1',           if (  (___jln_c_flags.get('optimization', 'default') == 'size') )
'-Os', '-Os',           else
            if (  (___jln_c_flags.get('optimization', 'default') == 'fast') )
'-Ofast', '-Ofast',             else
              if (  (___jln_c_flags.get('optimization', 'default') == '1') )
'-O1', '-O1',               else
                if (  (___jln_c_flags.get('optimization', 'default') == '2') )
'-O2', '-O2',                 else
                  if (  (___jln_c_flags.get('optimization', 'default') == '3') )
'-O3', '-O3',                   endif
                endif
              endif
            endif
          endif
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('cpu', 'default') == 'default')) )
      if (  (___jln_c_flags.get('cpu', 'default') == 'generic') )
'-mtune=generic', '-mtune=generic',       else
'-march=native', '-mtune=native', '-march=native', '-mtune=native',       endif
    endif
    if (  not ( (___jln_c_flags.get('whole_program', 'default') == 'default')) )
      if (  (___jln_c_flags.get('whole_program', 'default') == 'off') )
'-fno-whole-program',         if (  ( (___jln_c_compiler_id == 'clang') and not ( ___jln_c_compiler_version.version_compare('<3.9') ) ) )
'-fno-whole-program-vtables', '-fno-whole-program-vtables',         endif
      else
        if (  (___jln_c_linker_id == 'ld64') )
'-Wl,-dead_strip', '-Wl,-S',         else
'-s',           if (  (___jln_c_flags.get('whole_program', 'default') == 'strip_all') )
'-Wl,--gc-sections', '-Wl,--strip-all',           endif
        endif
        if (  (___jln_c_compiler_id == 'gcc') )
'-fwhole-program', '-fwhole-program',         else
          if (  (___jln_c_compiler_id == 'clang') )
            if (  not ( ___jln_c_compiler_version.version_compare('<3.9') ) )
              if (  not ( (___jln_c_flags.get('lto', 'default') == 'default')) )
                if (  not ( (___jln_c_flags.get('lto', 'default') == 'off') ) )
'-fwhole-program-vtables', '-fwhole-program-vtables',                 endif
              endif
              if (  not ( ___jln_c_compiler_version.version_compare('<7.0') ) )
'-fforce-emit-vtables', '-fforce-emit-vtables',               endif
            endif
          endif
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('pedantic', 'default') == 'default')) )
      if (  not ( (___jln_c_flags.get('pedantic', 'default') == 'off') ) )
'-pedantic',         if (  (___jln_c_flags.get('pedantic', 'default') == 'as_error') )
'-pedantic-errors',         endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('stack_protector', 'default') == 'default')) )
      if (  (___jln_c_flags.get('stack_protector', 'default') == 'off') )
'-Wno-stack-protector', '-U_FORTIFY_SOURCE', '-Wno-stack-protector',       else
'-D_FORTIFY_SOURCE=2', '-Wstack-protector',         if (  (___jln_c_flags.get('stack_protector', 'default') == 'strong') )
          if (  ( (___jln_c_compiler_id == 'gcc') and not ( ___jln_c_compiler_version.version_compare('<4.9') ) ) )
'-fstack-protector-strong', '-fstack-protector-strong',           else
            if (  (___jln_c_compiler_id == 'clang') )
'-fstack-protector-strong', '-fsanitize=safe-stack', '-fstack-protector-strong', '-fsanitize=safe-stack',             endif
          endif
        else
          if (  (___jln_c_flags.get('stack_protector', 'default') == 'all') )
'-fstack-protector-all', '-fstack-protector-all',             if (  (___jln_c_compiler_id == 'clang') )
'-fsanitize=safe-stack', '-fsanitize=safe-stack',               if (  not ( ___jln_c_compiler_version.version_compare('<11.0') ) )
'-fstack-clash-protection', '-fstack-clash-protection',               endif
            endif
          else
'-fstack-protector', '-fstack-protector',           endif
        endif
        if (  (___jln_c_compiler_id == 'clang') )
'-fsanitize=shadow-call-stack', '-fsanitize=shadow-call-stack',         endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('relro', 'default') == 'default')) )
      if (  (___jln_c_flags.get('relro', 'default') == 'off') )
'-Wl,-z,norelro',       else
        if (  (___jln_c_flags.get('relro', 'default') == 'on') )
'-Wl,-z,relro',         else
          if (  (___jln_c_flags.get('relro', 'default') == 'full') )
'-Wl,-z,relro,-z,now',           endif
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('pie', 'default') == 'default')) )
      if (  (___jln_c_flags.get('pie', 'default') == 'off') )
'-no-pic',       else
        if (  (___jln_c_flags.get('pie', 'default') == 'on') )
'-pie',         else
          if (  (___jln_c_flags.get('pie', 'default') == 'pic') )
'-fPIC',           endif
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('shadow_warnings', 'default') == 'default')) )
      if (  (___jln_c_flags.get('shadow_warnings', 'default') == 'off') )
'-Wno-shadow',         if (  ( (___jln_c_compiler_id == 'clang') and not ( ___jln_c_compiler_version.version_compare('<8.0') ) ) )
'-Wno-shadow-field',         endif
      else
        if (  (___jln_c_flags.get('shadow_warnings', 'default') == 'on') )
'-Wshadow',         else
          if (  (___jln_c_flags.get('shadow_warnings', 'default') == 'all') )
            if (  (___jln_c_compiler_id == 'clang') )
'-Wshadow-all',             else
'-Wshadow',             endif
          else
            if (  ( (___jln_c_compiler_id == 'gcc') and not ( ___jln_c_compiler_version.version_compare('<7.1') ) ) )
              if (  (___jln_c_flags.get('shadow_warnings', 'default') == 'local') )
'-Wshadow=local',               else
                if (  (___jln_c_flags.get('shadow_warnings', 'default') == 'compatible_local') )
'-Wshadow=compatible-local',                 endif
              endif
            endif
          endif
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('exceptions', 'default') == 'default')) )
      if (  (___jln_c_flags.get('exceptions', 'default') == 'on') )
'-fexceptions',       else
'-fno-exceptions',       endif
    endif
    if (  not ( (___jln_c_flags.get('sanitizers_extra', 'default') == 'default')) )
      if (  (___jln_c_flags.get('sanitizers_extra', 'default') == 'thread') )
'-fsanitize=thread',       else
        if (  (___jln_c_flags.get('sanitizers_extra', 'default') == 'pointer') )
          if (  ( (___jln_c_compiler_id == 'gcc') and not ( ___jln_c_compiler_version.version_compare('<8.0') ) ) )
'-fsanitize=pointer-compare', '-fsanitize=pointer-subtract',           endif
        endif
      endif
    endif
  endif
  if (  (___jln_c_linker_id == 'lld-link') )
    if (  not ( (___jln_c_flags.get('lto', 'default') == 'default')) )
      if (  (___jln_c_flags.get('lto', 'default') == 'off') )
'-fno-lto',       else
        if (  (___jln_c_flags.get('lto', 'default') == 'thin') )
'-flto=thin',         else
'-flto', '-flto',         endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('whole_program', 'default') == 'default')) )
      if (  (___jln_c_flags.get('whole_program', 'default') == 'off') )
'-fno-whole-program',       else
        if (  not ( (___jln_c_flags.get('lto', 'default') == 'default')) )
          if (  not ( (___jln_c_flags.get('lto', 'default') == 'off') ) )
'-fwhole-program-vtables', '-fwhole-program-vtables',           endif
        endif
      endif
    endif
  endif
  if (  ( (___jln_c_compiler_id == 'msvc') or (___jln_c_compiler_id == 'clang-cl') ) )
    if (  not ( (___jln_c_flags.get('stl_fix', 'default') == 'default')) )
      if (  (___jln_c_flags.get('stl_fix', 'default') == 'on') )
'/DNOMINMAX',       endif
    endif
    if (  not ( (___jln_c_flags.get('debug', 'default') == 'default')) )
      if (  (___jln_c_flags.get('debug', 'default') == 'off') )
'/DEBUG:NONE',       else
'/RTC1', '/Od',         if (  (___jln_c_flags.get('debug', 'default') == 'on') )
'/DEBUG',         else
          if (  (___jln_c_flags.get('debug', 'default') == 'line_tables_only') )
'/DEBUG:FASTLINK',           endif
        endif
        if (  not ( (___jln_c_flags.get('optimization', 'default') == 'default')) )
          if (  (___jln_c_flags.get('optimization', 'default') == 'g') )
'/Zi',           else
            if (  not ( (___jln_c_flags.get('whole_program', 'default') == 'default')) )
              if (  (___jln_c_flags.get('whole_program', 'default') == 'off') )
'/ZI',               else
'/Zi',               endif
            else
'/ZI',             endif
          endif
        else
          if (  not ( (___jln_c_flags.get('whole_program', 'default') == 'default')) )
            if (  (___jln_c_flags.get('whole_program', 'default') == 'off') )
'/ZI',             else
'/Zi',             endif
          else
'/ZI',           endif
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('exceptions', 'default') == 'default')) )
      if (  (___jln_c_flags.get('exceptions', 'default') == 'on') )
'/EHsc', '/D_HAS_EXCEPTIONS=1',       else
'/EHs-', '/D_HAS_EXCEPTIONS=0',       endif
    endif
    if (  not ( (___jln_c_flags.get('optimization', 'default') == 'default')) )
      if (  (___jln_c_flags.get('optimization', 'default') == '0') )
'/Ob0', '/Od', '/Oi-', '/Oy-',       else
        if (  (___jln_c_flags.get('optimization', 'default') == 'g') )
'/Ob1',         else
'/DNDEBUG',           if (  (___jln_c_flags.get('optimization', 'default') == '1') )
'/O1',           else
            if (  (___jln_c_flags.get('optimization', 'default') == '2') )
'/O2',             else
              if (  (___jln_c_flags.get('optimization', 'default') == '3') )
'/O2',               else
                if (  (___jln_c_flags.get('optimization', 'default') == 'size') )
'/O1', '/Gw',                 else
                  if (  (___jln_c_flags.get('optimization', 'default') == 'fast') )
'/O2', '/fp:fast',                   endif
                endif
              endif
            endif
          endif
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('whole_program', 'default') == 'default')) )
      if (  (___jln_c_flags.get('whole_program', 'default') == 'off') )
'/GL-',       else
'/GL', '/Gw', '/LTCG',         if (  (___jln_c_flags.get('whole_program', 'default') == 'strip_all') )
'/OPT:REF',         endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('pedantic', 'default') == 'default')) )
      if (  not ( (___jln_c_flags.get('pedantic', 'default') == 'off') ) )
'/permissive-',       endif
    endif
    if (  not ( (___jln_c_flags.get('rtti', 'default') == 'default')) )
      if (  (___jln_c_flags.get('rtti', 'default') == 'on') )
'/GR',       else
'/GR-',       endif
    endif
    if (  not ( (___jln_c_flags.get('stl_debug', 'default') == 'default')) )
      if (  (___jln_c_flags.get('stl_debug', 'default') == 'off') )
'/D_HAS_ITERATOR_DEBUGGING=0',       else
'/D_DEBUG', '/D_HAS_ITERATOR_DEBUGGING=1',       endif
    endif
    if (  not ( (___jln_c_flags.get('control_flow', 'default') == 'default')) )
      if (  (___jln_c_flags.get('control_flow', 'default') == 'off') )
'/guard:cf-',       else
'/guard:cf',       endif
    endif
    if (  not ( (___jln_c_flags.get('stack_protector', 'default') == 'default')) )
      if (  (___jln_c_flags.get('stack_protector', 'default') == 'off') )
'/GS-',       else
'/GS', '/sdl',         if (  (___jln_c_flags.get('stack_protector', 'default') == 'strong') )
'/RTC1',         else
          if (  (___jln_c_flags.get('stack_protector', 'default') == 'all') )
'/RTC1', '/RTCc',           endif
        endif
      endif
    endif
  endif
  if (  (___jln_c_compiler_id == 'msvc') )
    if (  not ( (___jln_c_flags.get('msvc_isystem', 'default') == 'default')) )
'/experimental:external', '/external:W0',       if (  (___jln_c_flags.get('msvc_isystem', 'default') == 'anglebrackets') )
'/external:anglebrackets',       else
'/external:env:INCLUDE', '/external:env:CAExcludePath',       endif
      if (  not ( (___jln_c_flags.get('msvc_isystem_with_template_from_non_external', 'default') == 'default')) )
        if (  (___jln_c_flags.get('msvc_isystem_with_template_from_non_external', 'default') == 'off') )
'/external:template',         else
'/external:template-',         endif
      endif
      if (  not ( (___jln_c_flags.get('warnings', 'default') == 'default')) )
        if (  (___jln_c_flags.get('warnings', 'default') == 'off') )
'/W0',         else
'/wd4710', '/wd4711',           if (  not ( not ( ___jln_c_compiler_version.version_compare('<19.21') ) ) )
'/wd4774',           endif
          if (  (___jln_c_flags.get('warnings', 'default') == 'on') )
'/W4', '/wd4244', '/wd4245',           else
'/Wall', '/wd4571', '/wd4355', '/wd4548', '/wd4577', '/wd4820', '/wd5039', '/wd4464', '/wd4868', '/wd5045',             if (  (___jln_c_flags.get('warnings', 'default') == 'strict') )
'/wd4583', '/wd4619',             endif
          endif
        endif
      endif
    else
      if (  not ( (___jln_c_flags.get('warnings', 'default') == 'default')) )
        if (  (___jln_c_flags.get('warnings', 'default') == 'off') )
'/W0',         else
          if (  (___jln_c_flags.get('warnings', 'default') == 'on') )
'/W4', '/wd4244', '/wd4245', '/wd4711',           else
'/Wall', '/wd4355', '/wd4365', '/wd4514', '/wd4548', '/wd4571', '/wd4577', '/wd4625', '/wd4626', '/wd4668', '/wd4710', '/wd4711',             if (  not ( not ( ___jln_c_compiler_version.version_compare('<19.21') ) ) )
'/wd4774',             endif
'/wd4820', '/wd5026', '/wd5027', '/wd5039', '/wd4464', '/wd4868', '/wd5045',             if (  (___jln_c_flags.get('warnings', 'default') == 'strict') )
'/wd4061', '/wd4266', '/wd4388', '/wd4583', '/wd4619', '/wd4623', '/wd5204',             endif
          endif
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('shadow_warnings', 'default') == 'default')) )
      if (  (___jln_c_flags.get('shadow_warnings', 'default') == 'off') )
'/wd4456', '/wd4459',       else
        if (  ( (___jln_c_flags.get('shadow_warnings', 'default') == 'on') or (___jln_c_flags.get('shadow_warnings', 'default') == 'all') ) )
'/w4456', '/w4459',         else
          if (  (___jln_c_flags.get('shadow_warnings', 'default') == 'local') )
'/w4456', '/wd4459',           endif
        endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('warnings_as_error', 'default') == 'default')) )
      if (  (___jln_c_flags.get('warnings_as_error', 'default') == 'on') )
'/WX', '/WX',       else
        if (  (___jln_c_flags.get('warnings_as_error', 'default') == 'off') )
'/WX-',         endif
      endif
    endif
    if (  not ( (___jln_c_flags.get('lto', 'default') == 'default')) )
      if (  (___jln_c_flags.get('lto', 'default') == 'off') )
'/LTCG:OFF',       else
'/GL', '/LTCG',       endif
    endif
    if (  not ( (___jln_c_flags.get('sanitizers', 'default') == 'default')) )
      if (  (___jln_c_flags.get('sanitizers', 'default') == 'on') )
'/sdl',       else
        if (  not ( (___jln_c_flags.get('stack_protector', 'default') == 'default')) )
          if (  not ( (___jln_c_flags.get('stack_protector', 'default') == 'off') ) )
'/sdl-',           endif
        endif
      endif
    endif
  endif

  jln_c_custom_c_flags += [jln_c_c_flags]
  jln_c_custom_link_flags += [jln_c_link_flags]
endforeach
