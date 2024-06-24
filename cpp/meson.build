#  ```meson
#  # launch example: meson -Djln_sanitizers=on
#  # note: `meson --warnlevel=0` implies `--Djln_warnings=off`
#  
#  project('test', 'cpp')
#  
#  # default options (without prefix)
#  # optional
#  jln_default_flags = {'rtti': 'off'}
#  
#  # options for specific buildtype (added to default options)
#  # optional.
#  jln_buildtype_flags = {
#    'debug': {'rtti': 'on'},
#  }
#  
#  # Use a default configuration when jln_buildtype_flags is unspecified.
#  # optional.
#  jln_use_profile_buildtype = true
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
#  # Warning:
#  
#  analyzer = default off on taint
#  analyzer_too_complex_warning = default off on
#  analyzer_verbosity = default 0 1 2 3
#  conversion_warnings = on default off sign conversion
#  covered_switch_default_warnings = on default off
#  fix_compiler_error = on default off
#  msvc_crt_secure_no_warnings = on default off
#  noexcept_warnings = default off on
#  reproducible_build_warnings = default off on
#  shadow_warnings = off default on local compatible_local all
#  suggestions = default off on
#  switch_warnings = on default off exhaustive_enum mandatory_default exhaustive_enum_and_mandatory_default
#  unsafe_buffer_usage_warnings = off default on
#  warnings = on default off strict very_strict
#  warnings_as_error = default off on basic
#  windows_abi_compatibility_warnings = off default on
#  
#  # Pedantic:
#  
#  msvc_conformance = all default all_without_throwing_new
#  pedantic = on default off as_error
#  stl_fix = on default off
#  
#  # Debug:
#  
#  debug = default off on line_tables_only gdb lldb sce
#  float_sanitizers = default off on
#  integer_sanitizers = default off on
#  ndebug = with_optimization_1_or_above default off on
#  other_sanitizers = default off thread pointer memory
#  sanitizers = default off on
#  stl_debug = default off on allow_broken_abi allow_broken_abi_and_bugs assert_as_exception
#  var_init = default uninitialized pattern zero
#  
#  # Optimization:
#  
#  cpu = default generic native
#  linker = default bfd gold lld native
#  lto = default off on normal fat thin
#  optimization = default 0 g 1 2 3 fast size z
#  whole_program = default off on strip_all
#  
#  # C++:
#  
#  exceptions = default off on
#  rtti = default off on
#  
#  # Hardening:
#  
#  control_flow = default off on branch return allow_bugs
#  relro = default off on full
#  stack_protector = default off on strong all
#  
#  # Other:
#  
#  color = default auto never always
#  coverage = default off on
#  diagnostics_format = default fixits patch print_source_range_info
#  diagnostics_show_template_tree = default off on
#  elide_type = default off on
#  msvc_diagnostics_format = caret default classic column
#  msvc_isystem = default anglebrackets include_and_caexcludepath external_as_include_system_flag
#  msvc_isystem_with_template_from_non_external = default off on
#  pie = default off on static fpic fPIC fpie fPIE
#  windows_bigobj = on default
#  ```
#  <!-- ./compiler-options.lua -->
#  
#  The value `default` does nothing.
#  
#  If not specified:
#  
#  - `msvc_conformance` is `all`
#  - `msvc_diagnostics_format` is `caret`
#  - `ndebug` is `with_optimization_1_or_above`
#  - The following values are `off`:
#    - `shadow_warnings`
#    - `unsafe_buffer_usage_warnings`
#    - `windows_abi_compatibility_warnings`
#  - The following values are `on`:
#    - `conversion_warnings`
#    - `covered_switch_default_warnings`
#    - `fix_compiler_error`
#    - `msvc_crt_secure_no_warnings`
#    - `pedantic`
#    - `stl_fix`
#    - `switch_warnings`
#    - `warnings`
#    - `windows_bigobj`
#  
#  <!-- enddefault -->
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

if get_variable('jln_use_profile_buildtype', false)
  ___jln_options_by_modes = {
    'debug': {
      'control_flow': 'on',
      'debug': 'on',
      'sanitizers': 'on',
      'stl_debug': 'on',
    },
    'debugoptimized': {
      'debug': 'on',
      'linker': 'native',
      'lto': 'on',
      'optimization': 'g',
    },
    'minsize': {
      'linker': 'native',
      'lto': 'on',
      'optimization': 'size',
    },
    'release': {
      'linker': 'native',
      'lto': 'on',
      'optimization': '3',
    },
  }
else
  ___jln_options_by_modes = {}
endif

___jln_default_flags = get_variable('jln_default_flags', {}) + get_variable('jln_buildtype_flags', ___jln_options_by_modes).get(get_option('buildtype'), {})
if get_option('warning_level') == '0'
  ___jln_warnings = 'off'
else
  ___jln_warnings = ___jln_default_flags.get('warnings', get_option('jln_warnings'))
endif
___jln_flags = {
  'analyzer': ___jln_default_flags.get('analyzer', get_option('jln_analyzer')),
  'analyzer_too_complex_warning': ___jln_default_flags.get('analyzer_too_complex_warning', get_option('jln_analyzer_too_complex_warning')),
  'analyzer_verbosity': ___jln_default_flags.get('analyzer_verbosity', get_option('jln_analyzer_verbosity')),
  'color': ___jln_default_flags.get('color', get_option('jln_color')),
  'control_flow': ___jln_default_flags.get('control_flow', get_option('jln_control_flow')),
  'conversion_warnings': ___jln_default_flags.get('conversion_warnings', get_option('jln_conversion_warnings')),
  'coverage': ___jln_default_flags.get('coverage', get_option('jln_coverage')),
  'covered_switch_default_warnings': ___jln_default_flags.get('covered_switch_default_warnings', get_option('jln_covered_switch_default_warnings')),
  'cpu': ___jln_default_flags.get('cpu', get_option('jln_cpu')),
  'debug': ___jln_default_flags.get('debug', get_option('jln_debug')),
  'diagnostics_format': ___jln_default_flags.get('diagnostics_format', get_option('jln_diagnostics_format')),
  'diagnostics_show_template_tree': ___jln_default_flags.get('diagnostics_show_template_tree', get_option('jln_diagnostics_show_template_tree')),
  'elide_type': ___jln_default_flags.get('elide_type', get_option('jln_elide_type')),
  'exceptions': ___jln_default_flags.get('exceptions', get_option('jln_exceptions')),
  'fix_compiler_error': ___jln_default_flags.get('fix_compiler_error', get_option('jln_fix_compiler_error')),
  'float_sanitizers': ___jln_default_flags.get('float_sanitizers', get_option('jln_float_sanitizers')),
  'integer_sanitizers': ___jln_default_flags.get('integer_sanitizers', get_option('jln_integer_sanitizers')),
  'linker': ___jln_default_flags.get('linker', get_option('jln_linker')),
  'lto': ___jln_default_flags.get('lto', get_option('jln_lto')),
  'msvc_conformance': ___jln_default_flags.get('msvc_conformance', get_option('jln_msvc_conformance')),
  'msvc_crt_secure_no_warnings': ___jln_default_flags.get('msvc_crt_secure_no_warnings', get_option('jln_msvc_crt_secure_no_warnings')),
  'msvc_diagnostics_format': ___jln_default_flags.get('msvc_diagnostics_format', get_option('jln_msvc_diagnostics_format')),
  'msvc_isystem': ___jln_default_flags.get('msvc_isystem', get_option('jln_msvc_isystem')),
  'msvc_isystem_with_template_from_non_external': ___jln_default_flags.get('msvc_isystem_with_template_from_non_external', get_option('jln_msvc_isystem_with_template_from_non_external')),
  'ndebug': ___jln_default_flags.get('ndebug', get_option('jln_ndebug')),
  'noexcept_warnings': ___jln_default_flags.get('noexcept_warnings', get_option('jln_noexcept_warnings')),
  'optimization': ___jln_default_flags.get('optimization', get_option('jln_optimization')),
  'other_sanitizers': ___jln_default_flags.get('other_sanitizers', get_option('jln_other_sanitizers')),
  'pedantic': ___jln_default_flags.get('pedantic', get_option('jln_pedantic')),
  'pie': ___jln_default_flags.get('pie', get_option('jln_pie')),
  'relro': ___jln_default_flags.get('relro', get_option('jln_relro')),
  'reproducible_build_warnings': ___jln_default_flags.get('reproducible_build_warnings', get_option('jln_reproducible_build_warnings')),
  'rtti': ___jln_default_flags.get('rtti', get_option('jln_rtti')),
  'sanitizers': ___jln_default_flags.get('sanitizers', get_option('jln_sanitizers')),
  'shadow_warnings': ___jln_default_flags.get('shadow_warnings', get_option('jln_shadow_warnings')),
  'stack_protector': ___jln_default_flags.get('stack_protector', get_option('jln_stack_protector')),
  'stl_debug': ___jln_default_flags.get('stl_debug', get_option('jln_stl_debug')),
  'stl_fix': ___jln_default_flags.get('stl_fix', get_option('jln_stl_fix')),
  'suggestions': ___jln_default_flags.get('suggestions', get_option('jln_suggestions')),
  'switch_warnings': ___jln_default_flags.get('switch_warnings', get_option('jln_switch_warnings')),
  'unsafe_buffer_usage_warnings': ___jln_default_flags.get('unsafe_buffer_usage_warnings', get_option('jln_unsafe_buffer_usage_warnings')),
  'var_init': ___jln_default_flags.get('var_init', get_option('jln_var_init')),
  'warnings': ___jln_warnings,
  'warnings_as_error': ___jln_default_flags.get('warnings_as_error', get_option('jln_warnings_as_error')),
  'whole_program': ___jln_default_flags.get('whole_program', get_option('jln_whole_program')),
  'windows_abi_compatibility_warnings': ___jln_default_flags.get('windows_abi_compatibility_warnings', get_option('jln_windows_abi_compatibility_warnings')),
  'windows_bigobj': ___jln_default_flags.get('windows_bigobj', get_option('jln_windows_bigobj')),
}

jln_custom_cpp_flags = []
jln_custom_link_flags = []

___jln_compiler = meson.get_compiler('cpp')
___jln_compiler_id = ___jln_compiler.get_id()
if ___jln_compiler_id == 'emscripten'
  ___jln_compiler_version = ___jln_compiler.get_define('__clang_major__.__clang_minor__').replace(' ', '')
else
  ___jln_compiler_version = ___jln_compiler.version()
endif
___jln_linker_id = ___jln_compiler.get_linker_id()

___jln_custom_flags = get_variable('jln_custom_flags', []) + [___jln_flags]

