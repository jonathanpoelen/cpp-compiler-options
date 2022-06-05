--  ```lua
--  -- launch example: xmake f --jln-sanitizers=on
--  
--  includes'cpp'
--  
--  -- Registers new command-line options and set default values
--  jln_cxx_init_options({warnings='very_strict'} --[[, category=string|boolean]])
--  
--  -- Set options for a specific mode (see also jln_cxx_rule())
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
--  jln_cxx_rule('custom_rule', {warnings_as_error='on'} --[[, disable_other_options = false]])
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
--      -- see also getoptions() and tovalues()
--      local options = flags.setoptions(target, {elide_type='on'} --[[, disable_other_options = false]])
--      print(options)
--    end)
--    add_files('src/hello.cpp')
--  
--  
--  -- jln_options can have 3 additional fields:
--  --  - `cxx`: (C++ only) compiler name (otherwise deducted from --cxx and --toolchain)
--  --  - `cc`: (C only) compiler name (otherwise deducted from --cc and --toolchain)
--  --  - `cxx_version` (C++ only) (otherwise deducted from cxx)
--  --  - `cc_version` (C only) (otherwise deducted from cc)
--  --  - `ld`: linker name
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
--  conversion_warnings = on default off sign conversion
--  covered_switch_default_warnings = on default off
--  fix_compiler_error = on default off
--  msvc_crt_secure_no_warnings = on default off
--  noexcept_warnings = default off on
--  reproducible_build_warnings = default off on
--  shadow_warnings = off default on local compatible_local all
--  suggestions = default off on
--  switch_warnings = on default off exhaustive_enum mandatory_default exhaustive_enum_and_mandatory_default
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
--  other_sanitizers = default off thread pointer memory
--  sanitizers = default off on
--  stl_debug = default off on allow_broken_abi allow_broken_abi_and_bugs assert_as_exception
--  
--  # Optimization:
--  
--  cpu = default generic native
--  linker = default bfd gold lld native
--  lto = default off on fat thin
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
--  msvc_isystem = default anglebrackets include_and_caexcludepath external_as_include_system_flag
--  msvc_isystem_with_template_from_non_external = default off on
--  pie = default off on static fpic fPIC fpie fPIE
--  windows_bigobj = on default
--  ```
--  <!-- ./compiler-options.lua -->
--  
--  The value `default` does nothing.
--  
--  If not specified, `conversion_warnings`, `covered_switch_default_warnings`, `fix_compiler_error`, `msvc_crt_secure_no_warnings`, `pedantic`, `stl_fix`, `switch_warnings`, `warnings` and `windows_bigobj` are `on` ; `msvc_conformance` are `all` ; `shadow_warnings` and `windows_abi_compatibility_warnings` are `off`.
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
  ["jln-cc"] = true,
  ["cc"] = true,
  ["jln-cc-version"] = true,
  ["cc_version"] = true,
  ["jln-ld"] = true,
  ["ld"] = true,
}

