--  ```lua
--  -- launch example: xmake f --jln-sanitizers=on
--
--  includes'cpp'
--
--  -- Registers new command-line options and set default values
--  jln_cxx_init_options({warnings='very_strict', warnings_as_error='basic'})
--
--  -- Set options for a specific mode (see also jln_cxx_rule())
--  -- When the first parameter is nil or unspecified, a default configuration is used.
--  jln_cxx_init_modes({
--    debug={
--      stl_hardening='debug_with_broken_abi',
--    },
--    release={
--      function() ... end, -- callback for release mode
--      lto='on',
--    },
--    -- ...
--  })
--
--  target('hello1')
--    set_kind('binary')
--    add_files('src/hello.cpp')
--
--
--
--  -- Create a new rule. Options are added to the current configuration
--  jln_cxx_rule('custom_rule', {warnings_as_error='on'})
--
--  target('hello2')
--    set_kind('binary')
--    add_rules('custom_rule')
--    add_files('src/hello.cpp')
--
--
--
--  target('hello3')
--    set_kind('binary')
--    -- Custom configuration when jln_cxx_rule() or jln_cxx_modes() are not enough
--    on_load(function(target)
--      import'cpp.flags'
--      -- see also get_flags() and create_options()
--      local flags = flags.set_flags(target, {elide_type='on'})
--      print(flags)
--    end)
--    add_files('src/hello.cpp')
--
--
--  -- NOTE: for C, jln_cxx_ prefix become jln_c_
--  ```
--
--
--  # Options
--
--  Supported options are listed below by category.
--  The same option can be found in several categories.
--
--  For a full description of options and values,
--  see [C++ Compiler Options reference](https://jonathanpoelen.github.io/cpp-compiler-options/)
--  or use the `list_options.lua` generator.
--
--  The first value corresponds to the one used by default,
--  and the value `default` has no associated behavior.
--
--  Options with a default value other than `default` are listed below.
--
--  <!-- ./compiler-options.lua generators/list_options.lua --color --categorized -->
--  ```ini
--  # Warning options:
--
--  warnings = on default off essential extensive
--  warnings_as_error = default off on basic
--  bidi_char_warnings = any default any_and_ucn unpaired unpaired_and_ucn
--  conversion_warnings = on default off sign float conversion all
--  covered_switch_default_warnings = on default off
--  msvc_crt_secure_no_warnings = on default off
--  noexcept_warnings = default off on
--  reproducible_build_warnings = default off on
--  shadow_warnings = off default on local compatible_local all
--  suggest_attributes = on default off common analysis unity all
--  switch_warnings = on default off exhaustive_enum mandatory_default exhaustive_enum_and_mandatory_default
--  unsafe_buffer_usage_warnings = default on off
--  windows_abi_compatibility_warnings = off default on
--
--
--  # Pedantic options:
--
--  pedantic = on default off as_error
--  stl_fix = on default off
--
--
--  # Debug options:
--
--  symbols = default hidden strip_all gc_sections nodebug debug minimal_debug full_debug btf codeview ctf ctf1 ctf2 vms vms1 vms2 vms3 dbx lldb sce dwarf
--  stl_hardening = default off fast extensive debug debug_with_broken_abi
--  sanitizers = default off on with_minimal_code_size extra extra_with_minimal_code_size address address_with_minimal_code_size thread undefined undefined_minimal_runtime scudo_hardened_allocator
--  var_init = default uninitialized pattern zero
--  emcc_debug = default off on slow
--  ndebug = with_optimization_1_or_above default off on
--  optimization = default 0 g 1 2 3 fast size z
--
--
--  # Optimization options:
--
--  cpu = default generic native
--  lto = default off on full thin_or_nothing whole_program whole_program_and_full_lto
--  optimization = default 0 g 1 2 3 fast size z
--  optimization_warnings = default off on
--
--
--  # C++ options:
--
--  exceptions = default off on
--  rtti = default off on
--
--
--  # Hardening options:
--
--  hardened = default off on all
--  stl_hardening = default off fast extensive debug debug_with_broken_abi
--
--
--  # Static Analyzer options:
--
--  analyzer = default off on with_external_headers
--  analyzer_too_complex_warning = default off on
--  analyzer_verbosity = default 0 1 2 3
--
--
--  # Other options:
--
--  color = default auto never always
--  coverage = default off on
--  diagnostics_format = default fixits patch print_source_range_info
--  diagnostics_show_template = default tree without_elided_types tree_without_elided_types
--  linker = default bfd gold lld mold native
--  msvc_diagnostics_format = caret default classic column
--  msvc_isystem = default anglebrackets include_and_caexcludepath external_as_include_system_flag assumed
--  msvc_isystem_with_template_instantiations_treated_as_non_external = default off on
--  windows_bigobj = on default
--  ```
--  <!-- ./compiler-options.lua -->
--
--  If not specified:
--
--  - `bidi_char_warnings` is `any`
--  - `msvc_diagnostics_format` is `caret`
--  - `ndebug` is `with_optimization_1_or_above`
--  - The following values are `off`:
--    - `shadow_warnings`
--    - `windows_abi_compatibility_warnings`
--  - The following values are `on`:
--    - `conversion_warnings`
--    - `covered_switch_default_warnings`
--    - `msvc_crt_secure_no_warnings`
--    - `pedantic`
--    - `stl_fix`
--    - `suggest_attributes`
--    - `switch_warnings`
--    - `warnings`
--    - `windows_bigobj`
--
--  <!-- enddefault -->
--
--  ## To know
--
--  - `msvc_isystem=external_as_include_system_flag` is only available with `cmake`.
--  - `stl_hardening=debug`
--    - msvc: unlike `stl_hardening=debug_with_broken_abi`, STL debugging is not enabled by this option, as it breaks the ABI (only hardening mode is enabled on recent versions). However, as the `_DEBUG` macro can be defined in many different ways, STL debugging can be activated and the ABI broken.
--
--
--  ## Sanitizers
--
--  Some sanitizers activated at compile time are only realistically active in the presence of a configuration in an environment variable.
--  `sanitizers=on` does not include these sanitizers, unlike `sanitizers=extra`.
--  The environment variables to use are as follows:
--
--  ```sh
--  # cl (Windows)
--  ASAN_OPTIONS=detect_stack_use_after_return=1
--
--  # gcc / clang (see -fsanitize=pointer-subtract and -fsanitize=pointer-compare)
--  ASAN_OPTIONS=detect_invalid_pointer_pairs=2
--
--  # macOS
--  ASAN_OPTIONS=detect_leaks=1
--  ```
--
--  See
--  [AddressSanitizer](https://github.com/google/sanitizers/wiki/AddressSanitizer),
--  [UndefinedBehaviorSanitizer](https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html),
--  [-fsanitize=pointer-compare](https://gcc.gnu.org/onlinedocs/gcc/Instrumentation-Options.html#index-fsanitize_003dpointer-compare) with GCC and
--  [-fsanitize-address-use-after-return](https://learn.microsoft.com/en-us/cpp/sanitizers/asan-building#fsanitize-address-use-after-return-compiler-option-experimental) with cl compiler
--  for more details.
--
--  See [AddressSanitizer Flags](https://github.com/google/sanitizers/wiki/AddressSanitizerFlags#run-time-flags)
--  for a list of supported options.
--  A useful pre-set to enable more aggressive diagnostics compared to the default behavior is given below:
--
--  ```sh
--  ASAN_OPTIONS=\
--  strict_string_checks=1:\
--  detect_stack_use_after_return=1:\
--  check_initialization_order=1:\
--  strict_init_order=1:\
--  alloc_dealloc_mismatch=1
--  ```
--
--  ## Recommended options
--
--  Some of the recommendations here are already made by build systems.
--  These include `ndebug`, `symbols` and `optimization`.
--
--  category | options
--  ---------|---------
--  debug | `emcc_debug=on` or `slow` (useless if Emscripten is not used)<br>`optimization=g` or `default`<br>`sanitizers=on` or `with_minimal_code_size`<br>`stl_hardening=debug_with_broken_abi` or `debug`<br>`symbols=debug` or `full_debug`<br>`var_init=pattern`
--  release | `cpu=native`<br>`lto=on`<br>`ndebug=on`<br>`optimization=3`<br>`rtti=off`<br>`symbols=strip_all`
--  security | `hardened=on`<br>`stl_hardening=fast` or `extensive`
--  really strict warnings | `pedantic=as_error`<br>`suggest_attributes=common`<br>`warnings=extensive`<br>`conversion_warnings=all`<br>`shadow_warnings=local`<br>`switch_warnings=exhaustive_enum`<br>`windows_abi_compatibility_warnings=on`
--
--  

-- File generated with https://github.com/jonathanpoelen/cpp-compiler-options

local _extraopt_flag_names = {
  ["jln-cxx"] = true,
  ["cxx"] = true,
  ["jln-cxx-version"] = true,
  ["cxx_version"] = true,
  ["jln-ld"] = true,
  ["ld"] = true,
}

local _flag_names = {
  ["jln-analyzer"] = {["default"]="", ["off"]="off", ["on"]="on", ["with_external_headers"]="with_external_headers", [""]=""},
  ["analyzer"] = {["default"]="", ["off"]="off", ["on"]="on", ["with_external_headers"]="with_external_headers", [""]=""},
  ["jln-analyzer-too-complex-warning"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["analyzer_too_complex_warning"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["jln-analyzer-verbosity"] = {["default"]="", ["0"]="0", ["1"]="1", ["2"]="2", ["3"]="3", [""]=""},
  ["analyzer_verbosity"] = {["default"]="", ["0"]="0", ["1"]="1", ["2"]="2", ["3"]="3", [""]=""},
  ["jln-bidi-char-warnings"] = {["default"]="", ["any"]="any", ["any_and_ucn"]="any_and_ucn", ["unpaired"]="unpaired", ["unpaired_and_ucn"]="unpaired_and_ucn", [""]=""},
  ["bidi_char_warnings"] = {["default"]="", ["any"]="any", ["any_and_ucn"]="any_and_ucn", ["unpaired"]="unpaired", ["unpaired_and_ucn"]="unpaired_and_ucn", [""]=""},
  ["jln-color"] = {["default"]="", ["auto"]="auto", ["never"]="never", ["always"]="always", [""]=""},
  ["color"] = {["default"]="", ["auto"]="auto", ["never"]="never", ["always"]="always", [""]=""},
  ["jln-conversion-warnings"] = {["default"]="", ["off"]="off", ["on"]="on", ["sign"]="sign", ["float"]="float", ["conversion"]="conversion", ["all"]="all", [""]=""},
  ["conversion_warnings"] = {["default"]="", ["off"]="off", ["on"]="on", ["sign"]="sign", ["float"]="float", ["conversion"]="conversion", ["all"]="all", [""]=""},
  ["jln-coverage"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["coverage"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["jln-covered-switch-default-warnings"] = {["default"]="", ["on"]="on", ["off"]="off", [""]=""},
  ["covered_switch_default_warnings"] = {["default"]="", ["on"]="on", ["off"]="off", [""]=""},
  ["jln-cpu"] = {["default"]="", ["generic"]="generic", ["native"]="native", [""]=""},
  ["cpu"] = {["default"]="", ["generic"]="generic", ["native"]="native", [""]=""},
  ["jln-diagnostics-format"] = {["default"]="", ["fixits"]="fixits", ["patch"]="patch", ["print_source_range_info"]="print_source_range_info", [""]=""},
  ["diagnostics_format"] = {["default"]="", ["fixits"]="fixits", ["patch"]="patch", ["print_source_range_info"]="print_source_range_info", [""]=""},
  ["jln-diagnostics-show-template"] = {["default"]="", ["tree"]="tree", ["without_elided_types"]="without_elided_types", ["tree_without_elided_types"]="tree_without_elided_types", [""]=""},
  ["diagnostics_show_template"] = {["default"]="", ["tree"]="tree", ["without_elided_types"]="without_elided_types", ["tree_without_elided_types"]="tree_without_elided_types", [""]=""},
  ["jln-emcc-debug"] = {["default"]="", ["off"]="off", ["on"]="on", ["slow"]="slow", [""]=""},
  ["emcc_debug"] = {["default"]="", ["off"]="off", ["on"]="on", ["slow"]="slow", [""]=""},
  ["jln-exceptions"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["exceptions"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["jln-hardened"] = {["default"]="", ["off"]="off", ["on"]="on", ["all"]="all", [""]=""},
  ["hardened"] = {["default"]="", ["off"]="off", ["on"]="on", ["all"]="all", [""]=""},
  ["jln-linker"] = {["default"]="", ["bfd"]="bfd", ["gold"]="gold", ["lld"]="lld", ["mold"]="mold", ["native"]="native", [""]=""},
  ["linker"] = {["default"]="", ["bfd"]="bfd", ["gold"]="gold", ["lld"]="lld", ["mold"]="mold", ["native"]="native", [""]=""},
  ["jln-lto"] = {["default"]="", ["off"]="off", ["on"]="on", ["full"]="full", ["thin_or_nothing"]="thin_or_nothing", ["whole_program"]="whole_program", ["whole_program_and_full_lto"]="whole_program_and_full_lto", [""]=""},
  ["lto"] = {["default"]="", ["off"]="off", ["on"]="on", ["full"]="full", ["thin_or_nothing"]="thin_or_nothing", ["whole_program"]="whole_program", ["whole_program_and_full_lto"]="whole_program_and_full_lto", [""]=""},
  ["jln-msvc-crt-secure-no-warnings"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["msvc_crt_secure_no_warnings"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["jln-msvc-diagnostics-format"] = {["default"]="", ["classic"]="classic", ["column"]="column", ["caret"]="caret", [""]=""},
  ["msvc_diagnostics_format"] = {["default"]="", ["classic"]="classic", ["column"]="column", ["caret"]="caret", [""]=""},
  ["jln-msvc-isystem"] = {["default"]="", ["anglebrackets"]="anglebrackets", ["include_and_caexcludepath"]="include_and_caexcludepath", ["assumed"]="assumed", [""]=""},
  ["msvc_isystem"] = {["default"]="", ["anglebrackets"]="anglebrackets", ["include_and_caexcludepath"]="include_and_caexcludepath", ["assumed"]="assumed", [""]=""},
  ["jln-msvc-isystem-with-template-instantiations-treated-as-non-external"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["msvc_isystem_with_template_instantiations_treated_as_non_external"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["jln-ndebug"] = {["default"]="", ["off"]="off", ["on"]="on", ["with_optimization_1_or_above"]="with_optimization_1_or_above", [""]=""},
  ["ndebug"] = {["default"]="", ["off"]="off", ["on"]="on", ["with_optimization_1_or_above"]="with_optimization_1_or_above", [""]=""},
  ["jln-noexcept-warnings"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["noexcept_warnings"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["jln-optimization"] = {["default"]="", ["0"]="0", ["g"]="g", ["1"]="1", ["2"]="2", ["3"]="3", ["fast"]="fast", ["size"]="size", ["z"]="z", [""]=""},
  ["optimization"] = {["default"]="", ["0"]="0", ["g"]="g", ["1"]="1", ["2"]="2", ["3"]="3", ["fast"]="fast", ["size"]="size", ["z"]="z", [""]=""},
  ["jln-optimization-warnings"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["optimization_warnings"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["jln-pedantic"] = {["default"]="", ["off"]="off", ["on"]="on", ["as_error"]="as_error", [""]=""},
  ["pedantic"] = {["default"]="", ["off"]="off", ["on"]="on", ["as_error"]="as_error", [""]=""},
  ["jln-reproducible-build-warnings"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["reproducible_build_warnings"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["jln-rtti"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["rtti"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["jln-sanitizers"] = {["default"]="", ["off"]="off", ["on"]="on", ["with_minimal_code_size"]="with_minimal_code_size", ["extra"]="extra", ["extra_with_minimal_code_size"]="extra_with_minimal_code_size", ["address"]="address", ["address_with_minimal_code_size"]="address_with_minimal_code_size", ["thread"]="thread", ["undefined"]="undefined", ["undefined_minimal_runtime"]="undefined_minimal_runtime", ["scudo_hardened_allocator"]="scudo_hardened_allocator", [""]=""},
  ["sanitizers"] = {["default"]="", ["off"]="off", ["on"]="on", ["with_minimal_code_size"]="with_minimal_code_size", ["extra"]="extra", ["extra_with_minimal_code_size"]="extra_with_minimal_code_size", ["address"]="address", ["address_with_minimal_code_size"]="address_with_minimal_code_size", ["thread"]="thread", ["undefined"]="undefined", ["undefined_minimal_runtime"]="undefined_minimal_runtime", ["scudo_hardened_allocator"]="scudo_hardened_allocator", [""]=""},
  ["jln-shadow-warnings"] = {["default"]="", ["off"]="off", ["on"]="on", ["local"]="local", ["compatible_local"]="compatible_local", ["all"]="all", [""]=""},
  ["shadow_warnings"] = {["default"]="", ["off"]="off", ["on"]="on", ["local"]="local", ["compatible_local"]="compatible_local", ["all"]="all", [""]=""},
  ["jln-stl-fix"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["stl_fix"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["jln-stl-hardening"] = {["default"]="", ["off"]="off", ["fast"]="fast", ["extensive"]="extensive", ["debug"]="debug", ["debug_with_broken_abi"]="debug_with_broken_abi", [""]=""},
  ["stl_hardening"] = {["default"]="", ["off"]="off", ["fast"]="fast", ["extensive"]="extensive", ["debug"]="debug", ["debug_with_broken_abi"]="debug_with_broken_abi", [""]=""},
  ["jln-suggest-attributes"] = {["default"]="", ["off"]="off", ["on"]="on", ["common"]="common", ["analysis"]="analysis", ["unity"]="unity", ["all"]="all", [""]=""},
  ["suggest_attributes"] = {["default"]="", ["off"]="off", ["on"]="on", ["common"]="common", ["analysis"]="analysis", ["unity"]="unity", ["all"]="all", [""]=""},
  ["jln-switch-warnings"] = {["default"]="", ["on"]="on", ["off"]="off", ["exhaustive_enum"]="exhaustive_enum", ["mandatory_default"]="mandatory_default", ["exhaustive_enum_and_mandatory_default"]="exhaustive_enum_and_mandatory_default", [""]=""},
  ["switch_warnings"] = {["default"]="", ["on"]="on", ["off"]="off", ["exhaustive_enum"]="exhaustive_enum", ["mandatory_default"]="mandatory_default", ["exhaustive_enum_and_mandatory_default"]="exhaustive_enum_and_mandatory_default", [""]=""},
  ["jln-symbols"] = {["default"]="", ["hidden"]="hidden", ["strip_all"]="strip_all", ["gc_sections"]="gc_sections", ["nodebug"]="nodebug", ["debug"]="debug", ["minimal_debug"]="minimal_debug", ["full_debug"]="full_debug", ["btf"]="btf", ["codeview"]="codeview", ["ctf"]="ctf", ["ctf1"]="ctf1", ["ctf2"]="ctf2", ["vms"]="vms", ["vms1"]="vms1", ["vms2"]="vms2", ["vms3"]="vms3", ["dbx"]="dbx", ["lldb"]="lldb", ["sce"]="sce", ["dwarf"]="dwarf", [""]=""},
  ["symbols"] = {["default"]="", ["hidden"]="hidden", ["strip_all"]="strip_all", ["gc_sections"]="gc_sections", ["nodebug"]="nodebug", ["debug"]="debug", ["minimal_debug"]="minimal_debug", ["full_debug"]="full_debug", ["btf"]="btf", ["codeview"]="codeview", ["ctf"]="ctf", ["ctf1"]="ctf1", ["ctf2"]="ctf2", ["vms"]="vms", ["vms1"]="vms1", ["vms2"]="vms2", ["vms3"]="vms3", ["dbx"]="dbx", ["lldb"]="lldb", ["sce"]="sce", ["dwarf"]="dwarf", [""]=""},
  ["jln-unsafe-buffer-usage-warnings"] = {["default"]="", ["on"]="on", ["off"]="off", [""]=""},
  ["unsafe_buffer_usage_warnings"] = {["default"]="", ["on"]="on", ["off"]="off", [""]=""},
  ["jln-var-init"] = {["default"]="", ["uninitialized"]="uninitialized", ["pattern"]="pattern", ["zero"]="zero", [""]=""},
  ["var_init"] = {["default"]="", ["uninitialized"]="uninitialized", ["pattern"]="pattern", ["zero"]="zero", [""]=""},
  ["jln-warnings"] = {["default"]="", ["off"]="off", ["on"]="on", ["essential"]="essential", ["extensive"]="extensive", [""]=""},
  ["warnings"] = {["default"]="", ["off"]="off", ["on"]="on", ["essential"]="essential", ["extensive"]="extensive", [""]=""},
  ["jln-warnings-as-error"] = {["default"]="", ["off"]="off", ["on"]="on", ["basic"]="basic", [""]=""},
  ["warnings_as_error"] = {["default"]="", ["off"]="off", ["on"]="on", ["basic"]="basic", [""]=""},
  ["jln-windows-abi-compatibility-warnings"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["windows_abi_compatibility_warnings"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["jln-windows-bigobj"] = {["default"]="", ["on"]="on", [""]=""},
  ["windows_bigobj"] = {["default"]="", ["on"]="on", [""]=""},
}


import'core.platform.platform'
import'lib.detect'

local _get_extra = function(opt)
  local x = get_config(opt)
  return x ~= '' and x or nil
end

local _check_flags = function(d)
  for k,v in pairs(d) do
    local ref = _flag_names[k]
    if not ref then
      if not _extraopt_flag_names[k] then
        os.raise(vformat("${color.error}cpp-compiler-options: Unknown key: '%s'", k))
      end
    elseif not ref[v] then
      os.raise(vformat("${color.error}cpp-compiler-options: Unknown value '%s' for '%s'", v, k))
    end
  end
end

-- Returns the merge of the default options and options parameter
-- `options`: table. ex: {warnings='on'}
-- `options` can have 3 additional fields:
--  - `cxx`: compiler name (otherwise deducted from --cxx and --toolchain)
--  - `cxx_version`: compiler version (otherwise deducted from cxx). ex: '7', '7.2'
--  - `ld`: linker name
-- `extra_options` = {
--   disable_other_options: bool = false
-- }
function create_options(options, extra_options)
  if options then
    _check_flags(options)
    local disable_other_options = extra_options and extra_options.disable_other_options
    return {
      analyzer = options.analyzer or options["jln-analyzer"] or (disable_other_options and "" or _flag_names.analyzer[get_config("jln-analyzer")]),
      analyzer_too_complex_warning = options.analyzer_too_complex_warning or options["jln-analyzer-too-complex-warning"] or (disable_other_options and "" or _flag_names.analyzer_too_complex_warning[get_config("jln-analyzer-too-complex-warning")]),
      analyzer_verbosity = options.analyzer_verbosity or options["jln-analyzer-verbosity"] or (disable_other_options and "" or _flag_names.analyzer_verbosity[get_config("jln-analyzer-verbosity")]),
      bidi_char_warnings = options.bidi_char_warnings or options["jln-bidi-char-warnings"] or (disable_other_options and "" or _flag_names.bidi_char_warnings[get_config("jln-bidi-char-warnings")]),
      color = options.color or options["jln-color"] or (disable_other_options and "" or _flag_names.color[get_config("jln-color")]),
      conversion_warnings = options.conversion_warnings or options["jln-conversion-warnings"] or (disable_other_options and "" or _flag_names.conversion_warnings[get_config("jln-conversion-warnings")]),
      coverage = options.coverage or options["jln-coverage"] or (disable_other_options and "" or _flag_names.coverage[get_config("jln-coverage")]),
      covered_switch_default_warnings = options.covered_switch_default_warnings or options["jln-covered-switch-default-warnings"] or (disable_other_options and "" or _flag_names.covered_switch_default_warnings[get_config("jln-covered-switch-default-warnings")]),
      cpu = options.cpu or options["jln-cpu"] or (disable_other_options and "" or _flag_names.cpu[get_config("jln-cpu")]),
      diagnostics_format = options.diagnostics_format or options["jln-diagnostics-format"] or (disable_other_options and "" or _flag_names.diagnostics_format[get_config("jln-diagnostics-format")]),
      diagnostics_show_template = options.diagnostics_show_template or options["jln-diagnostics-show-template"] or (disable_other_options and "" or _flag_names.diagnostics_show_template[get_config("jln-diagnostics-show-template")]),
      emcc_debug = options.emcc_debug or options["jln-emcc-debug"] or (disable_other_options and "" or _flag_names.emcc_debug[get_config("jln-emcc-debug")]),
      exceptions = options.exceptions or options["jln-exceptions"] or (disable_other_options and "" or _flag_names.exceptions[get_config("jln-exceptions")]),
      hardened = options.hardened or options["jln-hardened"] or (disable_other_options and "" or _flag_names.hardened[get_config("jln-hardened")]),
      linker = options.linker or options["jln-linker"] or (disable_other_options and "" or _flag_names.linker[get_config("jln-linker")]),
      lto = options.lto or options["jln-lto"] or (disable_other_options and "" or _flag_names.lto[get_config("jln-lto")]),
      msvc_crt_secure_no_warnings = options.msvc_crt_secure_no_warnings or options["jln-msvc-crt-secure-no-warnings"] or (disable_other_options and "" or _flag_names.msvc_crt_secure_no_warnings[get_config("jln-msvc-crt-secure-no-warnings")]),
      msvc_diagnostics_format = options.msvc_diagnostics_format or options["jln-msvc-diagnostics-format"] or (disable_other_options and "" or _flag_names.msvc_diagnostics_format[get_config("jln-msvc-diagnostics-format")]),
      msvc_isystem = options.msvc_isystem or options["jln-msvc-isystem"] or (disable_other_options and "" or _flag_names.msvc_isystem[get_config("jln-msvc-isystem")]),
      msvc_isystem_with_template_instantiations_treated_as_non_external = options.msvc_isystem_with_template_instantiations_treated_as_non_external or options["jln-msvc-isystem-with-template-instantiations-treated-as-non-external"] or (disable_other_options and "" or _flag_names.msvc_isystem_with_template_instantiations_treated_as_non_external[get_config("jln-msvc-isystem-with-template-instantiations-treated-as-non-external")]),
      ndebug = options.ndebug or options["jln-ndebug"] or (disable_other_options and "" or _flag_names.ndebug[get_config("jln-ndebug")]),
      noexcept_warnings = options.noexcept_warnings or options["jln-noexcept-warnings"] or (disable_other_options and "" or _flag_names.noexcept_warnings[get_config("jln-noexcept-warnings")]),
      optimization = options.optimization or options["jln-optimization"] or (disable_other_options and "" or _flag_names.optimization[get_config("jln-optimization")]),
      optimization_warnings = options.optimization_warnings or options["jln-optimization-warnings"] or (disable_other_options and "" or _flag_names.optimization_warnings[get_config("jln-optimization-warnings")]),
      pedantic = options.pedantic or options["jln-pedantic"] or (disable_other_options and "" or _flag_names.pedantic[get_config("jln-pedantic")]),
      reproducible_build_warnings = options.reproducible_build_warnings or options["jln-reproducible-build-warnings"] or (disable_other_options and "" or _flag_names.reproducible_build_warnings[get_config("jln-reproducible-build-warnings")]),
      rtti = options.rtti or options["jln-rtti"] or (disable_other_options and "" or _flag_names.rtti[get_config("jln-rtti")]),
      sanitizers = options.sanitizers or options["jln-sanitizers"] or (disable_other_options and "" or _flag_names.sanitizers[get_config("jln-sanitizers")]),
      shadow_warnings = options.shadow_warnings or options["jln-shadow-warnings"] or (disable_other_options and "" or _flag_names.shadow_warnings[get_config("jln-shadow-warnings")]),
      stl_fix = options.stl_fix or options["jln-stl-fix"] or (disable_other_options and "" or _flag_names.stl_fix[get_config("jln-stl-fix")]),
      stl_hardening = options.stl_hardening or options["jln-stl-hardening"] or (disable_other_options and "" or _flag_names.stl_hardening[get_config("jln-stl-hardening")]),
      suggest_attributes = options.suggest_attributes or options["jln-suggest-attributes"] or (disable_other_options and "" or _flag_names.suggest_attributes[get_config("jln-suggest-attributes")]),
      switch_warnings = options.switch_warnings or options["jln-switch-warnings"] or (disable_other_options and "" or _flag_names.switch_warnings[get_config("jln-switch-warnings")]),
      symbols = options.symbols or options["jln-symbols"] or (disable_other_options and "" or _flag_names.symbols[get_config("jln-symbols")]),
      unsafe_buffer_usage_warnings = options.unsafe_buffer_usage_warnings or options["jln-unsafe-buffer-usage-warnings"] or (disable_other_options and "" or _flag_names.unsafe_buffer_usage_warnings[get_config("jln-unsafe-buffer-usage-warnings")]),
      var_init = options.var_init or options["jln-var-init"] or (disable_other_options and "" or _flag_names.var_init[get_config("jln-var-init")]),
      warnings = options.warnings or options["jln-warnings"] or (disable_other_options and "" or _flag_names.warnings[get_config("jln-warnings")]),
      warnings_as_error = options.warnings_as_error or options["jln-warnings-as-error"] or (disable_other_options and "" or _flag_names.warnings_as_error[get_config("jln-warnings-as-error")]),
      windows_abi_compatibility_warnings = options.windows_abi_compatibility_warnings or options["jln-windows-abi-compatibility-warnings"] or (disable_other_options and "" or _flag_names.windows_abi_compatibility_warnings[get_config("jln-windows-abi-compatibility-warnings")]),
      windows_bigobj = options.windows_bigobj or options["jln-windows-bigobj"] or (disable_other_options and "" or _flag_names.windows_bigobj[get_config("jln-windows-bigobj")]),
      cxx = options.cxx or options["jln-cxx"] or (not disable_other_options and _get_extra("jln-cxx")) or nil,
      cxx_version = options.cxx_version or options["jln-cxx-version"] or (not disable_other_options and _get_extra("jln-cxx-version")) or nil,
      ld = options.ld or options["jln-ld"] or (not disable_other_options and _get_extra("jln-ld")) or nil,
    }
  else
    return {
      ["analyzer"] = _flag_names["analyzer"][get_config("jln-analyzer")],
      ["analyzer_too_complex_warning"] = _flag_names["analyzer_too_complex_warning"][get_config("jln-analyzer-too-complex-warning")],
      ["analyzer_verbosity"] = _flag_names["analyzer_verbosity"][get_config("jln-analyzer-verbosity")],
      ["bidi_char_warnings"] = _flag_names["bidi_char_warnings"][get_config("jln-bidi-char-warnings")],
      ["color"] = _flag_names["color"][get_config("jln-color")],
      ["conversion_warnings"] = _flag_names["conversion_warnings"][get_config("jln-conversion-warnings")],
      ["coverage"] = _flag_names["coverage"][get_config("jln-coverage")],
      ["covered_switch_default_warnings"] = _flag_names["covered_switch_default_warnings"][get_config("jln-covered-switch-default-warnings")],
      ["cpu"] = _flag_names["cpu"][get_config("jln-cpu")],
      ["diagnostics_format"] = _flag_names["diagnostics_format"][get_config("jln-diagnostics-format")],
      ["diagnostics_show_template"] = _flag_names["diagnostics_show_template"][get_config("jln-diagnostics-show-template")],
      ["emcc_debug"] = _flag_names["emcc_debug"][get_config("jln-emcc-debug")],
      ["exceptions"] = _flag_names["exceptions"][get_config("jln-exceptions")],
      ["hardened"] = _flag_names["hardened"][get_config("jln-hardened")],
      ["linker"] = _flag_names["linker"][get_config("jln-linker")],
      ["lto"] = _flag_names["lto"][get_config("jln-lto")],
      ["msvc_crt_secure_no_warnings"] = _flag_names["msvc_crt_secure_no_warnings"][get_config("jln-msvc-crt-secure-no-warnings")],
      ["msvc_diagnostics_format"] = _flag_names["msvc_diagnostics_format"][get_config("jln-msvc-diagnostics-format")],
      ["msvc_isystem"] = _flag_names["msvc_isystem"][get_config("jln-msvc-isystem")],
      ["msvc_isystem_with_template_instantiations_treated_as_non_external"] = _flag_names["msvc_isystem_with_template_instantiations_treated_as_non_external"][get_config("jln-msvc-isystem-with-template-instantiations-treated-as-non-external")],
      ["ndebug"] = _flag_names["ndebug"][get_config("jln-ndebug")],
      ["noexcept_warnings"] = _flag_names["noexcept_warnings"][get_config("jln-noexcept-warnings")],
      ["optimization"] = _flag_names["optimization"][get_config("jln-optimization")],
      ["optimization_warnings"] = _flag_names["optimization_warnings"][get_config("jln-optimization-warnings")],
      ["pedantic"] = _flag_names["pedantic"][get_config("jln-pedantic")],
      ["reproducible_build_warnings"] = _flag_names["reproducible_build_warnings"][get_config("jln-reproducible-build-warnings")],
      ["rtti"] = _flag_names["rtti"][get_config("jln-rtti")],
      ["sanitizers"] = _flag_names["sanitizers"][get_config("jln-sanitizers")],
      ["shadow_warnings"] = _flag_names["shadow_warnings"][get_config("jln-shadow-warnings")],
      ["stl_fix"] = _flag_names["stl_fix"][get_config("jln-stl-fix")],
      ["stl_hardening"] = _flag_names["stl_hardening"][get_config("jln-stl-hardening")],
      ["suggest_attributes"] = _flag_names["suggest_attributes"][get_config("jln-suggest-attributes")],
      ["switch_warnings"] = _flag_names["switch_warnings"][get_config("jln-switch-warnings")],
      ["symbols"] = _flag_names["symbols"][get_config("jln-symbols")],
      ["unsafe_buffer_usage_warnings"] = _flag_names["unsafe_buffer_usage_warnings"][get_config("jln-unsafe-buffer-usage-warnings")],
      ["var_init"] = _flag_names["var_init"][get_config("jln-var-init")],
      ["warnings"] = _flag_names["warnings"][get_config("jln-warnings")],
      ["warnings_as_error"] = _flag_names["warnings_as_error"][get_config("jln-warnings-as-error")],
      ["windows_abi_compatibility_warnings"] = _flag_names["windows_abi_compatibility_warnings"][get_config("jln-windows-abi-compatibility-warnings")],
      ["windows_bigobj"] = _flag_names["windows_bigobj"][get_config("jln-windows-bigobj")],
      ["cxx"] = _get_extra("jln-cxx"),
      ["cxx_version"] = _get_extra("jln-cxx-version"),
      ["ld"] = _get_extra("jln-ld"),
    }
  end
end

-- Same as get_flags() and apply the options on a target
function set_flags(target, options, extra_options)
  options = get_flags(options, extra_options)
  table.insert(options.cxxflags, {force=true})
  table.insert(options.ldflags, {force=true})
  target:add('cxxflags', table.unpack(options.cxxflags))
  target:add('ldflags', table.unpack(options.ldflags))
  table.remove(options.cxxflags)
  table.remove(options.ldflags)
  return options
end


local function extract_progname_and_version_from_path(compiler)
  compiler = compiler:match('/([^/]+)$') or compiler
  local version = compiler:match('%d+%.?%d*%.?%d*$') or ''
  -- remove version suffix
  local has_sep = compiler:byte(#compiler - #version) == 45 -- '-'
  compiler = compiler:sub(1, #compiler - #version - (has_sep and 1 or 0))
  return compiler, version
end


local _compiler_by_toolname = {
  vs='cl',
  cl='cl',
  gcc='gcc',
  gxx='gcc',
  clang='clang',
  clangxx='clang',
  icc='icc',
  icpc='icc',
  icl='icl',
  icx='icx',
  icpx='icx',
  ['icx-cl']='icx-cl',
  dpcpp='icx',
  ['dpcpp-cl']='icx-cl',
  ['em++']='emcc',
}

local _is_clang_like_by_compiler = {
  clang=true,
  -- ['clang-cl']=false,
  emcc=true,
  icx=true,
  ['icx-cl']=true,
}


local _comp_cache = {}
local _ld_cache

local function add_comp_cache(original_compiler, original_version, data)
  local tmp = _comp_cache[original_compiler] or {}
  tmp[original_version] = data
  _comp_cache[original_compiler] = tmp
end


-- Returns an array of compile and link flags
-- `options`: same as create_options()
-- `extra_options` = {
--   envs: table = nil -- for os.iorunv
--   disable_other_options: bool = false
--   print_compiler: bool = false -- for debug only
-- }
-- return {cxxflags=table, ldflags=table}
function get_flags(options, extra_options)
  options = create_options(options, extra_options)

  local compiler = options.cxx  local version = options.cxx_version
  local linker = options.ld

  if not linker then
    linker = _ld_cache
    if not linker then
      local program, toolname = platform.tool('ld')
      if extra_options and extra_options.print_compiler then
        cprint("jln.get_flags (1): linker: ${cyan}%s${reset} / ${cyan}%s${reset}", program, toolname)
      end
      linker = toolname or detect.find_toolname(program) or ''
      _ld_cache = linker
    end
  end
  if extra_options and extra_options.print_compiler then
    cprint("jln.get_flags: linker: ${cyan}%s${reset}", linker)
  end

  local original_compiler = compiler or ''
  local original_version = version or ''
  local compcache = (_comp_cache[original_compiler] or {})[original_version]

  if compcache then
    compiler = compcache[1]
    version = compcache[2]
    if not compiler then
      -- wrintf("Unknown compiler")
      return {cxxflags={}, ldflags={}}
    end
  else
    local compiler_path = compiler

    if compiler then
      if not version then
        compiler, version = extract_progname_and_version_from_path(compiler)
        if extra_options and extra_options.print_compiler then
          cprint("jln.get_flags (1): compiler: ${cyan}%s${reset} (${cyan}%s${reset})", compiler, version)
        end

        if version == '' then
          local compinfos = detect.find_tool(compiler, {version=true, program=compiler})
          if compinfos then
            compiler = compinfos.name
            version = compinfos.version
          end
        end
      end
    else
      local toolname
      compiler, toolname = platform.tool('cxx')
      if extra_options and extra_options.print_compiler then
        cprint("jln.get_flags (2): compiler: ${cyan}%s${reset} / ${cyan}%s${reset}", compiler, toolname)
      end

      if not compiler then
        -- wprint("Unknown compiler")
        add_comp_cache(original_compiler, original_version, {})
        return {cxxflags={}, ldflags={}}
      end

      compiler_path = compiler
      local compinfos = detect.find_tool(toolname or compiler, {version=true, program=compiler})
      if compinfos then
        compiler = compinfos.name
        version = compinfos.version
      else
        compiler, version = extract_progname_and_version_from_path(compiler)
      end
    end

    compiler = _compiler_by_toolname[compiler] or compiler

    if compiler == 'emcc' then
      compiler = 'clang-emcc'
      local outdata, errdata = os.iorunv(compiler_path, {'-v'}, {envs = extra_options.envs})
      version = errdata:match('clang version ([^ ]+)')
    elseif compiler == 'icx' or compiler == 'icx-cl' then
      compiler = compiler == 'icx' and 'clang' or 'clang-cl'
      try {
        function()
          -- . as cpp file is an error, but stderr is good
          os.iorunv(compiler_path, {'-v', '-x', 'c++', '.', '-E'}, {envs = extra_options.envs})
        end,
        catch {
          function(proc)
            version = proc.stderr:match('/clang/([^ ]+)')
          end
        }
      }
    end

    if extra_options and extra_options.print_compiler then
      cprint("jln.get_flags (3): compiler: ${cyan}%s${reset} (${cyan}%s${reset})", compiler, version)
    end

    local versparts = {}
    for i in version:gmatch("%d+") do
      table.insert(versparts, tonumber(i))
    end

    if versparts[1] then
      version = versparts[1] * 100000 + (versparts[2] or 0)
    else
      wprint("Wrong version format: %s", version)
      version = 0
    end

    add_comp_cache(original_compiler, original_version, {compiler, version})
  end

  local is_clang_like = _is_clang_like_by_compiler[compiler]

  if extra_options and extra_options.print_compiler then
    cprint("jln.get_flags: compiler: ${cyan}%s${reset} (${cyan}%s${reset}), linker: ${cyan}%s", compiler, version, linker)
  end

  local insert = table.insert
  local jln_cxflags, jln_ldflags = {}, {}

  if options.ndebug ~= "" then
    if ( compiler == 'cl' or compiler == 'icl' ) then
      if options.ndebug == "off" then
        insert(jln_cxflags, "/UNDEBUG")
      else
        if options.ndebug == "on" then
          insert(jln_cxflags, "/DNDEBUG")
        else
          if options.optimization ~= "" and not ( options.optimization == "0" or options.optimization == "g" ) then
            insert(jln_cxflags, "/DNDEBUG")
          end
        end
      end
    else
      if options.ndebug == "off" then
        insert(jln_cxflags, "-UNDEBUG")
      else
        if options.ndebug == "on" then
          insert(jln_cxflags, "-DNDEBUG")
        else
          if options.optimization ~= "" and not ( options.optimization == "0" or options.optimization == "g" ) then
            insert(jln_cxflags, "-DNDEBUG")
          end
        end
      end
    end
  end
  if ( compiler == 'gcc' or is_clang_like or compiler == 'clang-cl' ) then
    if options.warnings ~= "" then
      if options.warnings == "off" then
        insert(jln_cxflags, "-w")
      else
        if options.warnings == "essential" then
          insert(jln_cxflags, "-Wall")
          insert(jln_cxflags, "-Wextra")
        else
          if compiler == 'gcc' then
            insert(jln_cxflags, "-Wall")
            insert(jln_cxflags, "-Wextra")
            if version < 800000 then
              insert(jln_cxflags, "-Wcast-align")
            end
            insert(jln_cxflags, "-Wcast-qual")
            insert(jln_cxflags, "-Wdisabled-optimization")
            insert(jln_cxflags, "-Wfloat-equal")
            insert(jln_cxflags, "-Wformat-security")
            insert(jln_cxflags, "-Wformat=2")
            insert(jln_cxflags, "-Winvalid-pch")
            insert(jln_cxflags, "-Wmissing-declarations")
            insert(jln_cxflags, "-Wmissing-include-dirs")
            insert(jln_cxflags, "-Wpacked")
            insert(jln_cxflags, "-Wredundant-decls")
            insert(jln_cxflags, "-Wundef")
            insert(jln_cxflags, "-Wunused-macros")
            insert(jln_cxflags, "-Wpointer-arith")
            insert(jln_cxflags, "-Wnon-virtual-dtor")
            insert(jln_cxflags, "-Wold-style-cast")
            insert(jln_cxflags, "-Woverloaded-virtual")
            if version >= 400007 then
              insert(jln_cxflags, "-Wsuggest-attribute=noreturn")
              insert(jln_cxflags, "-Wzero-as-null-pointer-constant")
              insert(jln_cxflags, "-Wlogical-op")
              insert(jln_cxflags, "-Wvector-operation-performance")
              insert(jln_cxflags, "-Wdouble-promotion")
              insert(jln_cxflags, "-Wtrampolines")
              if version >= 400008 then
                insert(jln_cxflags, "-Wuseless-cast")
                if version >= 400009 then
                  insert(jln_cxflags, "-Wconditionally-supported")
                  if version >= 500001 then
                    insert(jln_cxflags, "-Wformat-signedness")
                    insert(jln_cxflags, "-Warray-bounds=2")
                    insert(jln_cxflags, "-Wstrict-null-sentinel")
                    insert(jln_cxflags, "-Wsuggest-override")
                    if version >= 600001 then
                      insert(jln_cxflags, "-Wduplicated-cond")
                      insert(jln_cxflags, "-Wnull-dereference")
                      if version >= 700000 then
                        insert(jln_cxflags, "-Waligned-new")
                        if version >= 700001 then
                          insert(jln_cxflags, "-Walloc-zero")
                          insert(jln_cxflags, "-Walloca")
                          insert(jln_cxflags, "-Wformat-overflow=2")
                          insert(jln_cxflags, "-Wduplicated-branches")
                          if version >= 800000 then
                            insert(jln_cxflags, "-Wcast-align=strict")
                            insert(jln_cxflags, "-Wformat-truncation=2")
                            insert(jln_cxflags, "-Wshift-overflow=2")
                            insert(jln_cxflags, "-Wclass-memaccess")
                            if version >= 1400000 then
                              insert(jln_cxflags, "-Walloc-size")
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
            if options.warnings == "extensive" then
              if version >= 800000 then
                insert(jln_cxflags, "-Wstringop-overflow=4")
                if version >= 1200000 then
                  insert(jln_cxflags, "-Wuse-after-free=3")
                end
              end
            end
          else
            insert(jln_cxflags, "-Weverything")
            insert(jln_cxflags, "-Wno-documentation")
            insert(jln_cxflags, "-Wno-documentation-unknown-command")
            insert(jln_cxflags, "-Wno-newline-eof")
            insert(jln_cxflags, "-Wno-c++98-compat")
            insert(jln_cxflags, "-Wno-c++98-compat-pedantic")
            insert(jln_cxflags, "-Wno-padded")
            insert(jln_cxflags, "-Wno-global-constructors")
            insert(jln_cxflags, "-Wno-weak-vtables")
            insert(jln_cxflags, "-Wno-exit-time-destructors")
            if  not ( ( options.switch_warnings == "off" or options.switch_warnings == "exhaustive_enum" or options.switch_warnings == "exhaustive_enum_and_mandatory_default" ) ) then
              insert(jln_cxflags, "-Wno-switch-enum")
            end
            if options.covered_switch_default_warnings == "" then
              insert(jln_cxflags, "-Wno-covered-switch-default")
            end
            if options.suggest_attributes == "" then
              insert(jln_cxflags, "-Wno-missing-noreturn")
            end
            if options.conversion_warnings ~= "" then
              if options.conversion_warnings == "conversion" then
                insert(jln_cxflags, "-Wno-sign-compare")
                insert(jln_cxflags, "-Wno-sign-conversion")
              else
                if ( options.conversion_warnings == "float" or options.conversion_warnings == "sign" ) then
                  insert(jln_cxflags, "-Wno-conversion")
                end
              end
            end
            if version >= 300009 then
              insert(jln_cxflags, "-Wno-undefined-var-template")
              if version >= 500000 then
                insert(jln_cxflags, "-Wno-inconsistent-missing-destructor-override")
                if version >= 900000 then
                  insert(jln_cxflags, "-Wno-ctad-maybe-unsupported")
                  if version >= 1000000 then
                    insert(jln_cxflags, "-Wno-c++20-compat")
                    if version >= 1100000 then
                      insert(jln_cxflags, "-Wno-suggest-destructor-override")
                      if version >= 1600000 then
                        if options.unsafe_buffer_usage_warnings == "" then
                          insert(jln_cxflags, "-Wno-unsafe-buffer-usage")
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
    if options.bidi_char_warnings ~= "" then
      if ( compiler == 'gcc' and version >= 1200000 ) then
        if options.bidi_char_warnings == "any" then
          insert(jln_cxflags, "-Wbidi-chars=any")
        else
          if options.bidi_char_warnings == "any_and_ucn" then
            insert(jln_cxflags, "-Wbidi-chars=any,ucn")
          else
            if options.bidi_char_warnings == "unpaired" then
              insert(jln_cxflags, "-Wbidi-chars=unpaired")
            else
              insert(jln_cxflags, "-Wbidi-chars=unpaired,ucn")
            end
          end
        end
      end
    end
    if options.optimization_warnings ~= "" then
      if compiler == 'gcc' then
        if version >= 900000 then
          insert(jln_cxflags, "-Wpessimizing-move")
          insert(jln_cxflags, "-Wredundant-move")
          if version >= 1100000 then
            insert(jln_cxflags, "-Wrange-loop-construct")
            if version >= 1300000 then
              insert(jln_cxflags, "-Wself-move")
              if version >= 1400000 then
                insert(jln_cxflags, "-Wnrvo")
              end
            end
          end
        end
      else
        if version >= 300006 then
          insert(jln_cxflags, "-Wself-move")
          if version >= 300007 then
            insert(jln_cxflags, "-Wpessimizing-move")
            insert(jln_cxflags, "-Wredundant-move")
            if version >= 1000000 then
              insert(jln_cxflags, "-Wrange-loop-construct")
            end
          end
        end
      end
    end
    if compiler == 'gcc' then
      if options.switch_warnings ~= "" then
        if options.switch_warnings == "on" then
          insert(jln_cxflags, "-Wswitch")
        else
          if options.switch_warnings == "exhaustive_enum" then
            insert(jln_cxflags, "-Wswitch-enum")
          else
            if options.switch_warnings == "mandatory_default" then
              insert(jln_cxflags, "-Wswitch-default")
            else
              if options.switch_warnings == "exhaustive_enum_and_mandatory_default" then
                insert(jln_cxflags, "-Wswitch-default")
                insert(jln_cxflags, "-Wswitch-enum")
              else
                insert(jln_cxflags, "-Wno-switch")
                insert(jln_cxflags, "-Wno-switch-enum")
                insert(jln_cxflags, "-Wno-switch-default")
              end
            end
          end
        end
      end
    else
      if options.switch_warnings ~= "" then
        if options.switch_warnings == "on" then
          insert(jln_cxflags, "-Wswitch")
          insert(jln_cxflags, "-Wno-switch-default")
        else
          if options.switch_warnings == "mandatory_default" then
            insert(jln_cxflags, "-Wswitch")
            insert(jln_cxflags, "-Wswitch-default")
          else
            if options.switch_warnings == "exhaustive_enum" then
              insert(jln_cxflags, "-Wswitch")
              insert(jln_cxflags, "-Wswitch-enum")
              insert(jln_cxflags, "-Wno-switch-default")
            else
              if options.switch_warnings == "exhaustive_enum_and_mandatory_default" then
                insert(jln_cxflags, "-Wswitch")
                insert(jln_cxflags, "-Wswitch-enum")
                insert(jln_cxflags, "-Wswitch-default")
              else
                insert(jln_cxflags, "-Wno-switch")
                insert(jln_cxflags, "-Wno-switch-enum")
                insert(jln_cxflags, "-Wno-switch-default")
              end
            end
          end
        end
      end
      if options.covered_switch_default_warnings ~= "" then
        if options.covered_switch_default_warnings == "off" then
          insert(jln_cxflags, "-Wno-covered-switch-default")
        else
          insert(jln_cxflags, "-Wcovered-switch-default")
        end
      end
    end
    if options.unsafe_buffer_usage_warnings ~= "" then
      if ( ( is_clang_like and version >= 1600000 ) or ( compiler == 'clang-cl' and version >= 1600000 ) ) then
        if options.unsafe_buffer_usage_warnings == "off" then
          insert(jln_cxflags, "-Wno-unsafe-buffer-usage")
        else
          insert(jln_cxflags, "-Wunsafe-buffer-usage")
        end
      end
    end
    if options.shadow_warnings ~= "" then
      if options.shadow_warnings == "off" then
        insert(jln_cxflags, "-Wno-shadow")
        if ( ( is_clang_like and version >= 800000 ) or ( compiler == 'clang-cl' and version >= 800000 ) ) then
          insert(jln_cxflags, "-Wno-shadow-field")
        end
      else
        if options.shadow_warnings == "on" then
          insert(jln_cxflags, "-Wshadow")
        else
          if options.shadow_warnings == "all" then
            if compiler == 'gcc' then
              insert(jln_cxflags, "-Wshadow")
            else
              insert(jln_cxflags, "-Wshadow-all")
            end
          else
            if ( compiler == 'gcc' and version >= 700001 ) then
              if options.shadow_warnings == "local" then
                insert(jln_cxflags, "-Wshadow=local")
              else
                insert(jln_cxflags, "-Wshadow=compatible-local")
              end
            end
          end
        end
      end
    end
    if options.suggest_attributes ~= "" then
      if options.suggest_attributes == "on" then
        insert(jln_cxflags, "-Wmissing-noreturn")
      else
        if options.suggest_attributes == "common" then
          insert(jln_cxflags, "-Wmissing-noreturn")
          insert(jln_cxflags, "-Wmissing-format-attribute")
        else
          if ( options.suggest_attributes == "analysis" or options.suggest_attributes == "all" ) then
            insert(jln_cxflags, "-Wmissing-noreturn")
            insert(jln_cxflags, "-Wmissing-format-attribute")
            if compiler == 'gcc' then
              if version >= 800000 then
                insert(jln_cxflags, "-Wsuggest-attribute=malloc")
                if version >= 1400000 then
                  insert(jln_cxflags, "-Wsuggest-attribute=returns_nonnull")
                end
              end
              if ( options.suggest_attributes == "all" or options.suggest_attributes == "unity" ) then
                if version >= 500000 then
                  insert(jln_cxflags, "-Wsuggest-final-types")
                  insert(jln_cxflags, "-Wsuggest-final-methods")
                end
                if options.suggest_attributes == "all" then
                  insert(jln_cxflags, "-Wsuggest-attribute=pure")
                  insert(jln_cxflags, "-Wsuggest-attribute=const")
                  if version >= 500001 then
                    insert(jln_cxflags, "-Wnoexcept")
                    if version >= 800000 then
                      insert(jln_cxflags, "-Wsuggest-attribute=cold")
                    end
                  end
                end
              end
            end
          else
            insert(jln_cxflags, "-Wno-missing-noreturn")
            insert(jln_cxflags, "-Wno-missing-format-attribute")
            if compiler == 'gcc' then
              insert(jln_cxflags, "-Wno-suggest-attribute=pure")
              insert(jln_cxflags, "-Wno-suggest-attribute=const")
              if version >= 500000 then
                insert(jln_cxflags, "-Wno-suggest-final-types")
                insert(jln_cxflags, "-Wno-suggest-final-methods")
                if version >= 500001 then
                  insert(jln_cxflags, "-Wno-noexcept")
                  if version >= 800000 then
                    insert(jln_cxflags, "-Wno-suggest-attribute=malloc")
                    if version >= 1400000 then
                      insert(jln_cxflags, "-Wno-suggest-attribute=returns_nonnull")
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
    if options.var_init ~= "" then
      if ( ( compiler == 'gcc' and version >= 1200000 ) or ( is_clang_like and version >= 800000 ) or ( compiler == 'clang-cl' and version >= 800000 ) ) then
        if options.var_init == "pattern" then
          insert(jln_cxflags, "-ftrivial-auto-var-init=pattern")
          if compiler == 'gcc' then
            insert(jln_cxflags, "-Wtrivial-auto-var-init")
          end
        else
          if options.var_init == "zero" then
            if ( ( is_clang_like and version <= 1500000 ) or ( compiler == 'clang-cl' and version <= 1500000 ) ) then
              if options.var_init == "zero" then
                insert(jln_cxflags, "-enable-trivial-auto-var-init-zero-knowing-it-will-be-removed-from-clang")
              end
            else
              insert(jln_cxflags, "-ftrivial-auto-var-init=zero")
              if compiler == 'gcc' then
                insert(jln_cxflags, "-Wtrivial-auto-var-init")
              end
            end
          else
            insert(jln_cxflags, "-ftrivial-auto-var-init=uninitialized")
          end
        end
      end
    end
    if options.windows_abi_compatibility_warnings ~= "" then
      if ( ( compiler == 'gcc' and version >= 1000000 ) or compiler ~= 'gcc' ) then
        if options.windows_abi_compatibility_warnings == "on" then
          insert(jln_cxflags, "-Wmismatched-tags")
        else
          insert(jln_cxflags, "-Wno-mismatched-tags")
        end
      end
    end
    if options.reproducible_build_warnings ~= "" then
      if ( compiler == 'gcc' and version >= 400009 ) then
        if options.reproducible_build_warnings == "on" then
          insert(jln_cxflags, "-Wdate-time")
        else
          insert(jln_cxflags, "-Wno-date-time")
        end
      end
    end
    if options.warnings_as_error ~= "" then
      if options.warnings_as_error == "on" then
        insert(jln_cxflags, "-Werror")
      else
        if options.warnings_as_error == "basic" then
          insert(jln_cxflags, "-Werror=return-type")
          insert(jln_cxflags, "-Werror=init-self")
          if compiler == 'gcc' then
            insert(jln_cxflags, "-Werror=div-by-zero")
            if version >= 500001 then
              insert(jln_cxflags, "-Werror=array-bounds")
              insert(jln_cxflags, "-Werror=logical-op")
              insert(jln_cxflags, "-Werror=logical-not-parentheses")
              if version >= 700000 then
                insert(jln_cxflags, "-Werror=literal-suffix")
              end
            end
          else
            insert(jln_cxflags, "-Werror=array-bounds")
            insert(jln_cxflags, "-Werror=division-by-zero")
            if version >= 300004 then
              insert(jln_cxflags, "-Werror=logical-not-parentheses")
              if version >= 300006 then
                insert(jln_cxflags, "-Werror=delete-incomplete")
                if version >= 600000 then
                  insert(jln_cxflags, "-Werror=user-defined-literals")
                  if version >= 700000 then
                    insert(jln_cxflags, "-Werror=dynamic-class-memaccess")
                  end
                end
              end
            end
          end
        else
          insert(jln_cxflags, "-Wno-error")
        end
      end
    end
    if options.color ~= "" then
      if ( version >= 400009 or compiler ~= 'gcc' ) then
        if options.color == "auto" then
          insert(jln_cxflags, "-fdiagnostics-color=auto")
        else
          if options.color == "never" then
            insert(jln_cxflags, "-fdiagnostics-color=never")
          else
            insert(jln_cxflags, "-fdiagnostics-color=always")
          end
        end
      end
    end
    if options.lto ~= "" then
      if options.lto == "off" then
        insert(jln_cxflags, "-fno-lto")
        insert(jln_ldflags, "-fno-lto")
        if compiler == 'gcc' then
          insert(jln_cxflags, "-fno-whole-program")
        end
      else
        if compiler == 'gcc' then
          if options.lto ~= "thin_or_nothing" then
            if ( options.lto == "whole_program" or options.lto == "whole_program_and_full_lto" ) then
              insert(jln_cxflags, "-fwhole-program")
            end
            if version >= 1000000 then
              insert(jln_cxflags, "-flto=auto")
              insert(jln_ldflags, "-flto=auto")
            else
              insert(jln_cxflags, "-flto")
              insert(jln_ldflags, "-flto")
            end
          end
        else
          if ( ( options.lto == "on" or options.lto == "thin_or_nothing" or options.lto == "whole_program" ) and version >= 400000 ) then
            insert(jln_cxflags, "-flto=thin")
            insert(jln_ldflags, "-flto=thin")
          else
            insert(jln_cxflags, "-flto")
            insert(jln_ldflags, "-flto")
            if version >= 1000000 then
              insert(jln_cxflags, "-fvirtual-function-elimination")
              insert(jln_ldflags, "-fvirtual-function-elimination")
            end
          end
          if version >= 300009 then
            if ( options.lto == "whole_program" or options.lto == "whole_program_and_full_lto" ) then
              insert(jln_cxflags, "-fwhole-program-vtables")
              insert(jln_ldflags, "-fwhole-program-vtables")
            end
            if version >= 700000 then
              insert(jln_cxflags, "-fforce-emit-vtables")
              insert(jln_ldflags, "-fforce-emit-vtables")
            end
          end
        end
      end
    end
    if options.stl_hardening ~= "" then
      if options.stl_hardening ~= "off" then
        if options.stl_hardening == "fast" then
          if compiler ~= 'clang-cl' then
            insert(jln_cxflags, "-D_GLIBCXX_ASSERTIONS")
          end
          insert(jln_cxflags, "-D_LIBCPP_HARDENING_MODE=_LIBCPP_HARDENING_MODE_FAST")
        else
          if options.stl_hardening == "extensive" then
            if compiler ~= 'clang-cl' then
              insert(jln_cxflags, "-D_GLIBCXX_ASSERTIONS")
            end
            insert(jln_cxflags, "-D_LIBCPP_HARDENING_MODE=_LIBCPP_HARDENING_MODE_EXTENSIVE")
          else
            if options.stl_hardening == "debug" then
              if compiler ~= 'clang-cl' then
                insert(jln_cxflags, "-D_GLIBCXX_ASSERTIONS")
              end
              insert(jln_cxflags, "-D_LIBCPP_HARDENING_MODE=_LIBCPP_HARDENING_MODE_DEBUG")
            else
              if compiler ~= 'clang-cl' then
                insert(jln_cxflags, "-D_GLIBCXX_DEBUG")
                if options.pedantic ~= "" and not ( options.pedantic == "off" ) then
                  insert(jln_cxflags, "-D_GLIBCXX_DEBUG_PEDANTIC")
                end
              end
              if ( is_clang_like and version < 1800000 ) then
                if version >= 800000 then
                  insert(jln_cxflags, "-D_LIBCPP_DEBUG=1")
                end
              else
                insert(jln_cxflags, "-D_LIBCPP_HARDENING_MODE=_LIBCPP_HARDENING_MODE_DEBUG")
                insert(jln_cxflags, "-D_LIBCPP_ABI_BOUNDED_ITERATORS")
                insert(jln_cxflags, "-D_LIBCPP_ABI_BOUNDED_ITERATORS_IN_STRING")
                insert(jln_cxflags, "-D_LIBCPP_ABI_BOUNDED_ITERATORS_IN_VECTOR")
                insert(jln_cxflags, "-D_LIBCPP_ABI_BOUNDED_UNIQUE_PTR")
                insert(jln_cxflags, "-D_LIBCPP_ABI_BOUNDED_ITERATORS_IN_STD_ARRAY")
              end
            end
          end
        end
      end
    end
    if options.sanitizers ~= "" then
      if ( ( compiler == 'gcc' and version >= 400008 ) or ( is_clang_like and version >= 300002 ) or ( compiler == 'clang-cl' and version >= 400000 ) ) then
        if options.sanitizers == "off" then
          insert(jln_cxflags, "-fno-sanitize=all")
          insert(jln_ldflags, "-fno-sanitize=all")
        else
          if options.sanitizers == "thread" then
            insert(jln_cxflags, "-fsanitize=thread")
            insert(jln_ldflags, "-fsanitize=thread")
          else
            if options.sanitizers == "undefined" then
              insert(jln_cxflags, "-fsanitize=undefined")
              insert(jln_ldflags, "-fsanitize=undefined")
            else
              if options.sanitizers == "undefined_minimal_runtime" then
                insert(jln_cxflags, "-fsanitize=undefined")
                insert(jln_ldflags, "-fsanitize=undefined")
                if ( ( is_clang_like or compiler == 'clang-cl' ) and version >= 600000 ) then
                  insert(jln_cxflags, "-fsanitize-minimal-runtime")
                  insert(jln_ldflags, "-fsanitize-minimal-runtime")
                end
              else
                if options.sanitizers == "scudo_hardened_allocator" then
                  if ( compiler == 'clang' and version >= 1300000 ) then
                    insert(jln_cxflags, "-fsanitize=scudo")
                    insert(jln_ldflags, "-fsanitize=scudo")
                  end
                else
                  insert(jln_cxflags, "-fno-omit-frame-pointer")
                  insert(jln_cxflags, "-fno-optimize-sibling-calls")
                  insert(jln_cxflags, "-fsanitize=address")
                  insert(jln_ldflags, "-fsanitize=address")
                  if ( options.sanitizers == "on" or options.sanitizers == "with_minimal_code_size" or options.sanitizers == "extra" or options.sanitizers == "extra_with_minimal_code_size" ) then
                    if ( ( compiler == 'gcc' and version >= 400009 ) or is_clang_like or compiler == 'clang-cl' ) then
                      insert(jln_cxflags, "-fsanitize=undefined")
                      insert(jln_ldflags, "-fsanitize=undefined")
                    end
                    if ( options.sanitizers == "with_minimal_code_size" or options.sanitizers == "extra_with_minimal_code_size" ) then
                      if ( ( is_clang_like and version >= 1300000 ) or ( compiler == 'clang-cl' and version >= 1300000 ) ) then
                        insert(jln_cxflags, "-fsanitize-address-use-after-return=always")
                        insert(jln_ldflags, "-fsanitize-address-use-after-return=always")
                      end
                    end
                    if ( options.sanitizers == "extra" or options.sanitizers == "extra_with_minimal_code_size" ) then
                      if ( ( compiler == 'gcc' and version >= 800000 ) or ( compiler == 'clang' and version >= 900000 ) or ( compiler == 'clang-cl' and version >= 900000 ) ) then
                        insert(jln_cxflags, "-fsanitize=pointer-compare")
                        insert(jln_cxflags, "-fsanitize=pointer-subtract")
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
    if options.emcc_debug ~= "" then
      if compiler == 'clang-emcc' then
        if options.emcc_debug == "off" then
          insert(jln_ldflags, "-sASSERTIONS=0")
          insert(jln_ldflags, "-sSAFE_HEAP=0")
          insert(jln_ldflags, "-sSTACK_OVERFLOW_CHECK=0")
        else
          if options.emcc_debug == "slow" then
            insert(jln_ldflags, "-sASSERTIONS=2")
          else
            insert(jln_ldflags, "-sASSERTIONS=1")
          end
          insert(jln_ldflags, "-sSTACK_OVERFLOW_CHECK=2")
          if  not ( ( options.sanitizers == "on" or options.sanitizers == "with_minimal_code_size" or options.sanitizers == "extra" or options.sanitizers == "extra_with_minimal_code_size" or options.sanitizers == "address" or options.sanitizers == "address_with_minimal_code_size" ) ) then
            insert(jln_ldflags, "-sSAFE_HEAP=1")
          end
        end
      end
    end
  end
  if options.conversion_warnings ~= "" then
    if ( compiler == 'gcc' or is_clang_like or compiler == 'clang-cl' or compiler == 'icc' ) then
      if options.conversion_warnings == "on" then
        insert(jln_cxflags, "-Wconversion")
        insert(jln_cxflags, "-Wsign-compare")
        insert(jln_cxflags, "-Wsign-conversion")
      else
        if options.conversion_warnings == "conversion" then
          insert(jln_cxflags, "-Wconversion")
        else
          if options.conversion_warnings == "float" then
            if compiler == 'gcc' then
              if version >= 400009 then
                insert(jln_cxflags, "-Wfloat-conversion")
              end
            else
              insert(jln_cxflags, "-Wfloat-conversion")
            end
          else
            if options.conversion_warnings == "sign" then
              insert(jln_cxflags, "-Wsign-compare")
              insert(jln_cxflags, "-Wsign-conversion")
            else
              if options.conversion_warnings == "all" then
                insert(jln_cxflags, "-Wconversion")
                if compiler == 'gcc' then
                  insert(jln_cxflags, "-Warith-conversion")
                end
              else
                insert(jln_cxflags, "-Wno-conversion")
                insert(jln_cxflags, "-Wno-sign-compare")
                insert(jln_cxflags, "-Wno-sign-conversion")
              end
            end
          end
        end
      end
    end
  end
  if ( compiler == 'gcc' or is_clang_like ) then
    if options.diagnostics_show_template ~= "" then
      if ( options.diagnostics_show_template == "tree_without_elided_types" or options.diagnostics_show_template == "tree" ) then
        if ( ( compiler == 'gcc' and version >= 800000 ) or is_clang_like ) then
          insert(jln_cxflags, "-fdiagnostics-show-template-tree")
        end
      end
      if ( options.diagnostics_show_template == "tree_without_elided_types" or options.diagnostics_show_template == "without_elided_types" ) then
        if ( ( compiler == 'gcc' and version >= 800000 ) or ( is_clang_like and version >= 300004 ) ) then
          insert(jln_cxflags, "-fno-elide-type")
        end
      end
    end
    if options.exceptions ~= "" then
      if options.exceptions == "on" then
        insert(jln_cxflags, "-fexceptions")
        if compiler == 'clang-emcc' then
          insert(jln_cxflags, "-sDISABLE_EXCEPTION_CATCHING=0")
        end
      else
        insert(jln_cxflags, "-fno-exceptions")
      end
    end
    if options.hardened ~= "" then
      if ( options.hardened == "on" or options.hardened == "all" ) then
        if ( compiler == 'gcc' and version >= 1400000 ) then
          insert(jln_cxflags, "-fhardened")
          insert(jln_cxflags, "-Whardened")
          if options.hardened == "all" then
            insert(jln_cxflags, "-fstack-protector-all")
          end
          insert(jln_cxflags, "-Wtrampolines")
          insert(jln_ldflags, "-Wl,-z,noexecstack")
        else
          if options.hardened == "all" then
            insert(jln_cxflags, "-fstack-protector-all")
          else
            insert(jln_cxflags, "-fstack-protector-strong")
          end
          if ( ( compiler == 'gcc' and version >= 1200000 ) or ( is_clang_like and version >= 1400000 ) ) then
            insert(jln_cxflags, "-D_FORTIFY_SOURCE=3")
            if ( ( compiler == 'gcc' and version >= 1300000 ) or ( is_clang_like and version >= 1600000 ) ) then
              insert(jln_cxflags, "-fstrict-flex-arrays=3")
            end
          else
            insert(jln_cxflags, "-D_FORTIFY_SOURCE=2")
          end
          if options.var_init == "" then
            if ( ( compiler == 'gcc' and version >= 1200000 ) or ( is_clang_like and version >= 800000 ) ) then
              if ( is_clang_like and version <= 1500000 ) then
                insert(jln_cxflags, "-enable-trivial-auto-var-init-zero-knowing-it-will-be-removed-from-clang")
              else
                insert(jln_cxflags, "-ftrivial-auto-var-init=zero")
                if compiler == 'gcc' then
                  insert(jln_cxflags, "-Wtrivial-auto-var-init")
                end
              end
            end
          end
          insert(jln_cxflags, "-fPIE")
          insert(jln_ldflags, "-fPIE")
          if compiler ~= 'clang-emcc' then
            insert(jln_cxflags, "-pie")
            insert(jln_ldflags, "-pie")
            insert(jln_ldflags, "-Wl,-z,relro,-z,now")
            insert(jln_ldflags, "-Wl,-z,noexecstack")
          end
          if compiler == 'gcc' then
            if version >= 400006 then
              insert(jln_cxflags, "-Wtrampolines")
              if version >= 800000 then
                insert(jln_cxflags, "-fstack-clash-protection")
                insert(jln_cxflags, "-fcf-protection=full")
              end
            end
          else
            if compiler ~= 'clang-emcc' then
              if version >= 700000 then
                insert(jln_cxflags, "-fcf-protection=full")
                if version >= 1100000 then
                  insert(jln_cxflags, "-fstack-clash-protection")
                end
              end
            end
          end
        end
      end
    end
    if options.rtti ~= "" then
      if options.rtti == "on" then
        insert(jln_cxflags, "-frtti")
      else
        insert(jln_cxflags, "-fno-rtti")
      end
    end
    if options.diagnostics_format ~= "" then
      if options.diagnostics_format == "fixits" then
        if ( ( compiler == 'gcc' and version >= 700000 ) or ( compiler ~= 'gcc' and version >= 500000 ) ) then
          insert(jln_cxflags, "-fdiagnostics-parseable-fixits")
        end
      else
        if options.diagnostics_format == "patch" then
          if ( compiler == 'gcc' and version >= 700000 ) then
            insert(jln_cxflags, "-fdiagnostics-generate-patch")
          end
        else
          if is_clang_like then
            insert(jln_cxflags, "-fdiagnostics-print-source-range-info")
          end
        end
      end
    end
    if options.pedantic ~= "" then
      if options.pedantic ~= "off" then
        insert(jln_cxflags, "-pedantic")
        if options.pedantic == "as_error" then
          insert(jln_cxflags, "-pedantic-errors")
          insert(jln_cxflags, "-Werror=write-strings")
          if compiler == 'gcc' then
            if version >= 400007 then
              insert(jln_cxflags, "-Werror=narrowing")
              if version >= 700001 then
                insert(jln_cxflags, "-Werror=literal-suffix")
              end
            end
          end
        end
      end
    end
    if options.symbols ~= "" then
      if options.symbols == "hidden" then
        insert(jln_cxflags, "-fvisibility=hidden")
      else
        if options.symbols == "strip_all" then
          insert(jln_ldflags, "-s")
        else
          if options.symbols == "gc_sections" then
            if linker == 'ld64' then
              insert(jln_ldflags, "-Wl,-S")
              insert(jln_ldflags, "-Wl,-dead_strip")
            end
            insert(jln_ldflags, "-s")
            insert(jln_ldflags, "-Wl,--gc-sections")
          else
            if options.symbols == "nodebug" then
              insert(jln_cxflags, "-g0")
            else
              if options.symbols == "debug" then
                insert(jln_cxflags, "-g")
              else
                if options.symbols == "minimal_debug" then
                  insert(jln_cxflags, "-g1")
                else
                  if options.symbols == "full_debug" then
                    insert(jln_cxflags, "-g3")
                  else
                    if compiler == 'clang' then
                      if options.symbols == "dwarf" then
                        insert(jln_cxflags, "-g")
                      end
                      if options.symbols == "lldb" then
                        insert(jln_cxflags, "-glldb")
                      end
                      if options.symbols == "sce" then
                        insert(jln_cxflags, "-gsce")
                      end
                      if options.symbols == "dbx" then
                        insert(jln_cxflags, "-gdbx")
                      end
                    else
                      if compiler == 'gcc' then
                        if options.symbols == "dwarf" then
                          insert(jln_cxflags, "-g")
                        end
                        if options.symbols == "codeview" then
                          insert(jln_cxflags, "-gcodeview")
                        end
                        if options.symbols == "btf" then
                          insert(jln_cxflags, "-gbtf")
                        end
                        if options.symbols == "ctf" then
                          insert(jln_cxflags, "-gctf")
                        end
                        if options.symbols == "ctf1" then
                          insert(jln_cxflags, "-gctf1")
                        end
                        if options.symbols == "ctf2" then
                          insert(jln_cxflags, "-gctf2")
                        end
                        if options.symbols == "vms" then
                          insert(jln_cxflags, "-gvms")
                        end
                        if options.symbols == "vms1" then
                          insert(jln_cxflags, "-gvms1")
                        end
                        if options.symbols == "vms2" then
                          insert(jln_cxflags, "-gvms2")
                        end
                        if options.symbols == "vms3" then
                          insert(jln_cxflags, "-gvms3")
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
    if compiler == 'clang-emcc' then
      if options.optimization ~= "" then
        if options.optimization == "0" then
          insert(jln_cxflags, "-O0")
          insert(jln_ldflags, "-O0")
        else
          if options.optimization == "g" then
            insert(jln_cxflags, "-Og")
            insert(jln_ldflags, "-Og")
          else
            if options.optimization == "1" then
              insert(jln_cxflags, "-O1")
              insert(jln_ldflags, "-O1")
            else
              if options.optimization == "2" then
                insert(jln_cxflags, "-O2")
                insert(jln_ldflags, "-O2")
              else
                if options.optimization == "3" then
                  insert(jln_cxflags, "-O3")
                  insert(jln_ldflags, "-O3")
                else
                  if options.optimization == "fast" then
                    insert(jln_cxflags, "-O3")
                    insert(jln_cxflags, "-mnontrapping-fptoint")
                    insert(jln_ldflags, "-O3")
                    insert(jln_ldflags, "-mnontrapping-fptoint")
                  else
                    if options.optimization == "size" then
                      insert(jln_cxflags, "-Os")
                      insert(jln_ldflags, "-Os")
                    else
                      insert(jln_cxflags, "-Oz")
                      insert(jln_ldflags, "-Oz")
                    end
                  end
                end
              end
            end
          end
        end
      end
    else
      if ( compiler == 'gcc' and version >= 1200000 ) then
        insert(jln_cxflags, "-ffold-simple-inlines")
      end
      if options.coverage ~= "" then
        if options.coverage == "on" then
          insert(jln_cxflags, "--coverage")
          insert(jln_ldflags, "--coverage")
          if compiler == 'clang' then
            insert(jln_ldflags, "-lprofile_rt")
          end
        end
      end
      if options.optimization ~= "" then
        if options.optimization == "0" then
          insert(jln_cxflags, "-O0")
        else
          if options.optimization == "g" then
            insert(jln_cxflags, "-Og")
          else
            insert(jln_ldflags, "-Wl,-O1")
            if options.optimization == "1" then
              insert(jln_cxflags, "-O1")
            else
              if options.optimization == "2" then
                insert(jln_cxflags, "-O2")
              else
                if options.optimization == "3" then
                  insert(jln_cxflags, "-O3")
                else
                  if options.optimization == "size" then
                    insert(jln_cxflags, "-Os")
                  else
                    if options.optimization == "z" then
                      if ( compiler == 'clang' or ( compiler == 'gcc' and version >= 1200000 ) ) then
                        insert(jln_cxflags, "-Oz")
                      else
                        insert(jln_cxflags, "-Os")
                      end
                    else
                      if compiler == 'clang' then
                        insert(jln_cxflags, "-O3")
                        insert(jln_cxflags, "-ffast-math")
                      else
                        insert(jln_cxflags, "-Ofast")
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
      if options.cpu ~= "" then
        if options.cpu == "generic" then
          insert(jln_cxflags, "-mtune=generic")
          insert(jln_ldflags, "-mtune=generic")
        else
          insert(jln_cxflags, "-march=native")
          insert(jln_cxflags, "-mtune=native")
          insert(jln_ldflags, "-march=native")
          insert(jln_ldflags, "-mtune=native")
        end
      end
      if options.linker ~= "" then
        if options.linker == "mold" then
          insert(jln_ldflags, "-fuse-ld=mold")
        else
          if options.linker == "native" then
            if compiler == 'gcc' then
              insert(jln_ldflags, "-fuse-ld=gold")
            else
              insert(jln_ldflags, "-fuse-ld=lld")
            end
          else
            if options.linker == "bfd" then
              insert(jln_ldflags, "-fuse-ld=bfd")
            else
              if ( options.linker == "gold" or ( compiler == 'gcc' and version < 900000 ) ) then
                insert(jln_ldflags, "-fuse-ld=gold")
              else
                insert(jln_ldflags, "-fuse-ld=lld")
              end
            end
          end
        end
      end
      if options.noexcept_warnings ~= "" then
        if ( compiler == 'gcc' and version >= 400006 ) then
          if options.noexcept_warnings == "on" then
            insert(jln_cxflags, "-Wnoexcept")
          else
            insert(jln_cxflags, "-Wno-noexcept")
          end
        end
      end
      if options.analyzer ~= "" then
        if ( compiler == 'gcc' and version >= 1000000 ) then
          if options.analyzer == "off" then
            insert(jln_cxflags, "-fno-analyzer")
          else
            insert(jln_cxflags, "-fanalyzer")
            if options.analyzer_too_complex_warning ~= "" then
              if options.analyzer_too_complex_warning == "on" then
                insert(jln_cxflags, "-Wanalyzer-too-complex")
              else
                insert(jln_cxflags, "-Wno-analyzer-too-complex")
              end
            end
            if options.analyzer_verbosity ~= "" then
              if options.analyzer_verbosity == "0" then
                insert(jln_cxflags, "-fanalyzer-verbosity=0")
              else
                if options.analyzer_verbosity == "1" then
                  insert(jln_cxflags, "-fanalyzer-verbosity=1")
                else
                  if options.analyzer_verbosity == "2" then
                    insert(jln_cxflags, "-fanalyzer-verbosity=2")
                  else
                    insert(jln_cxflags, "-fanalyzer-verbosity=3")
                  end
                end
              end
            end
          end
        end
      end
    end
  end
  if ( compiler == 'cl' or compiler == 'clang-cl' or compiler == 'icl' ) then
    if options.exceptions ~= "" then
      if options.exceptions == "on" then
        insert(jln_cxflags, "/EHsc")
      else
        insert(jln_cxflags, "/EHs-c-")
      end
    end
    if options.rtti ~= "" then
      if options.rtti == "on" then
        insert(jln_cxflags, "/GR")
      else
        insert(jln_cxflags, "/GR-")
      end
    end
    if options.stl_hardening ~= "" then
      if options.stl_hardening == "off" then
        insert(jln_cxflags, "/D_MSVC_STL_HARDENING=0")
        insert(jln_cxflags, "/D_MSVC_STL_DESTRUCTOR_TOMBSTONES=0")
        insert(jln_cxflags, "/D_ITERATOR_DEBUG_LEVEL=0")
        insert(jln_cxflags, "/D_HAS_ITERATOR_DEBUGGING=0")
        insert(jln_cxflags, "/D_SECURE_SCL=0")
      else
        if ( options.stl_hardening == "fast" or options.stl_hardening == "extensive" ) then
          insert(jln_cxflags, "/D_MSVC_STL_HARDENING=1")
        else
          if options.stl_hardening == "debug" then
            insert(jln_cxflags, "/D_MSVC_STL_HARDENING=1")
            insert(jln_cxflags, "/D_MSVC_STL_DESTRUCTOR_TOMBSTONES=1")
          else
            insert(jln_cxflags, "/D_DEBUG")
            insert(jln_cxflags, "/D_MSVC_STL_HARDENING=1")
            insert(jln_cxflags, "/D_MSVC_STL_DESTRUCTOR_TOMBSTONES=1")
          end
        end
      end
    end
    if options.stl_fix ~= "" then
      if options.stl_fix == "on" then
        insert(jln_cxflags, "/DNOMINMAX")
      end
    end
    if compiler ~= 'icl' then
      if options.symbols ~= "" then
        if options.symbols == "nodebug" then
          insert(jln_ldflags, "/DEBUG:NONE")
        else
          if ( options.symbols == "debug" or options.symbols == "minimal_debug" or options.symbols == "full_debug" or options.symbols == "codeview" ) then
            insert(jln_cxflags, "/Zi")
            insert(jln_ldflags, "/DEBUG:FULL")
          else
            if compiler == 'clang-cl' then
              if options.symbols == "dwarf" then
                insert(jln_ldflags, "-gdwarf")
              end
            end
          end
        end
      end
      if options.optimization ~= "" then
        if options.optimization == "0" then
          insert(jln_cxflags, "/Od")
        else
          if options.optimization == "g" then
            insert(jln_cxflags, "/Ob1")
          else
            if options.optimization == "2" then
              insert(jln_cxflags, "/O2")
            else
              if ( options.optimization == "1" or options.optimization == "size" ) then
                insert(jln_cxflags, "/O1")
              else
                if options.optimization == "z" then
                  insert(jln_cxflags, "/O1")
                  insert(jln_cxflags, "/Gw")
                else
                  if options.optimization == "fast" then
                    insert(jln_cxflags, "/fp:fast")
                  end
                  insert(jln_cxflags, "/O2")
                  if ( ( compiler == 'cl' and version >= 1900020 ) or compiler == 'clang-cl' ) then
                    insert(jln_cxflags, "/Ob3")
                  end
                  insert(jln_cxflags, "/Gw")
                end
              end
            end
          end
        end
      end
      if options.hardened ~= "" then
        if options.hardened == "off" then
          insert(jln_cxflags, "/GS-")
        else
          insert(jln_cxflags, "/sdl")
          insert(jln_cxflags, "/guard:cf")
          if ( ( compiler == 'cl' and version >= 1900027 ) or ( compiler == 'clang-cl' and version >= 1000000 ) ) then
            insert(jln_cxflags, "/guard:ehcont")
            insert(jln_ldflags, "/CETCOMPAT")
          end
        end
      end
    end
  end
  if compiler == 'cl' then
    if options.analyzer ~= "" then
      if version >= 1900000 then
        if options.analyzer == "off" then
          insert(jln_cxflags, "/analyze-")
        else
          insert(jln_cxflags, "/analyze")
          if options.analyzer ~= "with_external_headers" then
            if version >= 1600010 then
              insert(jln_cxflags, "/analyze:external-")
            end
          end
        end
      end
    end
    if options.windows_bigobj ~= "" then
      insert(jln_cxflags, "/bigobj")
    end
    if options.msvc_crt_secure_no_warnings ~= "" then
      if options.msvc_crt_secure_no_warnings == "on" then
        insert(jln_cxflags, "/D_CRT_SECURE_NO_WARNINGS=1")
      else
        if options.msvc_crt_secure_no_warnings == "off" then
          insert(jln_cxflags, "/U_CRT_SECURE_NO_WARNINGS")
        end
      end
    end
    if options.msvc_diagnostics_format ~= "" then
      if version >= 1900010 then
        if options.msvc_diagnostics_format == "classic" then
          insert(jln_cxflags, "/diagnostics:classic")
        else
          if options.msvc_diagnostics_format == "column" then
            insert(jln_cxflags, "/diagnostics:column")
          else
            insert(jln_cxflags, "/diagnostics:caret")
          end
        end
      end
    end
    if version < 1900013 then
      options.msvc_isystem = ""
    end
    if options.msvc_isystem ~= "" then
      if options.msvc_isystem == "external_as_include_system_flag" then
        if version < 1900029 then
          -- unimplementable
        else
          -- unimplementable
        end
      else
        if options.msvc_isystem ~= "assumed" then
          if version < 1900029 then
            insert(jln_cxflags, "/experimental:external")
          end
          insert(jln_cxflags, "/external:W0")
          if options.msvc_isystem == "anglebrackets" then
            insert(jln_cxflags, "/external:anglebrackets")
          else
            insert(jln_cxflags, "/external:env:INCLUDE")
            insert(jln_cxflags, "/external:env:CAExcludePath")
          end
        end
      end
      if options.msvc_isystem_with_template_instantiations_treated_as_non_external ~= "" then
        if options.msvc_isystem_with_template_instantiations_treated_as_non_external == "off" then
          insert(jln_cxflags, "/external:templates")
        else
          insert(jln_cxflags, "/external:templates-")
        end
      end
    end
    if options.warnings ~= "" then
      if options.warnings == "off" then
        insert(jln_cxflags, "/W0")
      else
        if options.warnings == "essential" then
          insert(jln_cxflags, "/W4")
          insert(jln_cxflags, "/wd4711")
        else
          if options.warnings == "on" then
            insert(jln_cxflags, "/W4")
            insert(jln_cxflags, "/wd4711")
            if options.msvc_isystem == "" then
              insert(jln_cxflags, "/w14263")
              insert(jln_cxflags, "/w14264")
            end
            insert(jln_cxflags, "/w14265")
            insert(jln_cxflags, "/w14296")
            insert(jln_cxflags, "/w14444")
            insert(jln_cxflags, "/w14555")
            insert(jln_cxflags, "/w14557")
            insert(jln_cxflags, "/w14608")
            insert(jln_cxflags, "/w14905")
            insert(jln_cxflags, "/w14906")
            insert(jln_cxflags, "/w14917")
            insert(jln_cxflags, "/w14928")
            insert(jln_cxflags, "/w14545")
            insert(jln_cxflags, "/w14546")
            insert(jln_cxflags, "/w14547")
            insert(jln_cxflags, "/w14548")
            insert(jln_cxflags, "/w14549")
            insert(jln_cxflags, "/w14822")
            insert(jln_cxflags, "/w14692")
            if version >= 1900000 then
              insert(jln_cxflags, "/w14426")
              insert(jln_cxflags, "/w14596")
              if options.msvc_isystem == "" then
                insert(jln_cxflags, "/w14654")
              end
              insert(jln_cxflags, "/w15031")
              insert(jln_cxflags, "/w15032")
              if version >= 1900011 then
                insert(jln_cxflags, "/w15038")
                if version >= 1900015 then
                  insert(jln_cxflags, "/w14643")
                  if version >= 1900022 then
                    insert(jln_cxflags, "/w14855")
                    if version >= 1900025 then
                      if options.msvc_isystem == "" then
                        insert(jln_cxflags, "/w15204")
                      end
                      if version >= 1900029 then
                        insert(jln_cxflags, "/w15233")
                        insert(jln_cxflags, "/w15240")
                        if version >= 1900030 then
                          if options.msvc_isystem == "" then
                            insert(jln_cxflags, "/w15246")
                          end
                          insert(jln_cxflags, "/w15249")
                          if version >= 1900032 then
                            insert(jln_cxflags, "/w15258")
                            if version >= 1900034 then
                              insert(jln_cxflags, "/w15263")
                              if options.msvc_isystem == "" then
                                insert(jln_cxflags, "/w15262")
                              end
                              if version >= 1900037 then
                                insert(jln_cxflags, "/w15267")
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          else
            insert(jln_cxflags, "/Wall")
            insert(jln_cxflags, "/wd4342")
            insert(jln_cxflags, "/wd4350")
            insert(jln_cxflags, "/wd4355")
            insert(jln_cxflags, "/wd4370")
            insert(jln_cxflags, "/wd4371")
            insert(jln_cxflags, "/wd4514")
            insert(jln_cxflags, "/wd4571")
            insert(jln_cxflags, "/wd4577")
            insert(jln_cxflags, "/wd4582")
            insert(jln_cxflags, "/wd4583")
            insert(jln_cxflags, "/wd4587")
            insert(jln_cxflags, "/wd4588")
            insert(jln_cxflags, "/wd4686")
            insert(jln_cxflags, "/wd4710")
            insert(jln_cxflags, "/wd4711")
            insert(jln_cxflags, "/wd4820")
            insert(jln_cxflags, "/wd4866")
            insert(jln_cxflags, "/wd4868")
            insert(jln_cxflags, "/wd5024")
            insert(jln_cxflags, "/wd5025")
            insert(jln_cxflags, "/wd5026")
            insert(jln_cxflags, "/wd5027")
            insert(jln_cxflags, "/wd5243")
            if options.msvc_isystem == "" then
              insert(jln_cxflags, "/wd4464")
              insert(jln_cxflags, "/wd4548")
              insert(jln_cxflags, "/wd4623")
              insert(jln_cxflags, "/wd4625")
              insert(jln_cxflags, "/wd4626")
              insert(jln_cxflags, "/wd4668")
              insert(jln_cxflags, "/wd5204")
              if version >= 1900000 then
                insert(jln_cxflags, "/wd4582")
                insert(jln_cxflags, "/wd4583")
                if version >= 1900034 then
                  insert(jln_cxflags, "/wd5262")
                  if version >= 1900000 then
                    insert(jln_cxflags, "/wd4774")
                  end
                end
              end
            end
            if version >= 1600000 then
              insert(jln_cxflags, "/wd4800")
              if version >= 1900039 then
                insert(jln_cxflags, "/wd4975")
                if version >= 1900040 then
                  insert(jln_cxflags, "/wd4860")
                  insert(jln_cxflags, "/wd4861")
                  insert(jln_cxflags, "/wd5273")
                  insert(jln_cxflags, "/wd5274")
                  if version >= 1900041 then
                    insert(jln_cxflags, "/wd5306")
                    if version >= 1900043 then
                      insert(jln_cxflags, "/wd5277")
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
    if options.conversion_warnings ~= "" then
      if ( options.conversion_warnings == "off" or options.conversion_warnings == "sign" ) then
        insert(jln_cxflags, "/wd4244")
        insert(jln_cxflags, "/wd4245")
        insert(jln_cxflags, "/wd4365")
      else
        insert(jln_cxflags, "/w14244")
        insert(jln_cxflags, "/w14245")
        insert(jln_cxflags, "/w14365")
      end
      if ( options.conversion_warnings == "on" or options.conversion_warnings == "all" or options.conversion_warnings == "sign" ) then
        insert(jln_cxflags, "/w14018")
        insert(jln_cxflags, "/w14388")
        insert(jln_cxflags, "/w14289")
      else
        insert(jln_cxflags, "/wd4018")
        insert(jln_cxflags, "/wd4388")
        insert(jln_cxflags, "/wd4289")
      end
    end
    if options.optimization_warnings ~= "" then
      insert(jln_cxflags, "/w15263")
    end
    if options.switch_warnings ~= "" then
      if ( options.switch_warnings == "on" or options.switch_warnings == "mandatory_default" ) then
        insert(jln_cxflags, "/wd4061")
        insert(jln_cxflags, "/w14062")
      else
        if ( options.switch_warnings == "exhaustive_enum" or options.switch_warnings == "exhaustive_enum_and_mandatory_default" ) then
          insert(jln_cxflags, "/w14061")
          insert(jln_cxflags, "/w14062")
        else
          insert(jln_cxflags, "/wd4061")
          insert(jln_cxflags, "/wd4062")
        end
      end
    end
    if options.shadow_warnings ~= "" then
      if version >= 1900000 then
        if options.shadow_warnings == "off" then
          insert(jln_cxflags, "/wd4456")
          insert(jln_cxflags, "/wd4459")
        else
          if ( options.shadow_warnings == "on" or options.shadow_warnings == "all" ) then
            insert(jln_cxflags, "/w14456")
            insert(jln_cxflags, "/w14459")
          else
            if options.shadow_warnings == "local" then
              insert(jln_cxflags, "/w4456")
              insert(jln_cxflags, "/wd4459")
            end
          end
        end
      end
    end
    if options.warnings_as_error ~= "" then
      if options.warnings_as_error == "on" then
        insert(jln_cxflags, "/WX")
      else
        if options.warnings_as_error == "off" then
          insert(jln_cxflags, "/WX-")
        else
          insert(jln_cxflags, "/we4455")
          insert(jln_cxflags, "/we4150")
          insert(jln_cxflags, "/we4716")
          insert(jln_cxflags, "/we2124")
        end
      end
    end
    if options.pedantic ~= "" then
      if options.pedantic ~= "off" then
        insert(jln_cxflags, "/permissive-")
        insert(jln_cxflags, "/Zc:inline")
        insert(jln_cxflags, "/Zc:referenceBinding")
        insert(jln_cxflags, "/Zc:throwingNew")
        if version >= 1900013 then
          insert(jln_cxflags, "/Zc:externConstexpr")
          if version >= 1900014 then
            insert(jln_cxflags, "/Zc:__cplusplus")
            if version >= 1900025 then
              insert(jln_cxflags, "/Zc:preprocessor")
              if version >= 1900028 then
                insert(jln_cxflags, "/Zc:lambda")
                if version >= 1900034 then
                  insert(jln_cxflags, "/Zc:enumTypes")
                  if version >= 1900035 then
                    insert(jln_cxflags, "/Zc:templateScope")
                  end
                end
              end
            end
          end
        end
        if options.pedantic == "as_error" then
          insert(jln_cxflags, "/we4608")
          insert(jln_cxflags, "/we4928")
          if version >= 1900031 then
            insert(jln_cxflags, "/we5254")
            if version >= 1900038 then
              insert(jln_cxflags, "/we5110")
            end
          end
        else
          insert(jln_cxflags, "/w14608")
          insert(jln_cxflags, "/w14928")
          if version >= 1900031 then
            insert(jln_cxflags, "/w15254")
            if version >= 1900038 then
              insert(jln_cxflags, "/w15110")
            end
          end
        end
        if options.msvc_isystem ~= "" then
          if version >= 1700000 then
            insert(jln_cxflags, "/we4471")
            if version >= 1900021 then
              insert(jln_cxflags, "/we5052")
            end
          end
        else
          if version >= 1700000 then
            insert(jln_cxflags, "/w14471")
          end
        end
      end
    end
    if options.lto ~= "" then
      if options.lto == "off" then
        insert(jln_cxflags, "/GL-")
      else
        if options.lto ~= "thin_or_nothing" then
          insert(jln_cxflags, "/GL")
          insert(jln_cxflags, "/Gw")
          insert(jln_ldflags, "/LTCG")
        end
      end
    end
    if options.sanitizers ~= "" then
      if version >= 1900028 then
        if ( options.sanitizers == "on" or options.sanitizers == "with_minimal_code_size" or options.sanitizers == "extra" or options.sanitizers == "extra_with_minimal_code_size" or options.sanitizers == "address" or options.sanitizers == "address_with_minimal_code_size" ) then
          insert(jln_cxflags, "/fsanitize=address")
          insert(jln_ldflags, "/fsanitize=address")
          if ( options.sanitizers == "extra" or options.sanitizers == "extra_with_minimal_code_size" ) then
            insert(jln_cxflags, "/fsanitize-address-use-after-return")
          end
        end
      else
        if ( options.sanitizers == "on" or options.sanitizers == "with_minimal_code_size" or options.sanitizers == "extra" or options.sanitizers == "extra_with_minimal_code_size" or options.sanitizers == "address" or options.sanitizers == "address_with_minimal_code_size" ) then
          insert(jln_cxflags, "/sdl")
          if ( options.optimization == "0" ) then
            insert(jln_cxflags, "/RTCsu")
          end
        else
          if options.sanitizers == "off" then
            if options.hardened == "" then
              insert(jln_cxflags, "/sdl-")
            end
          end
        end
      end
    end
  else
    if compiler == 'clang-cl' then
      if options.pedantic ~= "" then
        if options.pedantic ~= "off" then
          insert(jln_cxflags, "/Zc:twoPhase")
          if options.pedantic == "as_error" then
            insert(jln_cxflags, "-Werror=write-strings")
          end
        end
      end
      if options.color ~= "" then
        if options.color == "never" then
          insert(jln_cxflags, "-fno-color-diagnostics")
        else
          if options.color == "always" then
            insert(jln_cxflags, "-fcolor-diagnostics")
          end
        end
      end
      if options.diagnostics_format ~= "" then
        if options.diagnostics_format == "fixits" then
          insert(jln_cxflags, "-fdiagnostics-parseable-fixits")
        end
      end
      if options.cpu ~= "" then
        if options.cpu == "generic" then
          insert(jln_cxflags, "-mtune=generic")
          insert(jln_ldflags, "-mtune=generic")
        else
          insert(jln_cxflags, "-march=native")
          insert(jln_cxflags, "-mtune=native")
          insert(jln_ldflags, "-march=native")
          insert(jln_ldflags, "-mtune=native")
        end
      end
      if options.linker ~= "" then
        if ( options.linker == "lld" or options.linker == "native" ) then
          insert(jln_ldflags, "-fuse-ld=lld")
        else
          if options.linker == "mold" then
            insert(jln_ldflags, "-fuse-ld=mold")
          end
        end
      end
    else
      if compiler == 'icl' then
        if options.warnings ~= "" then
          if options.warnings == "off" then
            insert(jln_cxflags, "/w")
          else
            insert(jln_cxflags, "/W2")
            insert(jln_cxflags, "/Qdiag-disable:1418,2259")
          end
        end
        if options.warnings_as_error ~= "" then
          if options.warnings_as_error == "on" then
            insert(jln_cxflags, "/WX")
          else
            if options.warnings_as_error == "basic" then
              insert(jln_cxflags, "/Qdiag-error:1079,39,109")
            end
          end
        end
        if options.windows_bigobj ~= "" then
          insert(jln_cxflags, "/bigobj")
        end
        if options.symbols ~= "" then
          if options.symbols == "nodebug" then
            insert(jln_cxflags, "/debug:none")
          else
            if options.symbols == "minimal_debug" then
              insert(jln_cxflags, "/debug:minimal")
            else
              if ( options.symbols == "debug" or options.symbols == "full_debug" or options.symbols == "codeview" ) then
                insert(jln_cxflags, "/debug:full")
              end
            end
          end
        end
        if options.optimization ~= "" then
          if options.optimization == "0" then
            insert(jln_cxflags, "/Ob0")
          else
            if options.optimization == "g" then
              insert(jln_cxflags, "/Ob1")
            else
              insert(jln_cxflags, "/GF")
              if options.optimization == "1" then
                insert(jln_cxflags, "/O1")
              else
                if options.optimization == "2" then
                  insert(jln_cxflags, "/O2")
                else
                  if options.optimization == "3" then
                    insert(jln_cxflags, "/O2")
                  else
                    if options.optimization == "z" then
                      insert(jln_cxflags, "/O3")
                    else
                      if options.optimization == "size" then
                        insert(jln_cxflags, "/Os")
                      else
                        insert(jln_cxflags, "/fast")
                      end
                    end
                  end
                end
              end
            end
          end
        end
        if options.hardened ~= "" then
          if options.hardened == "off" then
            insert(jln_cxflags, "/GS-")
          else
            insert(jln_cxflags, "/GS")
            insert(jln_cxflags, "/guard:cf")
            insert(jln_cxflags, "/mconditional-branch:all-fix")
            insert(jln_cxflags, "/Qcf-protection:full")
          end
        end
        if options.sanitizers ~= "" then
          if ( options.sanitizers == "on" or options.sanitizers == "with_minimal_code_size" or options.sanitizers == "extra" or options.sanitizers == "extra_with_minimal_code_size" or options.sanitizers == "address" or options.sanitizers == "address_with_minimal_code_size" ) then
            insert(jln_cxflags, "/Qtrapuv")
            insert(jln_cxflags, "/RTCsu")
            if ( options.sanitizers == "on" or options.sanitizers == "with_minimal_code_size" or options.sanitizers == "extra" or options.sanitizers == "extra_with_minimal_code_size" ) then
              insert(jln_cxflags, "/Qfp-stack-check")
              insert(jln_cxflags, "/Qfp-trap:common")
            end
          end
        end
        if options.cpu ~= "" then
          if options.cpu == "generic" then
            insert(jln_cxflags, "/Qtune:generic")
            insert(jln_ldflags, "/Qtune:generic")
          else
            insert(jln_cxflags, "/QxHost")
            insert(jln_ldflags, "/QxHost")
          end
        end
      else
        if compiler == 'icc' then
          if options.warnings ~= "" then
            if options.warnings == "off" then
              insert(jln_cxflags, "-w")
            else
              if options.warnings == "essential" then
                insert(jln_cxflags, "-Wall")
              else
                insert(jln_cxflags, "-Wall")
                insert(jln_cxflags, "-Warray-bounds")
                insert(jln_cxflags, "-Wcast-qual")
                insert(jln_cxflags, "-Wchar-subscripts")
                insert(jln_cxflags, "-Wdisabled-optimization")
                insert(jln_cxflags, "-Wenum-compare")
                insert(jln_cxflags, "-Wextra")
                insert(jln_cxflags, "-Wfloat-equal")
                insert(jln_cxflags, "-Wformat-security")
                insert(jln_cxflags, "-Wformat=2")
                insert(jln_cxflags, "-Winit-self")
                insert(jln_cxflags, "-Winvalid-pch")
                insert(jln_cxflags, "-Wmaybe-uninitialized")
                insert(jln_cxflags, "-Wmissing-include-dirs")
                insert(jln_cxflags, "-Wnarrowing")
                insert(jln_cxflags, "-Wnonnull")
                insert(jln_cxflags, "-Wpointer-sign")
                insert(jln_cxflags, "-Wreorder")
                insert(jln_cxflags, "-Wsequence-point")
                insert(jln_cxflags, "-Wtrigraphs")
                insert(jln_cxflags, "-Wundef")
                insert(jln_cxflags, "-Wunused-function")
                insert(jln_cxflags, "-Wunused-but-set-variable")
                insert(jln_cxflags, "-Wunused-variable")
                insert(jln_cxflags, "-Wpointer-arith")
                insert(jln_cxflags, "-Wdeprecated")
                insert(jln_cxflags, "-Wnon-virtual-dtor")
                insert(jln_cxflags, "-Woverloaded-virtual")
              end
            end
          end
          if options.switch_warnings ~= "" then
            if ( options.switch_warnings == "on" or options.switch_warnings == "exhaustive_enum" ) then
              insert(jln_cxflags, "-Wswitch-enum")
            else
              if options.switch_warnings == "mandatory_default" then
                insert(jln_cxflags, "-Wswitch-default")
              else
                if options.switch_warnings == "exhaustive_enum_and_mandatory_default" then
                  insert(jln_cxflags, "-Wswitch")
                else
                  insert(jln_cxflags, "-Wno-switch")
                end
              end
            end
          end
          if options.warnings_as_error ~= "" then
            if options.warnings_as_error == "on" then
              insert(jln_cxflags, "-Werror")
            else
              if options.warnings_as_error == "basic" then
                insert(jln_cxflags, "-diag-error=1079,39,109")
              end
            end
          end
          if options.pedantic ~= "" then
            if options.pedantic == "off" then
              insert(jln_cxflags, "-fgnu-keywords")
            else
              insert(jln_cxflags, "-fno-gnu-keywords")
              insert(jln_cxflags, "/Zc:inline")
              insert(jln_cxflags, "/Zc:strictStrings")
              insert(jln_cxflags, "/Zc:throwingNew")
            end
          end
          if options.shadow_warnings ~= "" then
            if options.shadow_warnings == "off" then
              insert(jln_cxflags, "-Wno-shadow")
            else
              if ( options.shadow_warnings == "on" or options.shadow_warnings == "all" ) then
                insert(jln_cxflags, "-Wshadow")
              end
            end
          end
          if options.stl_hardening ~= "" then
            if options.stl_hardening == "debug_with_broken_abi" then
              insert(jln_cxflags, "-D_GLIBCXX_DEBUG")
              if options.pedantic ~= "" and not ( options.pedantic == "off" ) then
                insert(jln_cxflags, "-D_GLIBCXX_DEBUG_PEDANTIC")
              end
            else
              if options.stl_hardening ~= "off" then
                insert(jln_cxflags, "-D_GLIBCXX_ASSERTIONS")
              end
            end
          end
          if options.symbols ~= "" then
            if options.symbols == "nodebug" then
              insert(jln_cxflags, "-g0")
            else
              if options.symbols == "hidden" then
                insert(jln_cxflags, "-fvisibility=hidden")
              else
                if options.symbols == "debug" then
                  insert(jln_cxflags, "-g")
                else
                  if options.symbols == "minimal_debug" then
                    insert(jln_cxflags, "-g1")
                  else
                    if options.symbols == "full_debug" then
                      insert(jln_cxflags, "-g3")
                    end
                  end
                end
              end
            end
          end
          if options.optimization ~= "" then
            if options.optimization == "0" then
              insert(jln_cxflags, "-O0")
            else
              if options.optimization == "g" then
                insert(jln_cxflags, "-O1")
              else
                if options.optimization == "1" then
                  insert(jln_cxflags, "-O1")
                else
                  if options.optimization == "2" then
                    insert(jln_cxflags, "-O2")
                  else
                    if options.optimization == "3" then
                      insert(jln_cxflags, "-O3")
                    else
                      if options.optimization == "z" then
                        insert(jln_cxflags, "-fast")
                      else
                        if options.optimization == "size" then
                          insert(jln_cxflags, "-Os")
                        else
                          insert(jln_cxflags, "-Ofast")
                        end
                      end
                    end
                  end
                end
              end
            end
          end
          if options.hardened ~= "" then
            if ( options.hardened == "on" or options.hardened == "all" ) then
              insert(jln_cxflags, "-D_FORTIFY_SOURCE=2")
              if options.hardened == "all" then
                insert(jln_cxflags, "-fstack-protector-all")
              else
                insert(jln_cxflags, "-fstack-protector-strong")
              end
              insert(jln_cxflags, "-fcf-protection=full")
              insert(jln_ldflags, "-Xlinker-zrelro")
              insert(jln_ldflags, "-Xlinker-znow")
              insert(jln_ldflags, "-Xlinker-znoexecstack")
            end
          end
          if options.sanitizers ~= "" then
            if ( options.sanitizers == "on" or options.sanitizers == "with_minimal_code_size" or options.sanitizers == "extra" or options.sanitizers == "extra_with_minimal_code_size" or options.sanitizers == "address" or options.sanitizers == "address_with_minimal_code_size" ) then
              insert(jln_cxflags, "-ftrapuv")
              if ( options.sanitizers == "on" or options.sanitizers == "with_minimal_code_size" or options.sanitizers == "extra" or options.sanitizers == "extra_with_minimal_code_size" ) then
                insert(jln_cxflags, "-fp-stack-check")
                insert(jln_cxflags, "-fp-trap=common")
              end
            end
          end
          if options.linker ~= "" then
            if options.linker == "bfd" then
              insert(jln_ldflags, "-fuse-ld=bfd")
            else
              if options.linker == "gold" then
                insert(jln_ldflags, "-fuse-ld=gold")
              else
                if options.linker == "mold" then
                  insert(jln_ldflags, "-fuse-ld=mold")
                else
                  insert(jln_ldflags, "-fuse-ld=lld")
                end
              end
            end
          end
          if options.lto ~= "" then
            if options.lto == "off" then
              insert(jln_cxflags, "-no-ipo")
              insert(jln_ldflags, "-no-ipo")
            else
              if options.lto ~= "thin_or_nothing" then
                insert(jln_cxflags, "-ipo")
                insert(jln_ldflags, "-ipo")
              end
            end
          end
          if options.exceptions ~= "" then
            if options.exceptions == "on" then
              insert(jln_cxflags, "-fexceptions")
            else
              insert(jln_cxflags, "-fno-exceptions")
            end
          end
          if options.rtti ~= "" then
            if options.rtti == "on" then
              insert(jln_cxflags, "-frtti")
            else
              insert(jln_cxflags, "-fno-rtti")
            end
          end
          if options.cpu ~= "" then
            if options.cpu == "generic" then
              insert(jln_cxflags, "-mtune=generic")
              insert(jln_ldflags, "-mtune=generic")
            else
              insert(jln_cxflags, "-xHost")
              insert(jln_ldflags, "-xHost")
            end
          end
        else
          if is_plat("mingw") then
            if options.windows_bigobj ~= "" then
              insert(jln_cxflags, "-Wa,-mbig-obj")
            end
          end
        end
      end
    end
  end
  return {cxxflags=jln_cxflags, ldflags=jln_ldflags}
end