foreach ___jln_flags : ___jln_custom_flags
  jln_cpp_flags = []
  jln_link_flags = []


  if (  ___jln_flags.get('ndebug', 'default') != 'default' )
    if (  ( ___jln_compiler_id == 'msvc' or ___jln_compiler_id == 'intel-cl' ) )
      if (  ___jln_flags.get('ndebug', 'default') == 'off' )
        jln_cpp_flags += ['/UNDEBUG', ]
      else
        if (  ___jln_flags.get('ndebug', 'default') == 'on' )
          jln_cpp_flags += ['/DNDEBUG', ]
        else
          if (  ___jln_flags.get('optimization', 'default') != 'default' )
            if (  not ( ( ___jln_flags.get('optimization', 'default') == '0' or ___jln_flags.get('optimization', 'default') == 'g' ) ) )
              jln_cpp_flags += ['/DNDEBUG', ]
            endif
          endif
        endif
      endif
    else
      if (  ___jln_flags.get('ndebug', 'default') == 'off' )
        jln_cpp_flags += ['-UNDEBUG', ]
      else
        if (  ___jln_flags.get('ndebug', 'default') == 'on' )
          jln_cpp_flags += ['-DNDEBUG', ]
        else
          if (  ___jln_flags.get('optimization', 'default') != 'default' )
            if (  not ( ( ___jln_flags.get('optimization', 'default') == '0' or ___jln_flags.get('optimization', 'default') == 'g' ) ) )
              jln_cpp_flags += ['-DNDEBUG', ]
            endif
          endif
        endif
      endif
    endif
  endif
  if (  ( ___jln_compiler_id == 'gcc' or ___jln_compiler_id == 'clang' or ___jln_compiler_id == 'clang-cl' or ___jln_compiler_id == 'emscripten' ) )
    if (  ___jln_flags.get('warnings', 'default') != 'default' )
      if (  ___jln_flags.get('warnings', 'default') == 'off' )
        jln_cpp_flags += ['-w', ]
      else
        if (  ___jln_compiler_id == 'gcc' )
          jln_cpp_flags += ['-Wall', '-Wextra', '-Wcast-align', '-Wcast-qual', '-Wdisabled-optimization', '-Wfloat-equal', '-Wformat-security', '-Wformat=2', '-Winvalid-pch', '-Wmissing-include-dirs', '-Wpacked', '-Wredundant-decls', '-Wundef', '-Wunused-macros', '-Wpointer-arith', '-Wmissing-declarations', '-Wnon-virtual-dtor', '-Wold-style-cast', '-Woverloaded-virtual', ]
          if (  ___jln_compiler_version.version_compare('>=4.7') )
            jln_cpp_flags += ['-Wsuggest-attribute=noreturn', '-Wzero-as-null-pointer-constant', '-Wlogical-op', '-Wvector-operation-performance', '-Wdouble-promotion', '-Wtrampolines', ]
            if (  ___jln_compiler_version.version_compare('>=4.8') )
              jln_cpp_flags += ['-Wuseless-cast', ]
              if (  ___jln_compiler_version.version_compare('>=4.9') )
                jln_cpp_flags += ['-Wconditionally-supported', '-Wfloat-conversion', ]
                if (  ___jln_compiler_version.version_compare('>=5.1') )
                  jln_cpp_flags += ['-Wformat-signedness', '-Warray-bounds=2', '-Wstrict-null-sentinel', '-Wsuggest-override', ]
                  if (  ___jln_compiler_version.version_compare('>=6.1') )
                    jln_cpp_flags += ['-Wduplicated-cond', '-Wnull-dereference', ]
                    if (  ___jln_compiler_version.version_compare('>=7.0') )
                      jln_cpp_flags += ['-Waligned-new', ]
                      if (  ___jln_compiler_version.version_compare('>=7.1') )
                        jln_cpp_flags += ['-Walloc-zero', '-Walloca', '-Wformat-overflow=2', '-Wduplicated-branches', ]
                        if (  ___jln_compiler_version.version_compare('>=8.0') )
                          jln_cpp_flags += ['-Wclass-memaccess', ]
                          if (  ( ___jln_flags.get('warnings', 'default') == 'strict' or ___jln_flags.get('warnings', 'default') == 'very_strict' ) )
                            jln_cpp_flags += ['-Wcast-align=strict', ]
                          endif
                        endif
                      endif
                    endif
                  endif
                endif
              endif
            endif
          endif
        else
          jln_cpp_flags += ['-Weverything', '-Wno-documentation', '-Wno-documentation-unknown-command', '-Wno-newline-eof', '-Wno-c++98-compat', '-Wno-c++98-compat-pedantic', '-Wno-padded', '-Wno-global-constructors', '-Wno-weak-vtables', '-Wno-exit-time-destructors', ]
          if (   not ( ( ___jln_flags.get('switch_warnings', 'default') == 'off' or ___jln_flags.get('switch_warnings', 'default') == 'exhaustive_enum' or ___jln_flags.get('switch_warnings', 'default') == 'exhaustive_enum_and_mandatory_default' ) ) )
            jln_cpp_flags += ['-Wno-switch-enum', ]
          endif
          if (  ___jln_flags.get('covered_switch_default_warnings', 'default') == 'default' )
            jln_cpp_flags += ['-Wno-covered-switch-default', ]
          endif
          if (  ___jln_compiler_version.version_compare('>=3.9') )
            jln_cpp_flags += ['-Wno-undefined-var-template', ]
            if (  ___jln_compiler_version.version_compare('>=5.0') )
              jln_cpp_flags += ['-Wno-inconsistent-missing-destructor-override', ]
              if (  ___jln_compiler_version.version_compare('>=9.0') )
                jln_cpp_flags += ['-Wno-ctad-maybe-unsupported', ]
                if (  ___jln_compiler_version.version_compare('>=10.0') )
                  jln_cpp_flags += ['-Wno-c++20-compat', ]
                  if (  ___jln_compiler_version.version_compare('>=11.0') )
                    jln_cpp_flags += ['-Wno-suggest-destructor-override', ]
                    if (  ___jln_compiler_version.version_compare('>=16.0') )
                      if (  ___jln_flags.get('unsafe_buffer_usage_warnings', 'default') == 'default' )
                        jln_cpp_flags += ['-Wno-unsafe-buffer-usage', ]
                      endif
                    endif
                  endif
                endif
              endif
            endif
          endif
        endif
      endif
    endif
    if (  ___jln_compiler_id == 'gcc' )
      if (  ___jln_flags.get('switch_warnings', 'default') != 'default' )
        if (  ___jln_flags.get('switch_warnings', 'default') == 'on' )
          jln_cpp_flags += ['-Wswitch', ]
        else
          if (  ___jln_flags.get('switch_warnings', 'default') == 'exhaustive_enum' )
            jln_cpp_flags += ['-Wswitch-enum', ]
          else
            if (  ___jln_flags.get('switch_warnings', 'default') == 'mandatory_default' )
              jln_cpp_flags += ['-Wswitch-default', ]
            else
              if (  ___jln_flags.get('switch_warnings', 'default') == 'exhaustive_enum_and_mandatory_default' )
                jln_cpp_flags += ['-Wswitch-default', '-Wswitch-enum', ]
              else
                jln_cpp_flags += ['-Wno-switch', '-Wno-switch-enum', '-Wno-switch-default', ]
              endif
            endif
          endif
        endif
      endif
    else
      if (  ___jln_flags.get('switch_warnings', 'default') != 'default' )
        if (  ___jln_flags.get('switch_warnings', 'default') == 'on' )
          jln_cpp_flags += ['-Wswitch', '-Wno-switch-default', ]
        else
          if (  ___jln_flags.get('switch_warnings', 'default') == 'mandatory_default' )
            jln_cpp_flags += ['-Wswitch', '-Wswitch-default', ]
          else
            if (  ___jln_flags.get('switch_warnings', 'default') == 'exhaustive_enum' )
              jln_cpp_flags += ['-Wswitch', '-Wswitch-enum', '-Wno-switch-default', ]
            else
              if (  ___jln_flags.get('switch_warnings', 'default') == 'exhaustive_enum_and_mandatory_default' )
                jln_cpp_flags += ['-Wswitch', '-Wswitch-enum', '-Wswitch-default', ]
              else
                jln_cpp_flags += ['-Wno-switch', '-Wno-switch-enum', '-Wno-switch-default', ]
              endif
            endif
          endif
        endif
      endif
      if (  ___jln_flags.get('covered_switch_default_warnings', 'default') != 'default' )
        if (  ___jln_flags.get('covered_switch_default_warnings', 'default') == 'off' )
          jln_cpp_flags += ['-Wno-covered-switch-default', ]
        else
          jln_cpp_flags += ['-Wcovered-switch-default', ]
        endif
      endif
    endif
    if (  ___jln_flags.get('unsafe_buffer_usage_warnings', 'default') != 'default' )
      if (  ( ___jln_compiler_id == 'clang' and ___jln_compiler_version.version_compare('>=16.0') ) )
        if (  ___jln_flags.get('unsafe_buffer_usage_warnings', 'default') == 'off' )
          jln_cpp_flags += ['-Wno-unsafe-buffer-usage', ]
        else
          jln_cpp_flags += ['-Wunsafe-buffer-usage', ]
        endif
      endif
    endif
    if (  ___jln_flags.get('diagnostics_show_template_tree', 'default') != 'default' )
      if (  ( ( ___jln_compiler_id == 'gcc' and ___jln_compiler_version.version_compare('>=8.0') ) or ___jln_compiler_id == 'clang' ) )
        if (  ___jln_flags.get('diagnostics_show_template_tree', 'default') == 'on' )
          jln_cpp_flags += ['-fdiagnostics-show-template-tree', ]
        else
          jln_cpp_flags += ['-fno-diagnostics-show-template-tree', ]
        endif
      endif
    endif
    if (  ___jln_flags.get('elide_type', 'default') != 'default' )
      if (  ___jln_flags.get('elide_type', 'default') == 'on' )
        if (  ( ___jln_compiler_id == 'gcc' and ___jln_compiler_version.version_compare('>=8.0') ) )
          jln_cpp_flags += ['-felide-type', ]
        endif
      else
        if (  ( ( ___jln_compiler_id == 'gcc' and ___jln_compiler_version.version_compare('>=8.0') ) or ( ___jln_compiler_id == 'clang' and ___jln_compiler_version.version_compare('>=3.4') ) ) )
          jln_cpp_flags += ['-fno-elide-type', ]
        endif
      endif
    endif
    if (  ___jln_flags.get('exceptions', 'default') != 'default' )
      if (  ___jln_flags.get('exceptions', 'default') == 'on' )
        jln_cpp_flags += ['-fexceptions', ]
        if (  ___jln_compiler_id == 'emscripten' )
          jln_cpp_flags += ['-sDISABLE_EXCEPTION_CATCHING=0', ]
        endif
      else
        jln_cpp_flags += ['-fno-exceptions', ]
      endif
    endif
    if (  ___jln_flags.get('rtti', 'default') != 'default' )
      if (  ___jln_flags.get('rtti', 'default') == 'on' )
        jln_cpp_flags += ['-frtti', ]
      else
        jln_cpp_flags += ['-fno-rtti', ]
      endif
    endif
    if (  ___jln_flags.get('var_init', 'default') != 'default' )
      if (  ( ( ___jln_compiler_id == 'gcc' and ___jln_compiler_version.version_compare('>=12.0') ) or ( ___jln_compiler_id == 'clang' and ___jln_compiler_version.version_compare('>=8.0') ) ) )
        if (  ___jln_compiler_id == 'clang' )
          jln_cpp_flags += ['-enable-trivial-auto-var-init-zero-knowing-it-will-be-removed-from-clang', ]
        endif
        if (  ___jln_flags.get('var_init', 'default') == 'pattern' )
          jln_cpp_flags += ['-ftrivial-auto-var-init=pattern', ]
        else
          if (  ___jln_flags.get('var_init', 'default') == 'zero' )
            jln_cpp_flags += ['-ftrivial-auto-var-init=zero', ]
          else
            jln_cpp_flags += ['-ftrivial-auto-var-init=uninitialized', ]
          endif
        endif
      endif
    endif
    if (  ___jln_flags.get('windows_abi_compatibility_warnings', 'default') != 'default' )
      if (  ( ( ___jln_compiler_id == 'gcc' and ___jln_compiler_version.version_compare('>=10.0') ) or ___jln_compiler_id == 'clang' or ___jln_compiler_id == 'clang-cl' or ___jln_compiler_id == 'emscripten' ) )
        if (  ___jln_flags.get('windows_abi_compatibility_warnings', 'default') == 'on' )
          jln_cpp_flags += ['-Wmismatched-tags', ]
        else
          jln_cpp_flags += ['-Wno-mismatched-tags', ]
        endif
      endif
    endif
    if (  ___jln_flags.get('warnings_as_error', 'default') != 'default' )
      if (  ___jln_flags.get('warnings_as_error', 'default') == 'on' )
        jln_cpp_flags += ['-Werror', ]
      else
        if (  ___jln_flags.get('warnings_as_error', 'default') == 'basic' )
          jln_cpp_flags += ['-Werror=return-type', '-Werror=init-self', ]
          if (  ___jln_compiler_id == 'gcc' )
            jln_cpp_flags += ['-Werror=div-by-zero', ]
            if (  ___jln_compiler_version.version_compare('>=5.1') )
              jln_cpp_flags += ['-Werror=array-bounds', '-Werror=logical-op', '-Werror=logical-not-parentheses', ]
              if (  ___jln_compiler_version.version_compare('>=7.0') )
                jln_cpp_flags += ['-Werror=literal-suffix', ]
              endif
            endif
          else
            jln_cpp_flags += ['-Werror=array-bounds', '-Werror=division-by-zero', ]
            if (  ___jln_compiler_version.version_compare('>=3.4') )
              jln_cpp_flags += ['-Werror=logical-not-parentheses', ]
              if (  ___jln_compiler_version.version_compare('>=3.6') )
                jln_cpp_flags += ['-Werror=delete-incomplete', ]
                if (  ___jln_compiler_version.version_compare('>=6.0') )
                  jln_cpp_flags += ['-Werror=user-defined-literals', ]
                  if (  ___jln_compiler_version.version_compare('>=7.0') )
                    jln_cpp_flags += ['-Werror=dynamic-class-memaccess', ]
                  endif
                endif
              endif
            endif
          endif
        else
          jln_cpp_flags += ['-Wno-error', ]
        endif
      endif
    endif
    if (  ___jln_flags.get('suggestions', 'default') != 'default' )
      if (  ___jln_flags.get('suggestions', 'default') != 'off' )
        if (  ___jln_compiler_id == 'gcc' )
          jln_cpp_flags += ['-Wsuggest-attribute=pure', '-Wsuggest-attribute=const', ]
          if (  ___jln_compiler_version.version_compare('>=5.0') )
            jln_cpp_flags += ['-Wsuggest-final-types', '-Wsuggest-final-methods', ]
            if (  ___jln_compiler_version.version_compare('>=5.1') )
              jln_cpp_flags += ['-Wnoexcept', ]
            endif
          endif
        endif
      endif
    endif
    if (  ___jln_flags.get('sanitizers', 'default') != 'default' )
      if (  ___jln_flags.get('sanitizers', 'default') == 'off' )
        jln_cpp_flags += ['-fno-sanitize=all', ]
        jln_link_flags += ['-fno-sanitize=all', ]
      else
        if (  ___jln_compiler_id == 'clang-cl' )
          jln_cpp_flags += ['-fsanitize=undefined', '-fsanitize=address', '-fsanitize-address-use-after-scope', ]
        else
          if (  ( ___jln_compiler_id == 'clang' or ___jln_compiler_id == 'emscripten' ) )
            if (  ___jln_compiler_version.version_compare('>=3.1') )
              jln_cpp_flags += ['-fsanitize=undefined', '-fsanitize=address', '-fsanitize-address-use-after-scope', '-fno-omit-frame-pointer', '-fno-optimize-sibling-calls', ]
              jln_link_flags += ['-fsanitize=undefined', '-fsanitize=address', ]
              if (  ___jln_compiler_id == 'clang' )
                if (  ___jln_compiler_version.version_compare('>=3.4') )
                  jln_cpp_flags += ['-fsanitize=leak', ]
                  jln_link_flags += ['-fsanitize=leak', ]
                endif
                if (  ___jln_compiler_version.version_compare('>=6.0') )
                  if (  ___jln_flags.get('stack_protector', 'default') != 'default' )
                    if (  ___jln_flags.get('stack_protector', 'default') != 'off' )
                      jln_cpp_flags += ['-fsanitize-minimal-runtime', ]
                    endif
                  endif
                endif
              endif
            endif
          else
            if (  ___jln_compiler_version.version_compare('>=4.8') )
              jln_cpp_flags += ['-fsanitize=address', '-fno-omit-frame-pointer', '-fno-optimize-sibling-calls', ]
              jln_link_flags += ['-fsanitize=address', ]
              if (  ___jln_compiler_version.version_compare('>=4.9') )
                jln_cpp_flags += ['-fsanitize=undefined', '-fsanitize=leak', ]
                jln_link_flags += ['-fsanitize=undefined', '-fsanitize=leak', ]
              endif
            endif
          endif
        endif
      endif
    endif
    if (  ___jln_flags.get('control_flow', 'default') != 'default' )
      if (  ___jln_compiler_id == 'emscripten' )
        if (  ___jln_flags.get('control_flow', 'default') == 'off' )
          jln_link_flags += ['-sASSERTIONS=0', '-sSAFE_HEAP=0', ]
        else
          jln_link_flags += ['-sASSERTIONS=1', '-sDEMANGLE_SUPPORT=1', ]
          if (   not ( ( ___jln_flags.get('sanitizers', 'default') == 'on' ) ) )
            jln_link_flags += ['-sSAFE_HEAP=1', ]
          endif
        endif
      else
        if (  ___jln_flags.get('control_flow', 'default') == 'off' )
          if (  ( ___jln_compiler_id == 'gcc' and ___jln_compiler_version.version_compare('>=8.0') ) )
            jln_cpp_flags += ['-fcf-protection=none', ]
          else
            jln_cpp_flags += ['-fno-sanitize=cfi', '-fcf-protection=none', '-fno-sanitize-cfi-cross-dso', ]
            jln_link_flags += ['-fno-sanitize=cfi', ]
          endif
        else
          if (  ( ( ___jln_compiler_id == 'gcc' and ___jln_compiler_version.version_compare('>=8.0') ) or ___jln_compiler_id != 'gcc' ) )
            if (  ___jln_flags.get('control_flow', 'default') == 'branch' )
              jln_cpp_flags += ['-fcf-protection=branch', ]
            else
              if (  ___jln_flags.get('control_flow', 'default') == 'return' )
                jln_cpp_flags += ['-fcf-protection=return', ]
              else
                jln_cpp_flags += ['-fcf-protection=full', ]
              endif
            endif
            if (  ( ___jln_flags.get('control_flow', 'default') == 'allow_bugs' and ___jln_compiler_id == 'clang' ) )
              jln_cpp_flags += ['-fsanitize=cfi', '-fvisibility=hidden', '-flto', ]
              jln_link_flags += ['-fsanitize=cfi', '-flto', ]
            endif
          endif
        endif
      endif
    endif
    if (  ___jln_flags.get('color', 'default') != 'default' )
      if (  ( ___jln_compiler_version.version_compare('>=4.9') or ___jln_compiler_id != 'gcc' ) )
        if (  ___jln_flags.get('color', 'default') == 'auto' )
          jln_cpp_flags += ['-fdiagnostics-color=auto', ]
        else
          if (  ___jln_flags.get('color', 'default') == 'never' )
            jln_cpp_flags += ['-fdiagnostics-color=never', ]
          else
            jln_cpp_flags += ['-fdiagnostics-color=always', ]
          endif
        endif
      endif
    endif
    if (  ___jln_flags.get('reproducible_build_warnings', 'default') != 'default' )
      if (  ( ___jln_compiler_id == 'gcc' and ___jln_compiler_version.version_compare('>=4.9') ) )
        if (  ___jln_flags.get('reproducible_build_warnings', 'default') == 'on' )
          jln_cpp_flags += ['-Wdate-time', ]
        else
          jln_cpp_flags += ['-Wno-date-time', ]
        endif
      endif
    endif
    if (  ___jln_flags.get('diagnostics_format', 'default') != 'default' )
      if (  ___jln_flags.get('diagnostics_format', 'default') == 'fixits' )
        if (  ( ( ___jln_compiler_id == 'gcc' and ___jln_compiler_version.version_compare('>=7.0') ) or ( ___jln_compiler_id != 'gcc' and ___jln_compiler_version.version_compare('>=5.0') ) ) )
          jln_cpp_flags += ['-fdiagnostics-parseable-fixits', ]
        endif
      else
        if (  ___jln_flags.get('diagnostics_format', 'default') == 'patch' )
          if (  ( ___jln_compiler_id == 'gcc' and ___jln_compiler_version.version_compare('>=7.0') ) )
            jln_cpp_flags += ['-fdiagnostics-generate-patch', ]
          endif
        else
          if (  ___jln_compiler_id == 'clang' )
            jln_cpp_flags += ['-fdiagnostics-print-source-range-info', ]
          endif
        endif
      endif
    endif
    if (  ___jln_flags.get('fix_compiler_error', 'default') != 'default' )
      if (  ___jln_flags.get('fix_compiler_error', 'default') == 'on' )
        if (  ___jln_compiler_id == 'gcc' )
          if (  ___jln_compiler_version.version_compare('>=4.7') )
            jln_cpp_flags += ['-Werror=narrowing', ]
            if (  ___jln_compiler_version.version_compare('>=7.1') )
              jln_cpp_flags += ['-Werror=literal-suffix', ]
            endif
          endif
        endif
        jln_cpp_flags += ['-Werror=write-strings', ]
      else
        if (  ___jln_compiler_id != 'gcc' )
          jln_cpp_flags += ['-Wno-error=c++11-narrowing', '-Wno-reserved-user-defined-literal', ]
        endif
      endif
    endif
    if (  ___jln_flags.get('lto', 'default') != 'default' )
      if (  ___jln_flags.get('lto', 'default') == 'off' )
        jln_cpp_flags += ['-fno-lto', ]
        jln_link_flags += ['-fno-lto', ]
      else
        if (  ___jln_compiler_id == 'gcc' )
          jln_cpp_flags += ['-flto', ]
          jln_link_flags += ['-flto', ]
          if (  ___jln_compiler_version.version_compare('>=5.0') )
            if (  ___jln_flags.get('warnings', 'default') != 'default' )
              if (  ___jln_flags.get('warnings', 'default') != 'off' )
                jln_cpp_flags += ['-flto-odr-type-merging', ]
                jln_link_flags += ['-flto-odr-type-merging', ]
              endif
            endif
            if (  ___jln_flags.get('lto', 'default') == 'fat' )
              jln_cpp_flags += ['-ffat-lto-objects', ]
            else
              if (  ___jln_flags.get('lto', 'default') == 'thin' )
                jln_link_flags += ['-fuse-linker-plugin', ]
              endif
            endif
          endif
        else
          if (  ___jln_compiler_id == 'clang-cl' )
            jln_link_flags += ['-fuse-ld=lld', ]
          endif
          if (  ( ( ___jln_flags.get('lto', 'default') == 'thin' or ___jln_flags.get('lto', 'default') == 'on' ) and ___jln_compiler_version.version_compare('>=6.0') ) )
            jln_cpp_flags += ['-flto=thin', ]
            jln_link_flags += ['-flto=thin', ]
          else
            jln_cpp_flags += ['-flto', ]
            jln_link_flags += ['-flto', ]
          endif
        endif
      endif
    endif
    if (  ___jln_flags.get('shadow_warnings', 'default') != 'default' )
      if (  ___jln_flags.get('shadow_warnings', 'default') == 'off' )
        jln_cpp_flags += ['-Wno-shadow', ]
        if (  ( ___jln_compiler_id == 'clang-cl' or ( ___jln_compiler_id == 'clang' and ___jln_compiler_version.version_compare('>=8.0') ) ) )
          jln_cpp_flags += ['-Wno-shadow-field', ]
        endif
      else
        if (  ___jln_flags.get('shadow_warnings', 'default') == 'on' )
          jln_cpp_flags += ['-Wshadow', ]
        else
          if (  ___jln_flags.get('shadow_warnings', 'default') == 'all' )
            if (  ___jln_compiler_id == 'gcc' )
              jln_cpp_flags += ['-Wshadow', ]
            else
              jln_cpp_flags += ['-Wshadow-all', ]
            endif
          else
            if (  ( ___jln_compiler_id == 'gcc' and ___jln_compiler_version.version_compare('>=7.1') ) )
              if (  ___jln_flags.get('shadow_warnings', 'default') == 'local' )
                jln_cpp_flags += ['-Wshadow=local', ]
              else
                jln_cpp_flags += ['-Wshadow=compatible-local', ]
              endif
            endif
          endif
        endif
      endif
    endif
    if (  ___jln_flags.get('float_sanitizers', 'default') != 'default' )
      if (  ( ( ___jln_compiler_id == 'gcc' and ___jln_compiler_version.version_compare('>=5.0') ) or ( ___jln_compiler_id == 'clang' and ___jln_compiler_version.version_compare('>=5.0') ) or ___jln_compiler_id == 'clang-cl' ) )
        if (  ___jln_flags.get('float_sanitizers', 'default') == 'on' )
          jln_cpp_flags += ['-fsanitize=float-divide-by-zero', '-fsanitize=float-cast-overflow', ]
        else
          jln_cpp_flags += ['-fno-sanitize=float-divide-by-zero', '-fno-sanitize=float-cast-overflow', ]
        endif
      endif
    endif
    if (  ___jln_flags.get('integer_sanitizers', 'default') != 'default' )
      if (  ( ( ___jln_compiler_id == 'clang' and ___jln_compiler_version.version_compare('>=5.0') ) or ___jln_compiler_id == 'clang-cl' ) )
        if (  ___jln_flags.get('integer_sanitizers', 'default') == 'on' )
          jln_cpp_flags += ['-fsanitize=integer', ]
        else
          jln_cpp_flags += ['-fno-sanitize=integer', ]
        endif
      else
        if (  ( ___jln_compiler_id == 'gcc' and ___jln_compiler_version.version_compare('>=4.9') ) )
          if (  ___jln_flags.get('integer_sanitizers', 'default') == 'on' )
            jln_cpp_flags += ['-ftrapv', '-fsanitize=undefined', ]
          endif
        endif
      endif
    endif
  endif
  if (  ___jln_flags.get('conversion_warnings', 'default') != 'default' )
    if (  ( ___jln_compiler_id == 'gcc' or ___jln_compiler_id == 'clang' or ___jln_compiler_id == 'clang-cl' or ___jln_compiler_id == 'emscripten' or ___jln_compiler_id == 'intel' ) )
      if (  ___jln_flags.get('conversion_warnings', 'default') == 'on' )
        jln_cpp_flags += ['-Wconversion', '-Wsign-compare', '-Wsign-conversion', ]
      else
        if (  ___jln_flags.get('conversion_warnings', 'default') == 'conversion' )
          jln_cpp_flags += ['-Wconversion', ]
        else
          if (  ___jln_flags.get('conversion_warnings', 'default') == 'sign' )
            jln_cpp_flags += ['-Wsign-compare', '-Wsign-conversion', ]
          else
            jln_cpp_flags += ['-Wno-conversion', '-Wno-sign-compare', '-Wno-sign-conversion', ]
          endif
        endif
      endif
    endif
  endif
  if (  ( ___jln_compiler_id == 'gcc' or ___jln_compiler_id == 'clang' or ___jln_compiler_id == 'emscripten' ) )
    if (  ___jln_flags.get('stl_debug', 'default') != 'default' )
      if (  ___jln_flags.get('stl_debug', 'default') != 'off' )
        if (  ___jln_flags.get('stl_debug', 'default') == 'assert_as_exception' )
          jln_cpp_flags += ['-D_LIBCPP_DEBUG_USE_EXCEPTIONS', ]
        endif
        if (  ( ___jln_flags.get('stl_debug', 'default') == 'allow_broken_abi' or ___jln_flags.get('stl_debug', 'default') == 'allow_broken_abi_and_bugs' ) )
          if (  ___jln_compiler_id == 'clang' )
            if (  ( ___jln_compiler_version.version_compare('>=8.0') or ___jln_flags.get('stl_debug', 'default') == 'allow_broken_abi_and_bugs' ) )
              jln_cpp_flags += ['-D_LIBCPP_DEBUG=1', ]
            endif
          endif
          jln_cpp_flags += ['-D_GLIBCXX_DEBUG', ]
        else
          jln_cpp_flags += ['-D_GLIBCXX_ASSERTIONS', ]
        endif
        if (  ___jln_flags.get('pedantic', 'default') != 'default' )
          if (  ___jln_flags.get('pedantic', 'default') != 'off' )
            jln_cpp_flags += ['-D_GLIBCXX_DEBUG_PEDANTIC', ]
          endif
        endif
      endif
    endif
    if (  ___jln_flags.get('pedantic', 'default') != 'default' )
      if (  ___jln_flags.get('pedantic', 'default') != 'off' )
        jln_cpp_flags += ['-pedantic', ]
        if (  ___jln_flags.get('pedantic', 'default') == 'as_error' )
          jln_cpp_flags += ['-pedantic-errors', ]
        endif
      endif
    endif
  endif
  if (  ___jln_compiler_id == 'emscripten' )
    if (  ___jln_flags.get('optimization', 'default') != 'default' )
      if (  ___jln_flags.get('optimization', 'default') == '0' )
        jln_cpp_flags += ['-O0', ]
        jln_link_flags += ['-O0', ]
      else
        if (  ___jln_flags.get('optimization', 'default') == 'g' )
          jln_cpp_flags += ['-Og', ]
          jln_link_flags += ['-Og', ]
        else
          if (  ___jln_flags.get('optimization', 'default') == '1' )
            jln_cpp_flags += ['-O1', ]
            jln_link_flags += ['-O1', ]
          else
            if (  ___jln_flags.get('optimization', 'default') == '2' )
              jln_cpp_flags += ['-O2', ]
              jln_link_flags += ['-O2', ]
            else
              if (  ___jln_flags.get('optimization', 'default') == '3' )
                jln_cpp_flags += ['-O3', ]
                jln_link_flags += ['-O3', ]
              else
                if (  ___jln_flags.get('optimization', 'default') == 'fast' )
                  jln_cpp_flags += ['-O3', '-mnontrapping-fptoint', ]
                  jln_link_flags += ['-O3', '-mnontrapping-fptoint', ]
                else
                  if (  ___jln_flags.get('optimization', 'default') == 'size' )
                    jln_cpp_flags += ['-Os', ]
                    jln_link_flags += ['-Os', ]
                  else
                    jln_cpp_flags += ['-Oz', ]
                    jln_link_flags += ['-Oz', ]
                  endif
                endif
              endif
            endif
          endif
        endif
      endif
    endif
    if (  ___jln_flags.get('debug', 'default') != 'default' )
      if (  ___jln_flags.get('debug', 'default') == 'off' )
        jln_cpp_flags += ['-g0', ]
      else
        jln_cpp_flags += ['-g', ]
      endif
    endif
  else
    if (  ( ___jln_compiler_id == 'gcc' or ___jln_compiler_id == 'clang' ) )
      if (  ( ___jln_compiler_id == 'gcc' and ___jln_compiler_version.version_compare('>=12.0') ) )
        jln_cpp_flags += ['-ffold-simple-inlines', ]
      endif
      if (  ___jln_flags.get('coverage', 'default') != 'default' )
        if (  ___jln_flags.get('coverage', 'default') == 'on' )
          jln_cpp_flags += ['--coverage', ]
          jln_link_flags += ['--coverage', ]
          if (  ___jln_compiler_id == 'clang' )
            jln_link_flags += ['-lprofile_rt', ]
          endif
        endif
      endif
      if (  ___jln_flags.get('debug', 'default') != 'default' )
        if (  ___jln_flags.get('debug', 'default') == 'off' )
          jln_cpp_flags += ['-g0', ]
        else
          if (  ___jln_flags.get('debug', 'default') == 'gdb' )
            jln_cpp_flags += ['-ggdb', ]
          else
            if (  ___jln_compiler_id == 'clang' )
              if (  ___jln_flags.get('debug', 'default') == 'line_tables_only' )
                jln_cpp_flags += ['-gline-tables-only', ]
              else
                if (  ___jln_flags.get('debug', 'default') == 'lldb' )
                  jln_cpp_flags += ['-glldb', ]
                else
                  if (  ___jln_flags.get('debug', 'default') == 'sce' )
                    jln_cpp_flags += ['-gsce', ]
                  else
                    jln_cpp_flags += ['-g', ]
                  endif
                endif
              endif
            else
              jln_cpp_flags += ['-g', ]
            endif
          endif
        endif
      endif
      if (  ___jln_flags.get('optimization', 'default') != 'default' )
        if (  ___jln_flags.get('optimization', 'default') == '0' )
          jln_cpp_flags += ['-O0', ]
        else
          if (  ___jln_flags.get('optimization', 'default') == 'g' )
            jln_cpp_flags += ['-Og', ]
          else
            jln_link_flags += ['-Wl,-O1', ]
            if (  ___jln_flags.get('optimization', 'default') == '1' )
              jln_cpp_flags += ['-O1', ]
            else
              if (  ___jln_flags.get('optimization', 'default') == '2' )
                jln_cpp_flags += ['-O2', ]
              else
                if (  ___jln_flags.get('optimization', 'default') == '3' )
                  jln_cpp_flags += ['-O3', ]
                else
                  if (  ___jln_flags.get('optimization', 'default') == 'size' )
                    jln_cpp_flags += ['-Os', ]
                  else
                    if (  ___jln_flags.get('optimization', 'default') == 'z' )
                      if (  ___jln_compiler_id == 'clang' )
                        jln_cpp_flags += ['-Oz', ]
                      else
                        jln_cpp_flags += ['-Os', ]
                      endif
                    else
                      jln_cpp_flags += ['-Ofast', ]
                    endif
                  endif
                endif
              endif
            endif
          endif
        endif
      endif
      if (  ___jln_flags.get('cpu', 'default') != 'default' )
        if (  ___jln_flags.get('cpu', 'default') == 'generic' )
          jln_cpp_flags += ['-mtune=generic', ]
          jln_link_flags += ['-mtune=generic', ]
        else
          jln_cpp_flags += ['-march=native', '-mtune=native', ]
          jln_link_flags += ['-march=native', '-mtune=native', ]
        endif
      endif
      if (  ___jln_flags.get('linker', 'default') != 'default' )
        if (  ___jln_flags.get('linker', 'default') == 'native' )
          if (  ___jln_compiler_id == 'gcc' )
            jln_link_flags += ['-fuse-ld=gold', ]
          else
            jln_link_flags += ['-fuse-ld=lld', ]
          endif
        else
          if (  ___jln_flags.get('linker', 'default') == 'bfd' )
            jln_link_flags += ['-fuse-ld=bfd', ]
          else
            if (  ( ___jln_flags.get('linker', 'default') == 'gold' or ( ___jln_compiler_id == 'gcc' and ___jln_compiler_version.version_compare('<9.0') ) ) )
              jln_link_flags += ['-fuse-ld=gold', ]
            else
              if (  ___jln_flags.get('lto', 'default') != 'default' )
                if (  ( ___jln_flags.get('lto', 'default') != 'off' and ___jln_compiler_id == 'gcc' ) )
                  jln_link_flags += ['-fuse-ld=gold', ]
                else
                  jln_link_flags += ['-fuse-ld=lld', ]
                endif
              else
                jln_link_flags += ['-fuse-ld=lld', ]
              endif
            endif
          endif
        endif
      endif
      if (  ___jln_flags.get('whole_program', 'default') != 'default' )
        if (  ___jln_flags.get('whole_program', 'default') == 'off' )
          jln_cpp_flags += ['-fno-whole-program', ]
          if (  ( ___jln_compiler_id == 'clang' and ___jln_compiler_version.version_compare('>=3.9') ) )
            jln_cpp_flags += ['-fno-whole-program-vtables', ]
            jln_link_flags += ['-fno-whole-program-vtables', ]
          endif
        else
          if (  ___jln_linker_id == 'ld64' )
            jln_link_flags += ['-Wl,-dead_strip', '-Wl,-S', ]
          else
            jln_link_flags += ['-s', ]
            if (  ___jln_flags.get('whole_program', 'default') == 'strip_all' )
              jln_link_flags += ['-Wl,--gc-sections', '-Wl,--strip-all', ]
            endif
          endif
          if (  ___jln_compiler_id == 'gcc' )
            jln_cpp_flags += ['-fwhole-program', ]
            jln_link_flags += ['-fwhole-program', ]
          else
            if (  ___jln_compiler_id == 'clang' )
              if (  ___jln_compiler_version.version_compare('>=3.9') )
                if (  ___jln_flags.get('lto', 'default') != 'default' )
                  if (  ___jln_flags.get('lto', 'default') != 'off' )
                    jln_cpp_flags += ['-fwhole-program-vtables', ]
                    jln_link_flags += ['-fwhole-program-vtables', ]
                  endif
                endif
                if (  ___jln_compiler_version.version_compare('>=7.0') )
                  jln_cpp_flags += ['-fforce-emit-vtables', ]
                  jln_link_flags += ['-fforce-emit-vtables', ]
                endif
              endif
            endif
          endif
        endif
      endif
      if (  ___jln_flags.get('stack_protector', 'default') != 'default' )
        if (  ___jln_flags.get('stack_protector', 'default') == 'off' )
          jln_cpp_flags += ['-Wno-stack-protector', '-U_FORTIFY_SOURCE', ]
          jln_link_flags += ['-Wno-stack-protector', ]
        else
          jln_cpp_flags += ['-D_FORTIFY_SOURCE=2', '-Wstack-protector', ]
          if (  ___jln_flags.get('stack_protector', 'default') == 'strong' )
            if (  ___jln_compiler_id == 'gcc' )
              if (  ___jln_compiler_version.version_compare('>=4.9') )
                jln_cpp_flags += ['-fstack-protector-strong', ]
                jln_link_flags += ['-fstack-protector-strong', ]
                if (  ___jln_compiler_version.version_compare('>=8.0') )
                  jln_cpp_flags += ['-fstack-clash-protection', ]
                  jln_link_flags += ['-fstack-clash-protection', ]
                endif
              endif
            else
              if (  ___jln_compiler_id == 'clang' )
                jln_cpp_flags += ['-fstack-protector-strong', '-fsanitize=safe-stack', ]
                jln_link_flags += ['-fstack-protector-strong', '-fsanitize=safe-stack', ]
                if (  ___jln_compiler_version.version_compare('>=11.0') )
                  jln_cpp_flags += ['-fstack-clash-protection', ]
                  jln_link_flags += ['-fstack-clash-protection', ]
                endif
              endif
            endif
          else
            if (  ___jln_flags.get('stack_protector', 'default') == 'all' )
              jln_cpp_flags += ['-fstack-protector-all', ]
              jln_link_flags += ['-fstack-protector-all', ]
              if (  ( ___jln_compiler_id == 'gcc' and ___jln_compiler_version.version_compare('>=8.0') ) )
                jln_cpp_flags += ['-fstack-clash-protection', ]
                jln_link_flags += ['-fstack-clash-protection', ]
              else
                if (  ___jln_compiler_id == 'clang' )
                  jln_cpp_flags += ['-fsanitize=safe-stack', ]
                  jln_link_flags += ['-fsanitize=safe-stack', ]
                  if (  ___jln_compiler_version.version_compare('>=11.0') )
                    jln_cpp_flags += ['-fstack-clash-protection', ]
                    jln_link_flags += ['-fstack-clash-protection', ]
                  endif
                endif
              endif
            else
              jln_cpp_flags += ['-fstack-protector', ]
              jln_link_flags += ['-fstack-protector', ]
            endif
          endif
          if (  ___jln_compiler_id == 'clang' )
            jln_cpp_flags += ['-fsanitize=shadow-call-stack', ]
            jln_link_flags += ['-fsanitize=shadow-call-stack', ]
          endif
        endif
      endif
      if (  ___jln_flags.get('relro', 'default') != 'default' )
        if (  ___jln_flags.get('relro', 'default') == 'off' )
          jln_link_flags += ['-Wl,-z,norelro', ]
        else
          if (  ___jln_flags.get('relro', 'default') == 'on' )
            jln_link_flags += ['-Wl,-z,relro', ]
          else
            jln_link_flags += ['-Wl,-z,relro,-z,now,-z,noexecstack', ]
            if (  ___jln_flags.get('linker', 'default') != 'default' )
              if (  not ( ( ___jln_flags.get('linker', 'default') == 'gold' or ( ___jln_compiler_id == 'gcc' and ___jln_compiler_version.version_compare('<9.0') ) or ( ___jln_flags.get('linker', 'default') == 'native' and ___jln_compiler_id == 'gcc' ) ) ) )
                jln_link_flags += ['-Wl,-z,separate-code', ]
              endif
            endif
          endif
        endif
      endif
      if (  ___jln_flags.get('pie', 'default') != 'default' )
        if (  ___jln_flags.get('pie', 'default') == 'off' )
          jln_link_flags += ['-no-pic', ]
        else
          if (  ___jln_flags.get('pie', 'default') == 'on' )
            jln_link_flags += ['-pie', ]
          else
            if (  ___jln_flags.get('pie', 'default') == 'fpie' )
              jln_cpp_flags += ['-fpie', ]
            else
              if (  ___jln_flags.get('pie', 'default') == 'fpic' )
                jln_cpp_flags += ['-fpic', ]
              else
                if (  ___jln_flags.get('pie', 'default') == 'fPIE' )
                  jln_cpp_flags += ['-fPIE', ]
                else
                  if (  ___jln_flags.get('pie', 'default') == 'fPIC' )
                    jln_cpp_flags += ['-fPIC', ]
                  else
                    jln_link_flags += ['-static-pie', ]
                  endif
                endif
              endif
            endif
          endif
        endif
      endif
      if (  ___jln_flags.get('other_sanitizers', 'default') != 'default' )
        if (  ___jln_flags.get('other_sanitizers', 'default') == 'thread' )
          jln_cpp_flags += ['-fsanitize=thread', ]
        else
          if (  ___jln_flags.get('other_sanitizers', 'default') == 'memory' )
            if (  ( ___jln_compiler_id == 'clang' and ___jln_compiler_version.version_compare('>=5.0') ) )
              jln_cpp_flags += ['-fsanitize=memory', '-fno-omit-frame-pointer', ]
            endif
          else
            if (  ___jln_flags.get('other_sanitizers', 'default') == 'pointer' )
              if (  ( ___jln_compiler_id == 'gcc' and ___jln_compiler_version.version_compare('>=8.0') ) )
                jln_cpp_flags += ['-fsanitize=pointer-compare', '-fsanitize=pointer-subtract', ]
              endif
            endif
          endif
        endif
      endif
      if (  ___jln_flags.get('noexcept_warnings', 'default') != 'default' )
        if (  ( ___jln_compiler_id == 'gcc' and ___jln_compiler_version.version_compare('>=4.9') ) )
          if (  ___jln_flags.get('noexcept_warnings', 'default') == 'on' )
            jln_cpp_flags += ['-Wnoexcept', ]
          else
            jln_cpp_flags += ['-Wno-noexcept', ]
          endif
        endif
      endif
      if (  ___jln_flags.get('analyzer', 'default') != 'default' )
        if (  ( ___jln_compiler_id == 'gcc' and ___jln_compiler_version.version_compare('>=10.0') ) )
          if (  ___jln_flags.get('analyzer', 'default') == 'off' )
            jln_cpp_flags += ['-fno-analyzer', ]
          else
            jln_cpp_flags += ['-fanalyzer', ]
            if (  ___jln_flags.get('analyzer', 'default') == 'taint' )
              jln_cpp_flags += ['-fanalyzer-checker=taint', ]
            endif
            if (  ___jln_flags.get('analyzer_too_complex_warning', 'default') != 'default' )
              if (  ___jln_flags.get('analyzer_too_complex_warning', 'default') == 'on' )
                jln_cpp_flags += ['-Wanalyzer-too-complex', ]
              else
                jln_cpp_flags += ['-Wno-analyzer-too-complex', ]
              endif
            endif
            if (  ___jln_flags.get('analyzer_verbosity', 'default') != 'default' )
              if (  ___jln_flags.get('analyzer_verbosity', 'default') == '0' )
                jln_cpp_flags += ['-fanalyzer-verbosity=0', ]
              else
                if (  ___jln_flags.get('analyzer_verbosity', 'default') == '1' )
                  jln_cpp_flags += ['-fanalyzer-verbosity=1', ]
                else
                  if (  ___jln_flags.get('analyzer_verbosity', 'default') == '2' )
                    jln_cpp_flags += ['-fanalyzer-verbosity=2', ]
                  else
                    jln_cpp_flags += ['-fanalyzer-verbosity=3', ]
                  endif
                endif
              endif
            endif
          endif
        endif
      endif
    endif
  endif
  if (  ___jln_linker_id == 'lld-link' )
    if (  ___jln_flags.get('lto', 'default') != 'default' )
      if (  ___jln_flags.get('lto', 'default') == 'off' )
        jln_cpp_flags += ['-fno-lto', ]
      else
        if (  ( ___jln_flags.get('lto', 'default') == 'thin' or ___jln_flags.get('lto', 'default') == 'on' ) )
          jln_cpp_flags += ['-flto=thin', ]
        else
          jln_cpp_flags += ['-flto', ]
          jln_link_flags += ['-flto', ]
        endif
      endif
    endif
    if (  ___jln_flags.get('whole_program', 'default') != 'default' )
      if (  ___jln_flags.get('whole_program', 'default') == 'off' )
        jln_cpp_flags += ['-fno-whole-program', ]
      else
        if (  ___jln_flags.get('lto', 'default') != 'default' )
          if (  ___jln_flags.get('lto', 'default') != 'off' )
            jln_cpp_flags += ['-fwhole-program-vtables', ]
            jln_link_flags += ['-fwhole-program-vtables', ]
          endif
        endif
      endif
    endif
  endif
  if (  ( ___jln_compiler_id == 'msvc' or ___jln_compiler_id == 'clang-cl' or ___jln_compiler_id == 'intel-cl' ) )
    if (  ___jln_flags.get('exceptions', 'default') != 'default' )
      if (  ___jln_flags.get('exceptions', 'default') == 'on' )
        jln_cpp_flags += ['/EHsc', '/D_HAS_EXCEPTIONS=1', ]
      else
        jln_cpp_flags += ['/EHs-', '/D_HAS_EXCEPTIONS=0', ]
      endif
    endif
    if (  ___jln_flags.get('rtti', 'default') != 'default' )
      if (  ___jln_flags.get('rtti', 'default') == 'on' )
        jln_cpp_flags += ['/GR', ]
      else
        jln_cpp_flags += ['/GR-', ]
      endif
    endif
    if (  ___jln_flags.get('stl_debug', 'default') != 'default' )
      if (  ___jln_flags.get('stl_debug', 'default') == 'off' )
        jln_cpp_flags += ['/D_HAS_ITERATOR_DEBUGGING=0', ]
      else
        jln_cpp_flags += ['/D_DEBUG', '/D_HAS_ITERATOR_DEBUGGING=1', ]
      endif
    endif
    if (  ___jln_flags.get('stl_fix', 'default') != 'default' )
      if (  ___jln_flags.get('stl_fix', 'default') == 'on' )
        jln_cpp_flags += ['/DNOMINMAX', ]
      endif
    endif
    if (  ___jln_compiler_id != 'intel-cl' )
      if (  ___jln_flags.get('debug', 'default') != 'default' )
        if (  ___jln_flags.get('debug', 'default') == 'off' )
          jln_cpp_flags += ['/DEBUG:NONE', ]
        else
          jln_cpp_flags += ['/RTC1', '/Od', ]
          if (  ___jln_flags.get('debug', 'default') == 'on' )
            jln_cpp_flags += ['/DEBUG', ]
          else
            if (  ___jln_flags.get('debug', 'default') == 'line_tables_only' )
              if (  ___jln_compiler_id == 'clang-cl' )
                jln_cpp_flags += ['-gline-tables-only', ]
              endif
              jln_cpp_flags += ['/DEBUG:FASTLINK', ]
            endif
          endif
          if (  ___jln_flags.get('optimization', 'default') != 'default' )
            if (  ___jln_flags.get('optimization', 'default') == 'g' )
              jln_cpp_flags += ['/Zi', ]
            else
              if (  ___jln_flags.get('whole_program', 'default') != 'default' )
                if (  ___jln_flags.get('whole_program', 'default') == 'off' )
                  jln_cpp_flags += ['/ZI', ]
                else
                  jln_cpp_flags += ['/Zi', ]
                endif
              else
                jln_cpp_flags += ['/ZI', ]
              endif
            endif
          else
            if (  ___jln_flags.get('whole_program', 'default') != 'default' )
              if (  ___jln_flags.get('whole_program', 'default') == 'off' )
                jln_cpp_flags += ['/ZI', ]
              else
                jln_cpp_flags += ['/Zi', ]
              endif
            else
              jln_cpp_flags += ['/ZI', ]
            endif
          endif
        endif
      endif
      if (  ___jln_flags.get('optimization', 'default') != 'default' )
        if (  ___jln_flags.get('optimization', 'default') == '0' )
          jln_cpp_flags += ['/Ob0', '/Od', '/Oi-', '/Oy-', ]
        else
          if (  ___jln_flags.get('optimization', 'default') == 'g' )
            jln_cpp_flags += ['/Ob1', ]
          else
            if (  ___jln_flags.get('optimization', 'default') == '1' )
              jln_cpp_flags += ['/O1', ]
            else
              if (  ___jln_flags.get('optimization', 'default') == '2' )
                jln_cpp_flags += ['/O2', ]
              else
                if (  ___jln_flags.get('optimization', 'default') == '3' )
                  jln_cpp_flags += ['/O2', ]
                else
                  if (  ( ___jln_flags.get('optimization', 'default') == 'size' or ___jln_flags.get('optimization', 'default') == 'z' ) )
                    jln_cpp_flags += ['/O1', '/GL', '/Gw', ]
                  else
                    jln_cpp_flags += ['/O2', '/fp:fast', ]
                  endif
                endif
              endif
            endif
          endif
        endif
      endif
      if (  ___jln_flags.get('linker', 'default') != 'default' )
        if (  ___jln_compiler_id == 'clang-cl' )
          if (  ( ___jln_flags.get('linker', 'default') == 'lld' or ___jln_flags.get('linker', 'default') == 'native' ) )
            jln_link_flags += ['-fuse-ld=lld', ]
          endif
        endif
      endif
      if (  ___jln_flags.get('control_flow', 'default') != 'default' )
        if (  ___jln_flags.get('control_flow', 'default') == 'off' )
          jln_cpp_flags += ['/guard:cf-', ]
        else
          jln_cpp_flags += ['/guard:cf', ]
        endif
      endif
      if (  ___jln_flags.get('whole_program', 'default') != 'default' )
        if (  ___jln_flags.get('whole_program', 'default') == 'off' )
          jln_cpp_flags += ['/GL-', ]
        else
          jln_cpp_flags += ['/GL', '/Gw', ]
          jln_link_flags += ['/LTCG', ]
          if (  ___jln_flags.get('whole_program', 'default') == 'strip_all' )
            jln_link_flags += ['/OPT:REF', ]
          endif
        endif
      endif
      if (  ___jln_flags.get('pedantic', 'default') != 'default' )
        if (  ___jln_flags.get('pedantic', 'default') != 'off' )
          jln_cpp_flags += ['/permissive-', '/Zc:__cplusplus', ]
        endif
      endif
      if (  ___jln_flags.get('stack_protector', 'default') != 'default' )
        if (  ___jln_flags.get('stack_protector', 'default') == 'off' )
          jln_cpp_flags += ['/GS-', ]
        else
          jln_cpp_flags += ['/GS', '/sdl', ]
          if (  ___jln_flags.get('stack_protector', 'default') == 'strong' )
            jln_cpp_flags += ['/RTC1', ]
            if (  ( ___jln_compiler_id == 'msvc' and ___jln_compiler_version.version_compare('>=16.7') ) )
              jln_cpp_flags += ['/guard:ehcont', ]
              jln_link_flags += ['/CETCOMPAT', ]
            endif
          else
            if (  ___jln_flags.get('stack_protector', 'default') == 'all' )
              jln_cpp_flags += ['/RTC1', '/RTCc', ]
            endif
          endif
        endif
      endif
    endif
  endif
  if (  ___jln_compiler_id == 'msvc' )
    if (  ___jln_flags.get('windows_bigobj', 'default') != 'default' )
      jln_cpp_flags += ['/bigobj', ]
    endif
    if (  ___jln_flags.get('msvc_conformance', 'default') != 'default' )
      if (  ( ___jln_flags.get('msvc_conformance', 'default') == 'all' or ___jln_flags.get('msvc_conformance', 'default') == 'all_without_throwing_new' ) )
        jln_cpp_flags += ['/Zc:inline', '/Zc:referenceBinding', ]
        if (  ___jln_flags.get('msvc_conformance', 'default') == 'all' )
          jln_cpp_flags += ['/Zc:throwingNew', ]
        endif
        if (  ___jln_compiler_version.version_compare('>=15.6') )
          jln_cpp_flags += ['/Zc:externConstexpr', ]
          if (  ___jln_compiler_version.version_compare('>=16.5') )
            jln_cpp_flags += ['/Zc:preprocessor', ]
            if (  ___jln_compiler_version.version_compare('>=16.8') )
              jln_cpp_flags += ['/Zc:lambda', ]
              if (  ___jln_compiler_version.version_compare('>=17.4') )
                jln_cpp_flags += ['/Zc:enumTypes', ]
                if (  ___jln_compiler_version.version_compare('>=17.5') )
                  jln_cpp_flags += ['/Zc:templateScope', ]
                endif
              endif
            endif
          endif
        endif
      endif
    endif
    if (  ___jln_flags.get('msvc_crt_secure_no_warnings', 'default') != 'default' )
      if (  ___jln_flags.get('msvc_crt_secure_no_warnings', 'default') == 'on' )
        jln_cpp_flags += ['/D_CRT_SECURE_NO_WARNINGS=1', ]
      else
        if (  ___jln_flags.get('msvc_crt_secure_no_warnings', 'default') == 'off' )
          jln_cpp_flags += ['/U_CRT_SECURE_NO_WARNINGS', ]
        endif
      endif
    endif
    if (  ___jln_flags.get('msvc_diagnostics_format', 'default') != 'default' )
      if (  ___jln_compiler_version.version_compare('>=17.0') )
        if (  ___jln_flags.get('msvc_diagnostics_format', 'default') == 'classic' )
          jln_cpp_flags += ['/diagnostics:classic', ]
        else
          if (  ___jln_flags.get('msvc_diagnostics_format', 'default') == 'column' )
            jln_cpp_flags += ['/diagnostics:column', ]
          else
            jln_cpp_flags += ['/diagnostics:caret', ]
          endif
        endif
      endif
    endif
    if (  ___jln_compiler_version.version_compare('<15.16') )
      ___jln_flags += {'msvc_isystem': 'default'}
    endif
    if (  ___jln_flags.get('msvc_isystem', 'default') != 'default' )
      if (  ___jln_flags.get('msvc_isystem', 'default') == 'external_as_include_system_flag' )
        if (  ___jln_compiler_version.version_compare('<16.10') )
          # unimplementable
        else
          # unimplementable
        endif
      else
        if (  ___jln_compiler_version.version_compare('<16.10') )
          jln_cpp_flags += ['/experimental:external', ]
        endif
        jln_cpp_flags += ['/external:W0', ]
        if (  ___jln_flags.get('msvc_isystem', 'default') == 'anglebrackets' )
          jln_cpp_flags += ['/external:anglebrackets', ]
        else
          jln_cpp_flags += ['/external:env:INCLUDE', '/external:env:CAExcludePath', ]
        endif
      endif
      if (  ___jln_flags.get('msvc_isystem_with_template_from_non_external', 'default') != 'default' )
        if (  ___jln_flags.get('msvc_isystem_with_template_from_non_external', 'default') == 'off' )
          jln_cpp_flags += ['/external:template', ]
        else
          jln_cpp_flags += ['/external:template-', ]
        endif
      endif
      if (  ___jln_flags.get('warnings', 'default') != 'default' )
        if (  ___jln_flags.get('warnings', 'default') == 'off' )
          jln_cpp_flags += ['/W0', ]
        else
          jln_cpp_flags += ['/wd4710', '/wd4711', ]
          if (  ___jln_compiler_version.version_compare('<19.21') )
            jln_cpp_flags += ['/wd4774', ]
          endif
          if (  ___jln_flags.get('warnings', 'default') == 'on' )
            jln_cpp_flags += ['/W4', '/wd4514', ]
          else
            jln_cpp_flags += ['/Wall', '/wd4514', '/wd4571', '/wd4355', '/wd4548', '/wd4577', '/wd4820', '/wd5039', '/wd4464', '/wd4868', '/wd5045', ]
            if (  ___jln_flags.get('warnings', 'default') == 'strict' )
              jln_cpp_flags += ['/wd4583', '/wd4619', ]
            endif
          endif
        endif
      endif
      if (  ___jln_flags.get('switch_warnings', 'default') != 'default' )
        if (  ( ___jln_flags.get('switch_warnings', 'default') == 'on' or ___jln_flags.get('switch_warnings', 'default') == 'mandatory_default' ) )
          jln_cpp_flags += ['/w14062', ]
        else
          if (  ( ___jln_flags.get('switch_warnings', 'default') == 'exhaustive_enum' or ___jln_flags.get('switch_warnings', 'default') == 'exhaustive_enum_and_mandatory_default' ) )
            jln_cpp_flags += ['/w14061', '/w14062', ]
          else
            jln_cpp_flags += ['/wd4061', '/wd4062', ]
          endif
        endif
      endif
    else
      if (  ___jln_flags.get('warnings', 'default') != 'default' )
        if (  ___jln_flags.get('warnings', 'default') == 'off' )
          jln_cpp_flags += ['/W0', ]
        else
          if (  ___jln_flags.get('warnings', 'default') == 'on' )
            jln_cpp_flags += ['/W4', '/wd4514', '/wd4711', ]
          else
            jln_cpp_flags += ['/Wall', '/wd4355', '/wd4514', '/wd4548', '/wd4571', '/wd4577', '/wd4625', '/wd4626', '/wd4668', '/wd4710', '/wd4711', ]
            if (  ___jln_compiler_version.version_compare('<19.21') )
              jln_cpp_flags += ['/wd4774', ]
            endif
            jln_cpp_flags += ['/wd4820', '/wd5026', '/wd5027', '/wd5039', '/wd4464', '/wd4868', '/wd5045', ]
            if (  ___jln_flags.get('warnings', 'default') == 'strict' )
              jln_cpp_flags += ['/wd4061', '/wd4266', '/wd4583', '/wd4619', '/wd4623', '/wd5204', ]
            endif
          endif
        endif
      endif
    endif
    if (  ___jln_flags.get('conversion_warnings', 'default') != 'default' )
      if (  ___jln_flags.get('conversion_warnings', 'default') == 'on' )
        jln_cpp_flags += ['/w14244', '/w14245', '/w14388', '/w14365', ]
      else
        if (  ___jln_flags.get('conversion_warnings', 'default') == 'conversion' )
          jln_cpp_flags += ['/w14244', '/w14365', ]
        else
          if (  ___jln_flags.get('conversion_warnings', 'default') == 'sign' )
            jln_cpp_flags += ['/w14388', '/w14245', ]
          else
            jln_cpp_flags += ['/wd4244', '/wd4365', '/wd4388', '/wd4245', ]
          endif
        endif
      endif
    endif
    if (  ___jln_flags.get('shadow_warnings', 'default') != 'default' )
      if (  ___jln_flags.get('shadow_warnings', 'default') == 'off' )
        jln_cpp_flags += ['/wd4456', '/wd4459', ]
      else
        if (  ( ___jln_flags.get('shadow_warnings', 'default') == 'on' or ___jln_flags.get('shadow_warnings', 'default') == 'all' ) )
          jln_cpp_flags += ['/w4456', '/w4459', ]
        else
          if (  ___jln_flags.get('shadow_warnings', 'default') == 'local' )
            jln_cpp_flags += ['/w4456', '/wd4459', ]
          endif
        endif
      endif
    endif
    if (  ___jln_flags.get('warnings_as_error', 'default') != 'default' )
      if (  ___jln_flags.get('warnings_as_error', 'default') == 'on' )
        jln_cpp_flags += ['/WX', ]
      else
        if (  ___jln_flags.get('warnings_as_error', 'default') == 'off' )
          jln_cpp_flags += ['/WX-', ]
        else
          jln_cpp_flags += ['/we4455', '/we4150', '/we4716', '/we2124', ]
        endif
      endif
    endif
    if (  ___jln_flags.get('lto', 'default') != 'default' )
      if (  ___jln_flags.get('lto', 'default') == 'off' )
        jln_cpp_flags += ['/LTCG:OFF', ]
      else
        jln_cpp_flags += ['/GL', ]
        jln_link_flags += ['/LTCG', ]
      endif
    endif
    if (  ___jln_flags.get('sanitizers', 'default') != 'default' )
      if (  ___jln_compiler_version.version_compare('>=16.9') )
        jln_cpp_flags += ['/fsanitize=address', '/fsanitize-address-use-after-return', ]
      else
        if (  ___jln_flags.get('sanitizers', 'default') == 'on' )
          jln_cpp_flags += ['/sdl', ]
        else
          if (  ___jln_flags.get('stack_protector', 'default') != 'default' )
            if (  ___jln_flags.get('stack_protector', 'default') != 'off' )
              jln_cpp_flags += ['/sdl-', ]
            endif
          endif
        endif
      endif
    endif
  endif
  if (  ___jln_compiler_id == 'intel-cl' )
    if (  ___jln_flags.get('warnings', 'default') != 'default' )
      if (  ___jln_flags.get('warnings', 'default') == 'off' )
        jln_cpp_flags += ['/w', ]
      else
        jln_cpp_flags += ['/W2', '/Qdiag-disable:1418,2259', ]
      endif
    endif
    if (  ___jln_flags.get('warnings_as_error', 'default') != 'default' )
      if (  ___jln_flags.get('warnings_as_error', 'default') == 'on' )
        jln_cpp_flags += ['/WX', ]
      else
        if (  ___jln_flags.get('warnings_as_error', 'default') == 'basic' )
          jln_cpp_flags += ['/Qdiag-error:1079,39,109', ]
        endif
      endif
    endif
    if (  ___jln_flags.get('windows_bigobj', 'default') != 'default' )
      jln_cpp_flags += ['/bigobj', ]
    endif
    if (  ___jln_flags.get('msvc_conformance', 'default') != 'default' )
      if (  ( ___jln_flags.get('msvc_conformance', 'default') == 'all' or ___jln_flags.get('msvc_conformance', 'default') == 'all_without_throwing_new' ) )
        jln_cpp_flags += ['/Zc:inline', '/Zc:strictStrings', ]
        if (  ___jln_flags.get('msvc_conformance', 'default') == 'all' )
          jln_cpp_flags += ['/Zc:throwingNew', ]
        endif
      endif
    endif
    if (  ___jln_flags.get('debug', 'default') != 'default' )
      if (  ___jln_flags.get('debug', 'default') == 'off' )
        jln_cpp_flags += ['/debug:NONE', ]
      else
        jln_cpp_flags += ['/RTC1', '/Od', ]
        if (  ___jln_flags.get('debug', 'default') == 'on' )
          jln_cpp_flags += ['/debug:full', ]
        else
          if (  ___jln_flags.get('debug', 'default') == 'line_tables_only' )
            jln_cpp_flags += ['/debug:minimal', ]
          endif
        endif
        if (  ( ___jln_flags.get('optimization', 'default') == 'g' ) )
          jln_cpp_flags += ['/Zi', ]
        else
          if (  ___jln_flags.get('whole_program', 'default') != 'default' )
            if (  ___jln_flags.get('whole_program', 'default') == 'off' )
              jln_cpp_flags += ['/ZI', ]
            else
              jln_cpp_flags += ['/Zi', ]
            endif
          else
            jln_cpp_flags += ['/ZI', ]
          endif
        endif
      endif
    endif
    if (  ___jln_flags.get('optimization', 'default') != 'default' )
      if (  ___jln_flags.get('optimization', 'default') == '0' )
        jln_cpp_flags += ['/Ob0', '/Od', '/Oi-', '/Oy-', ]
      else
        if (  ___jln_flags.get('optimization', 'default') == 'g' )
          jln_cpp_flags += ['/Ob1', ]
        else
          jln_cpp_flags += ['/GF', ]
          if (  ___jln_flags.get('optimization', 'default') == '1' )
            jln_cpp_flags += ['/O1', ]
          else
            if (  ___jln_flags.get('optimization', 'default') == '2' )
              jln_cpp_flags += ['/O2', ]
            else
              if (  ___jln_flags.get('optimization', 'default') == '3' )
                jln_cpp_flags += ['/O2', ]
              else
                if (  ___jln_flags.get('optimization', 'default') == 'z' )
                  jln_cpp_flags += ['/O3', ]
                else
                  if (  ___jln_flags.get('optimization', 'default') == 'size' )
                    jln_cpp_flags += ['/Os', ]
                  else
                    jln_cpp_flags += ['/fast', ]
                  endif
                endif
              endif
            endif
          endif
        endif
      endif
    endif
    if (  ___jln_flags.get('stack_protector', 'default') != 'default' )
      if (  ___jln_flags.get('stack_protector', 'default') == 'off' )
        jln_cpp_flags += ['/GS-', ]
      else
        jln_cpp_flags += ['/GS', ]
        if (  ___jln_flags.get('stack_protector', 'default') == 'strong' )
          jln_cpp_flags += ['/RTC1', ]
        else
          if (  ___jln_flags.get('stack_protector', 'default') == 'all' )
            jln_cpp_flags += ['/RTC1', '/RTCc', ]
          endif
        endif
      endif
    endif
    if (  ___jln_flags.get('sanitizers', 'default') != 'default' )
      if (  ___jln_flags.get('sanitizers', 'default') == 'on' )
        jln_cpp_flags += ['/Qtrapuv', ]
      endif
    endif
    if (  ___jln_flags.get('float_sanitizers', 'default') != 'default' )
      if (  ___jln_flags.get('float_sanitizers', 'default') == 'on' )
        jln_cpp_flags += ['/Qfp-stack-check', '/Qfp-trap:common', ]
      endif
    endif
    if (  ___jln_flags.get('control_flow', 'default') != 'default' )
      if (  ___jln_flags.get('control_flow', 'default') == 'off' )
        jln_cpp_flags += ['/guard:cf-', '/mconditional-branch=keep', ]
      else
        jln_cpp_flags += ['/guard:cf', ]
        if (  ___jln_flags.get('control_flow', 'default') == 'branch' )
          jln_cpp_flags += ['/mconditional-branch:all-fix', '/Qcf-protection:branch', ]
        else
          if (  ___jln_flags.get('control_flow', 'default') == 'on' )
            jln_cpp_flags += ['/mconditional-branch:all-fix', '/Qcf-protection:full', ]
          endif
        endif
      endif
    endif
    if (  ___jln_flags.get('cpu', 'default') != 'default' )
      if (  ___jln_flags.get('cpu', 'default') == 'generic' )
        jln_cpp_flags += ['/Qtune:generic', ]
        jln_link_flags += ['/Qtune:generic', ]
      else
        jln_cpp_flags += ['/QxHost', ]
        jln_link_flags += ['/QxHost', ]
      endif
    endif
  else
    if (  ___jln_compiler_id == 'intel' )
      if (  ___jln_flags.get('warnings', 'default') != 'default' )
        if (  ___jln_flags.get('warnings', 'default') == 'off' )
          jln_cpp_flags += ['-w', ]
        else
          jln_cpp_flags += ['-Wall', '-Warray-bounds', '-Wcast-qual', '-Wchar-subscripts', '-Wdisabled-optimization', '-Wenum-compare', '-Wextra', '-Wfloat-equal', '-Wformat-security', '-Wformat=2', '-Winit-self', '-Winvalid-pch', '-Wmaybe-uninitialized', '-Wmissing-include-dirs', '-Wnarrowing', '-Wnonnull', '-Wparentheses', '-Wpointer-sign', '-Wreorder', '-Wsequence-point', '-Wtrigraphs', '-Wundef', '-Wunused-function', '-Wunused-but-set-variable', '-Wunused-variable', '-Wpointer-arith', '-Wdeprecated', '-Wnon-virtual-dtor', '-Woverloaded-virtual', ]
        endif
      endif
      if (  ___jln_flags.get('switch_warnings', 'default') != 'default' )
        if (  ( ___jln_flags.get('switch_warnings', 'default') == 'on' or ___jln_flags.get('switch_warnings', 'default') == 'exhaustive_enum' ) )
          jln_cpp_flags += ['-Wswitch-enum', ]
        else
          if (  ___jln_flags.get('switch_warnings', 'default') == 'mandatory_default' )
            jln_cpp_flags += ['-Wswitch-default', ]
          else
            if (  ___jln_flags.get('switch_warnings', 'default') == 'exhaustive_enum_and_mandatory_default' )
              jln_cpp_flags += ['-Wswitch', ]
            else
              jln_cpp_flags += ['-Wno-switch', ]
            endif
          endif
        endif
      endif
      if (  ___jln_flags.get('warnings_as_error', 'default') != 'default' )
        if (  ___jln_flags.get('warnings_as_error', 'default') == 'on' )
          jln_cpp_flags += ['-Werror', ]
        else
          if (  ___jln_flags.get('warnings_as_error', 'default') == 'basic' )
            jln_cpp_flags += ['-diag-error=1079,39,109', ]
          endif
        endif
      endif
      if (  ___jln_flags.get('pedantic', 'default') != 'default' )
        if (  ___jln_flags.get('pedantic', 'default') == 'off' )
          jln_cpp_flags += ['-fgnu-keywords', ]
        else
          jln_cpp_flags += ['-fno-gnu-keywords', ]
        endif
      endif
      if (  ___jln_flags.get('shadow_warnings', 'default') != 'default' )
        if (  ___jln_flags.get('shadow_warnings', 'default') == 'off' )
          jln_cpp_flags += ['-Wno-shadow', ]
        else
          if (  ( ___jln_flags.get('shadow_warnings', 'default') == 'on' or ___jln_flags.get('shadow_warnings', 'default') == 'all' ) )
            jln_cpp_flags += ['-Wshadow', ]
          endif
        endif
      endif
      if (  ___jln_flags.get('stl_debug', 'default') != 'default' )
        if (  ___jln_flags.get('stl_debug', 'default') != 'off' )
          if (  ( ___jln_flags.get('stl_debug', 'default') == 'allow_broken_abi' or ___jln_flags.get('stl_debug', 'default') == 'allow_broken_abi_and_bugs' ) )
            jln_cpp_flags += ['-D_GLIBCXX_DEBUG', ]
          else
            jln_cpp_flags += ['-D_GLIBCXX_ASSERTIONS', ]
          endif
        endif
      endif
      if (  ___jln_flags.get('debug', 'default') != 'default' )
        if (  ___jln_flags.get('debug', 'default') == 'off' )
          jln_cpp_flags += ['-g0', ]
        else
          jln_cpp_flags += ['-g', ]
        endif
      endif
      if (  ___jln_flags.get('optimization', 'default') != 'default' )
        if (  ___jln_flags.get('optimization', 'default') == '0' )
          jln_cpp_flags += ['-O0', ]
        else
          if (  ___jln_flags.get('optimization', 'default') == 'g' )
            jln_cpp_flags += ['-O1', ]
          else
            if (  ___jln_flags.get('optimization', 'default') == '1' )
              jln_cpp_flags += ['-O1', ]
            else
              if (  ___jln_flags.get('optimization', 'default') == '2' )
                jln_cpp_flags += ['-O2', ]
              else
                if (  ___jln_flags.get('optimization', 'default') == '3' )
                  jln_cpp_flags += ['-O3', ]
                else
                  if (  ___jln_flags.get('optimization', 'default') == 'z' )
                    jln_cpp_flags += ['-fast', ]
                  else
                    if (  ___jln_flags.get('optimization', 'default') == 'size' )
                      jln_cpp_flags += ['-Os', ]
                    else
                      jln_cpp_flags += ['-Ofast', ]
                    endif
                  endif
                endif
              endif
            endif
          endif
        endif
      endif
      if (  ___jln_flags.get('stack_protector', 'default') != 'default' )
        if (  ___jln_flags.get('stack_protector', 'default') == 'off' )
          jln_cpp_flags += ['-fno-protector-strong', '-U_FORTIFY_SOURCE', ]
          jln_link_flags += ['-fno-protector-strong', ]
        else
          jln_cpp_flags += ['-D_FORTIFY_SOURCE=2', ]
          if (  ___jln_flags.get('stack_protector', 'default') == 'strong' )
            jln_cpp_flags += ['-fstack-protector-strong', ]
            jln_link_flags += ['-fstack-protector-strong', ]
          else
            if (  ___jln_flags.get('stack_protector', 'default') == 'all' )
              jln_cpp_flags += ['-fstack-protector-all', ]
              jln_link_flags += ['-fstack-protector-all', ]
            else
              jln_cpp_flags += ['-fstack-protector', ]
              jln_link_flags += ['-fstack-protector', ]
            endif
          endif
        endif
      endif
      if (  ___jln_flags.get('relro', 'default') != 'default' )
        if (  ___jln_flags.get('relro', 'default') == 'off' )
          jln_link_flags += ['-Xlinker-znorelro', ]
        else
          if (  ___jln_flags.get('relro', 'default') == 'on' )
            jln_link_flags += ['-Xlinker-zrelro', ]
          else
            jln_link_flags += ['-Xlinker-zrelro', '-Xlinker-znow', '-Xlinker-znoexecstack', ]
          endif
        endif
      endif
      if (  ___jln_flags.get('pie', 'default') != 'default' )
        if (  ___jln_flags.get('pie', 'default') == 'off' )
          jln_link_flags += ['-no-pic', ]
        else
          if (  ___jln_flags.get('pie', 'default') == 'on' )
            jln_link_flags += ['-pie', ]
          else
            if (  ___jln_flags.get('pie', 'default') == 'fpie' )
              jln_cpp_flags += ['-fpie', ]
            else
              if (  ___jln_flags.get('pie', 'default') == 'fpic' )
                jln_cpp_flags += ['-fpic', ]
              else
                if (  ___jln_flags.get('pie', 'default') == 'fPIE' )
                  jln_cpp_flags += ['-fPIE', ]
                else
                  if (  ___jln_flags.get('pie', 'default') == 'fPIC' )
                    jln_cpp_flags += ['-fPIC', ]
                  endif
                endif
              endif
            endif
          endif
        endif
      endif
      if (  ___jln_flags.get('sanitizers', 'default') != 'default' )
        if (  ___jln_flags.get('sanitizers', 'default') == 'on' )
          jln_cpp_flags += ['-ftrapuv', ]
        endif
      endif
      if (  ___jln_flags.get('integer_sanitizers', 'default') != 'default' )
        if (  ___jln_flags.get('integer_sanitizers', 'default') == 'on' )
          jln_cpp_flags += ['-funsigned-bitfields', ]
        else
          jln_cpp_flags += ['-fno-unsigned-bitfields', ]
        endif
      endif
      if (  ___jln_flags.get('float_sanitizers', 'default') != 'default' )
        if (  ___jln_flags.get('float_sanitizers', 'default') == 'on' )
          jln_cpp_flags += ['-fp-stack-check', '-fp-trap=common', ]
        endif
      endif
      if (  ___jln_flags.get('linker', 'default') != 'default' )
        if (  ___jln_flags.get('linker', 'default') == 'bfd' )
          jln_link_flags += ['-fuse-ld=bfd', ]
        else
          if (  ___jln_flags.get('linker', 'default') == 'gold' )
            jln_link_flags += ['-fuse-ld=gold', ]
          else
            jln_link_flags += ['-fuse-ld=lld', ]
          endif
        endif
      endif
      if (  ___jln_flags.get('lto', 'default') != 'default' )
        if (  ___jln_flags.get('lto', 'default') == 'off' )
          jln_cpp_flags += ['-no-ipo', ]
          jln_link_flags += ['-no-ipo', ]
        else
          jln_cpp_flags += ['-ipo', ]
          jln_link_flags += ['-ipo', ]
          if (  ___jln_flags.get('lto', 'default') == 'fat' )
            if (  host_machine.system() == 'linux' )
              jln_cpp_flags += ['-ffat-lto-objects', ]
              jln_link_flags += ['-ffat-lto-objects', ]
            endif
          endif
        endif
      endif
      if (  ___jln_flags.get('control_flow', 'default') != 'default' )
        if (  ___jln_flags.get('control_flow', 'default') == 'off' )
          jln_cpp_flags += ['-mconditional-branch=keep', '-fcf-protection=none', ]
        else
          if (  ___jln_flags.get('control_flow', 'default') == 'branch' )
            jln_cpp_flags += ['-mconditional-branch=all-fix', '-fcf-protection=branch', ]
          else
            if (  ___jln_flags.get('control_flow', 'default') == 'on' )
              jln_cpp_flags += ['-mconditional-branch=all-fix', '-fcf-protection=full', ]
            endif
          endif
        endif
      endif
      if (  ___jln_flags.get('exceptions', 'default') != 'default' )
        if (  ___jln_flags.get('exceptions', 'default') == 'on' )
          jln_cpp_flags += ['-fexceptions', ]
        else
          jln_cpp_flags += ['-fno-exceptions', ]
        endif
      endif
      if (  ___jln_flags.get('rtti', 'default') != 'default' )
        if (  ___jln_flags.get('rtti', 'default') == 'on' )
          jln_cpp_flags += ['-frtti', ]
        else
          jln_cpp_flags += ['-fno-rtti', ]
        endif
      endif
      if (  ___jln_flags.get('cpu', 'default') != 'default' )
        if (  ___jln_flags.get('cpu', 'default') == 'generic' )
          jln_cpp_flags += ['-mtune=generic', ]
          jln_link_flags += ['-mtune=generic', ]
        else
          jln_cpp_flags += ['-xHost', ]
          jln_link_flags += ['-xHost', ]
        endif
      endif
    endif
  endif
  if (  (host_machine.system() == 'windows' and ___jln_compiler_id == 'gcc') )
    if (  ___jln_flags.get('windows_bigobj', 'default') != 'default' )
      jln_cpp_flags += ['-Wa,-mbig-obj', ]
    endif
  endif

  jln_custom_cpp_flags += [jln_cpp_flags]
  jln_custom_link_flags += [jln_link_flags]
endforeach