local _flag_names = {
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
  ["jln-lto"] = {["default"]="", ["off"]="off", ["on"]="on", ["fat"]="fat", ["thin"]="thin", [""]=""},
  ["lto"] = {["default"]="", ["off"]="off", ["on"]="on", ["fat"]="fat", ["thin"]="thin", [""]=""},
  ["jln-msvc-conformance"] = {["default"]="", ["all"]="all", ["all_without_throwing_new"]="all_without_throwing_new", [""]=""},
  ["msvc_conformance"] = {["default"]="", ["all"]="all", ["all_without_throwing_new"]="all_without_throwing_new", [""]=""},
  ["jln-msvc-crt-secure-no-warnings"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["msvc_crt_secure_no_warnings"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["jln-msvc-isystem"] = {["default"]="", ["anglebrackets"]="anglebrackets", ["include_and_caexcludepath"]="include_and_caexcludepath", [""]=""},
  ["msvc_isystem"] = {["default"]="", ["anglebrackets"]="anglebrackets", ["include_and_caexcludepath"]="include_and_caexcludepath", [""]=""},
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
  ["jln-sanitizers"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["sanitizers"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["jln-shadow-warnings"] = {["default"]="", ["off"]="off", ["on"]="on", ["local"]="local", ["compatible_local"]="compatible_local", ["all"]="all", [""]=""},
  ["shadow_warnings"] = {["default"]="", ["off"]="off", ["on"]="on", ["local"]="local", ["compatible_local"]="compatible_local", ["all"]="all", [""]=""},
  ["jln-stack-protector"] = {["default"]="", ["off"]="off", ["on"]="on", ["strong"]="strong", ["all"]="all", [""]=""},
  ["stack_protector"] = {["default"]="", ["off"]="off", ["on"]="on", ["strong"]="strong", ["all"]="all", [""]=""},
  ["jln-stl-fix"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["stl_fix"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["jln-suggestions"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["suggestions"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["jln-switch-warnings"] = {["default"]="", ["on"]="on", ["off"]="off", ["exhaustive_enum"]="exhaustive_enum", ["mandatory_default"]="mandatory_default", ["exhaustive_enum_and_mandatory_default"]="exhaustive_enum_and_mandatory_default", [""]=""},
  ["switch_warnings"] = {["default"]="", ["on"]="on", ["off"]="off", ["exhaustive_enum"]="exhaustive_enum", ["mandatory_default"]="mandatory_default", ["exhaustive_enum_and_mandatory_default"]="exhaustive_enum_and_mandatory_default", [""]=""},
  ["jln-warnings"] = {["default"]="", ["off"]="off", ["on"]="on", ["strict"]="strict", ["very_strict"]="very_strict", [""]=""},
  ["warnings"] = {["default"]="", ["off"]="off", ["on"]="on", ["strict"]="strict", ["very_strict"]="very_strict", [""]=""},
  ["jln-warnings-as-error"] = {["default"]="", ["off"]="off", ["on"]="on", ["basic"]="basic", [""]=""},
  ["warnings_as_error"] = {["default"]="", ["off"]="off", ["on"]="on", ["basic"]="basic", [""]=""},
  ["jln-whole-program"] = {["default"]="", ["off"]="off", ["on"]="on", ["strip_all"]="strip_all", [""]=""},
  ["whole_program"] = {["default"]="", ["off"]="off", ["on"]="on", ["strip_all"]="strip_all", [""]=""},
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
        os.raise(vformat("${color.error}Unknown key: '%s'", k))
      end
    elseif not ref[v] then
      os.raise(vformat("${color.error}Unknown value '%s' for '%s'", v, k))
    end
  end
end

-- Returns the merge of the default values and new value table
-- tovalues(table, disable_other_options = false)
-- `values`: table. ex: {warnings='on'}
-- `values` can have 3 additional fields:
--  - `cxx`: compiler name (otherwise deducted from --cxx and --toolchain)
--  - `cxx_version`: compiler version (otherwise deducted from cxx). ex: '7', '7.2'
--  - `ld`: linker name
function tovalues(values, disable_other_options)
  if values then
    _check_flags(values)
    return {
      ["color"] = values["color"] or values["jln-color"] or (disable_other_options and "" or _flag_names["color"][get_config("jln-color")]),
      ["control_flow"] = values["control_flow"] or values["jln-control-flow"] or (disable_other_options and "" or _flag_names["control_flow"][get_config("jln-control-flow")]),
      ["conversion_warnings"] = values["conversion_warnings"] or values["jln-conversion-warnings"] or (disable_other_options and "" or _flag_names["conversion_warnings"][get_config("jln-conversion-warnings")]),
      ["coverage"] = values["coverage"] or values["jln-coverage"] or (disable_other_options and "" or _flag_names["coverage"][get_config("jln-coverage")]),
      ["covered_switch_default_warnings"] = values["covered_switch_default_warnings"] or values["jln-covered-switch-default-warnings"] or (disable_other_options and "" or _flag_names["covered_switch_default_warnings"][get_config("jln-covered-switch-default-warnings")]),
      ["cpu"] = values["cpu"] or values["jln-cpu"] or (disable_other_options and "" or _flag_names["cpu"][get_config("jln-cpu")]),
      ["debug"] = values["debug"] or values["jln-debug"] or (disable_other_options and "" or _flag_names["debug"][get_config("jln-debug")]),
      ["diagnostics_format"] = values["diagnostics_format"] or values["jln-diagnostics-format"] or (disable_other_options and "" or _flag_names["diagnostics_format"][get_config("jln-diagnostics-format")]),
      ["exceptions"] = values["exceptions"] or values["jln-exceptions"] or (disable_other_options and "" or _flag_names["exceptions"][get_config("jln-exceptions")]),
      ["fix_compiler_error"] = values["fix_compiler_error"] or values["jln-fix-compiler-error"] or (disable_other_options and "" or _flag_names["fix_compiler_error"][get_config("jln-fix-compiler-error")]),
      ["float_sanitizers"] = values["float_sanitizers"] or values["jln-float-sanitizers"] or (disable_other_options and "" or _flag_names["float_sanitizers"][get_config("jln-float-sanitizers")]),
      ["integer_sanitizers"] = values["integer_sanitizers"] or values["jln-integer-sanitizers"] or (disable_other_options and "" or _flag_names["integer_sanitizers"][get_config("jln-integer-sanitizers")]),
      ["linker"] = values["linker"] or values["jln-linker"] or (disable_other_options and "" or _flag_names["linker"][get_config("jln-linker")]),
      ["lto"] = values["lto"] or values["jln-lto"] or (disable_other_options and "" or _flag_names["lto"][get_config("jln-lto")]),
      ["msvc_conformance"] = values["msvc_conformance"] or values["jln-msvc-conformance"] or (disable_other_options and "" or _flag_names["msvc_conformance"][get_config("jln-msvc-conformance")]),
      ["msvc_crt_secure_no_warnings"] = values["msvc_crt_secure_no_warnings"] or values["jln-msvc-crt-secure-no-warnings"] or (disable_other_options and "" or _flag_names["msvc_crt_secure_no_warnings"][get_config("jln-msvc-crt-secure-no-warnings")]),
      ["msvc_isystem"] = values["msvc_isystem"] or values["jln-msvc-isystem"] or (disable_other_options and "" or _flag_names["msvc_isystem"][get_config("jln-msvc-isystem")]),
      ["optimization"] = values["optimization"] or values["jln-optimization"] or (disable_other_options and "" or _flag_names["optimization"][get_config("jln-optimization")]),
      ["other_sanitizers"] = values["other_sanitizers"] or values["jln-other-sanitizers"] or (disable_other_options and "" or _flag_names["other_sanitizers"][get_config("jln-other-sanitizers")]),
      ["pedantic"] = values["pedantic"] or values["jln-pedantic"] or (disable_other_options and "" or _flag_names["pedantic"][get_config("jln-pedantic")]),
      ["pie"] = values["pie"] or values["jln-pie"] or (disable_other_options and "" or _flag_names["pie"][get_config("jln-pie")]),
      ["relro"] = values["relro"] or values["jln-relro"] or (disable_other_options and "" or _flag_names["relro"][get_config("jln-relro")]),
      ["reproducible_build_warnings"] = values["reproducible_build_warnings"] or values["jln-reproducible-build-warnings"] or (disable_other_options and "" or _flag_names["reproducible_build_warnings"][get_config("jln-reproducible-build-warnings")]),
      ["sanitizers"] = values["sanitizers"] or values["jln-sanitizers"] or (disable_other_options and "" or _flag_names["sanitizers"][get_config("jln-sanitizers")]),
      ["shadow_warnings"] = values["shadow_warnings"] or values["jln-shadow-warnings"] or (disable_other_options and "" or _flag_names["shadow_warnings"][get_config("jln-shadow-warnings")]),
      ["stack_protector"] = values["stack_protector"] or values["jln-stack-protector"] or (disable_other_options and "" or _flag_names["stack_protector"][get_config("jln-stack-protector")]),
      ["stl_fix"] = values["stl_fix"] or values["jln-stl-fix"] or (disable_other_options and "" or _flag_names["stl_fix"][get_config("jln-stl-fix")]),
      ["suggestions"] = values["suggestions"] or values["jln-suggestions"] or (disable_other_options and "" or _flag_names["suggestions"][get_config("jln-suggestions")]),
      ["switch_warnings"] = values["switch_warnings"] or values["jln-switch-warnings"] or (disable_other_options and "" or _flag_names["switch_warnings"][get_config("jln-switch-warnings")]),
      ["warnings"] = values["warnings"] or values["jln-warnings"] or (disable_other_options and "" or _flag_names["warnings"][get_config("jln-warnings")]),
      ["warnings_as_error"] = values["warnings_as_error"] or values["jln-warnings-as-error"] or (disable_other_options and "" or _flag_names["warnings_as_error"][get_config("jln-warnings-as-error")]),
      ["whole_program"] = values["whole_program"] or values["jln-whole-program"] or (disable_other_options and "" or _flag_names["whole_program"][get_config("jln-whole-program")]),
      ["windows_bigobj"] = values["windows_bigobj"] or values["jln-windows-bigobj"] or (disable_other_options and "" or _flag_names["windows_bigobj"][get_config("jln-windows-bigobj")]),
      ["cc"] = values["cc"] or (not disable_other_options and _get_extra("jln-cc")) or nil,
      ["cc_version"] = values["cc_version"] or (not disable_other_options and _get_extra("jln-cc-version")) or nil,
      ["ld"] = values["ld"] or (not disable_other_options and _get_extra("jln-ld")) or nil,
}
  else
    return {
      ["color"] = _flag_names["color"][get_config("jln-color")],
      ["control_flow"] = _flag_names["control_flow"][get_config("jln-control-flow")],
      ["conversion_warnings"] = _flag_names["conversion_warnings"][get_config("jln-conversion-warnings")],
      ["coverage"] = _flag_names["coverage"][get_config("jln-coverage")],
      ["covered_switch_default_warnings"] = _flag_names["covered_switch_default_warnings"][get_config("jln-covered-switch-default-warnings")],
      ["cpu"] = _flag_names["cpu"][get_config("jln-cpu")],
      ["debug"] = _flag_names["debug"][get_config("jln-debug")],
      ["diagnostics_format"] = _flag_names["diagnostics_format"][get_config("jln-diagnostics-format")],
      ["exceptions"] = _flag_names["exceptions"][get_config("jln-exceptions")],
      ["fix_compiler_error"] = _flag_names["fix_compiler_error"][get_config("jln-fix-compiler-error")],
      ["float_sanitizers"] = _flag_names["float_sanitizers"][get_config("jln-float-sanitizers")],
      ["integer_sanitizers"] = _flag_names["integer_sanitizers"][get_config("jln-integer-sanitizers")],
      ["linker"] = _flag_names["linker"][get_config("jln-linker")],
      ["lto"] = _flag_names["lto"][get_config("jln-lto")],
      ["msvc_conformance"] = _flag_names["msvc_conformance"][get_config("jln-msvc-conformance")],
      ["msvc_crt_secure_no_warnings"] = _flag_names["msvc_crt_secure_no_warnings"][get_config("jln-msvc-crt-secure-no-warnings")],
      ["msvc_isystem"] = _flag_names["msvc_isystem"][get_config("jln-msvc-isystem")],
      ["optimization"] = _flag_names["optimization"][get_config("jln-optimization")],
      ["other_sanitizers"] = _flag_names["other_sanitizers"][get_config("jln-other-sanitizers")],
      ["pedantic"] = _flag_names["pedantic"][get_config("jln-pedantic")],
      ["pie"] = _flag_names["pie"][get_config("jln-pie")],
      ["relro"] = _flag_names["relro"][get_config("jln-relro")],
      ["reproducible_build_warnings"] = _flag_names["reproducible_build_warnings"][get_config("jln-reproducible-build-warnings")],
      ["sanitizers"] = _flag_names["sanitizers"][get_config("jln-sanitizers")],
      ["shadow_warnings"] = _flag_names["shadow_warnings"][get_config("jln-shadow-warnings")],
      ["stack_protector"] = _flag_names["stack_protector"][get_config("jln-stack-protector")],
      ["stl_fix"] = _flag_names["stl_fix"][get_config("jln-stl-fix")],
      ["suggestions"] = _flag_names["suggestions"][get_config("jln-suggestions")],
      ["switch_warnings"] = _flag_names["switch_warnings"][get_config("jln-switch-warnings")],
      ["warnings"] = _flag_names["warnings"][get_config("jln-warnings")],
      ["warnings_as_error"] = _flag_names["warnings_as_error"][get_config("jln-warnings-as-error")],
      ["whole_program"] = _flag_names["whole_program"][get_config("jln-whole-program")],
      ["windows_bigobj"] = _flag_names["windows_bigobj"][get_config("jln-windows-bigobj")],
      ["cc"] = _get_extra("jln-cc"),
      ["cc_version"] = _get_extra("jln-cc-version"),
      ["ld"] = _get_extra("jln-ld"),
}
  end
end

-- same as getoptions() and apply the options on a target
function setoptions(target, values, disable_other_options, print_compiler)
  local options = getoptions(values, disable_other_options, print_compiler)
  table.insert(options.cxxflags, {force=true})
  table.insert(options.ldflags, {force=true})
  target:add('cflags', table.unpack(options.cflags))
  target:add('ldflags', table.unpack(options.ldflags))
  table.remove(options.cxxflags)
  table.remove(options.ldflags)
  return options
end

local _compiler_by_toolname = {
  vs='msvc',
  gcc='gcc',
  gxx='gcc',
  clang='clang',
  clangxx='clang',
  icc='icc',
  icpc='icc',
  icl='icl',
  icx='icx',
  icpx='icx',
  dpcpp='icx',
}

local _comp_cache = {}
local _ld_cache = {}

-- getoptions(values = {}, disable_other_options = false, print_compiler = false)
-- `values`: same as tovalues()
-- `disable_other_options`: boolean
-- `print_compiler`: boolean
-- return {cflags=table, ldflags=table}
function getoptions(values, disable_other_options, print_compiler)
  values = tovalues(values, disable_other_options)

  local compiler = values.cc  local version = values.cc_version
  local linker = values.ld

  do
    local original_linker = linker or ''
    linker = _ld_cache[original_linker]

    if not linker then
      if disable_other_options then
        linker = ''
        _ld_cache[original_linker] = linker
      else
        local program, toolname = platform.tool('ld')
        linker = toolname or detect.find_toolname(program) or ''
        _ld_cache[original_linker] = linker
      end
    end
  end

  local original_compiler = compiler or ''
  local compcache = _comp_cache[original_compiler]
  local compversion

  if compcache then
    compiler = compcache[1]
    version = compcache[2]
    compversion = compcache[3]
    if not compiler then
      -- wrintf("Unknown compiler")
      return {cflags={}, ldflags={}}
    end
  else
    _comp_cache[original_compiler] = {}

    local toolname
    if not compiler then
      compiler, toolname = platform.tool('cc')
      if not compiler then
        -- wprint("Unknown compiler")
        compcache[original_compiler] = {}
        return {cflags={}, ldflags={}}
      end
    end

    local compinfos = detect.find_tool(toolname or compiler, {version=true, program=compiler})
    if compinfos then
      compiler = compinfos.name
      version = compinfos.version
    else
      -- extract basename
      compiler = compiler:match('/([^/]+)$') or compiler
      version = compiler:match('%d+%.?%d*%.?%d*$') or ''
      local has_sep = compiler:byte(#compiler-1) == 45 -- '-'
      -- remove version suffix
      compiler = compiler:sub(1, #compiler - #version - (has_sep and 2 or 1))
    end

    compiler = _compiler_by_toolname[compiler]
            or (compiler:find('^vs') and 'msvc')
            or compiler

    compversion = {}
    for i in version:gmatch("%d+") do
      compversion[#compversion+1] = tonumber(i)
    end
    if not compversion[1] then
      cprint("${color.red}Wrong version format: %s", version)
      compcache[original_compiler] = {}
      return {cflags={}, ldflags={}}
    end

    compversion = compversion[1] * 100 + (compversion[2] or 0)
    _comp_cache[original_compiler] = {compiler, version, compversion}
  end

  if print_compiler then
    cprint("getoptions: compiler: ${cyan}%s${reset}, version: ${cyan}%s", compiler, version)
  end

  local insert = table.insert
  local jln_cxflags, jln_ldflags = {}, {}

  if ( compiler == "gcc" or compiler == "clang" or compiler == "clang-cl" ) then
    if not ( values["warnings"] == "") then
      if values["warnings"] == "off" then
        insert(jln_cxflags, "-w")
      else
        if compiler == "gcc" then
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
          insert(jln_cxflags, "-Wbad-function-cast")
          insert(jln_cxflags, "-Winit-self")
          insert(jln_cxflags, "-Wjump-misses-init")
          insert(jln_cxflags, "-Wnested-externs")
          insert(jln_cxflags, "-Wold-style-definition")
          insert(jln_cxflags, "-Wstrict-prototypes")
          insert(jln_cxflags, "-Wwrite-strings")
          if not ( values["switch_warnings"] == "") then
            if values["switch_warnings"] == "on" then
              insert(jln_cxflags, "-Wswitch")
            else
              if values["switch_warnings"] == "exhaustive_enum" then
                insert(jln_cxflags, "-Wswitch-enum")
              else
                if values["switch_warnings"] == "mandatory_default" then
                  insert(jln_cxflags, "-Wswitch-default")
                else
                  if values["switch_warnings"] == "exhaustive_enum_and_mandatory_default" then
                    insert(jln_cxflags, "-Wswitch-default")
                    insert(jln_cxflags, "-Wswitch-enum")
                  else
                    insert(jln_cxflags, "-Wno-switch")
                  end
                end
              end
            end
          end
          if not ( compversion < 407 ) then
            insert(jln_cxflags, "-Wsuggest-attribute=noreturn")
            insert(jln_cxflags, "-Wlogical-op")
            insert(jln_cxflags, "-Wvector-operation-performance")
            insert(jln_cxflags, "-Wdouble-promotion")
            insert(jln_cxflags, "-Wtrampolines")
            if not ( compversion < 408 ) then
              if not ( compversion < 409 ) then
                insert(jln_cxflags, "-Wfloat-conversion")
                if not ( compversion < 501 ) then
                  insert(jln_cxflags, "-Wformat-signedness")
                  insert(jln_cxflags, "-Warray-bounds=2")
                  if not ( compversion < 601 ) then
                    insert(jln_cxflags, "-Wduplicated-cond")
                    insert(jln_cxflags, "-Wnull-dereference")
                    if not ( compversion < 700 ) then
                      if not ( compversion < 701 ) then
                        insert(jln_cxflags, "-Walloc-zero")
                        insert(jln_cxflags, "-Walloca")
                        insert(jln_cxflags, "-Wformat-overflow=2")
                        insert(jln_cxflags, "-Wduplicated-branches")
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
          insert(jln_cxflags, "-Wno-padded")
          insert(jln_cxflags, "-Wno-global-constructors")
          if not ( values["switch_warnings"] == "") then
            if ( values["switch_warnings"] == "on" or values["switch_warnings"] == "mandatory_default" ) then
              insert(jln_cxflags, "-Wno-switch-enum")
            else
              if ( values["switch_warnings"] == "exhaustive_enum" or values["switch_warnings"] == "exhaustive_enum_and_mandatory_default" ) then
                insert(jln_cxflags, "-Wswitch-enum")
              else
                if values["switch_warnings"] == "off" then
                  insert(jln_cxflags, "-Wno-switch")
                  insert(jln_cxflags, "-Wno-switch-enum")
                end
              end
            end
          else
            insert(jln_cxflags, "-Wno-switch")
            insert(jln_cxflags, "-Wno-switch-enum")
          end
          if not ( values["covered_switch_default_warnings"] == "") then
            if values["covered_switch_default_warnings"] == "off" then
              insert(jln_cxflags, "-Wno-covered-switch-default")
            else
              insert(jln_cxflags, "-Wcovered-switch-default")
            end
          end
        end
        if ( values["warnings"] == "strict" or values["warnings"] == "very_strict" ) then
          if ( compiler == "gcc" and not ( compversion < 800 ) ) then
            insert(jln_cxflags, "-Wcast-align=strict")
          end
        end
      end
    end
    if not ( values["warnings_as_error"] == "") then
      if values["warnings_as_error"] == "on" then
        insert(jln_cxflags, "-Werror")
      else
        if values["warnings_as_error"] == "basic" then
          insert(jln_cxflags, "-Werror=return-type")
          insert(jln_cxflags, "-Werror=init-self")
          if compiler == "gcc" then
            insert(jln_cxflags, "-Werror=div-by-zero")
            if not ( compversion < 501 ) then
              insert(jln_cxflags, "-Werror=array-bounds")
              insert(jln_cxflags, "-Werror=logical-op")
              insert(jln_cxflags, "-Werror=logical-not-parentheses")
            end
          else
            if ( compiler == "clang" or compiler == "clang-cl" ) then
              insert(jln_cxflags, "-Werror=array-bounds")
              insert(jln_cxflags, "-Werror=division-by-zero")
              if not ( compversion < 304 ) then
                insert(jln_cxflags, "-Werror=logical-not-parentheses")
              end
            end
          end
        else
          insert(jln_cxflags, "-Wno-error")
        end
      end
    end
    if not ( values["suggestions"] == "") then
      if not ( values["suggestions"] == "off" ) then
        if compiler == "gcc" then
          insert(jln_cxflags, "-Wsuggest-attribute=pure")
          insert(jln_cxflags, "-Wsuggest-attribute=const")
        end
      end
    end
    if not ( values["sanitizers"] == "") then
      if values["sanitizers"] == "off" then
        insert(jln_cxflags, "-fno-sanitize=all")
        insert(jln_ldflags, "-fno-sanitize=all")
      else
        if compiler == "clang-cl" then
          insert(jln_cxflags, "-fsanitize=undefined")
          insert(jln_cxflags, "-fsanitize=address")
          insert(jln_cxflags, "-fsanitize-address-use-after-scope")
        else
          if compiler == "clang" then
            if not ( compversion < 301 ) then
              insert(jln_cxflags, "-fsanitize=undefined")
              insert(jln_cxflags, "-fsanitize=address")
              insert(jln_cxflags, "-fsanitize-address-use-after-scope")
              insert(jln_cxflags, "-fno-omit-frame-pointer")
              insert(jln_cxflags, "-fno-optimize-sibling-calls")
              insert(jln_ldflags, "-fsanitize=undefined")
              insert(jln_ldflags, "-fsanitize=address")
              if not ( compversion < 304 ) then
                insert(jln_cxflags, "-fsanitize=leak")
                insert(jln_ldflags, "-fsanitize=leak")
              end
              if not ( compversion < 600 ) then
                if not ( values["stack_protector"] == "") then
                  if not ( values["stack_protector"] == "off" ) then
                    insert(jln_cxflags, "-fsanitize-minimal-runtime")
                  end
                end
              end
            end
          else
            if not ( compversion < 408 ) then
              insert(jln_cxflags, "-fsanitize=address")
              insert(jln_cxflags, "-fno-omit-frame-pointer")
              insert(jln_cxflags, "-fno-optimize-sibling-calls")
              insert(jln_ldflags, "-fsanitize=address")
              if not ( compversion < 409 ) then
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
    if not ( values["control_flow"] == "") then
      if values["control_flow"] == "off" then
        if ( compiler == "gcc" and not ( compversion < 800 ) ) then
          insert(jln_cxflags, "-fcf-protection=none")
        else
          insert(jln_cxflags, "-fno-sanitize=cfi")
          insert(jln_cxflags, "-fcf-protection=none")
          insert(jln_cxflags, "-fno-sanitize-cfi-cross-dso")
          insert(jln_ldflags, "-fno-sanitize=cfi")
        end
      else
        if ( ( compiler == "gcc" and not ( compversion < 800 ) ) or not ( compiler == "gcc" ) ) then
          if values["control_flow"] == "branch" then
            insert(jln_cxflags, "-fcf-protection=branch")
          else
            if values["control_flow"] == "return" then
              insert(jln_cxflags, "-fcf-protection=return")
            else
              insert(jln_cxflags, "-fcf-protection=full")
            end
          end
          if ( values["control_flow"] == "allow_bugs" and compiler == "clang" ) then
            insert(jln_cxflags, "-fsanitize=cfi")
            insert(jln_cxflags, "-fvisibility=hidden")
            insert(jln_cxflags, "-flto")
            insert(jln_ldflags, "-fsanitize=cfi")
            insert(jln_ldflags, "-flto")
          end
        end
      end
    end
    if not ( values["color"] == "") then
      if ( ( compiler == "gcc" and not ( compversion < 409 ) ) or compiler == "clang" or compiler == "clang-cl" ) then
        if values["color"] == "auto" then
          insert(jln_cxflags, "-fdiagnostics-color=auto")
        else
          if values["color"] == "never" then
            insert(jln_cxflags, "-fdiagnostics-color=never")
          else
            if values["color"] == "always" then
              insert(jln_cxflags, "-fdiagnostics-color=always")
            end
          end
        end
      end
    end
    if not ( values["reproducible_build_warnings"] == "") then
      if ( compiler == "gcc" and not ( compversion < 409 ) ) then
        if values["reproducible_build_warnings"] == "on" then
          insert(jln_cxflags, "-Wdate-time")
        else
          insert(jln_cxflags, "-Wno-date-time")
        end
      end
    end
    if not ( values["diagnostics_format"] == "") then
      if values["diagnostics_format"] == "fixits" then
        if ( ( compiler == "gcc" and not ( compversion < 700 ) ) or ( compiler == "clang" and not ( compversion < 500 ) ) or ( compiler == "clang-cl" and not ( compversion < 500 ) ) ) then
          insert(jln_cxflags, "-fdiagnostics-parseable-fixits")
        end
      else
        if values["diagnostics_format"] == "patch" then
          if ( compiler == "gcc" and not ( compversion < 700 ) ) then
            insert(jln_cxflags, "-fdiagnostics-generate-patch")
          end
        else
          if values["diagnostics_format"] == "print_source_range_info" then
            if compiler == "clang" then
              insert(jln_cxflags, "-fdiagnostics-print-source-range-info")
            end
          end
        end
      end
    end
    if not ( values["fix_compiler_error"] == "") then
      if values["fix_compiler_error"] == "on" then
        insert(jln_cxflags, "-Werror=write-strings")
      else
        if ( compiler == "clang" or compiler == "clang-cl" ) then
          insert(jln_cxflags, "-Wno-error=c++11-narrowing")
          insert(jln_cxflags, "-Wno-reserved-user-defined-literal")
        end
      end
    end
    if not ( values["linker"] == "") then
      if values["linker"] == "native" then
        if compiler == "gcc" then
          insert(jln_ldflags, "-fuse-ld=gold")
        else
          insert(jln_ldflags, "-fuse-ld=lld")
        end
      else
        if values["linker"] == "bfd" then
          insert(jln_ldflags, "-fuse-ld=bfd")
        else
          if ( values["linker"] == "gold" or ( compiler == "gcc" and not ( not ( compversion < 900 ) ) ) ) then
            insert(jln_ldflags, "-fuse-ld=gold")
          else
            if not ( values["lto"] == "") then
              if ( not ( values["lto"] == "off" ) and compiler == "gcc" ) then
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
    if not ( values["lto"] == "") then
      if values["lto"] == "off" then
        insert(jln_cxflags, "-fno-lto")
        insert(jln_ldflags, "-fno-lto")
      else
        if compiler == "gcc" then
          insert(jln_cxflags, "-flto")
          insert(jln_ldflags, "-flto")
          if not ( compversion < 500 ) then
            if not ( values["warnings"] == "") then
              if not ( values["warnings"] == "off" ) then
                insert(jln_cxflags, "-flto-odr-type-merging")
                insert(jln_ldflags, "-flto-odr-type-merging")
              end
            end
            if values["lto"] == "fat" then
              insert(jln_cxflags, "-ffat-lto-objects")
            else
              if values["lto"] == "thin" then
                insert(jln_ldflags, "-fuse-linker-plugin")
              end
            end
          end
        else
          if compiler == "clang-cl" then
            insert(jln_ldflags, "-fuse-ld=lld")
          end
          if ( values["lto"] == "thin" and not ( compversion < 600 ) ) then
            insert(jln_cxflags, "-flto=thin")
            insert(jln_ldflags, "-flto=thin")
          else
            insert(jln_cxflags, "-flto")
            insert(jln_ldflags, "-flto")
          end
        end
      end
    end
    if not ( values["shadow_warnings"] == "") then
      if values["shadow_warnings"] == "off" then
        insert(jln_cxflags, "-Wno-shadow")
        if ( compiler == "clang-cl" or ( compiler == "clang" and not ( compversion < 800 ) ) ) then
          insert(jln_cxflags, "-Wno-shadow-field")
        end
      else
        if values["shadow_warnings"] == "on" then
          insert(jln_cxflags, "-Wshadow")
        else
          if values["shadow_warnings"] == "all" then
            if compiler == "gcc" then
              insert(jln_cxflags, "-Wshadow")
            else
              insert(jln_cxflags, "-Wshadow-all")
            end
          else
            if ( compiler == "gcc" and not ( compversion < 701 ) ) then
              if values["shadow_warnings"] == "local" then
                insert(jln_cxflags, "-Wshadow=local")
              else
                if values["shadow_warnings"] == "compatible_local" then
                  insert(jln_cxflags, "-Wshadow=compatible-local")
                end
              end
            end
          end
        end
      end
    end
    if not ( values["float_sanitizers"] == "") then
      if ( ( compiler == "gcc" and not ( compversion < 500 ) ) or ( compiler == "clang" and not ( compversion < 500 ) ) or compiler == "clang-cl" ) then
        if values["float_sanitizers"] == "on" then
          insert(jln_cxflags, "-fsanitize=float-divide-by-zero")
          insert(jln_cxflags, "-fsanitize=float-cast-overflow")
        else
          insert(jln_cxflags, "-fno-sanitize=float-divide-by-zero")
          insert(jln_cxflags, "-fno-sanitize=float-cast-overflow")
        end
      end
    end
    if not ( values["integer_sanitizers"] == "") then
      if ( ( compiler == "clang" and not ( compversion < 500 ) ) or compiler == "clang-cl" ) then
        if values["integer_sanitizers"] == "on" then
          insert(jln_cxflags, "-fsanitize=integer")
        else
          insert(jln_cxflags, "-fno-sanitize=integer")
        end
      else
        if ( compiler == "gcc" and not ( compversion < 409 ) ) then
          if values["integer_sanitizers"] == "on" then
            insert(jln_cxflags, "-ftrapv")
            insert(jln_cxflags, "-fsanitize=undefined")
          end
        end
      end
    end
  end
  if ( compiler == "gcc" or compiler == "clang" or compiler == "clang-cl" or compiler == "icc" ) then
    if not ( values["conversion_warnings"] == "") then
      if values["conversion_warnings"] == "on" then
        insert(jln_cxflags, "-Wconversion")
        insert(jln_cxflags, "-Wsign-compare")
        insert(jln_cxflags, "-Wsign-conversion")
      else
        if values["conversion_warnings"] == "conversion" then
          insert(jln_cxflags, "-Wconversion")
        else
          if values["conversion_warnings"] == "sign" then
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
  if ( compiler == "gcc" or compiler == "clang" ) then
    if not ( values["coverage"] == "") then
      if values["coverage"] == "on" then
        insert(jln_cxflags, "--coverage")
        insert(jln_ldflags, "--coverage")
        if compiler == "clang" then
          insert(jln_ldflags, "-lprofile_rt")
        end
      end
    end
    if not ( values["debug"] == "") then
      if values["debug"] == "off" then
        insert(jln_cxflags, "-g0")
      else
        if values["debug"] == "gdb" then
          insert(jln_cxflags, "-ggdb")
        else
          if compiler == "clang" then
            if values["debug"] == "line_tables_only" then
              insert(jln_cxflags, "-gline-tables-only")
            else
              if values["debug"] == "lldb" then
                insert(jln_cxflags, "-glldb")
              else
                if values["debug"] == "sce" then
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
    if not ( values["optimization"] == "") then
      if values["optimization"] == "0" then
        insert(jln_cxflags, "-O0")
        insert(jln_ldflags, "-O0")
      else
        if values["optimization"] == "g" then
          insert(jln_cxflags, "-Og")
          insert(jln_ldflags, "-Og")
        else
          insert(jln_cxflags, "-DNDEBUG")
          insert(jln_ldflags, "-Wl,-O1")
          if values["optimization"] == "size" then
            insert(jln_cxflags, "-Os")
            insert(jln_ldflags, "-Os")
          else
            if values["optimization"] == "z" then
              if ( compiler == "clang" or compiler == "clang-cl" ) then
                insert(jln_cxflags, "-Oz")
                insert(jln_ldflags, "-Oz")
              else
                insert(jln_cxflags, "-Os")
                insert(jln_ldflags, "-Os")
              end
            else
              if values["optimization"] == "fast" then
                insert(jln_cxflags, "-Ofast")
                insert(jln_ldflags, "-Ofast")
              else
                if values["optimization"] == "1" then
                  insert(jln_cxflags, "-O1")
                  insert(jln_ldflags, "-O1")
                else
                  if values["optimization"] == "2" then
                    insert(jln_cxflags, "-O2")
                    insert(jln_ldflags, "-O2")
                  else
                    if values["optimization"] == "3" then
                      insert(jln_cxflags, "-O3")
                      insert(jln_ldflags, "-O3")
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
    if not ( values["cpu"] == "") then
      if values["cpu"] == "generic" then
        insert(jln_cxflags, "-mtune=generic")
        insert(jln_ldflags, "-mtune=generic")
      else
        insert(jln_cxflags, "-march=native")
        insert(jln_cxflags, "-mtune=native")
        insert(jln_ldflags, "-march=native")
        insert(jln_ldflags, "-mtune=native")
      end
    end
    if not ( values["whole_program"] == "") then
      if values["whole_program"] == "off" then
        insert(jln_cxflags, "-fno-whole-program")
        if ( compiler == "clang" and not ( compversion < 309 ) ) then
          insert(jln_cxflags, "-fno-whole-program-vtables")
          insert(jln_ldflags, "-fno-whole-program-vtables")
        end
      else
        if linker == "ld64" then
          insert(jln_ldflags, "-Wl,-dead_strip")
          insert(jln_ldflags, "-Wl,-S")
        else
          insert(jln_ldflags, "-s")
          if values["whole_program"] == "strip_all" then
            insert(jln_ldflags, "-Wl,--gc-sections")
            insert(jln_ldflags, "-Wl,--strip-all")
          end
        end
        if compiler == "gcc" then
          insert(jln_cxflags, "-fwhole-program")
          insert(jln_ldflags, "-fwhole-program")
        else
          if compiler == "clang" then
            if not ( compversion < 309 ) then
              if not ( values["lto"] == "") then
                if not ( values["lto"] == "off" ) then
                  insert(jln_cxflags, "-fwhole-program-vtables")
                  insert(jln_ldflags, "-fwhole-program-vtables")
                end
              end
              if not ( compversion < 700 ) then
                insert(jln_cxflags, "-fforce-emit-vtables")
                insert(jln_ldflags, "-fforce-emit-vtables")
              end
            end
          end
        end
      end
    end
    if not ( values["pedantic"] == "") then
      if not ( values["pedantic"] == "off" ) then
        insert(jln_cxflags, "-pedantic")
        if values["pedantic"] == "as_error" then
          insert(jln_cxflags, "-pedantic-errors")
        end
      end
    end
    if not ( values["stack_protector"] == "") then
      if values["stack_protector"] == "off" then
        insert(jln_cxflags, "-Wno-stack-protector")
        insert(jln_cxflags, "-U_FORTIFY_SOURCE")
        insert(jln_ldflags, "-Wno-stack-protector")
      else
        insert(jln_cxflags, "-D_FORTIFY_SOURCE=2")
        insert(jln_cxflags, "-Wstack-protector")
        if values["stack_protector"] == "strong" then
          if compiler == "gcc" then
            if not ( compversion < 409 ) then
              insert(jln_cxflags, "-fstack-protector-strong")
              insert(jln_ldflags, "-fstack-protector-strong")
              if not ( compversion < 800 ) then
                insert(jln_cxflags, "-fstack-clash-protection")
                insert(jln_ldflags, "-fstack-clash-protection")
              end
            end
          else
            if compiler == "clang" then
              insert(jln_cxflags, "-fstack-protector-strong")
              insert(jln_cxflags, "-fsanitize=safe-stack")
              insert(jln_ldflags, "-fstack-protector-strong")
              insert(jln_ldflags, "-fsanitize=safe-stack")
              if not ( compversion < 1100 ) then
                insert(jln_cxflags, "-fstack-clash-protection")
                insert(jln_ldflags, "-fstack-clash-protection")
              end
            end
          end
        else
          if values["stack_protector"] == "all" then
            insert(jln_cxflags, "-fstack-protector-all")
            insert(jln_ldflags, "-fstack-protector-all")
            if ( compiler == "gcc" and not ( compversion < 800 ) ) then
              insert(jln_cxflags, "-fstack-clash-protection")
              insert(jln_ldflags, "-fstack-clash-protection")
            else
              if compiler == "clang" then
                insert(jln_cxflags, "-fsanitize=safe-stack")
                insert(jln_ldflags, "-fsanitize=safe-stack")
                if not ( compversion < 1100 ) then
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
        if compiler == "clang" then
          insert(jln_cxflags, "-fsanitize=shadow-call-stack")
          insert(jln_ldflags, "-fsanitize=shadow-call-stack")
        end
      end
    end
    if not ( values["relro"] == "") then
      if values["relro"] == "off" then
        insert(jln_ldflags, "-Wl,-z,norelro")
      else
        if values["relro"] == "on" then
          insert(jln_ldflags, "-Wl,-z,relro")
        else
          if values["relro"] == "full" then
            insert(jln_ldflags, "-Wl,-z,relro,-z,now,-z,noexecstack")
            if not ( values["linker"] == "") then
              if not ( ( values["linker"] == "gold" or ( compiler == "gcc" and not ( not ( compversion < 900 ) ) ) or ( values["linker"] == "native" and compiler == "gcc" ) ) ) then
                insert(jln_ldflags, "-Wl,-z,separate-code")
              end
            end
          end
        end
      end
    end
    if not ( values["pie"] == "") then
      if values["pie"] == "off" then
        insert(jln_ldflags, "-no-pic")
      else
        if values["pie"] == "on" then
          insert(jln_ldflags, "-pie")
        else
          if values["pie"] == "static" then
            insert(jln_ldflags, "-static-pie")
          else
            if values["pie"] == "fpie" then
              insert(jln_cxflags, "-fpie")
            else
              if values["pie"] == "fpic" then
                insert(jln_cxflags, "-fpic")
              else
                if values["pie"] == "fPIE" then
                  insert(jln_cxflags, "-fPIE")
                else
                  if values["pie"] == "fPIC" then
                    insert(jln_cxflags, "-fPIC")
                  end
                end
              end
            end
          end
        end
      end
    end
    if not ( values["exceptions"] == "") then
      if values["exceptions"] == "on" then
        insert(jln_cxflags, "-fexceptions")
      else
        insert(jln_cxflags, "-fno-exceptions")
      end
    end
    if not ( values["other_sanitizers"] == "") then
      if values["other_sanitizers"] == "thread" then
        insert(jln_cxflags, "-fsanitize=thread")
      else
        if values["other_sanitizers"] == "memory" then
          if ( compiler == "clang" and not ( compversion < 500 ) ) then
            insert(jln_cxflags, "-fsanitize=memory")
          end
        else
          if values["other_sanitizers"] == "pointer" then
            if ( compiler == "gcc" and not ( compversion < 800 ) ) then
              insert(jln_cxflags, "-fsanitize=pointer-compare")
              insert(jln_cxflags, "-fsanitize=pointer-subtract")
            end
          end
        end
      end
    end
  end
  if linker == "lld-link" then
    if not ( values["lto"] == "") then
      if values["lto"] == "off" then
        insert(jln_cxflags, "-fno-lto")
      else
        if values["lto"] == "thin" then
          insert(jln_cxflags, "-flto=thin")
        else
          insert(jln_cxflags, "-flto")
          insert(jln_ldflags, "-flto")
        end
      end
    end
    if not ( values["whole_program"] == "") then
      if values["whole_program"] == "off" then
        insert(jln_cxflags, "-fno-whole-program")
      else
        if not ( values["lto"] == "") then
          if not ( values["lto"] == "off" ) then
            insert(jln_cxflags, "-fwhole-program-vtables")
            insert(jln_ldflags, "-fwhole-program-vtables")
          end
        end
      end
    end
  end
  if ( compiler == "msvc" or compiler == "clang-cl" or compiler == "icl" ) then
    if not ( values["exceptions"] == "") then
      if values["exceptions"] == "on" then
        insert(jln_cxflags, "/EHsc")
        insert(jln_cxflags, "/D_HAS_EXCEPTIONS=1")
      else
        insert(jln_cxflags, "/EHs-")
        insert(jln_cxflags, "/D_HAS_EXCEPTIONS=0")
      end
    end
    if not ( values["rtti"] == "") then
      if values["rtti"] == "on" then
        insert(jln_cxflags, "/GR")
      else
        insert(jln_cxflags, "/GR-")
      end
    end
    if not ( values["stl_debug"] == "") then
      if values["stl_debug"] == "off" then
        insert(jln_cxflags, "/D_HAS_ITERATOR_DEBUGGING=0")
      else
        insert(jln_cxflags, "/D_DEBUG")
        insert(jln_cxflags, "/D_HAS_ITERATOR_DEBUGGING=1")
      end
    end
    if not ( compiler == "icl" ) then
      if not ( values["stl_fix"] == "") then
        if values["stl_fix"] == "on" then
          insert(jln_cxflags, "/DNOMINMAX")
        end
      end
      if not ( values["debug"] == "") then
        if values["debug"] == "off" then
          insert(jln_cxflags, "/DEBUG:NONE")
        else
          insert(jln_cxflags, "/RTC1")
          insert(jln_cxflags, "/Od")
          if values["debug"] == "on" then
            insert(jln_cxflags, "/DEBUG")
          else
            if values["debug"] == "line_tables_only" then
              if compiler == "clang-cl" then
                insert(jln_cxflags, "-gline-tables-only")
              end
              insert(jln_cxflags, "/DEBUG:FASTLINK")
            end
          end
          if not ( values["optimization"] == "") then
            if values["optimization"] == "g" then
              insert(jln_cxflags, "/Zi")
            else
              if not ( values["whole_program"] == "") then
                if values["whole_program"] == "off" then
                  insert(jln_cxflags, "/ZI")
                else
                  insert(jln_cxflags, "/Zi")
                end
              else
                insert(jln_cxflags, "/ZI")
              end
            end
          else
            if not ( values["whole_program"] == "") then
              if values["whole_program"] == "off" then
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
      if not ( values["optimization"] == "") then
        if values["optimization"] == "0" then
          insert(jln_cxflags, "/Ob0")
          insert(jln_cxflags, "/Od")
          insert(jln_cxflags, "/Oi-")
          insert(jln_cxflags, "/Oy-")
        else
          if values["optimization"] == "g" then
            insert(jln_cxflags, "/Ob1")
          else
            insert(jln_cxflags, "/DNDEBUG")
            if values["optimization"] == "1" then
              insert(jln_cxflags, "/O1")
            else
              if values["optimization"] == "2" then
                insert(jln_cxflags, "/O2")
              else
                if values["optimization"] == "3" then
                  insert(jln_cxflags, "/O2")
                else
                  if ( values["optimization"] == "size" or values["optimization"] == "z" ) then
                    insert(jln_cxflags, "/O1")
                    insert(jln_cxflags, "/GL")
                    insert(jln_cxflags, "/Gw")
                  else
                    if values["optimization"] == "fast" then
                      insert(jln_cxflags, "/O2")
                      insert(jln_cxflags, "/fp:fast")
                    end
                  end
                end
              end
            end
          end
        end
      end
      if not ( values["control_flow"] == "") then
        if values["control_flow"] == "off" then
          insert(jln_cxflags, "/guard:cf-")
        else
          insert(jln_cxflags, "/guard:cf")
        end
      end
      if not ( values["whole_program"] == "") then
        if values["whole_program"] == "off" then
          insert(jln_cxflags, "/GL-")
        else
          insert(jln_cxflags, "/GL")
          insert(jln_cxflags, "/Gw")
          insert(jln_ldflags, "/LTCG")
          if values["whole_program"] == "strip_all" then
            insert(jln_ldflags, "/OPT:REF")
          end
        end
      end
      if not ( values["pedantic"] == "") then
        if not ( values["pedantic"] == "off" ) then
          insert(jln_cxflags, "/permissive-")
        end
      end
      if not ( values["stack_protector"] == "") then
        if values["stack_protector"] == "off" then
          insert(jln_cxflags, "/GS-")
        else
          insert(jln_cxflags, "/GS")
          insert(jln_cxflags, "/sdl")
          if values["stack_protector"] == "strong" then
            insert(jln_cxflags, "/RTC1")
            if ( compiler == "msvc" and not ( compversion < 1607 ) ) then
              insert(jln_cxflags, "/guard:ehcont")
              insert(jln_ldflags, "/CETCOMPAT")
            end
          else
            if values["stack_protector"] == "all" then
              insert(jln_cxflags, "/RTC1")
              insert(jln_cxflags, "/RTCc")
            end
          end
        end
      end
    end
  end
  if compiler == "msvc" then
    if not ( values["windows_bigobj"] == "") then
      insert(jln_cxflags, "/bigobj")
    end
    if not ( values["msvc_conformance"] == "") then
      if ( values["msvc_conformance"] == "all" or values["msvc_conformance"] == "all_without_throwing_new" ) then
        insert(jln_cxflags, "/Zc:inline")
        insert(jln_cxflags, "/Zc:referenceBinding")
        if values["msvc_conformance"] == "all" then
          insert(jln_cxflags, "/Zc:throwingNew")
        end
        if not ( compversion < 1506 ) then
          if not ( compversion < 1605 ) then
            insert(jln_cxflags, "/Zc:preprocessor")
          end
        end
      end
    end
    if not ( values["msvc_crt_secure_no_warnings"] == "") then
      if values["msvc_crt_secure_no_warnings"] == "on" then
        insert(jln_cxflags, "/D_CRT_SECURE_NO_WARNINGS=1")
      else
        if values["msvc_crt_secure_no_warnings"] == "off" then
          insert(jln_cxflags, "/U_CRT_SECURE_NO_WARNINGS")
        end
      end
    end
    if not ( values["msvc_isystem"] == "") then
      if values["msvc_isystem"] == "external_as_include_system_flag" then
        -- unimplementable
      else
        insert(jln_cxflags, "/experimental:external")
        insert(jln_cxflags, "/external:W0")
        if values["msvc_isystem"] == "anglebrackets" then
          insert(jln_cxflags, "/external:anglebrackets")
        else
          insert(jln_cxflags, "/external:env:INCLUDE")
          insert(jln_cxflags, "/external:env:CAExcludePath")
        end
      end
      if not ( values["msvc_isystem_with_template_from_non_external"] == "") then
        if values["msvc_isystem_with_template_from_non_external"] == "off" then
          insert(jln_cxflags, "/external:template")
        else
          insert(jln_cxflags, "/external:template-")
        end
      end
      if not ( values["warnings"] == "") then
        if values["warnings"] == "off" then
          insert(jln_cxflags, "/W0")
        else
          insert(jln_cxflags, "/wd4710")
          insert(jln_cxflags, "/wd4711")
          if not ( not ( compversion < 1921 ) ) then
            insert(jln_cxflags, "/wd4774")
          end
          if values["warnings"] == "on" then
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
            if values["warnings"] == "strict" then
              insert(jln_cxflags, "/wd4583")
              insert(jln_cxflags, "/wd4619")
            end
          end
        end
      end
      if not ( values["switch_warnings"] == "") then
        if ( values["switch_warnings"] == "on" or values["switch_warnings"] == "mandatory_default" ) then
          insert(jln_cxflags, "/w14062")
        else
          if ( values["switch_warnings"] == "exhaustive_enum" or values["switch_warnings"] == "exhaustive_enum_and_mandatory_default" ) then
            insert(jln_cxflags, "/w14061")
            insert(jln_cxflags, "/w14062")
          else
            if values["switch_warnings"] == "off" then
              insert(jln_cxflags, "/wd4061")
              insert(jln_cxflags, "/wd4062")
            end
          end
        end
      end
    else
      if not ( values["warnings"] == "") then
        if values["warnings"] == "off" then
          insert(jln_cxflags, "/W0")
        else
          if values["warnings"] == "on" then
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
            if not ( not ( compversion < 1921 ) ) then
              insert(jln_cxflags, "/wd4774")
            end
            insert(jln_cxflags, "/wd4820")
            insert(jln_cxflags, "/wd5026")
            insert(jln_cxflags, "/wd5027")
            insert(jln_cxflags, "/wd5039")
            insert(jln_cxflags, "/wd4464")
            insert(jln_cxflags, "/wd4868")
            insert(jln_cxflags, "/wd5045")
            if values["warnings"] == "strict" then
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
    if not ( values["conversion_warnings"] == "") then
      if values["conversion_warnings"] == "on" then
        insert(jln_cxflags, "/w14244")
        insert(jln_cxflags, "/w14245")
        insert(jln_cxflags, "/w14388")
        insert(jln_cxflags, "/w14365")
      else
        if values["conversion_warnings"] == "conversion" then
          insert(jln_cxflags, "/w14244")
          insert(jln_cxflags, "/w14365")
        else
          if values["conversion_warnings"] == "sign" then
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
    if not ( values["shadow_warnings"] == "") then
      if values["shadow_warnings"] == "off" then
        insert(jln_cxflags, "/wd4456")
        insert(jln_cxflags, "/wd4459")
      else
        if ( values["shadow_warnings"] == "on" or values["shadow_warnings"] == "all" ) then
          insert(jln_cxflags, "/w4456")
          insert(jln_cxflags, "/w4459")
        else
          if values["shadow_warnings"] == "local" then
            insert(jln_cxflags, "/w4456")
            insert(jln_cxflags, "/wd4459")
          end
        end
      end
    end
    if not ( values["warnings_as_error"] == "") then
      if values["warnings_as_error"] == "on" then
        insert(jln_cxflags, "/WX")
        insert(jln_ldflags, "/WX")
      else
        if values["warnings_as_error"] == "off" then
          insert(jln_cxflags, "/WX-")
        else
          insert(jln_cxflags, "/we4716")
          insert(jln_cxflags, "/we2124")
        end
      end
    end
    if not ( values["lto"] == "") then
      if values["lto"] == "off" then
        insert(jln_cxflags, "/LTCG:OFF")
      else
        insert(jln_cxflags, "/GL")
        insert(jln_ldflags, "/LTCG")
      end
    end
    if not ( values["sanitizers"] == "") then
      if not ( compversion < 1609 ) then
        insert(jln_cxflags, "/fsanitize=address")
        insert(jln_cxflags, "/fsanitize-address-use-after-return")
      else
        if values["sanitizers"] == "on" then
          insert(jln_cxflags, "/sdl")
        else
          if not ( values["stack_protector"] == "") then
            if not ( values["stack_protector"] == "off" ) then
              insert(jln_cxflags, "/sdl-")
            end
          end
        end
      end
    end
  end
  if compiler == "icl" then
    if not ( values["warnings"] == "") then
      if values["warnings"] == "off" then
        insert(jln_cxflags, "/w")
      else
        insert(jln_cxflags, "/W2")
        insert(jln_cxflags, "/Qdiag-disable:1418,2259")
      end
    end
    if not ( values["warnings_as_error"] == "") then
      if values["warnings_as_error"] == "on" then
        insert(jln_cxflags, "/WX")
      else
        if values["warnings_as_error"] == "basic" then
          insert(jln_cxflags, "/Qdiag-error:1079,39,109")
        end
      end
    end
    if not ( values["windows_bigobj"] == "") then
      insert(jln_cxflags, "/bigobj")
    end
    if not ( values["msvc_conformance"] == "") then
      if ( values["msvc_conformance"] == "all" or values["msvc_conformance"] == "all_without_throwing_new" ) then
        insert(jln_cxflags, "/Zc:inline")
        insert(jln_cxflags, "/Zc:strictStrings")
        if values["msvc_conformance"] == "all" then
          insert(jln_cxflags, "/Zc:throwingNew")
        end
      end
    end
    if not ( values["debug"] == "") then
      if values["debug"] == "off" then
        insert(jln_cxflags, "/debug:NONE")
      else
        insert(jln_cxflags, "/RTC1")
        insert(jln_cxflags, "/Od")
        if values["debug"] == "on" then
          insert(jln_cxflags, "/debug:full")
        else
          if values["debug"] == "line_tables_only" then
            insert(jln_cxflags, "/debug:minimal")
          end
        end
        if not ( values["optimization"] == "") then
          if values["optimization"] == "g" then
            insert(jln_cxflags, "/Zi")
          else
            if not ( values["whole_program"] == "") then
              if values["whole_program"] == "off" then
                insert(jln_cxflags, "/ZI")
              else
                insert(jln_cxflags, "/Zi")
              end
            else
              insert(jln_cxflags, "/ZI")
            end
          end
        else
          if not ( values["whole_program"] == "") then
            if values["whole_program"] == "off" then
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
    if not ( values["optimization"] == "") then
      if values["optimization"] == "0" then
        insert(jln_cxflags, "/Ob0")
        insert(jln_cxflags, "/Od")
        insert(jln_cxflags, "/Oi-")
        insert(jln_cxflags, "/Oy-")
      else
        if values["optimization"] == "g" then
          insert(jln_cxflags, "/Ob1")
        else
          insert(jln_cxflags, "/DNDEBUG")
          insert(jln_cxflags, "/GF")
          if values["optimization"] == "1" then
            insert(jln_cxflags, "/O1")
          else
            if values["optimization"] == "2" then
              insert(jln_cxflags, "/O2")
            else
              if values["optimization"] == "3" then
                insert(jln_cxflags, "/O2")
              else
                if values["optimization"] == "z" then
                  insert(jln_cxflags, "/O3")
                else
                  if values["optimization"] == "size" then
                    insert(jln_cxflags, "/Os")
                  else
                    if values["optimization"] == "fast" then
                      insert(jln_cxflags, "/fast")
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
    if not ( values["stack_protector"] == "") then
      if values["stack_protector"] == "off" then
        insert(jln_cxflags, "/GS-")
      else
        insert(jln_cxflags, "/GS")
        if values["stack_protector"] == "strong" then
          insert(jln_cxflags, "/RTC1")
        else
          if values["stack_protector"] == "all" then
            insert(jln_cxflags, "/RTC1")
            insert(jln_cxflags, "/RTCc")
          end
        end
      end
    end
    if not ( values["sanitizers"] == "") then
      if values["sanitizers"] == "on" then
        insert(jln_cxflags, "/Qtrapuv")
      end
    end
    if not ( values["float_sanitizers"] == "") then
      if values["float_sanitizers"] == "on" then
        insert(jln_cxflags, "/Qfp-stack-check")
        insert(jln_cxflags, "/Qfp-trap:common")
      end
    end
    if not ( values["control_flow"] == "") then
      if values["control_flow"] == "off" then
        insert(jln_cxflags, "/guard:cf-")
        insert(jln_cxflags, "/mconditional-branch=keep")
      else
        insert(jln_cxflags, "/guard:cf")
        if values["control_flow"] == "branch" then
          insert(jln_cxflags, "/mconditional-branch:all-fix")
          insert(jln_cxflags, "/Qcf-protection:branch")
        else
          if values["control_flow"] == "on" then
            insert(jln_cxflags, "/mconditional-branch:all-fix")
            insert(jln_cxflags, "/Qcf-protection:full")
          end
        end
      end
    end
    if not ( values["cpu"] == "") then
      if values["cpu"] == "generic" then
        insert(jln_cxflags, "/Qtune:generic")
        insert(jln_ldflags, "/Qtune:generic")
      else
        insert(jln_cxflags, "/QxHost")
        insert(jln_ldflags, "/QxHost")
      end
    end
  else
    if compiler == "icc" then
      if not ( values["warnings"] == "") then
        if values["warnings"] == "off" then
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
          insert(jln_cxflags, "-Wold-style-definition")
          insert(jln_cxflags, "-Wstrict-prototypes")
          insert(jln_cxflags, "-Wwrite-strings")
          if not ( values["switch_warnings"] == "") then
            if ( values["switch_warnings"] == "on" or values["switch_warnings"] == "exhaustive_enum" ) then
              insert(jln_cxflags, "-Wswitch-enum")
            else
              if values["switch_warnings"] == "mandatory_default" then
                insert(jln_cxflags, "-Wswitch-default")
              else
                if values["switch_warnings"] == "exhaustive_enum_and_mandatory_default" then
                  insert(jln_cxflags, "-Wswitch")
                else
                  insert(jln_cxflags, "-Wno-switch")
                end
              end
            end
          end
        end
      end
      if not ( values["warnings_as_error"] == "") then
        if values["warnings_as_error"] == "on" then
          insert(jln_cxflags, "-Werror")
        else
          if values["warnings_as_error"] == "basic" then
            insert(jln_cxflags, "-diag-error=1079,39,109")
          end
        end
      end
      if not ( values["pedantic"] == "") then
        if values["pedantic"] == "off" then
          insert(jln_cxflags, "-fgnu-keywords")
        else
          insert(jln_cxflags, "-fno-gnu-keywords")
        end
      end
      if not ( values["shadow_warnings"] == "") then
        if values["shadow_warnings"] == "off" then
          insert(jln_cxflags, "-Wno-shadow")
        else
          if ( values["shadow_warnings"] == "on" or values["shadow_warnings"] == "all" ) then
            insert(jln_cxflags, "-Wshadow")
          end
        end
      end
      if not ( values["debug"] == "") then
        if values["debug"] == "off" then
          insert(jln_cxflags, "-g0")
        else
          insert(jln_cxflags, "-g")
        end
      end
      if not ( values["optimization"] == "") then
        if values["optimization"] == "0" then
          insert(jln_cxflags, "-O0")
        else
          if values["optimization"] == "g" then
            insert(jln_cxflags, "-O1")
          else
            insert(jln_cxflags, "-DNDEBUG")
            if values["optimization"] == "1" then
              insert(jln_cxflags, "-O1")
            else
              if values["optimization"] == "2" then
                insert(jln_cxflags, "-O2")
              else
                if values["optimization"] == "3" then
                  insert(jln_cxflags, "-O3")
                else
                  if values["optimization"] == "z" then
                    insert(jln_cxflags, "-fast")
                  else
                    if values["optimization"] == "size" then
                      insert(jln_cxflags, "-Os")
                    else
                      if values["optimization"] == "fast" then
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
      if not ( values["stack_protector"] == "") then
        if values["stack_protector"] == "off" then
          insert(jln_cxflags, "-fno-protector-strong")
          insert(jln_cxflags, "-U_FORTIFY_SOURCE")
          insert(jln_ldflags, "-fno-protector-strong")
        else
          insert(jln_cxflags, "-D_FORTIFY_SOURCE=2")
          if values["stack_protector"] == "strong" then
            insert(jln_cxflags, "-fstack-protector-strong")
            insert(jln_ldflags, "-fstack-protector-strong")
          else
            if values["stack_protector"] == "all" then
              insert(jln_cxflags, "-fstack-protector-all")
              insert(jln_ldflags, "-fstack-protector-all")
            else
              insert(jln_cxflags, "-fstack-protector")
              insert(jln_ldflags, "-fstack-protector")
            end
          end
        end
      end
      if not ( values["relro"] == "") then
        if values["relro"] == "off" then
          insert(jln_ldflags, "-Xlinker-znorelro")
        else
          if values["relro"] == "on" then
            insert(jln_ldflags, "-Xlinker-zrelro")
          else
            if values["relro"] == "full" then
              insert(jln_ldflags, "-Xlinker-zrelro")
              insert(jln_ldflags, "-Xlinker-znow")
              insert(jln_ldflags, "-Xlinker-znoexecstack")
            end
          end
        end
      end
      if not ( values["pie"] == "") then
        if values["pie"] == "off" then
          insert(jln_ldflags, "-no-pic")
        else
          if values["pie"] == "on" then
            insert(jln_ldflags, "-pie")
          else
            if values["pie"] == "fpie" then
              insert(jln_cxflags, "-fpie")
            else
              if values["pie"] == "fpic" then
                insert(jln_cxflags, "-fpic")
              else
                if values["pie"] == "fPIE" then
                  insert(jln_cxflags, "-fPIE")
                else
                  if values["pie"] == "fPIC" then
                    insert(jln_cxflags, "-fPIC")
                  end
                end
              end
            end
          end
        end
      end
      if not ( values["sanitizers"] == "") then
        if values["sanitizers"] == "on" then
          insert(jln_cxflags, "-ftrapuv")
        end
      end
      if not ( values["integer_sanitizers"] == "") then
        if values["integer_sanitizers"] == "on" then
          insert(jln_cxflags, "-funsigned-bitfields")
        else
          insert(jln_cxflags, "-fno-unsigned-bitfields")
        end
      end
      if not ( values["float_sanitizers"] == "") then
        if values["float_sanitizers"] == "on" then
          insert(jln_cxflags, "-fp-stack-check")
          insert(jln_cxflags, "-fp-trap=common")
        end
      end
      if not ( values["linker"] == "") then
        if values["linker"] == "bfd" then
          insert(jln_ldflags, "-fuse-ld=bfd")
        else
          if values["linker"] == "gold" then
            insert(jln_ldflags, "-fuse-ld=gold")
          else
            insert(jln_ldflags, "-fuse-ld=lld")
          end
        end
      end
      if not ( values["lto"] == "") then
        if values["lto"] == "off" then
          insert(jln_cxflags, "-no-ipo")
          insert(jln_ldflags, "-no-ipo")
        else
          insert(jln_cxflags, "-ipo")
          insert(jln_ldflags, "-ipo")
          if values["lto"] == "fat" then
            if is_plat("linux") then
              insert(jln_cxflags, "-ffat-lto-objects")
              insert(jln_ldflags, "-ffat-lto-objects")
            end
          end
        end
      end
      if not ( values["control_flow"] == "") then
        if values["control_flow"] == "off" then
          insert(jln_cxflags, "-mconditional-branch=keep")
          insert(jln_cxflags, "-fcf-protection=none")
        else
          if values["control_flow"] == "branch" then
            insert(jln_cxflags, "-mconditional-branch=all-fix")
            insert(jln_cxflags, "-fcf-protection=branch")
          else
            if values["control_flow"] == "on" then
              insert(jln_cxflags, "-mconditional-branch=all-fix")
              insert(jln_cxflags, "-fcf-protection=full")
            end
          end
        end
      end
      if not ( values["exceptions"] == "") then
        if values["exceptions"] == "on" then
          insert(jln_cxflags, "-fexceptions")
        else
          insert(jln_cxflags, "-fno-exceptions")
        end
      end
      if not ( values["cpu"] == "") then
        if values["cpu"] == "generic" then
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
    if not ( values["windows_bigobj"] == "") then
      insert(jln_cxflags, "-Wa,-mbig-obj")
    end
  end
  return {cflags=jln_cxflags, ldflags=jln_ldflags}
end

