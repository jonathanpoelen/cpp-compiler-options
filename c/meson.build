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
#  Supported options are listed below by category.
#  The same option can be found in several categories.
#
#  For a full description of options and values,
#  see [C++ Compiler Options reference](https://jonathanpoelen.github.io/cpp-compiler-options/)
#  or use the `list_options.lua` generator.
#
#  The first value corresponds to the one used by default,
#  and the value `default` has no associated behavior.
#
#  Options with a default value other than `default` are listed below.
#
#  <!-- ./compiler-options.lua generators/list_options.lua --color --categorized -->
#  ```ini
#  # Warning options:
#
#  warnings = on default off essential extensive
#  warnings_as_error = default off on basic
#  bidi_char_warnings = any default any_and_ucn unpaired unpaired_and_ucn
#  conversion_warnings = on default off sign float conversion all
#  covered_switch_default_warnings = on default off
#  msvc_crt_secure_no_warnings = on default off
#  noexcept_warnings = default off on
#  reproducible_build_warnings = default off on
#  shadow_warnings = off default on local compatible_local all
#  suggest_attributes = on default off common analysis unity all
#  switch_warnings = on default off exhaustive_enum mandatory_default exhaustive_enum_and_mandatory_default
#  unsafe_buffer_usage_warnings = default on off
#  windows_abi_compatibility_warnings = off default on
#
#
#  # Pedantic options:
#
#  pedantic = on default off as_error
#  stl_fix = on default off
#
#
#  # Debug options:
#
#  symbols = default hidden strip_all gc_sections nodebug debug minimal_debug full_debug btf codeview ctf ctf1 ctf2 vms vms1 vms2 vms3 dbx lldb sce dwarf
#  stl_hardening = default off fast extensive debug debug_with_broken_abi
#  sanitizers = default off on with_minimal_code_size extra extra_with_minimal_code_size address address_with_minimal_code_size thread undefined undefined_minimal_runtime scudo_hardened_allocator
#  var_init = default uninitialized pattern zero
#  emcc_debug = default off on slow
#  ndebug = with_optimization_1_or_above default off on
#  optimization = default 0 g 1 2 3 fast size z
#
#
#  # Optimization options:
#
#  cpu = default generic native
#  lto = default off on full thin_or_nothing whole_program whole_program_and_full_lto
#  optimization = default 0 g 1 2 3 fast size z
#  optimization_warnings = default off on
#
#
#  # C++ options:
#
#  exceptions = default off on
#  rtti = default off on
#
#
#  # Hardening options:
#
#  hardened = default off on all
#  stl_hardening = default off fast extensive debug debug_with_broken_abi
#
#
#  # Static Analyzer options:
#
#  analyzer = default off on with_external_headers
#  analyzer_too_complex_warning = default off on
#  analyzer_verbosity = default 0 1 2 3
#
#
#  # Other options:
#
#  color = default auto never always
#  coverage = default off on
#  diagnostics_format = default fixits patch print_source_range_info
#  diagnostics_show_template = default tree without_elided_types tree_without_elided_types
#  linker = default bfd gold lld mold native
#  msvc_diagnostics_format = caret default classic column
#  msvc_isystem = default anglebrackets include_and_caexcludepath external_as_include_system_flag assumed
#  msvc_isystem_with_template_instantiations_treated_as_non_external = default off on
#  windows_bigobj = on default
#  ```
#  <!-- ./compiler-options.lua -->
#
#  If not specified:
#
#  - `bidi_char_warnings` is `any`
#  - `msvc_diagnostics_format` is `caret`
#  - `ndebug` is `with_optimization_1_or_above`
#  - The following values are `off`:
#    - `shadow_warnings`
#    - `windows_abi_compatibility_warnings`
#  - The following values are `on`:
#    - `conversion_warnings`
#    - `covered_switch_default_warnings`
#    - `msvc_crt_secure_no_warnings`
#    - `pedantic`
#    - `stl_fix`
#    - `suggest_attributes`
#    - `switch_warnings`
#    - `warnings`
#    - `windows_bigobj`
#
#  <!-- enddefault -->
#
#  ## To know
#
#  - `msvc_isystem=external_as_include_system_flag` is only available with `cmake`.
#  - `stl_hardening=debug`
#    - msvc: unlike `stl_hardening=debug_with_broken_abi`, STL debugging is not enabled by this option, as it breaks the ABI (only hardening mode is enabled on recent versions). However, as the `_DEBUG` macro can be defined in many different ways, STL debugging can be activated and the ABI broken.
#
#
#  ## Sanitizers
#
#  Some sanitizers activated at compile time are only realistically active in the presence of a configuration in an environment variable.
#  `sanitizers=on` does not include these sanitizers, unlike `sanitizers=extra`.
#  The environment variables to use are as follows:
#
#  ```sh
#  # cl (Windows)
#  ASAN_OPTIONS=detect_stack_use_after_return=1
#
#  # gcc / clang (see -fsanitize=pointer-subtract and -fsanitize=pointer-compare)
#  ASAN_OPTIONS=detect_invalid_pointer_pairs=2
#
#  # macOS
#  ASAN_OPTIONS=detect_leaks=1
#  ```
#
#  See
#  [AddressSanitizer](https://github.com/google/sanitizers/wiki/AddressSanitizer),
#  [UndefinedBehaviorSanitizer](https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html),
#  [-fsanitize=pointer-compare](https://gcc.gnu.org/onlinedocs/gcc/Instrumentation-Options.html#index-fsanitize_003dpointer-compare) with GCC and
#  [-fsanitize-address-use-after-return](https://learn.microsoft.com/en-us/cpp/sanitizers/asan-building#fsanitize-address-use-after-return-compiler-option-experimental) with cl compiler
#  for more details.
#
#  See [AddressSanitizer Flags](https://github.com/google/sanitizers/wiki/AddressSanitizerFlags#run-time-flags)
#  for a list of supported options.
#  A useful pre-set to enable more aggressive diagnostics compared to the default behavior is given below:
#
#  ```sh
#  ASAN_OPTIONS=\
#  strict_string_checks=1:\
#  detect_stack_use_after_return=1:\
#  check_initialization_order=1:\
#  strict_init_order=1:\
#  alloc_dealloc_mismatch=1
#  ```
#
#  ## Recommended options
#
#  Some of the recommendations here are already made by build systems.
#  These include `ndebug`, `symbols` and `optimization`.
#
#  category | options
#  ---------|---------
#  debug | `emcc_debug=on` or `slow` (useless if Emscripten is not used)<br>`optimization=g` or `default`<br>`sanitizers=on` or `with_minimal_code_size`<br>`stl_hardening=debug_with_broken_abi` or `debug`<br>`symbols=debug` or `full_debug`<br>`var_init=pattern`
#  release | `cpu=native`<br>`lto=on`<br>`ndebug=on`<br>`optimization=3`<br>`rtti=off`<br>`symbols=strip_all`
#  security | `hardened=on`<br>`stl_hardening=fast` or `extensive`
#  really strict warnings | `pedantic=as_error`<br>`suggest_attributes=common`<br>`warnings=extensive`<br>`conversion_warnings=all`<br>`shadow_warnings=local`<br>`switch_warnings=exhaustive_enum`<br>`windows_abi_compatibility_warnings=on`
#
#  

# File generated with https://github.com/jonathanpoelen/cpp-compiler-options

if get_variable('jln_c_use_profile_buildtype', false)
  ___jln_options_by_modes = {
    'debug': {
      'emcc_debug': 'on',
      'sanitizers': 'on',
      'stl_hardening': 'debug',
      'symbols': 'debug',
    },
    'debugoptimized': {
      'optimization': 'g',
      'symbols': 'debug',
    },
    'minsize': {
      'lto': 'on',
      'optimization': 'size',
    },
    'release': {
      'lto': 'on',
      'optimization': '3',
    },
  }
else
  ___jln_options_by_modes = {}
endif

___jln_c_default_flags = get_variable('jln_c_default_flags', {}) + get_variable('jln_c_buildtype_flags', ___jln_options_by_modes).get(get_option('buildtype'), {})
if get_option('warning_level') == '0'
  ___jln_c_warnings = 'off'
else
  ___jln_c_warnings = ___jln_c_default_flags.get('warnings', get_option('jln_warnings'))
endif
___jln_c_flags = {
  'analyzer': ___jln_c_default_flags.get('analyzer', get_option('jln_analyzer')),
  'analyzer_too_complex_warning': ___jln_c_default_flags.get('analyzer_too_complex_warning', get_option('jln_analyzer_too_complex_warning')),
  'analyzer_verbosity': ___jln_c_default_flags.get('analyzer_verbosity', get_option('jln_analyzer_verbosity')),
  'bidi_char_warnings': ___jln_c_default_flags.get('bidi_char_warnings', get_option('jln_bidi_char_warnings')),
  'color': ___jln_c_default_flags.get('color', get_option('jln_color')),
  'conversion_warnings': ___jln_c_default_flags.get('conversion_warnings', get_option('jln_conversion_warnings')),
  'coverage': ___jln_c_default_flags.get('coverage', get_option('jln_coverage')),
  'covered_switch_default_warnings': ___jln_c_default_flags.get('covered_switch_default_warnings', get_option('jln_covered_switch_default_warnings')),
  'cpu': ___jln_c_default_flags.get('cpu', get_option('jln_cpu')),
  'diagnostics_format': ___jln_c_default_flags.get('diagnostics_format', get_option('jln_diagnostics_format')),
  'emcc_debug': ___jln_c_default_flags.get('emcc_debug', get_option('jln_emcc_debug')),
  'exceptions': ___jln_c_default_flags.get('exceptions', get_option('jln_exceptions')),
  'hardened': ___jln_c_default_flags.get('hardened', get_option('jln_hardened')),
  'linker': ___jln_c_default_flags.get('linker', get_option('jln_linker')),
  'lto': ___jln_c_default_flags.get('lto', get_option('jln_lto')),
  'msvc_crt_secure_no_warnings': ___jln_c_default_flags.get('msvc_crt_secure_no_warnings', get_option('jln_msvc_crt_secure_no_warnings')),
  'msvc_diagnostics_format': ___jln_c_default_flags.get('msvc_diagnostics_format', get_option('jln_msvc_diagnostics_format')),
  'msvc_isystem': ___jln_c_default_flags.get('msvc_isystem', get_option('jln_msvc_isystem')),
  'ndebug': ___jln_c_default_flags.get('ndebug', get_option('jln_ndebug')),
  'optimization': ___jln_c_default_flags.get('optimization', get_option('jln_optimization')),
  'pedantic': ___jln_c_default_flags.get('pedantic', get_option('jln_pedantic')),
  'reproducible_build_warnings': ___jln_c_default_flags.get('reproducible_build_warnings', get_option('jln_reproducible_build_warnings')),
  'sanitizers': ___jln_c_default_flags.get('sanitizers', get_option('jln_sanitizers')),
  'shadow_warnings': ___jln_c_default_flags.get('shadow_warnings', get_option('jln_shadow_warnings')),
  'stl_fix': ___jln_c_default_flags.get('stl_fix', get_option('jln_stl_fix')),
  'suggest_attributes': ___jln_c_default_flags.get('suggest_attributes', get_option('jln_suggest_attributes')),
  'switch_warnings': ___jln_c_default_flags.get('switch_warnings', get_option('jln_switch_warnings')),
  'symbols': ___jln_c_default_flags.get('symbols', get_option('jln_symbols')),
  'unsafe_buffer_usage_warnings': ___jln_c_default_flags.get('unsafe_buffer_usage_warnings', get_option('jln_unsafe_buffer_usage_warnings')),
  'var_init': ___jln_c_default_flags.get('var_init', get_option('jln_var_init')),
  'warnings': ___jln_c_warnings,
  'warnings_as_error': ___jln_c_default_flags.get('warnings_as_error', get_option('jln_warnings_as_error')),
  'windows_bigobj': ___jln_c_default_flags.get('windows_bigobj', get_option('jln_windows_bigobj')),
}

