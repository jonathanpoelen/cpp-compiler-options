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
--      stl_debug='on',
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
--  Supported options are (alphabetically in a category):
--  
--  <!-- ./compiler-options.lua generators/list_options.lua --color -->
--  ```ini
--  # Warning:
--  
--  analyzer = default off on taint
--  analyzer_too_complex_warning = default off on
--  analyzer_verbosity = default 0 1 2 3
--  conversion_warnings = on default off sign conversion
--  covered_switch_default_warnings = on default off
--  fix_compiler_error = on default off
--  msvc_crt_secure_no_warnings = on default off
--  noexcept_warnings = default off on
--  reproducible_build_warnings = default off on
--  shadow_warnings = off default on local compatible_local all
--  suggestions = default off on
--  switch_warnings = on default off exhaustive_enum mandatory_default exhaustive_enum_and_mandatory_default
--  unsafe_buffer_usage_warnings = default on off
--  warnings = on default off strict very_strict
--  warnings_as_error = default off on basic
--  windows_abi_compatibility_warnings = off default on
--  
--  # Pedantic:
--  
--  msvc_conformance = all default all_without_throwing_new
--  pedantic = on default off as_error
--  stl_fix = on default off
--  
--  # Debug:
--  
--  debug = default off on line_tables_only gdb lldb sce
--  float_sanitizers = default off on
--  integer_sanitizers = default off on
--  ndebug = with_optimization_1_or_above default off on
--  other_sanitizers = default off thread pointer memory
--  sanitizers = default off on
--  stl_debug = default off on allow_broken_abi allow_broken_abi_and_bugs assert_as_exception
--  var_init = default uninitialized pattern zero
--  
--  # Optimization:
--  
--  cpu = default generic native
--  linker = default bfd gold lld native
--  lto = default off on normal fat thin
--  optimization = default 0 g 1 2 3 fast size z
--  whole_program = default off on strip_all
--  
--  # C++:
--  
--  exceptions = default off on
--  rtti = default off on
--  
--  # Hardening:
--  
--  control_flow = default off on branch return allow_bugs
--  relro = default off on full
--  stack_protector = default off on strong all
--  
--  # Other:
--  
--  color = default auto never always
--  coverage = default off on
--  diagnostics_format = default fixits patch print_source_range_info
--  diagnostics_show_template_tree = default off on
--  elide_type = default off on
--  msvc_diagnostics_format = caret default classic column
--  msvc_isystem = default anglebrackets include_and_caexcludepath external_as_include_system_flag
--  msvc_isystem_with_template_from_non_external = default off on
--  pie = default off on static fpic fPIC fpie fPIE
--  windows_bigobj = on default
--  ```
--  <!-- ./compiler-options.lua -->
--  
--  The value `default` does nothing.
--  
--  If not specified:
--  
--  - `msvc_conformance` is `all`
--  - `msvc_diagnostics_format` is `caret`
--  - `ndebug` is `with_optimization_1_or_above`
--  - The following values are `off`:
--    - `shadow_warnings`
--    - `windows_abi_compatibility_warnings`
--  - The following values are `on`:
--    - `conversion_warnings`
--    - `covered_switch_default_warnings`
--    - `fix_compiler_error`
--    - `msvc_crt_secure_no_warnings`
--    - `pedantic`
--    - `stl_fix`
--    - `switch_warnings`
--    - `warnings`
--    - `windows_bigobj`
--  
--  <!-- enddefault -->
--  
--  - `control_flow=allow_bugs`
--    - clang: Can crash programs with "illegal hardware instruction" on totally unlikely lines. It can also cause link errors and force `-fvisibility=hidden` and `-flto`.
--  - `stl_debug=allow_broken_abi_and_bugs`
--    - clang: libc++ can crash on dynamic memory releases in the standard classes. This bug is fixed with the library associated with version 8.
--  - `msvc_isystem=external_as_include_system_flag` is only available with `cmake`.
--  
--  
--  ## Recommended options
--  
--  category | options
--  ---------|---------
--  debug | `control_flow=on`<br>`debug=on`<br>`sanitizers=on`<br>`stl_debug=allow_broken_abi` or `on`<br>
--  release | `cpu=native`<br>`linker=gold`, `lld` or `native`<br>`lto=on` or `thin`<br>`optimization=3`<br>`rtti=off`<br>`whole_program=strip_all`
--  security | `control_flow=on`<br>`relro=full`<br>`stack_protector=strong`<br>`pie=PIE`
--  really strict warnings | `pedantic=as_error`<br>`shadow_warnings=local`<br>`suggestions=on`<br>`warnings=very_strict`
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
  ["jln-analyzer"] = {["default"]="", ["off"]="off", ["on"]="on", ["taint"]="taint", [""]=""},
  ["analyzer"] = {["default"]="", ["off"]="off", ["on"]="on", ["taint"]="taint", [""]=""},
  ["jln-analyzer-too-complex-warning"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["analyzer_too_complex_warning"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["jln-analyzer-verbosity"] = {["default"]="", ["0"]="0", ["1"]="1", ["2"]="2", ["3"]="3", [""]=""},
  ["analyzer_verbosity"] = {["default"]="", ["0"]="0", ["1"]="1", ["2"]="2", ["3"]="3", [""]=""},
  ["jln-color"] = {["default"]="", ["auto"]="auto", ["never"]="never", ["always"]="always", [""]=""},
  ["color"] = {["default"]="", ["auto"]="auto", ["never"]="never", ["always"]="always", [""]=""},
  ["jln-control-flow"] = {["default"]="", ["off"]="off", ["on"]="on", ["branch"]="branch", ["return"]="return", ["allow_bugs"]="allow_bugs", [""]=""},
  ["control_flow"] = {["default"]="", ["off"]="off", ["on"]="on", ["branch"]="branch", ["return"]="return", ["allow_bugs"]="allow_bugs", [""]=""},
  ["jln-conversion-warnings"] = {["default"]="", ["off"]="off", ["on"]="on", ["sign"]="sign", ["conversion"]="conversion", [""]=""},
  ["conversion_warnings"] = {["default"]="", ["off"]="off", ["on"]="on", ["sign"]="sign", ["conversion"]="conversion", [""]=""},
  ["jln-coverage"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["coverage"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["jln-covered-switch-default-warnings"] = {["default"]="", ["on"]="on", ["off"]="off", [""]=""},
  ["covered_switch_default_warnings"] = {["default"]="", ["on"]="on", ["off"]="off", [""]=""},
  ["jln-cpu"] = {["default"]="", ["generic"]="generic", ["native"]="native", [""]=""},
  ["cpu"] = {["default"]="", ["generic"]="generic", ["native"]="native", [""]=""},
  ["jln-debug"] = {["default"]="", ["off"]="off", ["on"]="on", ["line_tables_only"]="line_tables_only", ["gdb"]="gdb", ["lldb"]="lldb", ["sce"]="sce", [""]=""},
  ["debug"] = {["default"]="", ["off"]="off", ["on"]="on", ["line_tables_only"]="line_tables_only", ["gdb"]="gdb", ["lldb"]="lldb", ["sce"]="sce", [""]=""},
  ["jln-diagnostics-format"] = {["default"]="", ["fixits"]="fixits", ["patch"]="patch", ["print_source_range_info"]="print_source_range_info", [""]=""},
  ["diagnostics_format"] = {["default"]="", ["fixits"]="fixits", ["patch"]="patch", ["print_source_range_info"]="print_source_range_info", [""]=""},
  ["jln-diagnostics-show-template-tree"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["diagnostics_show_template_tree"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["jln-elide-type"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["elide_type"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["jln-exceptions"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["exceptions"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["jln-fix-compiler-error"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["fix_compiler_error"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["jln-float-sanitizers"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["float_sanitizers"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["jln-integer-sanitizers"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["integer_sanitizers"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["jln-linker"] = {["default"]="", ["bfd"]="bfd", ["gold"]="gold", ["lld"]="lld", ["native"]="native", [""]=""},
  ["linker"] = {["default"]="", ["bfd"]="bfd", ["gold"]="gold", ["lld"]="lld", ["native"]="native", [""]=""},
  ["jln-lto"] = {["default"]="", ["off"]="off", ["on"]="on", ["normal"]="normal", ["fat"]="fat", ["thin"]="thin", [""]=""},
  ["lto"] = {["default"]="", ["off"]="off", ["on"]="on", ["normal"]="normal", ["fat"]="fat", ["thin"]="thin", [""]=""},
  ["jln-msvc-conformance"] = {["default"]="", ["all"]="all", ["all_without_throwing_new"]="all_without_throwing_new", [""]=""},
  ["msvc_conformance"] = {["default"]="", ["all"]="all", ["all_without_throwing_new"]="all_without_throwing_new", [""]=""},
  ["jln-msvc-crt-secure-no-warnings"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["msvc_crt_secure_no_warnings"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["jln-msvc-diagnostics-format"] = {["default"]="", ["classic"]="classic", ["column"]="column", ["caret"]="caret", [""]=""},
  ["msvc_diagnostics_format"] = {["default"]="", ["classic"]="classic", ["column"]="column", ["caret"]="caret", [""]=""},
  ["jln-msvc-isystem"] = {["default"]="", ["anglebrackets"]="anglebrackets", ["include_and_caexcludepath"]="include_and_caexcludepath", [""]=""},
  ["msvc_isystem"] = {["default"]="", ["anglebrackets"]="anglebrackets", ["include_and_caexcludepath"]="include_and_caexcludepath", [""]=""},
  ["jln-msvc-isystem-with-template-from-non-external"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["msvc_isystem_with_template_from_non_external"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["jln-ndebug"] = {["default"]="", ["off"]="off", ["on"]="on", ["with_optimization_1_or_above"]="with_optimization_1_or_above", [""]=""},
  ["ndebug"] = {["default"]="", ["off"]="off", ["on"]="on", ["with_optimization_1_or_above"]="with_optimization_1_or_above", [""]=""},
  ["jln-noexcept-warnings"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["noexcept_warnings"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["jln-optimization"] = {["default"]="", ["0"]="0", ["g"]="g", ["1"]="1", ["2"]="2", ["3"]="3", ["fast"]="fast", ["size"]="size", ["z"]="z", [""]=""},
  ["optimization"] = {["default"]="", ["0"]="0", ["g"]="g", ["1"]="1", ["2"]="2", ["3"]="3", ["fast"]="fast", ["size"]="size", ["z"]="z", [""]=""},
  ["jln-other-sanitizers"] = {["default"]="", ["off"]="off", ["thread"]="thread", ["pointer"]="pointer", ["memory"]="memory", [""]=""},
  ["other_sanitizers"] = {["default"]="", ["off"]="off", ["thread"]="thread", ["pointer"]="pointer", ["memory"]="memory", [""]=""},
  ["jln-pedantic"] = {["default"]="", ["off"]="off", ["on"]="on", ["as_error"]="as_error", [""]=""},
  ["pedantic"] = {["default"]="", ["off"]="off", ["on"]="on", ["as_error"]="as_error", [""]=""},
  ["jln-pie"] = {["default"]="", ["off"]="off", ["on"]="on", ["static"]="static", ["fpic"]="fpic", ["fPIC"]="fPIC", ["fpie"]="fpie", ["fPIE"]="fPIE", [""]=""},
  ["pie"] = {["default"]="", ["off"]="off", ["on"]="on", ["static"]="static", ["fpic"]="fpic", ["fPIC"]="fPIC", ["fpie"]="fpie", ["fPIE"]="fPIE", [""]=""},
  ["jln-relro"] = {["default"]="", ["off"]="off", ["on"]="on", ["full"]="full", [""]=""},
  ["relro"] = {["default"]="", ["off"]="off", ["on"]="on", ["full"]="full", [""]=""},
  ["jln-reproducible-build-warnings"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["reproducible_build_warnings"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["jln-rtti"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["rtti"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["jln-sanitizers"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["sanitizers"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["jln-shadow-warnings"] = {["default"]="", ["off"]="off", ["on"]="on", ["local"]="local", ["compatible_local"]="compatible_local", ["all"]="all", [""]=""},
  ["shadow_warnings"] = {["default"]="", ["off"]="off", ["on"]="on", ["local"]="local", ["compatible_local"]="compatible_local", ["all"]="all", [""]=""},
  ["jln-stack-protector"] = {["default"]="", ["off"]="off", ["on"]="on", ["strong"]="strong", ["all"]="all", [""]=""},
  ["stack_protector"] = {["default"]="", ["off"]="off", ["on"]="on", ["strong"]="strong", ["all"]="all", [""]=""},
  ["jln-stl-debug"] = {["default"]="", ["off"]="off", ["on"]="on", ["allow_broken_abi"]="allow_broken_abi", ["allow_broken_abi_and_bugs"]="allow_broken_abi_and_bugs", ["assert_as_exception"]="assert_as_exception", [""]=""},
  ["stl_debug"] = {["default"]="", ["off"]="off", ["on"]="on", ["allow_broken_abi"]="allow_broken_abi", ["allow_broken_abi_and_bugs"]="allow_broken_abi_and_bugs", ["assert_as_exception"]="assert_as_exception", [""]=""},
  ["jln-stl-fix"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["stl_fix"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["jln-suggestions"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["suggestions"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["jln-switch-warnings"] = {["default"]="", ["on"]="on", ["off"]="off", ["exhaustive_enum"]="exhaustive_enum", ["mandatory_default"]="mandatory_default", ["exhaustive_enum_and_mandatory_default"]="exhaustive_enum_and_mandatory_default", [""]=""},
  ["switch_warnings"] = {["default"]="", ["on"]="on", ["off"]="off", ["exhaustive_enum"]="exhaustive_enum", ["mandatory_default"]="mandatory_default", ["exhaustive_enum_and_mandatory_default"]="exhaustive_enum_and_mandatory_default", [""]=""},
  ["jln-unsafe-buffer-usage-warnings"] = {["default"]="", ["on"]="on", ["off"]="off", [""]=""},
  ["unsafe_buffer_usage_warnings"] = {["default"]="", ["on"]="on", ["off"]="off", [""]=""},
  ["jln-var-init"] = {["default"]="", ["uninitialized"]="uninitialized", ["pattern"]="pattern", ["zero"]="zero", [""]=""},
  ["var_init"] = {["default"]="", ["uninitialized"]="uninitialized", ["pattern"]="pattern", ["zero"]="zero", [""]=""},
  ["jln-warnings"] = {["default"]="", ["off"]="off", ["on"]="on", ["strict"]="strict", ["very_strict"]="very_strict", [""]=""},
  ["warnings"] = {["default"]="", ["off"]="off", ["on"]="on", ["strict"]="strict", ["very_strict"]="very_strict", [""]=""},
  ["jln-warnings-as-error"] = {["default"]="", ["off"]="off", ["on"]="on", ["basic"]="basic", [""]=""},
  ["warnings_as_error"] = {["default"]="", ["off"]="off", ["on"]="on", ["basic"]="basic", [""]=""},
  ["jln-whole-program"] = {["default"]="", ["off"]="off", ["on"]="on", ["strip_all"]="strip_all", [""]=""},
  ["whole_program"] = {["default"]="", ["off"]="off", ["on"]="on", ["strip_all"]="strip_all", [""]=""},
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
      color = options.color or options["jln-color"] or (disable_other_options and "" or _flag_names.color[get_config("jln-color")]),
      control_flow = options.control_flow or options["jln-control-flow"] or (disable_other_options and "" or _flag_names.control_flow[get_config("jln-control-flow")]),
      conversion_warnings = options.conversion_warnings or options["jln-conversion-warnings"] or (disable_other_options and "" or _flag_names.conversion_warnings[get_config("jln-conversion-warnings")]),
      coverage = options.coverage or options["jln-coverage"] or (disable_other_options and "" or _flag_names.coverage[get_config("jln-coverage")]),
      covered_switch_default_warnings = options.covered_switch_default_warnings or options["jln-covered-switch-default-warnings"] or (disable_other_options and "" or _flag_names.covered_switch_default_warnings[get_config("jln-covered-switch-default-warnings")]),
      cpu = options.cpu or options["jln-cpu"] or (disable_other_options and "" or _flag_names.cpu[get_config("jln-cpu")]),
      debug = options.debug or options["jln-debug"] or (disable_other_options and "" or _flag_names.debug[get_config("jln-debug")]),
      diagnostics_format = options.diagnostics_format or options["jln-diagnostics-format"] or (disable_other_options and "" or _flag_names.diagnostics_format[get_config("jln-diagnostics-format")]),
      diagnostics_show_template_tree = options.diagnostics_show_template_tree or options["jln-diagnostics-show-template-tree"] or (disable_other_options and "" or _flag_names.diagnostics_show_template_tree[get_config("jln-diagnostics-show-template-tree")]),
      elide_type = options.elide_type or options["jln-elide-type"] or (disable_other_options and "" or _flag_names.elide_type[get_config("jln-elide-type")]),
      exceptions = options.exceptions or options["jln-exceptions"] or (disable_other_options and "" or _flag_names.exceptions[get_config("jln-exceptions")]),
      fix_compiler_error = options.fix_compiler_error or options["jln-fix-compiler-error"] or (disable_other_options and "" or _flag_names.fix_compiler_error[get_config("jln-fix-compiler-error")]),
      float_sanitizers = options.float_sanitizers or options["jln-float-sanitizers"] or (disable_other_options and "" or _flag_names.float_sanitizers[get_config("jln-float-sanitizers")]),
      integer_sanitizers = options.integer_sanitizers or options["jln-integer-sanitizers"] or (disable_other_options and "" or _flag_names.integer_sanitizers[get_config("jln-integer-sanitizers")]),
      linker = options.linker or options["jln-linker"] or (disable_other_options and "" or _flag_names.linker[get_config("jln-linker")]),
      lto = options.lto or options["jln-lto"] or (disable_other_options and "" or _flag_names.lto[get_config("jln-lto")]),
      msvc_conformance = options.msvc_conformance or options["jln-msvc-conformance"] or (disable_other_options and "" or _flag_names.msvc_conformance[get_config("jln-msvc-conformance")]),
      msvc_crt_secure_no_warnings = options.msvc_crt_secure_no_warnings or options["jln-msvc-crt-secure-no-warnings"] or (disable_other_options and "" or _flag_names.msvc_crt_secure_no_warnings[get_config("jln-msvc-crt-secure-no-warnings")]),
      msvc_diagnostics_format = options.msvc_diagnostics_format or options["jln-msvc-diagnostics-format"] or (disable_other_options and "" or _flag_names.msvc_diagnostics_format[get_config("jln-msvc-diagnostics-format")]),
      msvc_isystem = options.msvc_isystem or options["jln-msvc-isystem"] or (disable_other_options and "" or _flag_names.msvc_isystem[get_config("jln-msvc-isystem")]),
      msvc_isystem_with_template_from_non_external = options.msvc_isystem_with_template_from_non_external or options["jln-msvc-isystem-with-template-from-non-external"] or (disable_other_options and "" or _flag_names.msvc_isystem_with_template_from_non_external[get_config("jln-msvc-isystem-with-template-from-non-external")]),
      ndebug = options.ndebug or options["jln-ndebug"] or (disable_other_options and "" or _flag_names.ndebug[get_config("jln-ndebug")]),
      noexcept_warnings = options.noexcept_warnings or options["jln-noexcept-warnings"] or (disable_other_options and "" or _flag_names.noexcept_warnings[get_config("jln-noexcept-warnings")]),
      optimization = options.optimization or options["jln-optimization"] or (disable_other_options and "" or _flag_names.optimization[get_config("jln-optimization")]),
      other_sanitizers = options.other_sanitizers or options["jln-other-sanitizers"] or (disable_other_options and "" or _flag_names.other_sanitizers[get_config("jln-other-sanitizers")]),
      pedantic = options.pedantic or options["jln-pedantic"] or (disable_other_options and "" or _flag_names.pedantic[get_config("jln-pedantic")]),
      pie = options.pie or options["jln-pie"] or (disable_other_options and "" or _flag_names.pie[get_config("jln-pie")]),
      relro = options.relro or options["jln-relro"] or (disable_other_options and "" or _flag_names.relro[get_config("jln-relro")]),
      reproducible_build_warnings = options.reproducible_build_warnings or options["jln-reproducible-build-warnings"] or (disable_other_options and "" or _flag_names.reproducible_build_warnings[get_config("jln-reproducible-build-warnings")]),
      rtti = options.rtti or options["jln-rtti"] or (disable_other_options and "" or _flag_names.rtti[get_config("jln-rtti")]),
      sanitizers = options.sanitizers or options["jln-sanitizers"] or (disable_other_options and "" or _flag_names.sanitizers[get_config("jln-sanitizers")]),
      shadow_warnings = options.shadow_warnings or options["jln-shadow-warnings"] or (disable_other_options and "" or _flag_names.shadow_warnings[get_config("jln-shadow-warnings")]),
      stack_protector = options.stack_protector or options["jln-stack-protector"] or (disable_other_options and "" or _flag_names.stack_protector[get_config("jln-stack-protector")]),
      stl_debug = options.stl_debug or options["jln-stl-debug"] or (disable_other_options and "" or _flag_names.stl_debug[get_config("jln-stl-debug")]),
      stl_fix = options.stl_fix or options["jln-stl-fix"] or (disable_other_options and "" or _flag_names.stl_fix[get_config("jln-stl-fix")]),
      suggestions = options.suggestions or options["jln-suggestions"] or (disable_other_options and "" or _flag_names.suggestions[get_config("jln-suggestions")]),
      switch_warnings = options.switch_warnings or options["jln-switch-warnings"] or (disable_other_options and "" or _flag_names.switch_warnings[get_config("jln-switch-warnings")]),
      unsafe_buffer_usage_warnings = options.unsafe_buffer_usage_warnings or options["jln-unsafe-buffer-usage-warnings"] or (disable_other_options and "" or _flag_names.unsafe_buffer_usage_warnings[get_config("jln-unsafe-buffer-usage-warnings")]),
      var_init = options.var_init or options["jln-var-init"] or (disable_other_options and "" or _flag_names.var_init[get_config("jln-var-init")]),
      warnings = options.warnings or options["jln-warnings"] or (disable_other_options and "" or _flag_names.warnings[get_config("jln-warnings")]),
      warnings_as_error = options.warnings_as_error or options["jln-warnings-as-error"] or (disable_other_options and "" or _flag_names.warnings_as_error[get_config("jln-warnings-as-error")]),
      whole_program = options.whole_program or options["jln-whole-program"] or (disable_other_options and "" or _flag_names.whole_program[get_config("jln-whole-program")]),
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
      ["color"] = _flag_names["color"][get_config("jln-color")],
      ["control_flow"] = _flag_names["control_flow"][get_config("jln-control-flow")],
      ["conversion_warnings"] = _flag_names["conversion_warnings"][get_config("jln-conversion-warnings")],
      ["coverage"] = _flag_names["coverage"][get_config("jln-coverage")],
      ["covered_switch_default_warnings"] = _flag_names["covered_switch_default_warnings"][get_config("jln-covered-switch-default-warnings")],
      ["cpu"] = _flag_names["cpu"][get_config("jln-cpu")],
      ["debug"] = _flag_names["debug"][get_config("jln-debug")],
      ["diagnostics_format"] = _flag_names["diagnostics_format"][get_config("jln-diagnostics-format")],
      ["diagnostics_show_template_tree"] = _flag_names["diagnostics_show_template_tree"][get_config("jln-diagnostics-show-template-tree")],
      ["elide_type"] = _flag_names["elide_type"][get_config("jln-elide-type")],
      ["exceptions"] = _flag_names["exceptions"][get_config("jln-exceptions")],
      ["fix_compiler_error"] = _flag_names["fix_compiler_error"][get_config("jln-fix-compiler-error")],
      ["float_sanitizers"] = _flag_names["float_sanitizers"][get_config("jln-float-sanitizers")],
      ["integer_sanitizers"] = _flag_names["integer_sanitizers"][get_config("jln-integer-sanitizers")],
      ["linker"] = _flag_names["linker"][get_config("jln-linker")],
      ["lto"] = _flag_names["lto"][get_config("jln-lto")],
      ["msvc_conformance"] = _flag_names["msvc_conformance"][get_config("jln-msvc-conformance")],
      ["msvc_crt_secure_no_warnings"] = _flag_names["msvc_crt_secure_no_warnings"][get_config("jln-msvc-crt-secure-no-warnings")],
      ["msvc_diagnostics_format"] = _flag_names["msvc_diagnostics_format"][get_config("jln-msvc-diagnostics-format")],
      ["msvc_isystem"] = _flag_names["msvc_isystem"][get_config("jln-msvc-isystem")],
      ["msvc_isystem_with_template_from_non_external"] = _flag_names["msvc_isystem_with_template_from_non_external"][get_config("jln-msvc-isystem-with-template-from-non-external")],
      ["ndebug"] = _flag_names["ndebug"][get_config("jln-ndebug")],
      ["noexcept_warnings"] = _flag_names["noexcept_warnings"][get_config("jln-noexcept-warnings")],
      ["optimization"] = _flag_names["optimization"][get_config("jln-optimization")],
      ["other_sanitizers"] = _flag_names["other_sanitizers"][get_config("jln-other-sanitizers")],
      ["pedantic"] = _flag_names["pedantic"][get_config("jln-pedantic")],
      ["pie"] = _flag_names["pie"][get_config("jln-pie")],
      ["relro"] = _flag_names["relro"][get_config("jln-relro")],
      ["reproducible_build_warnings"] = _flag_names["reproducible_build_warnings"][get_config("jln-reproducible-build-warnings")],
      ["rtti"] = _flag_names["rtti"][get_config("jln-rtti")],
      ["sanitizers"] = _flag_names["sanitizers"][get_config("jln-sanitizers")],
      ["shadow_warnings"] = _flag_names["shadow_warnings"][get_config("jln-shadow-warnings")],
      ["stack_protector"] = _flag_names["stack_protector"][get_config("jln-stack-protector")],
      ["stl_debug"] = _flag_names["stl_debug"][get_config("jln-stl-debug")],
      ["stl_fix"] = _flag_names["stl_fix"][get_config("jln-stl-fix")],
      ["suggestions"] = _flag_names["suggestions"][get_config("jln-suggestions")],
      ["switch_warnings"] = _flag_names["switch_warnings"][get_config("jln-switch-warnings")],
      ["unsafe_buffer_usage_warnings"] = _flag_names["unsafe_buffer_usage_warnings"][get_config("jln-unsafe-buffer-usage-warnings")],
      ["var_init"] = _flag_names["var_init"][get_config("jln-var-init")],
      ["warnings"] = _flag_names["warnings"][get_config("jln-warnings")],
      ["warnings_as_error"] = _flag_names["warnings_as_error"][get_config("jln-warnings-as-error")],
      ["whole_program"] = _flag_names["whole_program"][get_config("jln-whole-program")],
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
  ['clang-cl']=true,
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
          if options.optimization ~= "" then
            if not ( ( options.optimization == "0" or options.optimization == "g" ) ) then
              insert(jln_cxflags, "/DNDEBUG")
            end
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
          if options.optimization ~= "" then
            if not ( ( options.optimization == "0" or options.optimization == "g" ) ) then
              insert(jln_cxflags, "-DNDEBUG")
            end
          end
        end
      end
    end
  end
  if ( compiler == 'gcc' or is_clang_like ) then
    if options.warnings ~= "" then
      if options.warnings == "off" then
        insert(jln_cxflags, "-w")
      else
        if compiler == 'gcc' then
          insert(jln_cxflags, "-Wall")
          insert(jln_cxflags, "-Wextra")
          insert(jln_cxflags, "-Wcast-align")
          insert(jln_cxflags, "-Wcast-qual")
          insert(jln_cxflags, "-Wdisabled-optimization")
          insert(jln_cxflags, "-Wfloat-equal")
          insert(jln_cxflags, "-Wformat-security")
          insert(jln_cxflags, "-Wformat=2")
          insert(jln_cxflags, "-Winvalid-pch")
          insert(jln_cxflags, "-Wmissing-include-dirs")
          insert(jln_cxflags, "-Wpacked")
          insert(jln_cxflags, "-Wredundant-decls")
          insert(jln_cxflags, "-Wundef")
          insert(jln_cxflags, "-Wunused-macros")
          insert(jln_cxflags, "-Wpointer-arith")
          insert(jln_cxflags, "-Wmissing-declarations")
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
                insert(jln_cxflags, "-Wfloat-conversion")
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
                          insert(jln_cxflags, "-Wclass-memaccess")
                          if ( options.warnings == "strict" or options.warnings == "very_strict" ) then
                            insert(jln_cxflags, "-Wcast-align=strict")
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
      if ( is_clang_like and version >= 1600000 ) then
        if options.unsafe_buffer_usage_warnings == "off" then
          insert(jln_cxflags, "-Wno-unsafe-buffer-usage")
        else
          insert(jln_cxflags, "-Wunsafe-buffer-usage")
        end
      end
    end
    if options.diagnostics_show_template_tree ~= "" then
      if ( ( compiler == 'gcc' and version >= 800000 ) or is_clang_like ) then
        if options.diagnostics_show_template_tree == "on" then
          insert(jln_cxflags, "-fdiagnostics-show-template-tree")
        else
          insert(jln_cxflags, "-fno-diagnostics-show-template-tree")
        end
      end
    end
    if options.elide_type ~= "" then
      if options.elide_type == "on" then
        if ( compiler == 'gcc' and version >= 800000 ) then
          insert(jln_cxflags, "-felide-type")
        end
      else
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
    if options.rtti ~= "" then
      if options.rtti == "on" then
        insert(jln_cxflags, "-frtti")
      else
        insert(jln_cxflags, "-fno-rtti")
      end
    end
    if options.var_init ~= "" then
      if ( ( compiler == 'gcc' and version >= 1200000 ) or ( is_clang_like and version >= 800000 ) ) then
        if ( is_clang_like and version <= 1500000 ) then
          insert(jln_cxflags, "-enable-trivial-auto-var-init-zero-knowing-it-will-be-removed-from-clang")
        end
        if options.var_init == "pattern" then
          insert(jln_cxflags, "-ftrivial-auto-var-init=pattern")
        else
          if options.var_init == "zero" then
            insert(jln_cxflags, "-ftrivial-auto-var-init=zero")
          else
            insert(jln_cxflags, "-ftrivial-auto-var-init=uninitialized")
          end
        end
      end
    end
    if options.windows_abi_compatibility_warnings ~= "" then
      if ( ( compiler == 'gcc' and version >= 1000000 ) or is_clang_like ) then
        if options.windows_abi_compatibility_warnings == "on" then
          insert(jln_cxflags, "-Wmismatched-tags")
        else
          insert(jln_cxflags, "-Wno-mismatched-tags")
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
    if options.suggestions ~= "" then
      if options.suggestions ~= "off" then
        if compiler == 'gcc' then
          insert(jln_cxflags, "-Wsuggest-attribute=pure")
          insert(jln_cxflags, "-Wsuggest-attribute=const")
          if version >= 500000 then
            insert(jln_cxflags, "-Wsuggest-final-types")
            insert(jln_cxflags, "-Wsuggest-final-methods")
            if version >= 500001 then
              insert(jln_cxflags, "-Wnoexcept")
            end
          end
        end
      end
    end
    if options.sanitizers ~= "" then
      if options.sanitizers == "off" then
        insert(jln_cxflags, "-fno-sanitize=all")
        insert(jln_ldflags, "-fno-sanitize=all")
      else
        if compiler == 'clang-cl' then
          insert(jln_cxflags, "-fsanitize=undefined")
          insert(jln_cxflags, "-fsanitize=address")
          insert(jln_cxflags, "-fsanitize-address-use-after-scope")
        else
          if ( compiler == 'clang' or compiler == 'clang-emcc' ) then
            if version >= 300001 then
              insert(jln_cxflags, "-fsanitize=undefined")
              insert(jln_cxflags, "-fsanitize=address")
              insert(jln_cxflags, "-fsanitize-address-use-after-scope")
              insert(jln_cxflags, "-fno-omit-frame-pointer")
              insert(jln_cxflags, "-fno-optimize-sibling-calls")
              insert(jln_ldflags, "-fsanitize=undefined")
              insert(jln_ldflags, "-fsanitize=address")
              if compiler == 'clang' then
                if version >= 300004 then
                  insert(jln_cxflags, "-fsanitize=leak")
                  insert(jln_ldflags, "-fsanitize=leak")
                end
                if version >= 600000 then
                  if options.stack_protector ~= "" then
                    if options.stack_protector ~= "off" then
                      insert(jln_cxflags, "-fsanitize-minimal-runtime")
                    end
                  end
                end
              end
            end
          else
            if version >= 400008 then
              insert(jln_cxflags, "-fsanitize=address")
              insert(jln_cxflags, "-fno-omit-frame-pointer")
              insert(jln_cxflags, "-fno-optimize-sibling-calls")
              insert(jln_ldflags, "-fsanitize=address")
              if version >= 400009 then
                insert(jln_cxflags, "-fsanitize=undefined")
                insert(jln_cxflags, "-fsanitize=leak")
                insert(jln_ldflags, "-fsanitize=undefined")
                insert(jln_ldflags, "-fsanitize=leak")
              end
            end
          end
        end
      end
    end
    if options.control_flow ~= "" then
      if compiler == 'clang-emcc' then
        if options.control_flow == "off" then
          insert(jln_ldflags, "-sASSERTIONS=0")
          insert(jln_ldflags, "-sSAFE_HEAP=0")
        else
          insert(jln_ldflags, "-sASSERTIONS=1")
          insert(jln_ldflags, "-sDEMANGLE_SUPPORT=1")
          if  not ( ( options.sanitizers == "on" ) ) then
            insert(jln_ldflags, "-sSAFE_HEAP=1")
          end
        end
      else
        if options.control_flow == "off" then
          if ( compiler == 'gcc' and version >= 800000 ) then
            insert(jln_cxflags, "-fcf-protection=none")
          else
            insert(jln_cxflags, "-fno-sanitize=cfi")
            insert(jln_cxflags, "-fcf-protection=none")
            insert(jln_cxflags, "-fno-sanitize-cfi-cross-dso")
            insert(jln_ldflags, "-fno-sanitize=cfi")
          end
        else
          if ( ( compiler == 'gcc' and version >= 800000 ) or compiler ~= 'gcc' ) then
            if options.control_flow == "branch" then
              insert(jln_cxflags, "-fcf-protection=branch")
            else
              if options.control_flow == "return" then
                insert(jln_cxflags, "-fcf-protection=return")
              else
                insert(jln_cxflags, "-fcf-protection=full")
              end
            end
            if ( options.control_flow == "allow_bugs" and compiler == 'clang' ) then
              insert(jln_cxflags, "-fsanitize=cfi")
              insert(jln_cxflags, "-fvisibility=hidden")
              insert(jln_cxflags, "-flto")
              insert(jln_ldflags, "-fsanitize=cfi")
              insert(jln_ldflags, "-flto")
            end
          end
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
    if options.reproducible_build_warnings ~= "" then
      if ( compiler == 'gcc' and version >= 400009 ) then
        if options.reproducible_build_warnings == "on" then
          insert(jln_cxflags, "-Wdate-time")
        else
          insert(jln_cxflags, "-Wno-date-time")
        end
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
    if options.fix_compiler_error ~= "" then
      if options.fix_compiler_error == "on" then
        if compiler == 'gcc' then
          if version >= 400007 then
            insert(jln_cxflags, "-Werror=narrowing")
            if version >= 700001 then
              insert(jln_cxflags, "-Werror=literal-suffix")
            end
          end
        end
        insert(jln_cxflags, "-Werror=write-strings")
      else
        if compiler ~= 'gcc' then
          insert(jln_cxflags, "-Wno-error=c++11-narrowing")
          insert(jln_cxflags, "-Wno-reserved-user-defined-literal")
        end
      end
    end
    if options.lto ~= "" then
      if options.lto == "off" then
        insert(jln_cxflags, "-fno-lto")
        insert(jln_ldflags, "-fno-lto")
      else
        if compiler == 'gcc' then
          insert(jln_cxflags, "-flto")
          insert(jln_ldflags, "-flto")
          if version >= 500000 then
            if options.warnings ~= "" then
              if options.warnings ~= "off" then
                insert(jln_cxflags, "-flto-odr-type-merging")
                insert(jln_ldflags, "-flto-odr-type-merging")
              end
            end
            if options.lto == "fat" then
              insert(jln_cxflags, "-ffat-lto-objects")
            else
              if options.lto == "thin" then
                insert(jln_ldflags, "-fuse-linker-plugin")
              end
            end
          end
        else
          if compiler == 'clang-cl' then
            insert(jln_ldflags, "-fuse-ld=lld")
          end
          if ( ( options.lto == "thin" or options.lto == "on" ) and version >= 600000 ) then
            insert(jln_cxflags, "-flto=thin")
            insert(jln_ldflags, "-flto=thin")
          else
            insert(jln_cxflags, "-flto")
            insert(jln_ldflags, "-flto")
          end
        end
      end
    end
    if options.shadow_warnings ~= "" then
      if options.shadow_warnings == "off" then
        insert(jln_cxflags, "-Wno-shadow")
        if ( is_clang_like and version >= 800000 ) then
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
    if options.float_sanitizers ~= "" then
      if ( ( compiler == 'gcc' and version >= 500000 ) or ( is_clang_like and version >= 500000 ) ) then
        if options.float_sanitizers == "on" then
          insert(jln_cxflags, "-fsanitize=float-divide-by-zero")
          insert(jln_cxflags, "-fsanitize=float-cast-overflow")
        else
          insert(jln_cxflags, "-fno-sanitize=float-divide-by-zero")
          insert(jln_cxflags, "-fno-sanitize=float-cast-overflow")
        end
      end
    end
    if options.integer_sanitizers ~= "" then
      if ( is_clang_like and version >= 500000 ) then
        if options.integer_sanitizers == "on" then
          insert(jln_cxflags, "-fsanitize=integer")
        else
          insert(jln_cxflags, "-fno-sanitize=integer")
        end
      else
        if ( compiler == 'gcc' and version >= 400009 ) then
          if options.integer_sanitizers == "on" then
            insert(jln_cxflags, "-ftrapv")
            insert(jln_cxflags, "-fsanitize=undefined")
          end
        end
      end
    end
  end
  if options.conversion_warnings ~= "" then
    if ( compiler == 'gcc' or is_clang_like or compiler == 'icc' ) then
      if options.conversion_warnings == "on" then
        insert(jln_cxflags, "-Wconversion")
        insert(jln_cxflags, "-Wsign-compare")
        insert(jln_cxflags, "-Wsign-conversion")
      else
        if options.conversion_warnings == "conversion" then
          insert(jln_cxflags, "-Wconversion")
        else
          if options.conversion_warnings == "sign" then
            insert(jln_cxflags, "-Wsign-compare")
            insert(jln_cxflags, "-Wsign-conversion")
          else
            insert(jln_cxflags, "-Wno-conversion")
            insert(jln_cxflags, "-Wno-sign-compare")
            insert(jln_cxflags, "-Wno-sign-conversion")
          end
        end
      end
    end
  end
  if ( compiler == 'gcc' or compiler == 'clang' or compiler == 'clang-emcc' ) then
    if options.stl_debug ~= "" then
      if options.stl_debug ~= "off" then
        if options.stl_debug == "assert_as_exception" then
          insert(jln_cxflags, "-D_LIBCPP_DEBUG_USE_EXCEPTIONS")
        end
        if ( options.stl_debug == "allow_broken_abi" or options.stl_debug == "allow_broken_abi_and_bugs" ) then
          if compiler == 'clang' then
            if ( version >= 800000 or options.stl_debug == "allow_broken_abi_and_bugs" ) then
              insert(jln_cxflags, "-D_LIBCPP_DEBUG=1")
            end
          end
          insert(jln_cxflags, "-D_GLIBCXX_DEBUG")
        else
          insert(jln_cxflags, "-D_GLIBCXX_ASSERTIONS")
        end
        if options.pedantic ~= "" then
          if options.pedantic ~= "off" then
            insert(jln_cxflags, "-D_GLIBCXX_DEBUG_PEDANTIC")
          end
        end
      end
    end
    if options.pedantic ~= "" then
      if options.pedantic ~= "off" then
        insert(jln_cxflags, "-pedantic")
        if options.pedantic == "as_error" then
          insert(jln_cxflags, "-pedantic-errors")
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
    if options.debug ~= "" then
      if options.debug == "off" then
        insert(jln_cxflags, "-g0")
      else
        insert(jln_cxflags, "-g")
      end
    end
  else
    if ( compiler == 'gcc' or compiler == 'clang' ) then
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
      if options.debug ~= "" then
        if options.debug == "off" then
          insert(jln_cxflags, "-g0")
        else
          if options.debug == "gdb" then
            insert(jln_cxflags, "-ggdb")
          else
            if compiler == 'clang' then
              if options.debug == "line_tables_only" then
                insert(jln_cxflags, "-gline-tables-only")
              else
                if options.debug == "lldb" then
                  insert(jln_cxflags, "-glldb")
                else
                  if options.debug == "sce" then
                    insert(jln_cxflags, "-gsce")
                  else
                    insert(jln_cxflags, "-g")
                  end
                end
              end
            else
              insert(jln_cxflags, "-g")
            end
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
                      if compiler == 'clang' then
                        insert(jln_cxflags, "-Oz")
                      else
                        insert(jln_cxflags, "-Os")
                      end
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
              if options.lto ~= "" then
                if ( options.lto ~= "off" and compiler == 'gcc' ) then
                  insert(jln_ldflags, "-fuse-ld=gold")
                else
                  insert(jln_ldflags, "-fuse-ld=lld")
                end
              else
                insert(jln_ldflags, "-fuse-ld=lld")
              end
            end
          end
        end
      end
      if options.whole_program ~= "" then
        if options.whole_program == "off" then
          insert(jln_cxflags, "-fno-whole-program")
          if ( compiler == 'clang' and version >= 300009 ) then
            insert(jln_cxflags, "-fno-whole-program-vtables")
            insert(jln_ldflags, "-fno-whole-program-vtables")
          end
        else
          if linker == 'ld64' then
            insert(jln_ldflags, "-Wl,-dead_strip")
            insert(jln_ldflags, "-Wl,-S")
          else
            insert(jln_ldflags, "-s")
            if options.whole_program == "strip_all" then
              insert(jln_ldflags, "-Wl,--gc-sections")
              insert(jln_ldflags, "-Wl,--strip-all")
            end
          end
          if compiler == 'gcc' then
            insert(jln_cxflags, "-fwhole-program")
            insert(jln_ldflags, "-fwhole-program")
          else
            if compiler == 'clang' then
              if version >= 300009 then
                if options.lto ~= "" then
                  if options.lto ~= "off" then
                    insert(jln_cxflags, "-fwhole-program-vtables")
                    insert(jln_ldflags, "-fwhole-program-vtables")
                  end
                end
                if version >= 700000 then
                  insert(jln_cxflags, "-fforce-emit-vtables")
                  insert(jln_ldflags, "-fforce-emit-vtables")
                end
              end
            end
          end
        end
      end
      if options.stack_protector ~= "" then
        if options.stack_protector == "off" then
          insert(jln_cxflags, "-Wno-stack-protector")
          insert(jln_cxflags, "-U_FORTIFY_SOURCE")
          insert(jln_ldflags, "-Wno-stack-protector")
        else
          insert(jln_cxflags, "-D_FORTIFY_SOURCE=2")
          insert(jln_cxflags, "-Wstack-protector")
          if options.stack_protector == "strong" then
            if compiler == 'gcc' then
              if version >= 400009 then
                insert(jln_cxflags, "-fstack-protector-strong")
                insert(jln_ldflags, "-fstack-protector-strong")
                if version >= 800000 then
                  insert(jln_cxflags, "-fstack-clash-protection")
                  insert(jln_ldflags, "-fstack-clash-protection")
                end
              end
            else
              if compiler == 'clang' then
                insert(jln_cxflags, "-fstack-protector-strong")
                insert(jln_cxflags, "-fsanitize=safe-stack")
                insert(jln_ldflags, "-fstack-protector-strong")
                insert(jln_ldflags, "-fsanitize=safe-stack")
                if version >= 1100000 then
                  insert(jln_cxflags, "-fstack-clash-protection")
                  insert(jln_ldflags, "-fstack-clash-protection")
                end
              end
            end
          else
            if options.stack_protector == "all" then
              insert(jln_cxflags, "-fstack-protector-all")
              insert(jln_ldflags, "-fstack-protector-all")
              if ( compiler == 'gcc' and version >= 800000 ) then
                insert(jln_cxflags, "-fstack-clash-protection")
                insert(jln_ldflags, "-fstack-clash-protection")
              else
                if compiler == 'clang' then
                  insert(jln_cxflags, "-fsanitize=safe-stack")
                  insert(jln_ldflags, "-fsanitize=safe-stack")
                  if version >= 1100000 then
                    insert(jln_cxflags, "-fstack-clash-protection")
                    insert(jln_ldflags, "-fstack-clash-protection")
                  end
                end
              end
            else
              insert(jln_cxflags, "-fstack-protector")
              insert(jln_ldflags, "-fstack-protector")
            end
          end
          if compiler == 'clang' then
            insert(jln_cxflags, "-fsanitize=shadow-call-stack")
            insert(jln_ldflags, "-fsanitize=shadow-call-stack")
          end
        end
      end
      if options.relro ~= "" then
        if options.relro == "off" then
          insert(jln_ldflags, "-Wl,-z,norelro")
        else
          if options.relro == "on" then
            insert(jln_ldflags, "-Wl,-z,relro")
          else
            insert(jln_ldflags, "-Wl,-z,relro,-z,now,-z,noexecstack")
            if options.linker ~= "" then
              if not ( ( options.linker == "gold" or ( compiler == 'gcc' and version < 900000 ) or ( options.linker == "native" and compiler == 'gcc' ) ) ) then
                insert(jln_ldflags, "-Wl,-z,separate-code")
              end
            end
          end
        end
      end
      if options.pie ~= "" then
        if options.pie == "off" then
          insert(jln_ldflags, "-no-pic")
        else
          if options.pie == "on" then
            insert(jln_ldflags, "-pie")
          else
            if options.pie == "fpie" then
              insert(jln_cxflags, "-fpie")
            else
              if options.pie == "fpic" then
                insert(jln_cxflags, "-fpic")
              else
                if options.pie == "fPIE" then
                  insert(jln_cxflags, "-fPIE")
                else
                  if options.pie == "fPIC" then
                    insert(jln_cxflags, "-fPIC")
                  else
                    insert(jln_ldflags, "-static-pie")
                  end
                end
              end
            end
          end
        end
      end
      if options.other_sanitizers ~= "" then
        if options.other_sanitizers == "thread" then
          insert(jln_cxflags, "-fsanitize=thread")
        else
          if options.other_sanitizers == "memory" then
            if ( compiler == 'clang' and version >= 500000 ) then
              insert(jln_cxflags, "-fsanitize=memory")
              insert(jln_cxflags, "-fno-omit-frame-pointer")
            end
          else
            if options.other_sanitizers == "pointer" then
              if ( compiler == 'gcc' and version >= 800000 ) then
                insert(jln_cxflags, "-fsanitize=pointer-compare")
                insert(jln_cxflags, "-fsanitize=pointer-subtract")
              end
            end
          end
        end
      end
      if options.noexcept_warnings ~= "" then
        if ( compiler == 'gcc' and version >= 400009 ) then
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
            if options.analyzer == "taint" then
              insert(jln_cxflags, "-fanalyzer-checker=taint")
            end
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
  if linker == 'lld-link' then
    if options.lto ~= "" then
      if options.lto == "off" then
        insert(jln_cxflags, "-fno-lto")
      else
        if ( options.lto == "thin" or options.lto == "on" ) then
          insert(jln_cxflags, "-flto=thin")
        else
          insert(jln_cxflags, "-flto")
          insert(jln_ldflags, "-flto")
        end
      end
    end
    if options.whole_program ~= "" then
      if options.whole_program == "off" then
        insert(jln_cxflags, "-fno-whole-program")
      else
        if options.lto ~= "" then
          if options.lto ~= "off" then
            insert(jln_cxflags, "-fwhole-program-vtables")
            insert(jln_ldflags, "-fwhole-program-vtables")
          end
        end
      end
    end
  end
  if ( compiler == 'cl' or compiler == 'clang-cl' or compiler == 'icl' ) then
    if options.exceptions ~= "" then
      if options.exceptions == "on" then
        insert(jln_cxflags, "/EHsc")
        insert(jln_cxflags, "/D_HAS_EXCEPTIONS=1")
      else
        insert(jln_cxflags, "/EHs-")
        insert(jln_cxflags, "/D_HAS_EXCEPTIONS=0")
      end
    end
    if options.rtti ~= "" then
      if options.rtti == "on" then
        insert(jln_cxflags, "/GR")
      else
        insert(jln_cxflags, "/GR-")
      end
    end
    if options.stl_debug ~= "" then
      if options.stl_debug == "off" then
        insert(jln_cxflags, "/D_HAS_ITERATOR_DEBUGGING=0")
      else
        insert(jln_cxflags, "/D_DEBUG")
        insert(jln_cxflags, "/D_HAS_ITERATOR_DEBUGGING=1")
      end
    end
    if options.stl_fix ~= "" then
      if options.stl_fix == "on" then
        insert(jln_cxflags, "/DNOMINMAX")
      end
    end
    if compiler ~= 'icl' then
      if options.debug ~= "" then
        if options.debug == "off" then
          insert(jln_cxflags, "/DEBUG:NONE")
        else
          insert(jln_cxflags, "/RTC1")
          insert(jln_cxflags, "/Od")
          if options.debug == "on" then
            insert(jln_cxflags, "/DEBUG")
          else
            if options.debug == "line_tables_only" then
              if compiler == 'clang-cl' then
                insert(jln_cxflags, "-gline-tables-only")
              end
              insert(jln_cxflags, "/DEBUG:FASTLINK")
            end
          end
          if options.optimization ~= "" then
            if options.optimization == "g" then
              insert(jln_cxflags, "/Zi")
            else
              if options.whole_program ~= "" then
                if options.whole_program == "off" then
                  insert(jln_cxflags, "/ZI")
                else
                  insert(jln_cxflags, "/Zi")
                end
              else
                insert(jln_cxflags, "/ZI")
              end
            end
          else
            if options.whole_program ~= "" then
              if options.whole_program == "off" then
                insert(jln_cxflags, "/ZI")
              else
                insert(jln_cxflags, "/Zi")
              end
            else
              insert(jln_cxflags, "/ZI")
            end
          end
        end
      end
      if options.optimization ~= "" then
        if options.optimization == "0" then
          insert(jln_cxflags, "/Ob0")
          insert(jln_cxflags, "/Od")
          insert(jln_cxflags, "/Oi-")
          insert(jln_cxflags, "/Oy-")
        else
          if options.optimization == "g" then
            insert(jln_cxflags, "/Ob1")
          else
            if options.optimization == "1" then
              insert(jln_cxflags, "/O1")
            else
              if options.optimization == "2" then
                insert(jln_cxflags, "/O2")
              else
                if options.optimization == "3" then
                  insert(jln_cxflags, "/O2")
                else
                  if ( options.optimization == "size" or options.optimization == "z" ) then
                    insert(jln_cxflags, "/O1")
                    insert(jln_cxflags, "/GL")
                    insert(jln_cxflags, "/Gw")
                  else
                    insert(jln_cxflags, "/O2")
                    insert(jln_cxflags, "/fp:fast")
                  end
                end
              end
            end
          end
        end
      end
      if options.linker ~= "" then
        if compiler == 'clang-cl' then
          if ( options.linker == "lld" or options.linker == "native" ) then
            insert(jln_ldflags, "-fuse-ld=lld")
          end
        end
      end
      if options.control_flow ~= "" then
        if options.control_flow == "off" then
          insert(jln_cxflags, "/guard:cf-")
        else
          insert(jln_cxflags, "/guard:cf")
        end
      end
      if options.whole_program ~= "" then
        if options.whole_program == "off" then
          insert(jln_cxflags, "/GL-")
        else
          insert(jln_cxflags, "/GL")
          insert(jln_cxflags, "/Gw")
          insert(jln_ldflags, "/LTCG")
          if options.whole_program == "strip_all" then
            insert(jln_ldflags, "/OPT:REF")
          end
        end
      end
      if options.pedantic ~= "" then
        if options.pedantic ~= "off" then
          insert(jln_cxflags, "/permissive-")
          insert(jln_cxflags, "/Zc:__cplusplus")
        end
      end
      if options.stack_protector ~= "" then
        if options.stack_protector == "off" then
          insert(jln_cxflags, "/GS-")
        else
          insert(jln_cxflags, "/GS")
          insert(jln_cxflags, "/sdl")
          if options.stack_protector == "strong" then
            insert(jln_cxflags, "/RTC1")
            if ( compiler == 'cl' and version >= 1600007 ) then
              insert(jln_cxflags, "/guard:ehcont")
              insert(jln_ldflags, "/CETCOMPAT")
            end
          else
            if options.stack_protector == "all" then
              insert(jln_cxflags, "/RTC1")
              insert(jln_cxflags, "/RTCc")
            end
          end
        end
      end
    end
  end
  if compiler == 'cl' then
    if options.windows_bigobj ~= "" then
      insert(jln_cxflags, "/bigobj")
    end
    if options.msvc_conformance ~= "" then
      if ( options.msvc_conformance == "all" or options.msvc_conformance == "all_without_throwing_new" ) then
        insert(jln_cxflags, "/Zc:inline")
        insert(jln_cxflags, "/Zc:referenceBinding")
        if options.msvc_conformance == "all" then
          insert(jln_cxflags, "/Zc:throwingNew")
        end
        if version >= 1500006 then
          insert(jln_cxflags, "/Zc:externConstexpr")
          if version >= 1600005 then
            insert(jln_cxflags, "/Zc:preprocessor")
            if version >= 1600008 then
              insert(jln_cxflags, "/Zc:lambda")
              if version >= 1700004 then
                insert(jln_cxflags, "/Zc:enumTypes")
                if version >= 1700005 then
                  insert(jln_cxflags, "/Zc:templateScope")
                end
              end
            end
          end
        end
      end
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
      if version >= 1700000 then
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
    if version < 1500016 then
      options.msvc_isystem = ""
    end
    if options.msvc_isystem ~= "" then
      if options.msvc_isystem == "external_as_include_system_flag" then
        if version < 1600010 then
          -- unimplementable
        else
          -- unimplementable
        end
      else
        if version < 1600010 then
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
      if options.msvc_isystem_with_template_from_non_external ~= "" then
        if options.msvc_isystem_with_template_from_non_external == "off" then
          insert(jln_cxflags, "/external:template")
        else
          insert(jln_cxflags, "/external:template-")
        end
      end
      if options.warnings ~= "" then
        if options.warnings == "off" then
          insert(jln_cxflags, "/W0")
        else
          insert(jln_cxflags, "/wd4710")
          insert(jln_cxflags, "/wd4711")
          if version < 1900021 then
            insert(jln_cxflags, "/wd4774")
          end
          if options.warnings == "on" then
            insert(jln_cxflags, "/W4")
            insert(jln_cxflags, "/wd4514")
          else
            insert(jln_cxflags, "/Wall")
            insert(jln_cxflags, "/wd4514")
            insert(jln_cxflags, "/wd4571")
            insert(jln_cxflags, "/wd4355")
            insert(jln_cxflags, "/wd4548")
            insert(jln_cxflags, "/wd4577")
            insert(jln_cxflags, "/wd4820")
            insert(jln_cxflags, "/wd5039")
            insert(jln_cxflags, "/wd4464")
            insert(jln_cxflags, "/wd4868")
            insert(jln_cxflags, "/wd5045")
            if options.warnings == "strict" then
              insert(jln_cxflags, "/wd4583")
              insert(jln_cxflags, "/wd4619")
            end
          end
        end
      end
      if options.switch_warnings ~= "" then
        if ( options.switch_warnings == "on" or options.switch_warnings == "mandatory_default" ) then
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
    else
      if options.warnings ~= "" then
        if options.warnings == "off" then
          insert(jln_cxflags, "/W0")
        else
          if options.warnings == "on" then
            insert(jln_cxflags, "/W4")
            insert(jln_cxflags, "/wd4514")
            insert(jln_cxflags, "/wd4711")
          else
            insert(jln_cxflags, "/Wall")
            insert(jln_cxflags, "/wd4355")
            insert(jln_cxflags, "/wd4514")
            insert(jln_cxflags, "/wd4548")
            insert(jln_cxflags, "/wd4571")
            insert(jln_cxflags, "/wd4577")
            insert(jln_cxflags, "/wd4625")
            insert(jln_cxflags, "/wd4626")
            insert(jln_cxflags, "/wd4668")
            insert(jln_cxflags, "/wd4710")
            insert(jln_cxflags, "/wd4711")
            if version < 1900021 then
              insert(jln_cxflags, "/wd4774")
            end
            insert(jln_cxflags, "/wd4820")
            insert(jln_cxflags, "/wd5026")
            insert(jln_cxflags, "/wd5027")
            insert(jln_cxflags, "/wd5039")
            insert(jln_cxflags, "/wd4464")
            insert(jln_cxflags, "/wd4868")
            insert(jln_cxflags, "/wd5045")
            if options.warnings == "strict" then
              insert(jln_cxflags, "/wd4061")
              insert(jln_cxflags, "/wd4266")
              insert(jln_cxflags, "/wd4583")
              insert(jln_cxflags, "/wd4619")
              insert(jln_cxflags, "/wd4623")
              insert(jln_cxflags, "/wd5204")
            end
          end
        end
      end
    end
    if options.conversion_warnings ~= "" then
      if options.conversion_warnings == "on" then
        insert(jln_cxflags, "/w14244")
        insert(jln_cxflags, "/w14245")
        insert(jln_cxflags, "/w14388")
        insert(jln_cxflags, "/w14365")
      else
        if options.conversion_warnings == "conversion" then
          insert(jln_cxflags, "/w14244")
          insert(jln_cxflags, "/w14365")
        else
          if options.conversion_warnings == "sign" then
            insert(jln_cxflags, "/w14388")
            insert(jln_cxflags, "/w14245")
          else
            insert(jln_cxflags, "/wd4244")
            insert(jln_cxflags, "/wd4365")
            insert(jln_cxflags, "/wd4388")
            insert(jln_cxflags, "/wd4245")
          end
        end
      end
    end
    if options.shadow_warnings ~= "" then
      if options.shadow_warnings == "off" then
        insert(jln_cxflags, "/wd4456")
        insert(jln_cxflags, "/wd4459")
      else
        if ( options.shadow_warnings == "on" or options.shadow_warnings == "all" ) then
          insert(jln_cxflags, "/w4456")
          insert(jln_cxflags, "/w4459")
        else
          if options.shadow_warnings == "local" then
            insert(jln_cxflags, "/w4456")
            insert(jln_cxflags, "/wd4459")
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
    if options.lto ~= "" then
      if options.lto == "off" then
        insert(jln_cxflags, "/LTCG:OFF")
      else
        insert(jln_cxflags, "/GL")
        insert(jln_ldflags, "/LTCG")
      end
    end
    if options.sanitizers ~= "" then
      if version >= 1600009 then
        insert(jln_cxflags, "/fsanitize=address")
        insert(jln_cxflags, "/fsanitize-address-use-after-return")
      else
        if options.sanitizers == "on" then
          insert(jln_cxflags, "/sdl")
        else
          if options.stack_protector ~= "" then
            if options.stack_protector ~= "off" then
              insert(jln_cxflags, "/sdl-")
            end
          end
        end
      end
    end
  end
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
    if options.msvc_conformance ~= "" then
      if ( options.msvc_conformance == "all" or options.msvc_conformance == "all_without_throwing_new" ) then
        insert(jln_cxflags, "/Zc:inline")
        insert(jln_cxflags, "/Zc:strictStrings")
        if options.msvc_conformance == "all" then
          insert(jln_cxflags, "/Zc:throwingNew")
        end
      end
    end
    if options.debug ~= "" then
      if options.debug == "off" then
        insert(jln_cxflags, "/debug:NONE")
      else
        insert(jln_cxflags, "/RTC1")
        insert(jln_cxflags, "/Od")
        if options.debug == "on" then
          insert(jln_cxflags, "/debug:full")
        else
          if options.debug == "line_tables_only" then
            insert(jln_cxflags, "/debug:minimal")
          end
        end
        if ( options.optimization == "g" ) then
          insert(jln_cxflags, "/Zi")
        else
          if options.whole_program ~= "" then
            if options.whole_program == "off" then
              insert(jln_cxflags, "/ZI")
            else
              insert(jln_cxflags, "/Zi")
            end
          else
            insert(jln_cxflags, "/ZI")
          end
        end
      end
    end
    if options.optimization ~= "" then
      if options.optimization == "0" then
        insert(jln_cxflags, "/Ob0")
        insert(jln_cxflags, "/Od")
        insert(jln_cxflags, "/Oi-")
        insert(jln_cxflags, "/Oy-")
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
    if options.stack_protector ~= "" then
      if options.stack_protector == "off" then
        insert(jln_cxflags, "/GS-")
      else
        insert(jln_cxflags, "/GS")
        if options.stack_protector == "strong" then
          insert(jln_cxflags, "/RTC1")
        else
          if options.stack_protector == "all" then
            insert(jln_cxflags, "/RTC1")
            insert(jln_cxflags, "/RTCc")
          end
        end
      end
    end
    if options.sanitizers ~= "" then
      if options.sanitizers == "on" then
        insert(jln_cxflags, "/Qtrapuv")
      end
    end
    if options.float_sanitizers ~= "" then
      if options.float_sanitizers == "on" then
        insert(jln_cxflags, "/Qfp-stack-check")
        insert(jln_cxflags, "/Qfp-trap:common")
      end
    end
    if options.control_flow ~= "" then
      if options.control_flow == "off" then
        insert(jln_cxflags, "/guard:cf-")
        insert(jln_cxflags, "/mconditional-branch=keep")
      else
        insert(jln_cxflags, "/guard:cf")
        if options.control_flow == "branch" then
          insert(jln_cxflags, "/mconditional-branch:all-fix")
          insert(jln_cxflags, "/Qcf-protection:branch")
        else
          if options.control_flow == "on" then
            insert(jln_cxflags, "/mconditional-branch:all-fix")
            insert(jln_cxflags, "/Qcf-protection:full")
          end
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
          insert(jln_cxflags, "-Wparentheses")
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
      if options.stl_debug ~= "" then
        if options.stl_debug ~= "off" then
          if ( options.stl_debug == "allow_broken_abi" or options.stl_debug == "allow_broken_abi_and_bugs" ) then
            insert(jln_cxflags, "-D_GLIBCXX_DEBUG")
          else
            insert(jln_cxflags, "-D_GLIBCXX_ASSERTIONS")
          end
        end
      end
      if options.debug ~= "" then
        if options.debug == "off" then
          insert(jln_cxflags, "-g0")
        else
          insert(jln_cxflags, "-g")
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
      if options.stack_protector ~= "" then
        if options.stack_protector == "off" then
          insert(jln_cxflags, "-fno-protector-strong")
          insert(jln_cxflags, "-U_FORTIFY_SOURCE")
          insert(jln_ldflags, "-fno-protector-strong")
        else
          insert(jln_cxflags, "-D_FORTIFY_SOURCE=2")
          if options.stack_protector == "strong" then
            insert(jln_cxflags, "-fstack-protector-strong")
            insert(jln_ldflags, "-fstack-protector-strong")
          else
            if options.stack_protector == "all" then
              insert(jln_cxflags, "-fstack-protector-all")
              insert(jln_ldflags, "-fstack-protector-all")
            else
              insert(jln_cxflags, "-fstack-protector")
              insert(jln_ldflags, "-fstack-protector")
            end
          end
        end
      end
      if options.relro ~= "" then
        if options.relro == "off" then
          insert(jln_ldflags, "-Xlinker-znorelro")
        else
          if options.relro == "on" then
            insert(jln_ldflags, "-Xlinker-zrelro")
          else
            insert(jln_ldflags, "-Xlinker-zrelro")
            insert(jln_ldflags, "-Xlinker-znow")
            insert(jln_ldflags, "-Xlinker-znoexecstack")
          end
        end
      end
      if options.pie ~= "" then
        if options.pie == "off" then
          insert(jln_ldflags, "-no-pic")
        else
          if options.pie == "on" then
            insert(jln_ldflags, "-pie")
          else
            if options.pie == "fpie" then
              insert(jln_cxflags, "-fpie")
            else
              if options.pie == "fpic" then
                insert(jln_cxflags, "-fpic")
              else
                if options.pie == "fPIE" then
                  insert(jln_cxflags, "-fPIE")
                else
                  if options.pie == "fPIC" then
                    insert(jln_cxflags, "-fPIC")
                  end
                end
              end
            end
          end
        end
      end
      if options.sanitizers ~= "" then
        if options.sanitizers == "on" then
          insert(jln_cxflags, "-ftrapuv")
        end
      end
      if options.integer_sanitizers ~= "" then
        if options.integer_sanitizers == "on" then
          insert(jln_cxflags, "-funsigned-bitfields")
        else
          insert(jln_cxflags, "-fno-unsigned-bitfields")
        end
      end
      if options.float_sanitizers ~= "" then
        if options.float_sanitizers == "on" then
          insert(jln_cxflags, "-fp-stack-check")
          insert(jln_cxflags, "-fp-trap=common")
        end
      end
      if options.linker ~= "" then
        if options.linker == "bfd" then
          insert(jln_ldflags, "-fuse-ld=bfd")
        else
          if options.linker == "gold" then
            insert(jln_ldflags, "-fuse-ld=gold")
          else
            insert(jln_ldflags, "-fuse-ld=lld")
          end
        end
      end
      if options.lto ~= "" then
        if options.lto == "off" then
          insert(jln_cxflags, "-no-ipo")
          insert(jln_ldflags, "-no-ipo")
        else
          insert(jln_cxflags, "-ipo")
          insert(jln_ldflags, "-ipo")
          if options.lto == "fat" then
            if is_plat("linux") then
              insert(jln_cxflags, "-ffat-lto-objects")
              insert(jln_ldflags, "-ffat-lto-objects")
            end
          end
        end
      end
      if options.control_flow ~= "" then
        if options.control_flow == "off" then
          insert(jln_cxflags, "-mconditional-branch=keep")
          insert(jln_cxflags, "-fcf-protection=none")
        else
          if options.control_flow == "branch" then
            insert(jln_cxflags, "-mconditional-branch=all-fix")
            insert(jln_cxflags, "-fcf-protection=branch")
          else
            if options.control_flow == "on" then
              insert(jln_cxflags, "-mconditional-branch=all-fix")
              insert(jln_cxflags, "-fcf-protection=full")
            end
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
    end
  end
  if is_plat("mingw") then
    if options.windows_bigobj ~= "" then
      insert(jln_cxflags, "-Wa,-mbig-obj")
    end
  end
  return {cxxflags=jln_cxflags, ldflags=jln_ldflags}
end