jln_c_custom_c_flags = []
jln_c_custom_link_flags = []

___jln_c_compiler = meson.get_compiler('c')
___jln_c_compiler_id = ___jln_c_compiler.get_id()
if ___jln_c_compiler_id == 'emscripten'
  ___jln_c_compiler_version = ___jln_c_compiler.get_define('__clang_major__.__clang_minor__').replace(' ', '')
  ___jln_c_is_clang_like = true
else
  ___jln_c_compiler_version = ___jln_c_compiler.version()
  ___jln_c_is_clang_like = ['clang', 'emscripten', 'icx', 'icx-cl'].contains(___jln_c_compiler_id)
endif
___jln_c_linker_id = ___jln_c_compiler.get_linker_id()

___jln_c_custom_flags = get_variable('jln_c_custom_flags', []) + [___jln_c_flags]

foreach ___jln_c_flags : ___jln_c_custom_flags
  jln_c_c_flags = []
  jln_c_link_flags = []


  if (  ___jln_c_flags.get('ndebug', 'default') != 'default' )
    if (  ( ___jln_c_compiler_id == 'msvc' or ___jln_c_compiler_id == 'intel-cl' ) )
      if (  ___jln_c_flags.get('ndebug', 'default') == 'off' )
        jln_c_c_flags += ['/UNDEBUG', ]
      else
        if (  ___jln_c_flags.get('ndebug', 'default') == 'on' )
          jln_c_c_flags += ['/DNDEBUG', ]
        else
          if (  ___jln_c_flags.get('optimization', 'default') != 'default' and not ( ___jln_c_flags.get('optimization', 'default') == '0' or ___jln_c_flags.get('optimization', 'default') == 'g' ) )
            jln_c_c_flags += ['/DNDEBUG', ]
          endif
        endif
      endif
    else
      if (  ___jln_c_flags.get('ndebug', 'default') == 'off' )
        jln_c_c_flags += ['-UNDEBUG', ]
      else
        if (  ___jln_c_flags.get('ndebug', 'default') == 'on' )
          jln_c_c_flags += ['-DNDEBUG', ]
        else
          if (  ___jln_c_flags.get('optimization', 'default') != 'default' and not ( ___jln_c_flags.get('optimization', 'default') == '0' or ___jln_c_flags.get('optimization', 'default') == 'g' ) )
            jln_c_c_flags += ['-DNDEBUG', ]
          endif
        endif
      endif
    endif
  endif
  if (  ( ___jln_c_compiler_id == 'gcc' or ___jln_c_is_clang_like or ___jln_c_compiler_id == 'clang-cl' ) )
    if (  ___jln_c_flags.get('warnings', 'default') != 'default' )
      if (  ___jln_c_flags.get('warnings', 'default') == 'off' )
        jln_c_c_flags += ['-w', ]
      else
        if (  ___jln_c_flags.get('warnings', 'default') == 'essential' )
          jln_c_c_flags += ['-Wall', '-Wextra', '-Wwrite-strings', ]
        else
          if (  ___jln_c_compiler_id == 'gcc' )
            jln_c_c_flags += ['-Wall', '-Wextra', ]
            if (  ___jln_c_compiler_version.version_compare('<8.0') )
              jln_c_c_flags += ['-Wcast-align', ]
            endif
            jln_c_c_flags += ['-Wcast-qual', '-Wdisabled-optimization', '-Wfloat-equal', '-Wformat-security', '-Wformat=2', '-Winvalid-pch', '-Wmissing-declarations', '-Wmissing-include-dirs', '-Wpacked', '-Wredundant-decls', '-Wundef', '-Wunused-macros', '-Wpointer-arith', '-Wbad-function-cast', '-Winit-self', '-Wjump-misses-init', '-Wnested-externs', '-Wold-style-definition', '-Wstrict-prototypes', '-Wwrite-strings', ]
            if (  ___jln_c_compiler_version.version_compare('>=4.7') )
              jln_c_c_flags += ['-Wsuggest-attribute=noreturn', '-Wlogical-op', '-Wvector-operation-performance', '-Wdouble-promotion', '-Wtrampolines', ]
              if (  ___jln_c_compiler_version.version_compare('>=4.8') )
                if (  ___jln_c_compiler_version.version_compare('>=4.9') )
                  if (  ___jln_c_compiler_version.version_compare('>=5.1') )
                    jln_c_c_flags += ['-Wformat-signedness', '-Warray-bounds=2', ]
                    if (  ___jln_c_compiler_version.version_compare('>=6.1') )
                      jln_c_c_flags += ['-Wduplicated-cond', '-Wnull-dereference', ]
                      if (  ___jln_c_compiler_version.version_compare('>=7.0') )
                        if (  ___jln_c_compiler_version.version_compare('>=7.1') )
                          jln_c_c_flags += ['-Walloc-zero', '-Walloca', '-Wformat-overflow=2', '-Wduplicated-branches', ]
                          if (  ___jln_c_compiler_version.version_compare('>=8.0') )
                            jln_c_c_flags += ['-Wcast-align=strict', '-Wformat-truncation=2', '-Wshift-overflow=2', ]
                            if (  ___jln_c_compiler_version.version_compare('>=14.0') )
                              jln_c_c_flags += ['-Walloc-size', ]
                            endif
                          endif
                        endif
                      endif
                    endif
                  endif
                endif
              endif
            endif
            if (  ___jln_c_flags.get('warnings', 'default') == 'extensive' )
              if (  ___jln_c_compiler_version.version_compare('>=8.0') )
                jln_c_c_flags += ['-Wstringop-overflow=4', ]
                if (  ___jln_c_compiler_version.version_compare('>=12.0') )
                  jln_c_c_flags += ['-Wuse-after-free=3', ]
                endif
              endif
            endif
          else
            jln_c_c_flags += ['-Weverything', '-Wno-documentation', '-Wno-documentation-unknown-command', '-Wno-newline-eof', '-Wno-padded', '-Wno-global-constructors', ]
            if (   not ( ( ___jln_c_flags.get('switch_warnings', 'default') == 'off' or ___jln_c_flags.get('switch_warnings', 'default') == 'exhaustive_enum' or ___jln_c_flags.get('switch_warnings', 'default') == 'exhaustive_enum_and_mandatory_default' ) ) )
              jln_c_c_flags += ['-Wno-switch-enum', ]
            endif
            if (  ___jln_c_flags.get('covered_switch_default_warnings', 'default') == 'default' )
              jln_c_c_flags += ['-Wno-covered-switch-default', ]
            endif
            if (  ___jln_c_flags.get('suggest_attributes', 'default') == 'default' )
              jln_c_c_flags += ['-Wno-missing-noreturn', ]
            endif
            if (  ___jln_c_flags.get('conversion_warnings', 'default') != 'default' )
              if (  ___jln_c_flags.get('conversion_warnings', 'default') == 'conversion' )
                jln_c_c_flags += ['-Wno-sign-compare', '-Wno-sign-conversion', ]
              else
                if (  ( ___jln_c_flags.get('conversion_warnings', 'default') == 'float' or ___jln_c_flags.get('conversion_warnings', 'default') == 'sign' ) )
                  jln_c_c_flags += ['-Wno-conversion', ]
                endif
              endif
            endif
            if (  ___jln_c_compiler_version.version_compare('>=3.9') )
              if (  ___jln_c_compiler_version.version_compare('>=5.0') )
                if (  ___jln_c_compiler_version.version_compare('>=9.0') )
                  if (  ___jln_c_compiler_version.version_compare('>=10.0') )
                    if (  ___jln_c_compiler_version.version_compare('>=11.0') )
                      if (  ___jln_c_compiler_version.version_compare('>=16.0') )
                        if (  ___jln_c_flags.get('unsafe_buffer_usage_warnings', 'default') == 'default' )
                          jln_c_c_flags += ['-Wno-unsafe-buffer-usage', ]
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
    endif
    if (  ___jln_c_flags.get('bidi_char_warnings', 'default') != 'default' )
      if (  ( ___jln_c_compiler_id == 'gcc' and ___jln_c_compiler_version.version_compare('>=12.0') ) )
        if (  ___jln_c_flags.get('bidi_char_warnings', 'default') == 'any' )
          jln_c_c_flags += ['-Wbidi-chars=any', ]
        else
          if (  ___jln_c_flags.get('bidi_char_warnings', 'default') == 'any_and_ucn' )
            jln_c_c_flags += ['-Wbidi-chars=any,ucn', ]
          else
            if (  ___jln_c_flags.get('bidi_char_warnings', 'default') == 'unpaired' )
              jln_c_c_flags += ['-Wbidi-chars=unpaired', ]
            else
              jln_c_c_flags += ['-Wbidi-chars=unpaired,ucn', ]
            endif
          endif
        endif
      endif
    endif
    if (  ___jln_c_compiler_id == 'gcc' )
      if (  ___jln_c_flags.get('switch_warnings', 'default') != 'default' )
        if (  ___jln_c_flags.get('switch_warnings', 'default') == 'on' )
          jln_c_c_flags += ['-Wswitch', ]
        else
          if (  ___jln_c_flags.get('switch_warnings', 'default') == 'exhaustive_enum' )
            jln_c_c_flags += ['-Wswitch-enum', ]
          else
            if (  ___jln_c_flags.get('switch_warnings', 'default') == 'mandatory_default' )
              jln_c_c_flags += ['-Wswitch-default', ]
            else
              if (  ___jln_c_flags.get('switch_warnings', 'default') == 'exhaustive_enum_and_mandatory_default' )
                jln_c_c_flags += ['-Wswitch-default', '-Wswitch-enum', ]
              else
                jln_c_c_flags += ['-Wno-switch', '-Wno-switch-enum', '-Wno-switch-default', ]
              endif
            endif
          endif
        endif
      endif
    else
      if (  ___jln_c_flags.get('switch_warnings', 'default') != 'default' )
        if (  ___jln_c_flags.get('switch_warnings', 'default') == 'on' )
          jln_c_c_flags += ['-Wswitch', '-Wno-switch-default', ]
        else
          if (  ___jln_c_flags.get('switch_warnings', 'default') == 'mandatory_default' )
            jln_c_c_flags += ['-Wswitch', '-Wswitch-default', ]
          else
            if (  ___jln_c_flags.get('switch_warnings', 'default') == 'exhaustive_enum' )
              jln_c_c_flags += ['-Wswitch', '-Wswitch-enum', '-Wno-switch-default', ]
            else
              if (  ___jln_c_flags.get('switch_warnings', 'default') == 'exhaustive_enum_and_mandatory_default' )
                jln_c_c_flags += ['-Wswitch', '-Wswitch-enum', '-Wswitch-default', ]
              else
                jln_c_c_flags += ['-Wno-switch', '-Wno-switch-enum', '-Wno-switch-default', ]
              endif
            endif
          endif
        endif
      endif
      if (  ___jln_c_flags.get('covered_switch_default_warnings', 'default') != 'default' )
        if (  ___jln_c_flags.get('covered_switch_default_warnings', 'default') == 'off' )
          jln_c_c_flags += ['-Wno-covered-switch-default', ]
        else
          jln_c_c_flags += ['-Wcovered-switch-default', ]
        endif
      endif
    endif
    if (  ___jln_c_flags.get('unsafe_buffer_usage_warnings', 'default') != 'default' )
      if (  ( ( ___jln_c_is_clang_like and ___jln_c_compiler_version.version_compare('>=16.0') ) or ( ___jln_c_compiler_id == 'clang-cl' and ___jln_c_compiler_version.version_compare('>=16.0') ) ) )
        if (  ___jln_c_flags.get('unsafe_buffer_usage_warnings', 'default') == 'off' )
          jln_c_c_flags += ['-Wno-unsafe-buffer-usage', ]
        endif
      endif
    endif
    if (  ___jln_c_flags.get('shadow_warnings', 'default') != 'default' )
      if (  ___jln_c_flags.get('shadow_warnings', 'default') == 'off' )
        jln_c_c_flags += ['-Wno-shadow', ]
        if (  ( ( ___jln_c_is_clang_like and ___jln_c_compiler_version.version_compare('>=8.0') ) or ( ___jln_c_compiler_id == 'clang-cl' and ___jln_c_compiler_version.version_compare('>=8.0') ) ) )
          jln_c_c_flags += ['-Wno-shadow-field', ]
        endif
      else
        if (  ___jln_c_flags.get('shadow_warnings', 'default') == 'on' )
          jln_c_c_flags += ['-Wshadow', ]
        else
          if (  ___jln_c_flags.get('shadow_warnings', 'default') == 'all' )
            if (  ___jln_c_compiler_id == 'gcc' )
              jln_c_c_flags += ['-Wshadow', ]
            else
              jln_c_c_flags += ['-Wshadow-all', ]
            endif
          else
            if (  ( ___jln_c_compiler_id == 'gcc' and ___jln_c_compiler_version.version_compare('>=7.1') ) )
              if (  ___jln_c_flags.get('shadow_warnings', 'default') == 'local' )
                jln_c_c_flags += ['-Wshadow=local', ]
              else
                jln_c_c_flags += ['-Wshadow=compatible-local', ]
              endif
            endif
          endif
        endif
      endif
    endif
    if (  ___jln_c_flags.get('suggest_attributes', 'default') != 'default' )
      if (  ___jln_c_flags.get('suggest_attributes', 'default') == 'on' )
        jln_c_c_flags += ['-Wmissing-noreturn', ]
      else
        if (  ___jln_c_flags.get('suggest_attributes', 'default') == 'common' )
          jln_c_c_flags += ['-Wmissing-noreturn', '-Wmissing-format-attribute', ]
        else
          if (  ( ___jln_c_flags.get('suggest_attributes', 'default') == 'analysis' or ___jln_c_flags.get('suggest_attributes', 'default') == 'all' ) )
            jln_c_c_flags += ['-Wmissing-noreturn', '-Wmissing-format-attribute', ]
            if (  ___jln_c_compiler_id == 'gcc' )
              if (  ___jln_c_compiler_version.version_compare('>=8.0') )
                jln_c_c_flags += ['-Wsuggest-attribute=malloc', ]
                if (  ___jln_c_compiler_version.version_compare('>=14.0') )
                  jln_c_c_flags += ['-Wsuggest-attribute=returns_nonnull', ]
                endif
              endif
              if (  ( ___jln_c_flags.get('suggest_attributes', 'default') == 'all' or ___jln_c_flags.get('suggest_attributes', 'default') == 'unity' ) )
                if (  ___jln_c_flags.get('suggest_attributes', 'default') == 'all' )
                  jln_c_c_flags += ['-Wsuggest-attribute=pure', '-Wsuggest-attribute=const', ]
                  if (  ___jln_c_compiler_version.version_compare('>=5.1') )
                    if (  ___jln_c_compiler_version.version_compare('>=8.0') )
                      jln_c_c_flags += ['-Wsuggest-attribute=cold', ]
                    endif
                  endif
                endif
              endif
            endif
          else
            jln_c_c_flags += ['-Wno-missing-noreturn', '-Wno-missing-format-attribute', ]
            if (  ___jln_c_compiler_id == 'gcc' )
              jln_c_c_flags += ['-Wno-suggest-attribute=pure', '-Wno-suggest-attribute=const', ]
              if (  ___jln_c_compiler_version.version_compare('>=5.0') )
                if (  ___jln_c_compiler_version.version_compare('>=5.1') )
                  if (  ___jln_c_compiler_version.version_compare('>=8.0') )
                    jln_c_c_flags += ['-Wno-suggest-attribute=malloc', ]
                    if (  ___jln_c_compiler_version.version_compare('>=14.0') )
                      jln_c_c_flags += ['-Wno-suggest-attribute=returns_nonnull', ]
                    endif
                  endif
                endif
              endif
            endif
          endif
        endif
      endif
    endif
    if (  ___jln_c_flags.get('var_init', 'default') != 'default' )
      if (  ( ( ___jln_c_compiler_id == 'gcc' and ___jln_c_compiler_version.version_compare('>=12.0') ) or ( ___jln_c_is_clang_like and ___jln_c_compiler_version.version_compare('>=8.0') ) or ( ___jln_c_compiler_id == 'clang-cl' and ___jln_c_compiler_version.version_compare('>=8.0') ) ) )
        if (  ___jln_c_flags.get('var_init', 'default') == 'pattern' )
          jln_c_c_flags += ['-ftrivial-auto-var-init=pattern', ]
          if (  ___jln_c_compiler_id == 'gcc' )
            jln_c_c_flags += ['-Wtrivial-auto-var-init', ]
          endif
        else
          if (  ___jln_c_flags.get('var_init', 'default') == 'zero' )
            if (  ( ( ___jln_c_is_clang_like and ___jln_c_compiler_version.version_compare('<=15.0') ) or ( ___jln_c_compiler_id == 'clang-cl' and ___jln_c_compiler_version.version_compare('<=15.0') ) ) )
              if (  ___jln_c_flags.get('var_init', 'default') == 'zero' )
                jln_c_c_flags += ['-enable-trivial-auto-var-init-zero-knowing-it-will-be-removed-from-clang', ]
              endif
            else
              jln_c_c_flags += ['-ftrivial-auto-var-init=zero', ]
              if (  ___jln_c_compiler_id == 'gcc' )
                jln_c_c_flags += ['-Wtrivial-auto-var-init', ]
              endif
            endif
          else
            jln_c_c_flags += ['-ftrivial-auto-var-init=uninitialized', ]
          endif
        endif
      endif
    endif
    if (  ___jln_c_flags.get('reproducible_build_warnings', 'default') != 'default' )
      if (  ( ___jln_c_compiler_id == 'gcc' and ___jln_c_compiler_version.version_compare('>=4.9') ) )
        if (  ___jln_c_flags.get('reproducible_build_warnings', 'default') == 'on' )
          jln_c_c_flags += ['-Wdate-time', ]
        else
          jln_c_c_flags += ['-Wno-date-time', ]
        endif
      endif
    endif
    if (  ___jln_c_flags.get('warnings_as_error', 'default') != 'default' )
      if (  ___jln_c_flags.get('warnings_as_error', 'default') == 'on' )
        jln_c_c_flags += ['-Werror', ]
      else
        if (  ___jln_c_flags.get('warnings_as_error', 'default') == 'basic' )
          jln_c_c_flags += ['-Werror=return-type', '-Werror=init-self', ]
          if (  ___jln_c_compiler_id == 'gcc' )
            jln_c_c_flags += ['-Werror=div-by-zero', ]
            if (  ___jln_c_compiler_version.version_compare('>=5.1') )
              jln_c_c_flags += ['-Werror=array-bounds', '-Werror=logical-op', '-Werror=logical-not-parentheses', ]
            endif
          else
            jln_c_c_flags += ['-Werror=array-bounds', '-Werror=division-by-zero', ]
            if (  ___jln_c_compiler_version.version_compare('>=3.4') )
              jln_c_c_flags += ['-Werror=logical-not-parentheses', ]
            endif
          endif
        else
          jln_c_c_flags += ['-Wno-error', ]
        endif
      endif
    endif
    if (  ___jln_c_flags.get('color', 'default') != 'default' )
      if (  ( ___jln_c_compiler_version.version_compare('>=4.9') or ___jln_c_compiler_id != 'gcc' ) )
        if (  ___jln_c_flags.get('color', 'default') == 'auto' )
          jln_c_c_flags += ['-fdiagnostics-color=auto', ]
        else
          if (  ___jln_c_flags.get('color', 'default') == 'never' )
            jln_c_c_flags += ['-fdiagnostics-color=never', ]
          else
            jln_c_c_flags += ['-fdiagnostics-color=always', ]
          endif
        endif
      endif
    endif
    if (  ___jln_c_flags.get('lto', 'default') != 'default' )
      if (  ___jln_c_flags.get('lto', 'default') == 'off' )
        jln_c_c_flags += ['-fno-lto', ]
        jln_c_link_flags += ['-fno-lto', ]
        if (  ___jln_c_compiler_id == 'gcc' )
          jln_c_c_flags += ['-fno-whole-program', ]
        endif
      else
        if (  ___jln_c_compiler_id == 'gcc' )
          if (  ___jln_c_flags.get('lto', 'default') != 'thin_or_nothing' )
            if (  ( ___jln_c_flags.get('lto', 'default') == 'whole_program' or ___jln_c_flags.get('lto', 'default') == 'whole_program_and_full_lto' ) )
              jln_c_c_flags += ['-fwhole-program', ]
            endif
            if (  ___jln_c_compiler_version.version_compare('>=10.0') )
              jln_c_c_flags += ['-flto=auto', ]
              jln_c_link_flags += ['-flto=auto', ]
            else
              jln_c_c_flags += ['-flto', ]
              jln_c_link_flags += ['-flto', ]
            endif
          endif
        else
          if (  ( ( ___jln_c_flags.get('lto', 'default') == 'on' or ___jln_c_flags.get('lto', 'default') == 'thin_or_nothing' or ___jln_c_flags.get('lto', 'default') == 'whole_program' ) and ___jln_c_compiler_version.version_compare('>=4.0') ) )
            jln_c_c_flags += ['-flto=thin', ]
            jln_c_link_flags += ['-flto=thin', ]
          else
            jln_c_c_flags += ['-flto', ]
            jln_c_link_flags += ['-flto', ]
            if (  ___jln_c_compiler_version.version_compare('>=10.0') )
              jln_c_c_flags += ['-fvirtual-function-elimination', ]
              jln_c_link_flags += ['-fvirtual-function-elimination', ]
            endif
          endif
          if (  ___jln_c_compiler_version.version_compare('>=3.9') )
            if (  ( ___jln_c_flags.get('lto', 'default') == 'whole_program' or ___jln_c_flags.get('lto', 'default') == 'whole_program_and_full_lto' ) )
              jln_c_c_flags += ['-fwhole-program-vtables', ]
              jln_c_link_flags += ['-fwhole-program-vtables', ]
            endif
            if (  ___jln_c_compiler_version.version_compare('>=7.0') )
              jln_c_c_flags += ['-fforce-emit-vtables', ]
              jln_c_link_flags += ['-fforce-emit-vtables', ]
            endif
          endif
        endif
      endif
    endif
    if (  ___jln_c_flags.get('sanitizers', 'default') != 'default' )
      if (  ( ( ___jln_c_compiler_id == 'gcc' and ___jln_c_compiler_version.version_compare('>=4.8') ) or ( ___jln_c_is_clang_like and ___jln_c_compiler_version.version_compare('>=3.2') ) or ( ___jln_c_compiler_id == 'clang-cl' and ___jln_c_compiler_version.version_compare('>=4.0') ) ) )
        if (  ___jln_c_flags.get('sanitizers', 'default') == 'off' )
          jln_c_c_flags += ['-fno-sanitize=all', ]
          jln_c_link_flags += ['-fno-sanitize=all', ]
        else
          if (  ___jln_c_flags.get('sanitizers', 'default') == 'thread' )
            jln_c_c_flags += ['-fsanitize=thread', ]
            jln_c_link_flags += ['-fsanitize=thread', ]
          else
            if (  ___jln_c_flags.get('sanitizers', 'default') == 'undefined' )
              jln_c_c_flags += ['-fsanitize=undefined', ]
              jln_c_link_flags += ['-fsanitize=undefined', ]
            else
              if (  ___jln_c_flags.get('sanitizers', 'default') == 'undefined_minimal_runtime' )
                jln_c_c_flags += ['-fsanitize=undefined', ]
                jln_c_link_flags += ['-fsanitize=undefined', ]
                if (  ( ( ___jln_c_is_clang_like or ___jln_c_compiler_id == 'clang-cl' ) and ___jln_c_compiler_version.version_compare('>=6.0') ) )
                  jln_c_c_flags += ['-fsanitize-minimal-runtime', ]
                  jln_c_link_flags += ['-fsanitize-minimal-runtime', ]
                endif
              else
                if (  ___jln_c_flags.get('sanitizers', 'default') == 'scudo_hardened_allocator' )
                  if (  ( ___jln_c_compiler_id == 'clang' and ___jln_c_compiler_version.version_compare('>=13.0') ) )
                    jln_c_c_flags += ['-fsanitize=scudo', ]
                    jln_c_link_flags += ['-fsanitize=scudo', ]
                  endif
                else
                  jln_c_c_flags += ['-fno-omit-frame-pointer', '-fno-optimize-sibling-calls', '-fsanitize=address', ]
                  jln_c_link_flags += ['-fsanitize=address', ]
                  if (  ( ___jln_c_flags.get('sanitizers', 'default') == 'on' or ___jln_c_flags.get('sanitizers', 'default') == 'with_minimal_code_size' or ___jln_c_flags.get('sanitizers', 'default') == 'extra' or ___jln_c_flags.get('sanitizers', 'default') == 'extra_with_minimal_code_size' ) )
                    if (  ( ( ___jln_c_compiler_id == 'gcc' and ___jln_c_compiler_version.version_compare('>=4.9') ) or ___jln_c_is_clang_like or ___jln_c_compiler_id == 'clang-cl' ) )
                      jln_c_c_flags += ['-fsanitize=undefined', ]
                      jln_c_link_flags += ['-fsanitize=undefined', ]
                    endif
                    if (  ( ___jln_c_flags.get('sanitizers', 'default') == 'with_minimal_code_size' or ___jln_c_flags.get('sanitizers', 'default') == 'extra_with_minimal_code_size' ) )
                      if (  ( ( ___jln_c_is_clang_like and ___jln_c_compiler_version.version_compare('>=13.0') ) or ( ___jln_c_compiler_id == 'clang-cl' and ___jln_c_compiler_version.version_compare('>=13.0') ) ) )
                        jln_c_c_flags += ['-fsanitize-address-use-after-return=always', ]
                        jln_c_link_flags += ['-fsanitize-address-use-after-return=always', ]
                      endif
                    endif
                    if (  ( ___jln_c_flags.get('sanitizers', 'default') == 'extra' or ___jln_c_flags.get('sanitizers', 'default') == 'extra_with_minimal_code_size' ) )
                      if (  ( ( ___jln_c_compiler_id == 'gcc' and ___jln_c_compiler_version.version_compare('>=8.0') ) or ( ___jln_c_compiler_id == 'clang' and ___jln_c_compiler_version.version_compare('>=9.0') ) or ( ___jln_c_compiler_id == 'clang-cl' and ___jln_c_compiler_version.version_compare('>=9.0') ) ) )
                        jln_c_c_flags += ['-fsanitize=pointer-compare', '-fsanitize=pointer-subtract', ]
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
    if (  ___jln_c_flags.get('emcc_debug', 'default') != 'default' )
      if (  ___jln_c_compiler_id == 'emscripten' )
        if (  ___jln_c_flags.get('emcc_debug', 'default') == 'off' )
          jln_c_link_flags += ['-sASSERTIONS=0', '-sSAFE_HEAP=0', '-sSTACK_OVERFLOW_CHECK=0', ]
        else
          if (  ___jln_c_flags.get('emcc_debug', 'default') == 'slow' )
            jln_c_link_flags += ['-sASSERTIONS=2', ]
          else
            jln_c_link_flags += ['-sASSERTIONS=1', ]
          endif
          jln_c_link_flags += ['-sSTACK_OVERFLOW_CHECK=2', ]
          if (   not ( ( ___jln_c_flags.get('sanitizers', 'default') == 'on' or ___jln_c_flags.get('sanitizers', 'default') == 'with_minimal_code_size' or ___jln_c_flags.get('sanitizers', 'default') == 'extra' or ___jln_c_flags.get('sanitizers', 'default') == 'extra_with_minimal_code_size' or ___jln_c_flags.get('sanitizers', 'default') == 'address' or ___jln_c_flags.get('sanitizers', 'default') == 'address_with_minimal_code_size' ) ) )
            jln_c_link_flags += ['-sSAFE_HEAP=1', ]
          endif
        endif
      endif
    endif
  endif
  if (  ___jln_c_flags.get('conversion_warnings', 'default') != 'default' )
    if (  ( ___jln_c_compiler_id == 'gcc' or ___jln_c_is_clang_like or ___jln_c_compiler_id == 'clang-cl' or ___jln_c_compiler_id == 'intel' ) )
      if (  ___jln_c_flags.get('conversion_warnings', 'default') == 'on' )
        jln_c_c_flags += ['-Wconversion', '-Wsign-compare', '-Wsign-conversion', ]
      else
        if (  ___jln_c_flags.get('conversion_warnings', 'default') == 'conversion' )
          jln_c_c_flags += ['-Wconversion', ]
        else
          if (  ___jln_c_flags.get('conversion_warnings', 'default') == 'float' )
            if (  ___jln_c_compiler_id == 'gcc' )
              if (  ___jln_c_compiler_version.version_compare('>=4.9') )
                jln_c_c_flags += ['-Wfloat-conversion', ]
              endif
            else
              jln_c_c_flags += ['-Wfloat-conversion', ]
            endif
          else
            if (  ___jln_c_flags.get('conversion_warnings', 'default') == 'sign' )
              jln_c_c_flags += ['-Wsign-compare', '-Wsign-conversion', ]
            else
              if (  ___jln_c_flags.get('conversion_warnings', 'default') == 'all' )
                jln_c_c_flags += ['-Wconversion', ]
                if (  ___jln_c_compiler_id == 'gcc' )
                  jln_c_c_flags += ['-Warith-conversion', ]
                endif
              else
                jln_c_c_flags += ['-Wno-conversion', '-Wno-sign-compare', '-Wno-sign-conversion', ]
              endif
            endif
          endif
        endif
      endif
    endif
  endif
  if (  ( ___jln_c_compiler_id == 'gcc' or ___jln_c_is_clang_like ) )
    if (  ___jln_c_flags.get('exceptions', 'default') != 'default' )
      if (  ___jln_c_flags.get('exceptions', 'default') == 'on' )
        jln_c_c_flags += ['-fexceptions', ]
        if (  ___jln_c_compiler_id == 'emscripten' )
          jln_c_c_flags += ['-sDISABLE_EXCEPTION_CATCHING=0', ]
        endif
      else
        jln_c_c_flags += ['-fno-exceptions', ]
      endif
    endif
    if (  ___jln_c_flags.get('hardened', 'default') != 'default' )
      if (  ( ___jln_c_flags.get('hardened', 'default') == 'on' or ___jln_c_flags.get('hardened', 'default') == 'all' ) )
        if (  ( ___jln_c_compiler_id == 'gcc' and ___jln_c_compiler_version.version_compare('>=14.0') ) )
          jln_c_c_flags += ['-fhardened', '-Whardened', ]
          if (  ___jln_c_flags.get('hardened', 'default') == 'all' )
            jln_c_c_flags += ['-fstack-protector-all', ]
          endif
          jln_c_c_flags += ['-Wtrampolines', ]
          jln_c_link_flags += ['-Wl,-z,noexecstack', ]
        else
          if (  ___jln_c_flags.get('hardened', 'default') == 'all' )
            jln_c_c_flags += ['-fstack-protector-all', ]
          else
            jln_c_c_flags += ['-fstack-protector-strong', ]
          endif
          if (  ( ( ___jln_c_compiler_id == 'gcc' and ___jln_c_compiler_version.version_compare('>=12.0') ) or ( ___jln_c_is_clang_like and ___jln_c_compiler_version.version_compare('>=14.0') ) ) )
            jln_c_c_flags += ['-D_FORTIFY_SOURCE=3', ]
            if (  ( ( ___jln_c_compiler_id == 'gcc' and ___jln_c_compiler_version.version_compare('>=13.0') ) or ( ___jln_c_is_clang_like and ___jln_c_compiler_version.version_compare('>=16.0') ) ) )
              jln_c_c_flags += ['-fstrict-flex-arrays=3', ]
            endif
          else
            jln_c_c_flags += ['-D_FORTIFY_SOURCE=2', ]
          endif
          if (  ___jln_c_flags.get('var_init', 'default') == 'default' )
            if (  ( ( ___jln_c_compiler_id == 'gcc' and ___jln_c_compiler_version.version_compare('>=12.0') ) or ( ___jln_c_is_clang_like and ___jln_c_compiler_version.version_compare('>=8.0') ) ) )
              if (  ( ___jln_c_is_clang_like and ___jln_c_compiler_version.version_compare('<=15.0') ) )
                jln_c_c_flags += ['-enable-trivial-auto-var-init-zero-knowing-it-will-be-removed-from-clang', ]
              else
                jln_c_c_flags += ['-ftrivial-auto-var-init=zero', ]
                if (  ___jln_c_compiler_id == 'gcc' )
                  jln_c_c_flags += ['-Wtrivial-auto-var-init', ]
                endif
              endif
            endif
          endif
          jln_c_c_flags += ['-fPIE', ]
          jln_c_link_flags += ['-fPIE', ]
          if (  ___jln_c_compiler_id != 'emscripten' )
            jln_c_c_flags += ['-pie', ]
            jln_c_link_flags += ['-pie', '-Wl,-z,relro,-z,now', '-Wl,-z,noexecstack', ]
          endif
          if (  ___jln_c_compiler_id == 'gcc' )
            if (  ___jln_c_compiler_version.version_compare('>=4.6') )
              jln_c_c_flags += ['-Wtrampolines', ]
              if (  ___jln_c_compiler_version.version_compare('>=8.0') )
                jln_c_c_flags += ['-fstack-clash-protection', '-fcf-protection=full', ]
              endif
            endif
          else
            if (  ___jln_c_compiler_id != 'emscripten' )
              if (  ___jln_c_compiler_version.version_compare('>=7.0') )
                jln_c_c_flags += ['-fcf-protection=full', ]
                if (  ___jln_c_compiler_version.version_compare('>=11.0') )
                  jln_c_c_flags += ['-fstack-clash-protection', ]
                endif
              endif
            endif
          endif
        endif
      endif
    endif
    if (  ___jln_c_flags.get('diagnostics_format', 'default') != 'default' )
      if (  ___jln_c_flags.get('diagnostics_format', 'default') == 'fixits' )
        if (  ( ( ___jln_c_compiler_id == 'gcc' and ___jln_c_compiler_version.version_compare('>=7.0') ) or ( ___jln_c_compiler_id != 'gcc' and ___jln_c_compiler_version.version_compare('>=5.0') ) ) )
          jln_c_c_flags += ['-fdiagnostics-parseable-fixits', ]
        endif
      else
        if (  ___jln_c_flags.get('diagnostics_format', 'default') == 'patch' )
          if (  ( ___jln_c_compiler_id == 'gcc' and ___jln_c_compiler_version.version_compare('>=7.0') ) )
            jln_c_c_flags += ['-fdiagnostics-generate-patch', ]
          endif
        else
          if (  ___jln_c_is_clang_like )
            jln_c_c_flags += ['-fdiagnostics-print-source-range-info', ]
          endif
        endif
      endif
    endif
    if (  ___jln_c_flags.get('pedantic', 'default') != 'default' )
      if (  ___jln_c_flags.get('pedantic', 'default') != 'off' )
        jln_c_c_flags += ['-pedantic', ]
        if (  ___jln_c_flags.get('pedantic', 'default') == 'as_error' )
          jln_c_c_flags += ['-pedantic-errors', '-Werror=write-strings', ]
        endif
      endif
    endif
    if (  ___jln_c_flags.get('symbols', 'default') != 'default' )
      if (  ___jln_c_flags.get('symbols', 'default') == 'hidden' )
        jln_c_c_flags += ['-fvisibility=hidden', ]
      else
        if (  ___jln_c_flags.get('symbols', 'default') == 'strip_all' )
          jln_c_link_flags += ['-s', ]
        else
          if (  ___jln_c_flags.get('symbols', 'default') == 'gc_sections' )
            if (  ___jln_c_linker_id == 'ld64' )
              jln_c_link_flags += ['-Wl,-S', '-Wl,-dead_strip', ]
            endif
            jln_c_link_flags += ['-s', '-Wl,--gc-sections', ]
          else
            if (  ___jln_c_flags.get('symbols', 'default') == 'nodebug' )
              jln_c_c_flags += ['-g0', ]
            else
              if (  ___jln_c_flags.get('symbols', 'default') == 'debug' )
                jln_c_c_flags += ['-g', ]
              else
                if (  ___jln_c_flags.get('symbols', 'default') == 'minimal_debug' )
                  jln_c_c_flags += ['-g1', ]
                else
                  if (  ___jln_c_flags.get('symbols', 'default') == 'full_debug' )
                    jln_c_c_flags += ['-g3', ]
                  else
                    if (  ___jln_c_compiler_id == 'clang' )
                      if (  ___jln_c_flags.get('symbols', 'default') == 'dwarf' )
                        jln_c_c_flags += ['-g', ]
                      endif
                      if (  ___jln_c_flags.get('symbols', 'default') == 'lldb' )
                        jln_c_c_flags += ['-glldb', ]
                      endif
                      if (  ___jln_c_flags.get('symbols', 'default') == 'sce' )
                        jln_c_c_flags += ['-gsce', ]
                      endif
                      if (  ___jln_c_flags.get('symbols', 'default') == 'dbx' )
                        jln_c_c_flags += ['-gdbx', ]
                      endif
                    else
                      if (  ___jln_c_compiler_id == 'gcc' )
                        if (  ___jln_c_flags.get('symbols', 'default') == 'dwarf' )
                          jln_c_c_flags += ['-g', ]
                        endif
                        if (  ___jln_c_flags.get('symbols', 'default') == 'codeview' )
                          jln_c_c_flags += ['-gcodeview', ]
                        endif
                        if (  ___jln_c_flags.get('symbols', 'default') == 'btf' )
                          jln_c_c_flags += ['-gbtf', ]
                        endif
                        if (  ___jln_c_flags.get('symbols', 'default') == 'ctf' )
                          jln_c_c_flags += ['-gctf', ]
                        endif
                        if (  ___jln_c_flags.get('symbols', 'default') == 'ctf1' )
                          jln_c_c_flags += ['-gctf1', ]
                        endif
                        if (  ___jln_c_flags.get('symbols', 'default') == 'ctf2' )
                          jln_c_c_flags += ['-gctf2', ]
                        endif
                        if (  ___jln_c_flags.get('symbols', 'default') == 'vms' )
                          jln_c_c_flags += ['-gvms', ]
                        endif
                        if (  ___jln_c_flags.get('symbols', 'default') == 'vms1' )
                          jln_c_c_flags += ['-gvms1', ]
                        endif
                        if (  ___jln_c_flags.get('symbols', 'default') == 'vms2' )
                          jln_c_c_flags += ['-gvms2', ]
                        endif
                        if (  ___jln_c_flags.get('symbols', 'default') == 'vms3' )
                          jln_c_c_flags += ['-gvms3', ]
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
    endif
    if (  ___jln_c_compiler_id == 'emscripten' )
      if (  ___jln_c_flags.get('optimization', 'default') != 'default' )
        if (  ___jln_c_flags.get('optimization', 'default') == '0' )
          jln_c_c_flags += ['-O0', ]
          jln_c_link_flags += ['-O0', ]
        else
          if (  ___jln_c_flags.get('optimization', 'default') == 'g' )
            jln_c_c_flags += ['-Og', ]
            jln_c_link_flags += ['-Og', ]
          else
            if (  ___jln_c_flags.get('optimization', 'default') == '1' )
              jln_c_c_flags += ['-O1', ]
              jln_c_link_flags += ['-O1', ]
            else
              if (  ___jln_c_flags.get('optimization', 'default') == '2' )
                jln_c_c_flags += ['-O2', ]
                jln_c_link_flags += ['-O2', ]
              else
                if (  ___jln_c_flags.get('optimization', 'default') == '3' )
                  jln_c_c_flags += ['-O3', ]
                  jln_c_link_flags += ['-O3', ]
                else
                  if (  ___jln_c_flags.get('optimization', 'default') == 'fast' )
                    jln_c_c_flags += ['-O3', '-mnontrapping-fptoint', ]
                    jln_c_link_flags += ['-O3', '-mnontrapping-fptoint', ]
                  else
                    if (  ___jln_c_flags.get('optimization', 'default') == 'size' )
                      jln_c_c_flags += ['-Os', ]
                      jln_c_link_flags += ['-Os', ]
                    else
                      jln_c_c_flags += ['-Oz', ]
                      jln_c_link_flags += ['-Oz', ]
                    endif
                  endif
                endif
              endif
            endif
          endif
        endif
      endif
    else
      if (  ___jln_c_flags.get('coverage', 'default') != 'default' )
        if (  ___jln_c_flags.get('coverage', 'default') == 'on' )
          jln_c_c_flags += ['--coverage', ]
          jln_c_link_flags += ['--coverage', ]
          if (  ___jln_c_compiler_id == 'clang' )
            jln_c_link_flags += ['-lprofile_rt', ]
          endif
        endif
      endif
      if (  ___jln_c_flags.get('optimization', 'default') != 'default' )
        if (  ___jln_c_flags.get('optimization', 'default') == '0' )
          jln_c_c_flags += ['-O0', ]
        else
          if (  ___jln_c_flags.get('optimization', 'default') == 'g' )
            jln_c_c_flags += ['-Og', ]
          else
            jln_c_link_flags += ['-Wl,-O1', ]
            if (  ___jln_c_flags.get('optimization', 'default') == '1' )
              jln_c_c_flags += ['-O1', ]
            else
              if (  ___jln_c_flags.get('optimization', 'default') == '2' )
                jln_c_c_flags += ['-O2', ]
              else
                if (  ___jln_c_flags.get('optimization', 'default') == '3' )
                  jln_c_c_flags += ['-O3', ]
                else
                  if (  ___jln_c_flags.get('optimization', 'default') == 'size' )
                    jln_c_c_flags += ['-Os', ]
                  else
                    if (  ___jln_c_flags.get('optimization', 'default') == 'z' )
                      if (  ( ___jln_c_compiler_id == 'clang' or ( ___jln_c_compiler_id == 'gcc' and ___jln_c_compiler_version.version_compare('>=12.0') ) ) )
                        jln_c_c_flags += ['-Oz', ]
                      else
                        jln_c_c_flags += ['-Os', ]
                      endif
                    else
                      if (  ___jln_c_compiler_id == 'clang' )
                        jln_c_c_flags += ['-O3', '-ffast-math', ]
                      else
                        jln_c_c_flags += ['-Ofast', ]
                      endif
                    endif
                  endif
                endif
              endif
            endif
          endif
        endif
      endif
      if (  ___jln_c_flags.get('cpu', 'default') != 'default' )
        if (  ___jln_c_flags.get('cpu', 'default') == 'generic' )
          jln_c_c_flags += ['-mtune=generic', ]
          jln_c_link_flags += ['-mtune=generic', ]
        else
          jln_c_c_flags += ['-march=native', '-mtune=native', ]
          jln_c_link_flags += ['-march=native', '-mtune=native', ]
        endif
      endif
      if (  ___jln_c_flags.get('linker', 'default') != 'default' )
        if (  ___jln_c_flags.get('linker', 'default') == 'mold' )
          jln_c_link_flags += ['-fuse-ld=mold', ]
        else
          if (  ___jln_c_flags.get('linker', 'default') == 'native' )
            if (  ___jln_c_compiler_id == 'gcc' )
              jln_c_link_flags += ['-fuse-ld=gold', ]
            else
              jln_c_link_flags += ['-fuse-ld=lld', ]
            endif
          else
            if (  ___jln_c_flags.get('linker', 'default') == 'bfd' )
              jln_c_link_flags += ['-fuse-ld=bfd', ]
            else
              if (  ( ___jln_c_flags.get('linker', 'default') == 'gold' or ( ___jln_c_compiler_id == 'gcc' and ___jln_c_compiler_version.version_compare('<9.0') ) ) )
                jln_c_link_flags += ['-fuse-ld=gold', ]
              else
                jln_c_link_flags += ['-fuse-ld=lld', ]
              endif
            endif
          endif
        endif
      endif
      if (  ___jln_c_flags.get('analyzer', 'default') != 'default' )
        if (  ( ___jln_c_compiler_id == 'gcc' and ___jln_c_compiler_version.version_compare('>=10.0') ) )
          if (  ___jln_c_flags.get('analyzer', 'default') == 'off' )
            jln_c_c_flags += ['-fno-analyzer', ]
          else
            jln_c_c_flags += ['-fanalyzer', ]
            if (  ___jln_c_flags.get('analyzer_too_complex_warning', 'default') != 'default' )
              if (  ___jln_c_flags.get('analyzer_too_complex_warning', 'default') == 'on' )
                jln_c_c_flags += ['-Wanalyzer-too-complex', ]
              else
                jln_c_c_flags += ['-Wno-analyzer-too-complex', ]
              endif
            endif
            if (  ___jln_c_flags.get('analyzer_verbosity', 'default') != 'default' )
              if (  ___jln_c_flags.get('analyzer_verbosity', 'default') == '0' )
                jln_c_c_flags += ['-fanalyzer-verbosity=0', ]
              else
                if (  ___jln_c_flags.get('analyzer_verbosity', 'default') == '1' )
                  jln_c_c_flags += ['-fanalyzer-verbosity=1', ]
                else
                  if (  ___jln_c_flags.get('analyzer_verbosity', 'default') == '2' )
                    jln_c_c_flags += ['-fanalyzer-verbosity=2', ]
                  else
                    jln_c_c_flags += ['-fanalyzer-verbosity=3', ]
                  endif
                endif
              endif
            endif
          endif
        endif
      endif
    endif
  endif
  if (  ( ___jln_c_compiler_id == 'msvc' or ___jln_c_compiler_id == 'clang-cl' or ___jln_c_compiler_id == 'intel-cl' ) )
    if (  ___jln_c_flags.get('exceptions', 'default') != 'default' )
      if (  ___jln_c_flags.get('exceptions', 'default') == 'on' )
        jln_c_c_flags += ['/EHsc', ]
      else
        jln_c_c_flags += ['/EHs-c-', ]
      endif
    endif
    if (  ___jln_c_flags.get('rtti', 'default') != 'default' )
      if (  ___jln_c_flags.get('rtti', 'default') == 'on' )
        jln_c_c_flags += ['/GR', ]
      else
        jln_c_c_flags += ['/GR-', ]
      endif
    endif
    if (  ___jln_c_flags.get('stl_hardening', 'default') != 'default' )
      if (  ___jln_c_flags.get('stl_hardening', 'default') == 'off' )
        jln_c_c_flags += ['/D_SECURE_SCL=0', ]
      else
        if (  ( not ( ( ___jln_c_flags.get('stl_hardening', 'default') == 'fast' or ___jln_c_flags.get('stl_hardening', 'default') == 'extensive' ) ) and ___jln_c_flags.get('stl_hardening', 'default') != 'debug' ) )
          jln_c_c_flags += ['/D_DEBUG', ]
        endif
      endif
    endif
    if (  ___jln_c_flags.get('stl_fix', 'default') != 'default' )
      if (  ___jln_c_flags.get('stl_fix', 'default') == 'on' )
        jln_c_c_flags += ['/DNOMINMAX', ]
      endif
    endif
    if (  ___jln_c_compiler_id != 'intel-cl' )
      if (  ___jln_c_flags.get('symbols', 'default') != 'default' )
        if (  ___jln_c_flags.get('symbols', 'default') == 'nodebug' )
          jln_c_link_flags += ['/DEBUG:NONE', ]
        else
          if (  ( ___jln_c_flags.get('symbols', 'default') == 'debug' or ___jln_c_flags.get('symbols', 'default') == 'minimal_debug' or ___jln_c_flags.get('symbols', 'default') == 'full_debug' or ___jln_c_flags.get('symbols', 'default') == 'codeview' ) )
            jln_c_c_flags += ['/Zi', ]
            jln_c_link_flags += ['/DEBUG:FULL', ]
          else
            if (  ___jln_c_compiler_id == 'clang-cl' )
              if (  ___jln_c_flags.get('symbols', 'default') == 'dwarf' )
                jln_c_link_flags += ['-gdwarf', ]
              endif
            endif
          endif
        endif
      endif
      if (  ___jln_c_flags.get('optimization', 'default') != 'default' )
        if (  ___jln_c_flags.get('optimization', 'default') == '0' )
          jln_c_c_flags += ['/Od', ]
        else
          if (  ___jln_c_flags.get('optimization', 'default') == 'g' )
            jln_c_c_flags += ['/Ob1', ]
          else
            if (  ___jln_c_flags.get('optimization', 'default') == '2' )
              jln_c_c_flags += ['/O2', ]
            else
              if (  ( ___jln_c_flags.get('optimization', 'default') == '1' or ___jln_c_flags.get('optimization', 'default') == 'size' ) )
                jln_c_c_flags += ['/O1', ]
              else
                if (  ___jln_c_flags.get('optimization', 'default') == 'z' )
                  jln_c_c_flags += ['/O1', '/Gw', ]
                else
                  if (  ___jln_c_flags.get('optimization', 'default') == 'fast' )
                    jln_c_c_flags += ['/fp:fast', ]
                  endif
                  jln_c_c_flags += ['/O2', ]
                  if (  ( ( ___jln_c_compiler_id == 'msvc' and ___jln_c_compiler_version.version_compare('>=19.20') ) or ___jln_c_compiler_id == 'clang-cl' ) )
                    jln_c_c_flags += ['/Ob3', ]
                  endif
                  jln_c_c_flags += ['/Gw', ]
                endif
              endif
            endif
          endif
        endif
      endif
      if (  ___jln_c_flags.get('hardened', 'default') != 'default' )
        if (  ___jln_c_flags.get('hardened', 'default') == 'off' )
          jln_c_c_flags += ['/GS-', ]
        else
          jln_c_c_flags += ['/sdl', '/guard:cf', ]
          if (  ( ( ___jln_c_compiler_id == 'msvc' and ___jln_c_compiler_version.version_compare('>=19.27') ) or ( ___jln_c_compiler_id == 'clang-cl' and ___jln_c_compiler_version.version_compare('>=10.0') ) ) )
            jln_c_c_flags += ['/guard:ehcont', ]
            jln_c_link_flags += ['/CETCOMPAT', ]
          endif
        endif
      endif
    endif
  endif
  if (  ___jln_c_compiler_id == 'msvc' )
    if (  ___jln_c_flags.get('analyzer', 'default') != 'default' )
      if (  ___jln_c_compiler_version.version_compare('>=19.0') )
        if (  ___jln_c_flags.get('analyzer', 'default') == 'off' )
          jln_c_c_flags += ['/analyze-', ]
        else
          jln_c_c_flags += ['/analyze', ]
          if (  ___jln_c_flags.get('analyzer', 'default') != 'with_external_headers' )
            if (  ___jln_c_compiler_version.version_compare('>=16.10') )
              jln_c_c_flags += ['/analyze:external-', ]
            endif
          endif
        endif
      endif
    endif
    if (  ___jln_c_flags.get('windows_bigobj', 'default') != 'default' )
      jln_c_c_flags += ['/bigobj', ]
    endif
    if (  ___jln_c_flags.get('msvc_crt_secure_no_warnings', 'default') != 'default' )
      if (  ___jln_c_flags.get('msvc_crt_secure_no_warnings', 'default') == 'on' )
        jln_c_c_flags += ['/D_CRT_SECURE_NO_WARNINGS=1', ]
      else
        if (  ___jln_c_flags.get('msvc_crt_secure_no_warnings', 'default') == 'off' )
          jln_c_c_flags += ['/U_CRT_SECURE_NO_WARNINGS', ]
        endif
      endif
    endif
    if (  ___jln_c_flags.get('msvc_diagnostics_format', 'default') != 'default' )
      if (  ___jln_c_compiler_version.version_compare('>=19.10') )
        if (  ___jln_c_flags.get('msvc_diagnostics_format', 'default') == 'classic' )
          jln_c_c_flags += ['/diagnostics:classic', ]
        else
          if (  ___jln_c_flags.get('msvc_diagnostics_format', 'default') == 'column' )
            jln_c_c_flags += ['/diagnostics:column', ]
          else
            jln_c_c_flags += ['/diagnostics:caret', ]
          endif
        endif
      endif
    endif
    if (  ___jln_c_compiler_version.version_compare('<19.13') )
      ___jln_c_flags += {'msvc_isystem': 'default'}
    endif
    if (  ___jln_c_flags.get('msvc_isystem', 'default') != 'default' )
      if (  ___jln_c_flags.get('msvc_isystem', 'default') == 'external_as_include_system_flag' )
        if (  ___jln_c_compiler_version.version_compare('<19.29') )
          # unimplementable
        else
          # unimplementable
        endif
      else
        if (  ___jln_c_flags.get('msvc_isystem', 'default') != 'assumed' )
          if (  ___jln_c_compiler_version.version_compare('<19.29') )
            jln_c_c_flags += ['/experimental:external', ]
          endif
          jln_c_c_flags += ['/external:W0', ]
          if (  ___jln_c_flags.get('msvc_isystem', 'default') == 'anglebrackets' )
            jln_c_c_flags += ['/external:anglebrackets', ]
          else
            jln_c_c_flags += ['/external:env:INCLUDE', '/external:env:CAExcludePath', ]
          endif
        endif
      endif
      if (  ___jln_c_flags.get('msvc_isystem_with_template_instantiations_treated_as_non_external', 'default') != 'default' )
        if (  ___jln_c_flags.get('msvc_isystem_with_template_instantiations_treated_as_non_external', 'default') == 'off' )
          jln_c_c_flags += ['/external:templates', ]
        else
          jln_c_c_flags += ['/external:templates-', ]
        endif
      endif
    endif
    if (  ___jln_c_flags.get('warnings', 'default') != 'default' )
      if (  ___jln_c_flags.get('warnings', 'default') == 'off' )
        jln_c_c_flags += ['/W0', ]
      else
        if (  ___jln_c_flags.get('warnings', 'default') == 'essential' )
          jln_c_c_flags += ['/W4', '/wd4711', ]
        else
          if (  ___jln_c_flags.get('warnings', 'default') == 'on' )
            jln_c_c_flags += ['/W4', '/wd4711', '/w14296', '/w14444', '/w14555', '/w14557', '/w14905', '/w14906', '/w14917', '/w14545', '/w14546', '/w14547', '/w14548', '/w14549', ]
            if (  ___jln_c_compiler_version.version_compare('>=19.0') )
              jln_c_c_flags += ['/w14426', ]
              if (  ___jln_c_flags.get('msvc_isystem', 'default') == 'default' )
                jln_c_c_flags += ['/w14654', ]
              endif
              jln_c_c_flags += ['/w15031', '/w15032', ]
              if (  ___jln_c_compiler_version.version_compare('>=19.11') )
                if (  ___jln_c_compiler_version.version_compare('>=19.15') )
                  if (  ___jln_c_compiler_version.version_compare('>=19.22') )
                    if (  ___jln_c_compiler_version.version_compare('>=19.25') )
                      if (  ___jln_c_compiler_version.version_compare('>=19.29') )
                        jln_c_c_flags += ['/w15240', ]
                        if (  ___jln_c_compiler_version.version_compare('>=19.30') )
                          jln_c_c_flags += ['/w15249', ]
                          if (  ___jln_c_compiler_version.version_compare('>=19.32') )
                            jln_c_c_flags += ['/w15258', ]
                            if (  ___jln_c_compiler_version.version_compare('>=19.34') )
                              if (  ___jln_c_flags.get('msvc_isystem', 'default') == 'default' )
                                jln_c_c_flags += ['/w15262', ]
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
          else
            jln_c_c_flags += ['/Wall', '/wd4370', '/wd4371', '/wd4514', '/wd4571', '/wd4577', '/wd4686', '/wd4710', '/wd4711', '/wd4820', '/wd4866', ]
            if (  ___jln_c_flags.get('msvc_isystem', 'default') == 'default' )
              jln_c_c_flags += ['/wd4464', '/wd4548', '/wd4668', ]
              if (  ___jln_c_compiler_version.version_compare('>=19.0') )
                if (  ___jln_c_compiler_version.version_compare('>=19.34') )
                  jln_c_c_flags += ['/wd5262', ]
                  if (  ___jln_c_compiler_version.version_compare('>=19.0') )
                    jln_c_c_flags += ['/wd4774', ]
                  endif
                endif
              endif
            endif
            if (  ___jln_c_compiler_version.version_compare('>=16.0') )
              jln_c_c_flags += ['/wd4800', ]
              if (  ___jln_c_compiler_version.version_compare('>=19.39') )
                jln_c_c_flags += ['/wd4975', ]
                if (  ___jln_c_compiler_version.version_compare('>=19.40') )
                  jln_c_c_flags += ['/wd4860', '/wd4861', '/wd5273', '/wd5274', ]
                  if (  ___jln_c_compiler_version.version_compare('>=19.41') )
                    jln_c_c_flags += ['/wd5306', ]
                    if (  ___jln_c_compiler_version.version_compare('>=19.43') )
                      jln_c_c_flags += ['/wd5277', ]
                    endif
                  endif
                endif
              endif
            endif
          endif
        endif
      endif
    endif
    if (  ___jln_c_flags.get('conversion_warnings', 'default') != 'default' )
      if (  ( ___jln_c_flags.get('conversion_warnings', 'default') == 'off' or ___jln_c_flags.get('conversion_warnings', 'default') == 'sign' ) )
        jln_c_c_flags += ['/wd4244', '/wd4245', '/wd4365', ]
      else
        jln_c_c_flags += ['/w14244', '/w14245', '/w14365', ]
      endif
      if (  ( ___jln_c_flags.get('conversion_warnings', 'default') == 'on' or ___jln_c_flags.get('conversion_warnings', 'default') == 'all' or ___jln_c_flags.get('conversion_warnings', 'default') == 'sign' ) )
        jln_c_c_flags += ['/w14018', '/w14388', '/w14289', ]
      else
        jln_c_c_flags += ['/wd4018', '/wd4388', '/wd4289', ]
      endif
    endif
    if (  ___jln_c_flags.get('switch_warnings', 'default') != 'default' )
      if (  ( ___jln_c_flags.get('switch_warnings', 'default') == 'on' or ___jln_c_flags.get('switch_warnings', 'default') == 'mandatory_default' ) )
        jln_c_c_flags += ['/wd4061', '/w14062', ]
      else
        if (  ( ___jln_c_flags.get('switch_warnings', 'default') == 'exhaustive_enum' or ___jln_c_flags.get('switch_warnings', 'default') == 'exhaustive_enum_and_mandatory_default' ) )
          jln_c_c_flags += ['/w14061', '/w14062', ]
        else
          jln_c_c_flags += ['/wd4061', '/wd4062', ]
        endif
      endif
    endif
    if (  ___jln_c_flags.get('shadow_warnings', 'default') != 'default' )
      if (  ___jln_c_compiler_version.version_compare('>=19.0') )
        if (  ___jln_c_flags.get('shadow_warnings', 'default') == 'off' )
          jln_c_c_flags += ['/wd4456', '/wd4459', ]
        else
          if (  ( ___jln_c_flags.get('shadow_warnings', 'default') == 'on' or ___jln_c_flags.get('shadow_warnings', 'default') == 'all' ) )
            jln_c_c_flags += ['/w14456', '/w14459', ]
          else
            if (  ___jln_c_flags.get('shadow_warnings', 'default') == 'local' )
              jln_c_c_flags += ['/w4456', '/wd4459', ]
            endif
          endif
        endif
      endif
    endif
    if (  ___jln_c_flags.get('warnings_as_error', 'default') != 'default' )
      if (  ___jln_c_flags.get('warnings_as_error', 'default') == 'on' )
        jln_c_c_flags += ['/WX', ]
      else
        if (  ___jln_c_flags.get('warnings_as_error', 'default') == 'off' )
          jln_c_c_flags += ['/WX-', ]
        else
          jln_c_c_flags += ['/we4716', '/we2124', ]
        endif
      endif
    endif
    if (  ___jln_c_flags.get('pedantic', 'default') != 'default' )
      if (  ___jln_c_flags.get('pedantic', 'default') != 'off' )
        jln_c_c_flags += ['/permissive-', '/Zc:inline', ]
        if (  ___jln_c_compiler_version.version_compare('>=19.13') )
          if (  ___jln_c_compiler_version.version_compare('>=19.14') )
            if (  ___jln_c_compiler_version.version_compare('>=19.25') )
              jln_c_c_flags += ['/Zc:preprocessor', ]
            endif
          endif
        endif
        if (  ___jln_c_flags.get('pedantic', 'default') == 'as_error' )
          jln_c_c_flags += ['/we4608', ]
          if (  ___jln_c_compiler_version.version_compare('>=19.31') )
            if (  ___jln_c_compiler_version.version_compare('>=19.38') )
              jln_c_c_flags += ['/we5110', ]
            endif
          endif
        else
          jln_c_c_flags += ['/w14608', ]
          if (  ___jln_c_compiler_version.version_compare('>=19.31') )
            if (  ___jln_c_compiler_version.version_compare('>=19.38') )
              jln_c_c_flags += ['/w15110', ]
            endif
          endif
        endif
      endif
    endif
    if (  ___jln_c_flags.get('lto', 'default') != 'default' )
      if (  ___jln_c_flags.get('lto', 'default') == 'off' )
        jln_c_c_flags += ['/GL-', ]
      else
        if (  ___jln_c_flags.get('lto', 'default') != 'thin_or_nothing' )
          jln_c_c_flags += ['/GL', '/Gw', ]
          jln_c_link_flags += ['/LTCG', ]
        endif
      endif
    endif
    if (  ___jln_c_flags.get('sanitizers', 'default') != 'default' )
      if (  ___jln_c_compiler_version.version_compare('>=19.28') )
        if (  ( ___jln_c_flags.get('sanitizers', 'default') == 'on' or ___jln_c_flags.get('sanitizers', 'default') == 'with_minimal_code_size' or ___jln_c_flags.get('sanitizers', 'default') == 'extra' or ___jln_c_flags.get('sanitizers', 'default') == 'extra_with_minimal_code_size' or ___jln_c_flags.get('sanitizers', 'default') == 'address' or ___jln_c_flags.get('sanitizers', 'default') == 'address_with_minimal_code_size' ) )
          jln_c_c_flags += ['/fsanitize=address', ]
          jln_c_link_flags += ['/fsanitize=address', ]
          if (  ( ___jln_c_flags.get('sanitizers', 'default') == 'extra' or ___jln_c_flags.get('sanitizers', 'default') == 'extra_with_minimal_code_size' ) )
            jln_c_c_flags += ['/fsanitize-address-use-after-return', ]
          endif
        endif
      else
        if (  ( ___jln_c_flags.get('sanitizers', 'default') == 'on' or ___jln_c_flags.get('sanitizers', 'default') == 'with_minimal_code_size' or ___jln_c_flags.get('sanitizers', 'default') == 'extra' or ___jln_c_flags.get('sanitizers', 'default') == 'extra_with_minimal_code_size' or ___jln_c_flags.get('sanitizers', 'default') == 'address' or ___jln_c_flags.get('sanitizers', 'default') == 'address_with_minimal_code_size' ) )
          jln_c_c_flags += ['/sdl', ]
          if (  ( ___jln_c_flags.get('optimization', 'default') == '0' ) )
            jln_c_c_flags += ['/RTCsu', ]
          endif
        else
          if (  ___jln_c_flags.get('sanitizers', 'default') == 'off' )
            if (  ___jln_c_flags.get('hardened', 'default') == 'default' )
              jln_c_c_flags += ['/sdl-', ]
            endif
          endif
        endif
      endif
    endif
  else
    if (  ___jln_c_compiler_id == 'clang-cl' )
      if (  ___jln_c_flags.get('pedantic', 'default') != 'default' )
        if (  ___jln_c_flags.get('pedantic', 'default') != 'off' )
          if (  ___jln_c_flags.get('pedantic', 'default') == 'as_error' )
            jln_c_c_flags += ['-Werror=write-strings', ]
          endif
        endif
      endif
      if (  ___jln_c_flags.get('color', 'default') != 'default' )
        if (  ___jln_c_flags.get('color', 'default') == 'never' )
          jln_c_c_flags += ['-fno-color-diagnostics', ]
        else
          if (  ___jln_c_flags.get('color', 'default') == 'always' )
            jln_c_c_flags += ['-fcolor-diagnostics', ]
          endif
        endif
      endif
      if (  ___jln_c_flags.get('diagnostics_format', 'default') != 'default' )
        if (  ___jln_c_flags.get('diagnostics_format', 'default') == 'fixits' )
          jln_c_c_flags += ['-fdiagnostics-parseable-fixits', ]
        endif
      endif
      if (  ___jln_c_flags.get('cpu', 'default') != 'default' )
        if (  ___jln_c_flags.get('cpu', 'default') == 'generic' )
          jln_c_c_flags += ['-mtune=generic', ]
          jln_c_link_flags += ['-mtune=generic', ]
        else
          jln_c_c_flags += ['-march=native', '-mtune=native', ]
          jln_c_link_flags += ['-march=native', '-mtune=native', ]
        endif
      endif
      if (  ___jln_c_flags.get('linker', 'default') != 'default' )
        if (  ( ___jln_c_flags.get('linker', 'default') == 'lld' or ___jln_c_flags.get('linker', 'default') == 'native' ) )
          jln_c_link_flags += ['-fuse-ld=lld', ]
        else
          if (  ___jln_c_flags.get('linker', 'default') == 'mold' )
            jln_c_link_flags += ['-fuse-ld=mold', ]
          endif
        endif
      endif
    else
      if (  ___jln_c_compiler_id == 'intel-cl' )
        if (  ___jln_c_flags.get('warnings', 'default') != 'default' )
          if (  ___jln_c_flags.get('warnings', 'default') == 'off' )
            jln_c_c_flags += ['/w', ]
          else
            jln_c_c_flags += ['/W2', '/Qdiag-disable:1418,2259', ]
          endif
        endif
        if (  ___jln_c_flags.get('warnings_as_error', 'default') != 'default' )
          if (  ___jln_c_flags.get('warnings_as_error', 'default') == 'on' )
            jln_c_c_flags += ['/WX', ]
          else
            if (  ___jln_c_flags.get('warnings_as_error', 'default') == 'basic' )
              jln_c_c_flags += ['/Qdiag-error:1079,39,109', ]
            endif
          endif
        endif
        if (  ___jln_c_flags.get('windows_bigobj', 'default') != 'default' )
          jln_c_c_flags += ['/bigobj', ]
        endif
        if (  ___jln_c_flags.get('symbols', 'default') != 'default' )
          if (  ___jln_c_flags.get('symbols', 'default') == 'nodebug' )
            jln_c_c_flags += ['/debug:none', ]
          else
            if (  ___jln_c_flags.get('symbols', 'default') == 'minimal_debug' )
              jln_c_c_flags += ['/debug:minimal', ]
            else
              if (  ( ___jln_c_flags.get('symbols', 'default') == 'debug' or ___jln_c_flags.get('symbols', 'default') == 'full_debug' or ___jln_c_flags.get('symbols', 'default') == 'codeview' ) )
                jln_c_c_flags += ['/debug:full', ]
              endif
            endif
          endif
        endif
        if (  ___jln_c_flags.get('optimization', 'default') != 'default' )
          if (  ___jln_c_flags.get('optimization', 'default') == '0' )
            jln_c_c_flags += ['/Ob0', ]
          else
            if (  ___jln_c_flags.get('optimization', 'default') == 'g' )
              jln_c_c_flags += ['/Ob1', ]
            else
              jln_c_c_flags += ['/GF', ]
              if (  ___jln_c_flags.get('optimization', 'default') == '1' )
                jln_c_c_flags += ['/O1', ]
              else
                if (  ___jln_c_flags.get('optimization', 'default') == '2' )
                  jln_c_c_flags += ['/O2', ]
                else
                  if (  ___jln_c_flags.get('optimization', 'default') == '3' )
                    jln_c_c_flags += ['/O2', ]
                  else
                    if (  ___jln_c_flags.get('optimization', 'default') == 'z' )
                      jln_c_c_flags += ['/O3', ]
                    else
                      if (  ___jln_c_flags.get('optimization', 'default') == 'size' )
                        jln_c_c_flags += ['/Os', ]
                      else
                        jln_c_c_flags += ['/fast', ]
                      endif
                    endif
                  endif
                endif
              endif
            endif
          endif
        endif
        if (  ___jln_c_flags.get('hardened', 'default') != 'default' )
          if (  ___jln_c_flags.get('hardened', 'default') == 'off' )
            jln_c_c_flags += ['/GS-', ]
          else
            jln_c_c_flags += ['/GS', '/guard:cf', '/mconditional-branch:all-fix', '/Qcf-protection:full', ]
          endif
        endif
        if (  ___jln_c_flags.get('sanitizers', 'default') != 'default' )
          if (  ( ___jln_c_flags.get('sanitizers', 'default') == 'on' or ___jln_c_flags.get('sanitizers', 'default') == 'with_minimal_code_size' or ___jln_c_flags.get('sanitizers', 'default') == 'extra' or ___jln_c_flags.get('sanitizers', 'default') == 'extra_with_minimal_code_size' or ___jln_c_flags.get('sanitizers', 'default') == 'address' or ___jln_c_flags.get('sanitizers', 'default') == 'address_with_minimal_code_size' ) )
            jln_c_c_flags += ['/Qtrapuv', '/RTCsu', ]
            if (  ( ___jln_c_flags.get('sanitizers', 'default') == 'on' or ___jln_c_flags.get('sanitizers', 'default') == 'with_minimal_code_size' or ___jln_c_flags.get('sanitizers', 'default') == 'extra' or ___jln_c_flags.get('sanitizers', 'default') == 'extra_with_minimal_code_size' ) )
              jln_c_c_flags += ['/Qfp-stack-check', '/Qfp-trap:common', ]
            endif
          endif
        endif
        if (  ___jln_c_flags.get('cpu', 'default') != 'default' )
          if (  ___jln_c_flags.get('cpu', 'default') == 'generic' )
            jln_c_c_flags += ['/Qtune:generic', ]
            jln_c_link_flags += ['/Qtune:generic', ]
          else
            jln_c_c_flags += ['/QxHost', ]
            jln_c_link_flags += ['/QxHost', ]
          endif
        endif
      else
        if (  ___jln_c_compiler_id == 'intel' )
          if (  ___jln_c_flags.get('warnings', 'default') != 'default' )
            if (  ___jln_c_flags.get('warnings', 'default') == 'off' )
              jln_c_c_flags += ['-w', ]
            else
              if (  ___jln_c_flags.get('warnings', 'default') == 'essential' )
                jln_c_c_flags += ['-Wall', ]
              else
                jln_c_c_flags += ['-Wall', '-Warray-bounds', '-Wcast-qual', '-Wchar-subscripts', '-Wdisabled-optimization', '-Wenum-compare', '-Wextra', '-Wfloat-equal', '-Wformat-security', '-Wformat=2', '-Winit-self', '-Winvalid-pch', '-Wmaybe-uninitialized', '-Wmissing-include-dirs', '-Wnarrowing', '-Wnonnull', '-Wpointer-sign', '-Wreorder', '-Wsequence-point', '-Wtrigraphs', '-Wundef', '-Wunused-function', '-Wunused-but-set-variable', '-Wunused-variable', '-Wpointer-arith', '-Wold-style-definition', '-Wstrict-prototypes', '-Wwrite-strings', ]
              endif
            endif
          endif
          if (  ___jln_c_flags.get('switch_warnings', 'default') != 'default' )
            if (  ( ___jln_c_flags.get('switch_warnings', 'default') == 'on' or ___jln_c_flags.get('switch_warnings', 'default') == 'exhaustive_enum' ) )
              jln_c_c_flags += ['-Wswitch-enum', ]
            else
              if (  ___jln_c_flags.get('switch_warnings', 'default') == 'mandatory_default' )
                jln_c_c_flags += ['-Wswitch-default', ]
              else
                if (  ___jln_c_flags.get('switch_warnings', 'default') == 'exhaustive_enum_and_mandatory_default' )
                  jln_c_c_flags += ['-Wswitch', ]
                else
                  jln_c_c_flags += ['-Wno-switch', ]
                endif
              endif
            endif
          endif
          if (  ___jln_c_flags.get('warnings_as_error', 'default') != 'default' )
            if (  ___jln_c_flags.get('warnings_as_error', 'default') == 'on' )
              jln_c_c_flags += ['-Werror', ]
            else
              if (  ___jln_c_flags.get('warnings_as_error', 'default') == 'basic' )
                jln_c_c_flags += ['-diag-error=1079,39,109', ]
              endif
            endif
          endif
          if (  ___jln_c_flags.get('pedantic', 'default') != 'default' )
            if (  ___jln_c_flags.get('pedantic', 'default') == 'off' )
              jln_c_c_flags += ['-fgnu-keywords', ]
            else
              jln_c_c_flags += ['-fno-gnu-keywords', '/Zc:inline', '/Zc:strictStrings', '/Zc:throwingNew', ]
            endif
          endif
          if (  ___jln_c_flags.get('shadow_warnings', 'default') != 'default' )
            if (  ___jln_c_flags.get('shadow_warnings', 'default') == 'off' )
              jln_c_c_flags += ['-Wno-shadow', ]
            else
              if (  ( ___jln_c_flags.get('shadow_warnings', 'default') == 'on' or ___jln_c_flags.get('shadow_warnings', 'default') == 'all' ) )
                jln_c_c_flags += ['-Wshadow', ]
              endif
            endif
          endif
          if (  ___jln_c_flags.get('symbols', 'default') != 'default' )
            if (  ___jln_c_flags.get('symbols', 'default') == 'nodebug' )
              jln_c_c_flags += ['-g0', ]
            else
              if (  ___jln_c_flags.get('symbols', 'default') == 'hidden' )
                jln_c_c_flags += ['-fvisibility=hidden', ]
              else
                if (  ___jln_c_flags.get('symbols', 'default') == 'debug' )
                  jln_c_c_flags += ['-g', ]
                else
                  if (  ___jln_c_flags.get('symbols', 'default') == 'minimal_debug' )
                    jln_c_c_flags += ['-g1', ]
                  else
                    if (  ___jln_c_flags.get('symbols', 'default') == 'full_debug' )
                      jln_c_c_flags += ['-g3', ]
                    endif
                  endif
                endif
              endif
            endif
          endif
          if (  ___jln_c_flags.get('optimization', 'default') != 'default' )
            if (  ___jln_c_flags.get('optimization', 'default') == '0' )
              jln_c_c_flags += ['-O0', ]
            else
              if (  ___jln_c_flags.get('optimization', 'default') == 'g' )
                jln_c_c_flags += ['-O1', ]
              else
                if (  ___jln_c_flags.get('optimization', 'default') == '1' )
                  jln_c_c_flags += ['-O1', ]
                else
                  if (  ___jln_c_flags.get('optimization', 'default') == '2' )
                    jln_c_c_flags += ['-O2', ]
                  else
                    if (  ___jln_c_flags.get('optimization', 'default') == '3' )
                      jln_c_c_flags += ['-O3', ]
                    else
                      if (  ___jln_c_flags.get('optimization', 'default') == 'z' )
                        jln_c_c_flags += ['-fast', ]
                      else
                        if (  ___jln_c_flags.get('optimization', 'default') == 'size' )
                          jln_c_c_flags += ['-Os', ]
                        else
                          jln_c_c_flags += ['-Ofast', ]
                        endif
                      endif
                    endif
                  endif
                endif
              endif
            endif
          endif
          if (  ___jln_c_flags.get('hardened', 'default') != 'default' )
            if (  ( ___jln_c_flags.get('hardened', 'default') == 'on' or ___jln_c_flags.get('hardened', 'default') == 'all' ) )
              jln_c_c_flags += ['-D_FORTIFY_SOURCE=2', ]
              if (  ___jln_c_flags.get('hardened', 'default') == 'all' )
                jln_c_c_flags += ['-fstack-protector-all', ]
              else
                jln_c_c_flags += ['-fstack-protector-strong', ]
              endif
              jln_c_c_flags += ['-fcf-protection=full', ]
              jln_c_link_flags += ['-Xlinker-zrelro', '-Xlinker-znow', '-Xlinker-znoexecstack', ]
            endif
          endif
          if (  ___jln_c_flags.get('sanitizers', 'default') != 'default' )
            if (  ( ___jln_c_flags.get('sanitizers', 'default') == 'on' or ___jln_c_flags.get('sanitizers', 'default') == 'with_minimal_code_size' or ___jln_c_flags.get('sanitizers', 'default') == 'extra' or ___jln_c_flags.get('sanitizers', 'default') == 'extra_with_minimal_code_size' or ___jln_c_flags.get('sanitizers', 'default') == 'address' or ___jln_c_flags.get('sanitizers', 'default') == 'address_with_minimal_code_size' ) )
              jln_c_c_flags += ['-ftrapuv', ]
              if (  ( ___jln_c_flags.get('sanitizers', 'default') == 'on' or ___jln_c_flags.get('sanitizers', 'default') == 'with_minimal_code_size' or ___jln_c_flags.get('sanitizers', 'default') == 'extra' or ___jln_c_flags.get('sanitizers', 'default') == 'extra_with_minimal_code_size' ) )
                jln_c_c_flags += ['-fp-stack-check', '-fp-trap=common', ]
              endif
            endif
          endif
          if (  ___jln_c_flags.get('linker', 'default') != 'default' )
            if (  ___jln_c_flags.get('linker', 'default') == 'bfd' )
              jln_c_link_flags += ['-fuse-ld=bfd', ]
            else
              if (  ___jln_c_flags.get('linker', 'default') == 'gold' )
                jln_c_link_flags += ['-fuse-ld=gold', ]
              else
                if (  ___jln_c_flags.get('linker', 'default') == 'mold' )
                  jln_c_link_flags += ['-fuse-ld=mold', ]
                else
                  jln_c_link_flags += ['-fuse-ld=lld', ]
                endif
              endif
            endif
          endif
          if (  ___jln_c_flags.get('lto', 'default') != 'default' )
            if (  ___jln_c_flags.get('lto', 'default') == 'off' )
              jln_c_c_flags += ['-no-ipo', ]
              jln_c_link_flags += ['-no-ipo', ]
            else
              if (  ___jln_c_flags.get('lto', 'default') != 'thin_or_nothing' )
                jln_c_c_flags += ['-ipo', ]
                jln_c_link_flags += ['-ipo', ]
              endif
            endif
          endif
          if (  ___jln_c_flags.get('exceptions', 'default') != 'default' )
            if (  ___jln_c_flags.get('exceptions', 'default') == 'on' )
              jln_c_c_flags += ['-fexceptions', ]
            else
              jln_c_c_flags += ['-fno-exceptions', ]
            endif
          endif
          if (  ___jln_c_flags.get('cpu', 'default') != 'default' )
            if (  ___jln_c_flags.get('cpu', 'default') == 'generic' )
              jln_c_c_flags += ['-mtune=generic', ]
              jln_c_link_flags += ['-mtune=generic', ]
            else
              jln_c_c_flags += ['-xHost', ]
              jln_c_link_flags += ['-xHost', ]
            endif
          endif
        else
          if (  (host_machine.system() == 'windows' and ___jln_c_compiler_id == 'gcc') )
            if (  ___jln_c_flags.get('windows_bigobj', 'default') != 'default' )
              jln_c_c_flags += ['-Wa,-mbig-obj', ]
            endif
          endif
        endif
      endif
    endif
  endif

  jln_c_custom_c_flags += [jln_c_c_flags]
  jln_c_custom_link_flags += [jln_c_link_flags]
endforeach
