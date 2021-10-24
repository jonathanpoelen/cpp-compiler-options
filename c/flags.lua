--  ```lua
--  -- launch example: xmake f --jln-sanitizers=on
--  
--  includes'cpp'
--  
--  -- Registers new command-line options and set default values
--  jln_cxx_init_options({warnings='very_strict'} --[[, category=string|boolean]])
--  
--  options = {}
--  if is_mode('debug') then
--    options.str_debug = 'on'
--  end
--  
--  -- Create a new rule. Options are added to the current configuration
--  jln_cxx_rule('jln_debug', options --[[, disable_others = false, imported='cpp.flags']])
--  add_rules('jln_flags')
--  
--  target('hello')
--    set_kind('binary')
--    -- Custom configuration when jln_cxx_rule() is not enough
--    on_load(function(target)
--      import'cpp.flags'
--      -- getoptions(values = {}, disable_others = false, print_compiler = false)
--      -- `values`: table. ex: {warnings='on'}
--      -- `values` can have 3 additional fields:
--      --  - `cxx`: compiler name (otherwise deducted from --cxx and --toolchain)
--      --  - `cxx_version` (otherwise deducted from cxx)
--      --  - `ld`: linker name
--      -- `disable_others`: boolean
--      -- `print_compiler`: boolean
--      -- return {cxxflags=table, ldflags=table}
--      -- Note: with C language, cxxflags, cxx and cxx_version become cflags, cc and cc_version
--      local options = flags.getoptions({elide_type='on'})
--      for _,opt in ipairs(options.cxxflags) do target:add('cxxflags', opt, {force=true}) end
--      for _,opt in ipairs(options.ldflags) do target:add('ldflags', opt, {force=true}) end
--  
--      -- or equivalent (return also options)
--      flags.setoptions(target, {elide_type='on'})
--  
--      -- return the merge of the default values and new value table
--      local values = flags.tovalues({elide_type='on'}, --[[disable_others:bool]])
--      print(values)
--    end)
--  
--    add_files('src/*.cpp')
--  
--  -- NOTE: for C, jln_ and jln_cxx_ prefix function become jln_c_
--  ```
--  
--  
--  # Options
--  
--  Supported options are (in alphabetical order):
--  
--  <!-- ./compiler-options.lua generators/list_options.lua --color -->
--  ```ini
--  color = default auto never always
--  control_flow = default off on branch return allow_bugs
--  conversion_warnings = on default off sign conversion
--  coverage = default off on
--  covered_switch_default_warnings = on default off
--  cpu = default generic native
--  debug = default off on line_tables_only gdb lldb sce
--  diagnostics_format = default fixits patch print_source_range_info
--  diagnostics_show_template_tree = default off on
--  elide_type = default off on
--  exceptions = default off on
--  fix_compiler_error = on default off
--  float_sanitizers = default off on
--  integer_sanitizers = default off on
--  linker = default bfd gold lld native
--  lto = default off on fat thin
--  microsoft_abi_compatibility_warnings = off default on
--  msvc_isystem = default anglebrackets include_and_caexcludepath external_as_include_system_flag
--  msvc_isystem_with_template_from_non_external = default off on
--  noexcept_warnings = default off on
--  optimization = default 0 g 1 2 3 fast size z
--  other_sanitizers = default off thread pointer memory
--  pedantic = on default off as_error
--  pie = default off on static fpic fPIC fpie fPIE
--  relro = default off on full
--  reproducible_build_warnings = default off on
--  rtti = default off on
--  sanitizers = default off on
--  shadow_warnings = off default on local compatible_local all
--  stack_protector = default off on strong all
--  stl_debug = default off on allow_broken_abi allow_broken_abi_and_bugs assert_as_exception
--  stl_fix = on default off
--  suggestions = default off on
--  switch_warnings = on default off enum mandatory_default
--  warnings = on default off strict very_strict
--  warnings_as_error = default off on basic
--  whole_program = default off on strip_all
--  ```
--  <!-- ./compiler-options.lua -->
--  
--  The value `default` does nothing.
--  
--  If not specified, `conversion_warnings`, `covered_switch_default_warnings`, `fix_compiler_error`, `pedantic`, `stl_fix`, `switch_warnings` and `warnings` are `on` ; `microsoft_abi_compatibility_warnings` and `shadow_warnings` are `off`.
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
  ["jln-linker"] = {["default"]="", ["bfd"]="bfd", ["gold"]="gold", ["lld"]="lld", ["native"]="native", [""]=""},
  ["linker"] = {["default"]="", ["bfd"]="bfd", ["gold"]="gold", ["lld"]="lld", ["native"]="native", [""]=""},
  ["jln-lto"] = {["default"]="", ["off"]="off", ["on"]="on", ["fat"]="fat", ["thin"]="thin", [""]=""},
  ["lto"] = {["default"]="", ["off"]="off", ["on"]="on", ["fat"]="fat", ["thin"]="thin", [""]=""},
  ["jln-microsoft-abi-compatibility-warning"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["microsoft_abi_compatibility_warning"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["jln-msvc-isystem"] = {["default"]="", ["anglebrackets"]="anglebrackets", ["include_and_caexcludepath"]="include_and_caexcludepath", ["external_as_include_system_flag"]="external_as_include_system_flag", [""]=""},
  ["msvc_isystem"] = {["default"]="", ["anglebrackets"]="anglebrackets", ["include_and_caexcludepath"]="include_and_caexcludepath", ["external_as_include_system_flag"]="external_as_include_system_flag", [""]=""},
  ["jln-msvc-isystem-with-template-from-non-external"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["msvc_isystem_with_template_from_non_external"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["jln-optimization"] = {["default"]="", ["0"]="0", ["g"]="g", ["1"]="1", ["2"]="2", ["3"]="3", ["fast"]="fast", ["size"]="size", ["z"]="z", [""]=""},
  ["optimization"] = {["default"]="", ["0"]="0", ["g"]="g", ["1"]="1", ["2"]="2", ["3"]="3", ["fast"]="fast", ["size"]="size", ["z"]="z", [""]=""},
  ["jln-pedantic"] = {["default"]="", ["off"]="off", ["on"]="on", ["as_error"]="as_error", [""]=""},
  ["pedantic"] = {["default"]="", ["off"]="off", ["on"]="on", ["as_error"]="as_error", [""]=""},
  ["jln-pie"] = {["default"]="", ["off"]="off", ["on"]="on", ["pic"]="pic", [""]=""},
  ["pie"] = {["default"]="", ["off"]="off", ["on"]="on", ["pic"]="pic", [""]=""},
  ["jln-relro"] = {["default"]="", ["off"]="off", ["on"]="on", ["full"]="full", [""]=""},
  ["relro"] = {["default"]="", ["off"]="off", ["on"]="on", ["full"]="full", [""]=""},
  ["jln-reproducible-build-warnings"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["reproducible_build_warnings"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["jln-rtti"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["rtti"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["jln-sanitizers"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["sanitizers"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["jln-sanitizers-extra"] = {["default"]="", ["off"]="off", ["thread"]="thread", ["pointer"]="pointer", [""]=""},
  ["sanitizers_extra"] = {["default"]="", ["off"]="off", ["thread"]="thread", ["pointer"]="pointer", [""]=""},
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
  ["jln-warnings"] = {["default"]="", ["off"]="off", ["on"]="on", ["strict"]="strict", ["very_strict"]="very_strict", [""]=""},
  ["warnings"] = {["default"]="", ["off"]="off", ["on"]="on", ["strict"]="strict", ["very_strict"]="very_strict", [""]=""},
  ["jln-warnings-as-error"] = {["default"]="", ["off"]="off", ["on"]="on", ["basic"]="basic", [""]=""},
  ["warnings_as_error"] = {["default"]="", ["off"]="off", ["on"]="on", ["basic"]="basic", [""]=""},
  ["jln-warnings-covered-switch-default"] = {["default"]="", ["on"]="on", ["off"]="off", [""]=""},
  ["warnings_covered_switch_default"] = {["default"]="", ["on"]="on", ["off"]="off", [""]=""},
  ["jln-warnings-switch"] = {["default"]="", ["on"]="on", ["off"]="off", ["enum"]="enum", ["mandatory_default"]="mandatory_default", [""]=""},
  ["warnings_switch"] = {["default"]="", ["on"]="on", ["off"]="off", ["enum"]="enum", ["mandatory_default"]="mandatory_default", [""]=""},
  ["jln-whole-program"] = {["default"]="", ["off"]="off", ["on"]="on", ["strip_all"]="strip_all", [""]=""},
  ["whole_program"] = {["default"]="", ["off"]="off", ["on"]="on", ["strip_all"]="strip_all", [""]=""},
}


import'core.platform.platform'
import"lib.detect"

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
-- tovalues(table, disable_others = false)
-- `values`: table. ex: {warnings='on'}
-- `values` can have 3 additional fields:
--  - `cxx`: compiler name (otherwise deducted from --cxx and --toolchain)
--  - `cxx_version`: compiler version (otherwise deducted from cxx). ex: '7', '7.2'
--  - `ld`: linker name
function tovalues(values, disable_others)
  if values then
    _check_flags(values)
    return {
      ["color"] = values["color"] or values["jln-color"] or (disable_others and "" or _flag_names["color"][get_config("jln-color")]),
      ["control_flow"] = values["control_flow"] or values["jln-control-flow"] or (disable_others and "" or _flag_names["control_flow"][get_config("jln-control-flow")]),
      ["conversion_warnings"] = values["conversion_warnings"] or values["jln-conversion-warnings"] or (disable_others and "" or _flag_names["conversion_warnings"][get_config("jln-conversion-warnings")]),
      ["coverage"] = values["coverage"] or values["jln-coverage"] or (disable_others and "" or _flag_names["coverage"][get_config("jln-coverage")]),
      ["cpu"] = values["cpu"] or values["jln-cpu"] or (disable_others and "" or _flag_names["cpu"][get_config("jln-cpu")]),
      ["debug"] = values["debug"] or values["jln-debug"] or (disable_others and "" or _flag_names["debug"][get_config("jln-debug")]),
      ["diagnostics_format"] = values["diagnostics_format"] or values["jln-diagnostics-format"] or (disable_others and "" or _flag_names["diagnostics_format"][get_config("jln-diagnostics-format")]),
      ["diagnostics_show_template_tree"] = values["diagnostics_show_template_tree"] or values["jln-diagnostics-show-template-tree"] or (disable_others and "" or _flag_names["diagnostics_show_template_tree"][get_config("jln-diagnostics-show-template-tree")]),
      ["elide_type"] = values["elide_type"] or values["jln-elide-type"] or (disable_others and "" or _flag_names["elide_type"][get_config("jln-elide-type")]),
      ["exceptions"] = values["exceptions"] or values["jln-exceptions"] or (disable_others and "" or _flag_names["exceptions"][get_config("jln-exceptions")]),
      ["fix_compiler_error"] = values["fix_compiler_error"] or values["jln-fix-compiler-error"] or (disable_others and "" or _flag_names["fix_compiler_error"][get_config("jln-fix-compiler-error")]),
      ["linker"] = values["linker"] or values["jln-linker"] or (disable_others and "" or _flag_names["linker"][get_config("jln-linker")]),
      ["lto"] = values["lto"] or values["jln-lto"] or (disable_others and "" or _flag_names["lto"][get_config("jln-lto")]),
      ["microsoft_abi_compatibility_warning"] = values["microsoft_abi_compatibility_warning"] or values["jln-microsoft-abi-compatibility-warning"] or (disable_others and "" or _flag_names["microsoft_abi_compatibility_warning"][get_config("jln-microsoft-abi-compatibility-warning")]),
      ["msvc_isystem"] = values["msvc_isystem"] or values["jln-msvc-isystem"] or (disable_others and "" or _flag_names["msvc_isystem"][get_config("jln-msvc-isystem")]),
      ["msvc_isystem_with_template_from_non_external"] = values["msvc_isystem_with_template_from_non_external"] or values["jln-msvc-isystem-with-template-from-non-external"] or (disable_others and "" or _flag_names["msvc_isystem_with_template_from_non_external"][get_config("jln-msvc-isystem-with-template-from-non-external")]),
      ["optimization"] = values["optimization"] or values["jln-optimization"] or (disable_others and "" or _flag_names["optimization"][get_config("jln-optimization")]),
      ["pedantic"] = values["pedantic"] or values["jln-pedantic"] or (disable_others and "" or _flag_names["pedantic"][get_config("jln-pedantic")]),
      ["pie"] = values["pie"] or values["jln-pie"] or (disable_others and "" or _flag_names["pie"][get_config("jln-pie")]),
      ["relro"] = values["relro"] or values["jln-relro"] or (disable_others and "" or _flag_names["relro"][get_config("jln-relro")]),
      ["reproducible_build_warnings"] = values["reproducible_build_warnings"] or values["jln-reproducible-build-warnings"] or (disable_others and "" or _flag_names["reproducible_build_warnings"][get_config("jln-reproducible-build-warnings")]),
      ["rtti"] = values["rtti"] or values["jln-rtti"] or (disable_others and "" or _flag_names["rtti"][get_config("jln-rtti")]),
      ["sanitizers"] = values["sanitizers"] or values["jln-sanitizers"] or (disable_others and "" or _flag_names["sanitizers"][get_config("jln-sanitizers")]),
      ["sanitizers_extra"] = values["sanitizers_extra"] or values["jln-sanitizers-extra"] or (disable_others and "" or _flag_names["sanitizers_extra"][get_config("jln-sanitizers-extra")]),
      ["shadow_warnings"] = values["shadow_warnings"] or values["jln-shadow-warnings"] or (disable_others and "" or _flag_names["shadow_warnings"][get_config("jln-shadow-warnings")]),
      ["stack_protector"] = values["stack_protector"] or values["jln-stack-protector"] or (disable_others and "" or _flag_names["stack_protector"][get_config("jln-stack-protector")]),
      ["stl_debug"] = values["stl_debug"] or values["jln-stl-debug"] or (disable_others and "" or _flag_names["stl_debug"][get_config("jln-stl-debug")]),
      ["stl_fix"] = values["stl_fix"] or values["jln-stl-fix"] or (disable_others and "" or _flag_names["stl_fix"][get_config("jln-stl-fix")]),
      ["suggestions"] = values["suggestions"] or values["jln-suggestions"] or (disable_others and "" or _flag_names["suggestions"][get_config("jln-suggestions")]),
      ["warnings"] = values["warnings"] or values["jln-warnings"] or (disable_others and "" or _flag_names["warnings"][get_config("jln-warnings")]),
      ["warnings_as_error"] = values["warnings_as_error"] or values["jln-warnings-as-error"] or (disable_others and "" or _flag_names["warnings_as_error"][get_config("jln-warnings-as-error")]),
      ["warnings_covered_switch_default"] = values["warnings_covered_switch_default"] or values["jln-warnings-covered-switch-default"] or (disable_others and "" or _flag_names["warnings_covered_switch_default"][get_config("jln-warnings-covered-switch-default")]),
      ["warnings_switch"] = values["warnings_switch"] or values["jln-warnings-switch"] or (disable_others and "" or _flag_names["warnings_switch"][get_config("jln-warnings-switch")]),
      ["whole_program"] = values["whole_program"] or values["jln-whole-program"] or (disable_others and "" or _flag_names["whole_program"][get_config("jln-whole-program")]),
      ["cc"] = values["cc"] or (not disable_others and _get_extra("jln-cc")) or nil,
      ["cc_version"] = values["cc_version"] or (not disable_others and _get_extra("jln-cc-version")) or nil,
      ["ld"] = values["ld"] or (not disable_others and _get_extra("jln-ld")) or nil,
}
  else
    return {
      ["color"] = _flag_names["color"][get_config("jln-color")],
      ["control_flow"] = _flag_names["control_flow"][get_config("jln-control-flow")],
      ["conversion_warnings"] = _flag_names["conversion_warnings"][get_config("jln-conversion-warnings")],
      ["coverage"] = _flag_names["coverage"][get_config("jln-coverage")],
      ["cpu"] = _flag_names["cpu"][get_config("jln-cpu")],
      ["debug"] = _flag_names["debug"][get_config("jln-debug")],
      ["diagnostics_format"] = _flag_names["diagnostics_format"][get_config("jln-diagnostics-format")],
      ["diagnostics_show_template_tree"] = _flag_names["diagnostics_show_template_tree"][get_config("jln-diagnostics-show-template-tree")],
      ["elide_type"] = _flag_names["elide_type"][get_config("jln-elide-type")],
      ["exceptions"] = _flag_names["exceptions"][get_config("jln-exceptions")],
      ["fix_compiler_error"] = _flag_names["fix_compiler_error"][get_config("jln-fix-compiler-error")],
      ["linker"] = _flag_names["linker"][get_config("jln-linker")],
      ["lto"] = _flag_names["lto"][get_config("jln-lto")],
      ["microsoft_abi_compatibility_warning"] = _flag_names["microsoft_abi_compatibility_warning"][get_config("jln-microsoft-abi-compatibility-warning")],
      ["msvc_isystem"] = _flag_names["msvc_isystem"][get_config("jln-msvc-isystem")],
      ["msvc_isystem_with_template_from_non_external"] = _flag_names["msvc_isystem_with_template_from_non_external"][get_config("jln-msvc-isystem-with-template-from-non-external")],
      ["optimization"] = _flag_names["optimization"][get_config("jln-optimization")],
      ["pedantic"] = _flag_names["pedantic"][get_config("jln-pedantic")],
      ["pie"] = _flag_names["pie"][get_config("jln-pie")],
      ["relro"] = _flag_names["relro"][get_config("jln-relro")],
      ["reproducible_build_warnings"] = _flag_names["reproducible_build_warnings"][get_config("jln-reproducible-build-warnings")],
      ["rtti"] = _flag_names["rtti"][get_config("jln-rtti")],
      ["sanitizers"] = _flag_names["sanitizers"][get_config("jln-sanitizers")],
      ["sanitizers_extra"] = _flag_names["sanitizers_extra"][get_config("jln-sanitizers-extra")],
      ["shadow_warnings"] = _flag_names["shadow_warnings"][get_config("jln-shadow-warnings")],
      ["stack_protector"] = _flag_names["stack_protector"][get_config("jln-stack-protector")],
      ["stl_debug"] = _flag_names["stl_debug"][get_config("jln-stl-debug")],
      ["stl_fix"] = _flag_names["stl_fix"][get_config("jln-stl-fix")],
      ["suggestions"] = _flag_names["suggestions"][get_config("jln-suggestions")],
      ["warnings"] = _flag_names["warnings"][get_config("jln-warnings")],
      ["warnings_as_error"] = _flag_names["warnings_as_error"][get_config("jln-warnings-as-error")],
      ["warnings_covered_switch_default"] = _flag_names["warnings_covered_switch_default"][get_config("jln-warnings-covered-switch-default")],
      ["warnings_switch"] = _flag_names["warnings_switch"][get_config("jln-warnings-switch")],
      ["whole_program"] = _flag_names["whole_program"][get_config("jln-whole-program")],
      ["cc"] = _get_extra("jln-cc"),
      ["cc_version"] = _get_extra("jln-cc-version"),
      ["ld"] = _get_extra("jln-ld"),
}
  end
end

-- same as getoptions() and apply the options on a target
function setoptions(target, values, disable_others, print_compiler)
  local options = getoptions(values, disable_others, print_compiler)
  for _,opt in ipairs(options.cflags) do target:add('cflags', opt, {force=true}) end
  for _,opt in ipairs(options.ldflags) do target:add('ldflags', opt, {force=true}) end
  return options
end

local _compiler_by_toolname = {
  vs='msvc',
  gcc='gcc',
  gxx='gcc',
  clang='clang',
  clangxx='clang',
}

local _comp_cache = {}
local _ld_cache = {}

-- getoptions(values = {}, disable_others = false, print_compiler = false)
-- `values`: same as tovalue()
-- `disable_others`: boolean
-- `print_compiler`: boolean
-- return {cflags=table, ldflags=table}
function getoptions(values, disable_others, print_compiler)
  local compversion

  values = tovalues(values, disable_others)
  local compiler = values.cc  local version = values.cc_version
  local linker = values.ld

  do
    local original_linker = linker or ''
    linker = _ld_cache[original_linker]

    if not linker then
      if disable_others then
        linker = ''
        _ld_cache[original_linker] = linker
      else
        local program, toolname = platform.tool('ld')
        linker = toolname or detect.find_toolname(program) or nil
        _ld_cache[original_linker] = linker or ''
      end
    end
  end

  local cache = _comp_cache
  local original_compiler = compiler or ''
  local compcache = cache[original_compiler]

  if compcache then
    compiler = compcache[1]
    version = compcache[2]
    compversion = compcache[3]
    if not compiler then
      -- wrintf("Unknown compiler")
      return {buildoptions={}, linkoptions={}}
    end
  else
    cache[original_compiler] = {}

    local toolname
    if not compiler then
      compiler, toolname = platform.tool('cc')
    end

    if not compiler then
      -- wprint("Unknown compiler")
      return {cflags={}, ldflags={}}
    end

    local realcompiler = compiler

    compiler = detect.find_toolname(compiler)
    if not compiler then
      compiler = detect.find_toolname(toolname) or toolname
      if compiler then
        if not version then
          version = toolname:match("%d+%.?%d*%.?%d*$")
        end
      else
        compiler = realcompiler
      end
    end
    compiler = _compiler_by_toolname[compiler]
            or (compiler:find('^vs') and 'msvc')
            or compiler

    if not version then
      version = detect.find_programver(realcompiler)

      if not version then
        version = tostring(tonumber(os.date("%y")) - (compiler:sub(0, 5) == 'clang' and 14 or 12))
      end
    end

    compversion = {}
    for i in version:gmatch("%d+") do
      compversion[#compversion+1] = tonumber(i)
    end
    if not compversion[1] then
      cprint("${color.red}Wrong version format: %s", version)
      return {cflags={}, ldflags={}}
    end
    compversion = compversion[1] * 100 + (compversion[2] or 0)

    cache[original_compiler] = {compiler, version, compversion}
  end

  if print_compiler then
    cprint("getoptions: compiler: ${cyan}%s${reset}, version: ${cyan}%s", compiler, version)
  end

  local jln_cxflags, jln_ldflags = {}, {}

  if ( compiler == "gcc" or compiler == "clang" or compiler == "clang-cl" ) then
    if not ( values["warnings"] == "") then
      if values["warnings"] == "off" then
        jln_cxflags[#jln_cxflags+1] = "-w"
      else
        if compiler == "gcc" then
          jln_cxflags[#jln_cxflags+1] = "-Wall"
          jln_cxflags[#jln_cxflags+1] = "-Wextra"
          jln_cxflags[#jln_cxflags+1] = "-Wcast-align"
          jln_cxflags[#jln_cxflags+1] = "-Wcast-qual"
          jln_cxflags[#jln_cxflags+1] = "-Wdisabled-optimization"
          jln_cxflags[#jln_cxflags+1] = "-Wfloat-equal"
          jln_cxflags[#jln_cxflags+1] = "-Wformat-security"
          jln_cxflags[#jln_cxflags+1] = "-Wformat=2"
          jln_cxflags[#jln_cxflags+1] = "-Wmissing-include-dirs"
          jln_cxflags[#jln_cxflags+1] = "-Wpacked"
          jln_cxflags[#jln_cxflags+1] = "-Wredundant-decls"
          jln_cxflags[#jln_cxflags+1] = "-Wundef"
          jln_cxflags[#jln_cxflags+1] = "-Wunused-macros"
          jln_cxflags[#jln_cxflags+1] = "-Winvalid-pch"
          jln_cxflags[#jln_cxflags+1] = "-Wpointer-arith"
          jln_cxflags[#jln_cxflags+1] = "-Wbad-function-cast"
          jln_cxflags[#jln_cxflags+1] = "-Winit-self"
          jln_cxflags[#jln_cxflags+1] = "-Wjump-misses-init"
          jln_cxflags[#jln_cxflags+1] = "-Wnested-externs"
          jln_cxflags[#jln_cxflags+1] = "-Wold-style-definition"
          jln_cxflags[#jln_cxflags+1] = "-Wstrict-prototypes"
          jln_cxflags[#jln_cxflags+1] = "-Wwrite-strings"
          if not ( values["warnings_switch"] == "") then
            if values["warnings_switch"] == "on" then
              jln_cxflags[#jln_cxflags+1] = "-Wswitch"
            else
              if values["warnings_switch"] == "enum" then
                jln_cxflags[#jln_cxflags+1] = "-Wswitch-enum"
              else
                if values["warnings_switch"] == "mandatory_default" then
                  jln_cxflags[#jln_cxflags+1] = "-Wswitch-default"
                else
                  jln_cxflags[#jln_cxflags+1] = "-Wno-switch"
                end
              end
            end
          end
          if not ( compversion < 407 ) then
            jln_cxflags[#jln_cxflags+1] = "-Wsuggest-attribute=noreturn"
            jln_cxflags[#jln_cxflags+1] = "-Wlogical-op"
            jln_cxflags[#jln_cxflags+1] = "-Wvector-operation-performance"
            jln_cxflags[#jln_cxflags+1] = "-Wdouble-promotion"
            jln_cxflags[#jln_cxflags+1] = "-Wtrampolines"
            if not ( compversion < 408 ) then
              if not ( compversion < 409 ) then
                jln_cxflags[#jln_cxflags+1] = "-Wfloat-conversion"
                if not ( compversion < 501 ) then
                  jln_cxflags[#jln_cxflags+1] = "-Wformat-signedness"
                  jln_cxflags[#jln_cxflags+1] = "-Warray-bounds=2"
                  if not ( compversion < 601 ) then
                    jln_cxflags[#jln_cxflags+1] = "-Wduplicated-cond"
                    jln_cxflags[#jln_cxflags+1] = "-Wnull-dereference"
                    if not ( compversion < 700 ) then
                      if not ( compversion < 701 ) then
                        jln_cxflags[#jln_cxflags+1] = "-Walloc-zero"
                        jln_cxflags[#jln_cxflags+1] = "-Walloca"
                        jln_cxflags[#jln_cxflags+1] = "-Wformat-overflow=2"
                        jln_cxflags[#jln_cxflags+1] = "-Wduplicated-branches"
                      end
                    end
                  end
                end
              end
            end
          end
        else
          if ( compiler == "clang" or compiler == "clang-cl" ) then
            jln_cxflags[#jln_cxflags+1] = "-Weverything"
            jln_cxflags[#jln_cxflags+1] = "-Wno-documentation"
            jln_cxflags[#jln_cxflags+1] = "-Wno-documentation-unknown-command"
            jln_cxflags[#jln_cxflags+1] = "-Wno-newline-eof"
            jln_cxflags[#jln_cxflags+1] = "-Wno-padded"
            jln_cxflags[#jln_cxflags+1] = "-Wno-global-constructors"
            if not ( values["warnings_switch"] == "") then
              if values["warnings_switch"] == "on" then
                jln_cxflags[#jln_cxflags+1] = "-Wno-switch-enum"
              else
                if values["warnings_switch"] == "enum" then
                  jln_cxflags[#jln_cxflags+1] = "-Wswitch-enum"
                else
                  if values["warnings_switch"] == "off" then
                    jln_cxflags[#jln_cxflags+1] = "-Wno-switch"
                    jln_cxflags[#jln_cxflags+1] = "-Wno-switch-enum"
                  end
                end
              end
            else
              jln_cxflags[#jln_cxflags+1] = "-Wno-switch"
              jln_cxflags[#jln_cxflags+1] = "-Wno-switch-enum"
            end
            if not ( values["warnings_covered_switch_default"] == "") then
              if values["warnings_covered_switch_default"] == "off" then
                jln_cxflags[#jln_cxflags+1] = "-Wno-covered-switch-default"
              end
            end
          end
        end
        if ( values["warnings"] == "strict" or values["warnings"] == "very_strict" ) then
          if ( compiler == "gcc" and not ( compversion < 800 ) ) then
            jln_cxflags[#jln_cxflags+1] = "-Wcast-align=strict"
          end
        end
      end
    end
    if not ( values["conversion_warnings"] == "") then
      if values["conversion_warnings"] == "on" then
        jln_cxflags[#jln_cxflags+1] = "-Wconversion"
        jln_cxflags[#jln_cxflags+1] = "-Wsign-compare"
        jln_cxflags[#jln_cxflags+1] = "-Wsign-conversion"
      else
        if values["conversion_warnings"] == "conversion" then
          jln_cxflags[#jln_cxflags+1] = "-Wconversion"
        else
          if values["conversion_warnings"] == "sign" then
            jln_cxflags[#jln_cxflags+1] = "-Wsign-compare"
            jln_cxflags[#jln_cxflags+1] = "-Wsign-conversion"
          else
            jln_cxflags[#jln_cxflags+1] = "-Wno-conversion"
            jln_cxflags[#jln_cxflags+1] = "-Wno-sign-compare"
            jln_cxflags[#jln_cxflags+1] = "-Wno-sign-conversion"
          end
        end
      end
    end
    if not ( values["warnings_as_error"] == "") then
      if values["warnings_as_error"] == "on" then
        jln_cxflags[#jln_cxflags+1] = "-Werror"
      else
        if values["warnings_as_error"] == "basic" then
          jln_cxflags[#jln_cxflags+1] = "-Werror=return-type"
          jln_cxflags[#jln_cxflags+1] = "-Werror=init-self"
          if ( compiler == "gcc" and not ( compversion < 501 ) ) then
            jln_cxflags[#jln_cxflags+1] = "-Werror=array-bounds"
            jln_cxflags[#jln_cxflags+1] = "-Werror=logical-op"
            jln_cxflags[#jln_cxflags+1] = "-Werror=logical-not-parentheses"
          else
            if ( compiler == "clang" or compiler == "clang-cl" ) then
              jln_cxflags[#jln_cxflags+1] = "-Werror=array-bounds"
              jln_cxflags[#jln_cxflags+1] = "-Werror=division-by-zero"
              if not ( compversion < 304 ) then
                jln_cxflags[#jln_cxflags+1] = "-Werror=logical-not-parentheses"
              end
            end
          end
        else
          jln_cxflags[#jln_cxflags+1] = "-Wno-error"
        end
      end
    end
    if not ( values["suggestions"] == "") then
      if not ( values["suggestions"] == "off" ) then
        if compiler == "gcc" then
          jln_cxflags[#jln_cxflags+1] = "-Wsuggest-attribute=pure"
          jln_cxflags[#jln_cxflags+1] = "-Wsuggest-attribute=const"
          if not ( compversion < 500 ) then
            if not ( compversion < 501 ) then
              jln_cxflags[#jln_cxflags+1] = "-Wnoexcept"
            end
          end
        end
      end
    end
    if not ( values["sanitizers"] == "") then
      if values["sanitizers"] == "off" then
        jln_cxflags[#jln_cxflags+1] = "-fno-sanitize=all"
        jln_ldflags[#jln_ldflags+1] = "-fno-sanitize=all"
      else
        if compiler == "clang-cl" then
          jln_cxflags[#jln_cxflags+1] = "-fsanitize=undefined"
          jln_cxflags[#jln_cxflags+1] = "-fsanitize=address"
          jln_cxflags[#jln_cxflags+1] = "-fsanitize-address-use-after-scope"
        else
          if compiler == "clang" then
            if not ( compversion < 301 ) then
              jln_cxflags[#jln_cxflags+1] = "-fsanitize=undefined"
              jln_cxflags[#jln_cxflags+1] = "-fsanitize=address"
              jln_cxflags[#jln_cxflags+1] = "-fsanitize-address-use-after-scope"
              jln_cxflags[#jln_cxflags+1] = "-fno-omit-frame-pointer"
              jln_cxflags[#jln_cxflags+1] = "-fno-optimize-sibling-calls"
              jln_ldflags[#jln_ldflags+1] = "-fsanitize=undefined"
              jln_ldflags[#jln_ldflags+1] = "-fsanitize=address"
              if not ( compversion < 304 ) then
                jln_cxflags[#jln_cxflags+1] = "-fsanitize=leak"
                jln_ldflags[#jln_ldflags+1] = "-fsanitize=leak"
              end
            end
          else
            if compiler == "gcc" then
              if not ( compversion < 408 ) then
                jln_cxflags[#jln_cxflags+1] = "-fsanitize=address"
                jln_cxflags[#jln_cxflags+1] = "-fno-omit-frame-pointer"
                jln_cxflags[#jln_cxflags+1] = "-fno-optimize-sibling-calls"
                jln_ldflags[#jln_ldflags+1] = "-fsanitize=address"
                if not ( compversion < 409 ) then
                  jln_cxflags[#jln_cxflags+1] = "-fsanitize=undefined"
                  jln_cxflags[#jln_cxflags+1] = "-fsanitize=leak"
                  jln_ldflags[#jln_ldflags+1] = "-fsanitize=undefined"
                  jln_ldflags[#jln_ldflags+1] = "-fsanitize=leak"
                end
              end
            end
          end
        end
      end
    end
    if not ( values["control_flow"] == "") then
      if values["control_flow"] == "off" then
        if ( compiler == "gcc" and not ( compversion < 800 ) ) then
          jln_cxflags[#jln_cxflags+1] = "-fcf-protection=none"
        else
          if compiler == "clang-cl" then
            jln_cxflags[#jln_cxflags+1] = "-fcf-protection=none"
            jln_cxflags[#jln_cxflags+1] = "-fno-sanitize-cfi-cross-dso"
          end
        end
        if compiler == "clang" then
          jln_cxflags[#jln_cxflags+1] = "-fno-sanitize=cfi"
          jln_ldflags[#jln_ldflags+1] = "-fno-sanitize=cfi"
        end
      else
        if ( ( compiler == "gcc" and not ( compversion < 800 ) ) or compiler == "clang-cl" ) then
          if values["control_flow"] == "branch" then
            jln_cxflags[#jln_cxflags+1] = "-fcf-protection=branch"
          else
            if values["control_flow"] == "return" then
              jln_cxflags[#jln_cxflags+1] = "-fcf-protection=return"
            else
              jln_cxflags[#jln_cxflags+1] = "-fcf-protection=full"
            end
          end
        else
          if ( values["control_flow"] == "allow_bugs" and compiler == "clang" ) then
            jln_cxflags[#jln_cxflags+1] = "-fsanitize=cfi"
            jln_cxflags[#jln_cxflags+1] = "-fvisibility=hidden"
            jln_cxflags[#jln_cxflags+1] = "-flto"
            jln_ldflags[#jln_ldflags+1] = "-fsanitize=cfi"
            jln_ldflags[#jln_ldflags+1] = "-flto"
          end
        end
      end
    end
    if not ( values["color"] == "") then
      if ( ( compiler == "gcc" and not ( compversion < 409 ) ) or compiler == "clang" or compiler == "clang-cl" ) then
        if values["color"] == "auto" then
          jln_cxflags[#jln_cxflags+1] = "-fdiagnostics-color=auto"
        else
          if values["color"] == "never" then
            jln_cxflags[#jln_cxflags+1] = "-fdiagnostics-color=never"
          else
            if values["color"] == "always" then
              jln_cxflags[#jln_cxflags+1] = "-fdiagnostics-color=always"
            end
          end
        end
      end
    end
    if not ( values["reproducible_build_warnings"] == "") then
      if ( compiler == "gcc" and not ( compversion < 409 ) ) then
        if values["reproducible_build_warnings"] == "on" then
          jln_cxflags[#jln_cxflags+1] = "-Wdate-time"
        else
          jln_cxflags[#jln_cxflags+1] = "-Wno-date-time"
        end
      end
    end
    if not ( values["diagnostics_format"] == "") then
      if values["diagnostics_format"] == "fixits" then
        if ( ( compiler == "gcc" and not ( compversion < 700 ) ) or ( compiler == "clang" and not ( compversion < 500 ) ) or ( compiler == "clang-cl" and not ( compversion < 500 ) ) ) then
          jln_cxflags[#jln_cxflags+1] = "-fdiagnostics-parseable-fixits"
        end
      else
        if values["diagnostics_format"] == "patch" then
          if ( compiler == "gcc" and not ( compversion < 700 ) ) then
            jln_cxflags[#jln_cxflags+1] = "-fdiagnostics-generate-patch"
          end
        else
          if values["diagnostics_format"] == "print_source_range_info" then
            if compiler == "clang" then
              jln_cxflags[#jln_cxflags+1] = "-fdiagnostics-print-source-range-info"
            end
          end
        end
      end
    end
    if not ( values["fix_compiler_error"] == "") then
      if values["fix_compiler_error"] == "on" then
        jln_cxflags[#jln_cxflags+1] = "-Werror=write-strings"
      else
        if ( compiler == "clang" or compiler == "clang-cl" ) then
          jln_cxflags[#jln_cxflags+1] = "-Wno-error=c++11-narrowing"
          jln_cxflags[#jln_cxflags+1] = "-Wno-reserved-user-defined-literal"
        end
      end
    end
  end
  if ( compiler == "gcc" or compiler == "clang" ) then
    if not ( values["coverage"] == "") then
      if values["coverage"] == "on" then
        jln_cxflags[#jln_cxflags+1] = "--coverage"
        jln_ldflags[#jln_ldflags+1] = "--coverage"
        if compiler == "clang" then
          jln_ldflags[#jln_ldflags+1] = "-lprofile_rt"
        end
      end
    end
    if not ( values["debug"] == "") then
      if values["debug"] == "off" then
        jln_cxflags[#jln_cxflags+1] = "-g0"
      else
        if values["debug"] == "gdb" then
          jln_cxflags[#jln_cxflags+1] = "-ggdb"
        else
          if compiler == "clang" then
            if values["debug"] == "line_tables_only" then
              jln_cxflags[#jln_cxflags+1] = "-gline-tables-only"
            end
            if values["debug"] == "lldb" then
              jln_cxflags[#jln_cxflags+1] = "-glldb"
            else
              if values["debug"] == "sce" then
                jln_cxflags[#jln_cxflags+1] = "-gsce"
              else
                jln_cxflags[#jln_cxflags+1] = "-g"
              end
            end
          else
            jln_cxflags[#jln_cxflags+1] = "-g"
          end
        end
      end
    end
    if not ( values["linker"] == "") then
      if values["linker"] == "native" then
        if compiler == "gcc" then
          jln_ldflags[#jln_ldflags+1] = "-fuse-ld=gold"
        else
          jln_ldflags[#jln_ldflags+1] = "-fuse-ld=lld"
        end
      else
        if values["linker"] == "bfd" then
          jln_ldflags[#jln_ldflags+1] = "-fuse-ld=bfd"
        else
          if ( values["linker"] == "gold" or ( compiler == "gcc" and not ( not ( compversion < 900 ) ) ) ) then
            jln_ldflags[#jln_ldflags+1] = "-fuse-ld=gold"
          else
            if not ( values["lto"] == "") then
              if ( not ( values["lto"] == "off" ) and compiler == "gcc" ) then
                jln_ldflags[#jln_ldflags+1] = "-fuse-ld=gold"
              else
                jln_ldflags[#jln_ldflags+1] = "-fuse-ld=lld"
              end
            else
              jln_ldflags[#jln_ldflags+1] = "-fuse-ld=lld"
            end
          end
        end
      end
    end
    if not ( values["lto"] == "") then
      if values["lto"] == "off" then
        jln_cxflags[#jln_cxflags+1] = "-fno-lto"
        jln_ldflags[#jln_ldflags+1] = "-fno-lto"
      else
        if compiler == "gcc" then
          jln_cxflags[#jln_cxflags+1] = "-flto"
          jln_ldflags[#jln_ldflags+1] = "-flto"
          if not ( compversion < 500 ) then
            if not ( values["warnings"] == "") then
              if not ( values["warnings"] == "off" ) then
                jln_cxflags[#jln_cxflags+1] = "-flto-odr-type-merging"
                jln_ldflags[#jln_ldflags+1] = "-flto-odr-type-merging"
              end
            end
            if values["lto"] == "fat" then
              jln_cxflags[#jln_cxflags+1] = "-ffat-lto-objects"
            else
              if values["lto"] == "thin" then
                jln_ldflags[#jln_ldflags+1] = "-fuse-linker-plugin"
              end
            end
          end
        else
          if ( values["lto"] == "thin" and compiler == "clang" and not ( compversion < 600 ) ) then
            jln_cxflags[#jln_cxflags+1] = "-flto=thin"
            jln_ldflags[#jln_ldflags+1] = "-flto=thin"
          else
            jln_cxflags[#jln_cxflags+1] = "-flto"
            jln_ldflags[#jln_ldflags+1] = "-flto"
          end
        end
      end
    end
    if not ( values["optimization"] == "") then
      if values["optimization"] == "0" then
        jln_cxflags[#jln_cxflags+1] = "-O0"
        jln_ldflags[#jln_ldflags+1] = "-O0"
      else
        if values["optimization"] == "g" then
          jln_cxflags[#jln_cxflags+1] = "-Og"
          jln_ldflags[#jln_ldflags+1] = "-Og"
        else
          jln_cxflags[#jln_cxflags+1] = "-DNDEBUG"
          jln_ldflags[#jln_ldflags+1] = "-Wl,-O1"
          if values["optimization"] == "size" then
            jln_cxflags[#jln_cxflags+1] = "-Os"
            jln_ldflags[#jln_ldflags+1] = "-Os"
          else
            if values["optimization"] == "z" then
              if ( compiler == "clang" or compiler == "clang-cl" ) then
                jln_cxflags[#jln_cxflags+1] = "-Oz"
                jln_ldflags[#jln_ldflags+1] = "-Oz"
              else
                jln_cxflags[#jln_cxflags+1] = "-Os"
                jln_ldflags[#jln_ldflags+1] = "-Os"
              end
            else
              if values["optimization"] == "fast" then
                jln_cxflags[#jln_cxflags+1] = "-Ofast"
                jln_ldflags[#jln_ldflags+1] = "-Ofast"
              else
                if values["optimization"] == "1" then
                  jln_cxflags[#jln_cxflags+1] = "-O1"
                  jln_ldflags[#jln_ldflags+1] = "-O1"
                else
                  if values["optimization"] == "2" then
                    jln_cxflags[#jln_cxflags+1] = "-O2"
                    jln_ldflags[#jln_ldflags+1] = "-O2"
                  else
                    if values["optimization"] == "3" then
                      jln_cxflags[#jln_cxflags+1] = "-O3"
                      jln_ldflags[#jln_ldflags+1] = "-O3"
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
        jln_cxflags[#jln_cxflags+1] = "-mtune=generic"
        jln_ldflags[#jln_ldflags+1] = "-mtune=generic"
      else
        jln_cxflags[#jln_cxflags+1] = "-march=native"
        jln_cxflags[#jln_cxflags+1] = "-mtune=native"
        jln_ldflags[#jln_ldflags+1] = "-march=native"
        jln_ldflags[#jln_ldflags+1] = "-mtune=native"
      end
    end
    if not ( values["whole_program"] == "") then
      if values["whole_program"] == "off" then
        jln_cxflags[#jln_cxflags+1] = "-fno-whole-program"
        if ( compiler == "clang" and not ( compversion < 309 ) ) then
          jln_cxflags[#jln_cxflags+1] = "-fno-whole-program-vtables"
          jln_ldflags[#jln_ldflags+1] = "-fno-whole-program-vtables"
        end
      else
        if linker == "ld64" then
          jln_ldflags[#jln_ldflags+1] = "-Wl,-dead_strip"
          jln_ldflags[#jln_ldflags+1] = "-Wl,-S"
        else
          jln_ldflags[#jln_ldflags+1] = "-s"
          if values["whole_program"] == "strip_all" then
            jln_ldflags[#jln_ldflags+1] = "-Wl,--gc-sections"
            jln_ldflags[#jln_ldflags+1] = "-Wl,--strip-all"
          end
        end
        if compiler == "gcc" then
          jln_cxflags[#jln_cxflags+1] = "-fwhole-program"
          jln_ldflags[#jln_ldflags+1] = "-fwhole-program"
        else
          if compiler == "clang" then
            if not ( compversion < 309 ) then
              if not ( values["lto"] == "") then
                if not ( values["lto"] == "off" ) then
                  jln_cxflags[#jln_cxflags+1] = "-fwhole-program-vtables"
                  jln_ldflags[#jln_ldflags+1] = "-fwhole-program-vtables"
                end
              end
              if not ( compversion < 700 ) then
                jln_cxflags[#jln_cxflags+1] = "-fforce-emit-vtables"
                jln_ldflags[#jln_ldflags+1] = "-fforce-emit-vtables"
              end
            end
          end
        end
      end
    end
    if not ( values["pedantic"] == "") then
      if not ( values["pedantic"] == "off" ) then
        jln_cxflags[#jln_cxflags+1] = "-pedantic"
        if values["pedantic"] == "as_error" then
          jln_cxflags[#jln_cxflags+1] = "-pedantic-errors"
        end
      end
    end
    if not ( values["stack_protector"] == "") then
      if values["stack_protector"] == "off" then
        jln_cxflags[#jln_cxflags+1] = "-Wno-stack-protector"
        jln_cxflags[#jln_cxflags+1] = "-U_FORTIFY_SOURCE"
        jln_ldflags[#jln_ldflags+1] = "-Wno-stack-protector"
      else
        jln_cxflags[#jln_cxflags+1] = "-D_FORTIFY_SOURCE=2"
        jln_cxflags[#jln_cxflags+1] = "-Wstack-protector"
        if values["stack_protector"] == "strong" then
          if ( compiler == "gcc" and not ( compversion < 409 ) ) then
            jln_cxflags[#jln_cxflags+1] = "-fstack-protector-strong"
            jln_ldflags[#jln_ldflags+1] = "-fstack-protector-strong"
          else
            if compiler == "clang" then
              jln_cxflags[#jln_cxflags+1] = "-fstack-protector-strong"
              jln_cxflags[#jln_cxflags+1] = "-fsanitize=safe-stack"
              jln_ldflags[#jln_ldflags+1] = "-fstack-protector-strong"
              jln_ldflags[#jln_ldflags+1] = "-fsanitize=safe-stack"
            end
          end
        else
          if values["stack_protector"] == "all" then
            jln_cxflags[#jln_cxflags+1] = "-fstack-protector-all"
            jln_ldflags[#jln_ldflags+1] = "-fstack-protector-all"
            if compiler == "clang" then
              jln_cxflags[#jln_cxflags+1] = "-fsanitize=safe-stack"
              jln_ldflags[#jln_ldflags+1] = "-fsanitize=safe-stack"
              if not ( compversion < 1100 ) then
                jln_cxflags[#jln_cxflags+1] = "-fstack-clash-protection"
                jln_ldflags[#jln_ldflags+1] = "-fstack-clash-protection"
              end
            end
          else
            jln_cxflags[#jln_cxflags+1] = "-fstack-protector"
            jln_ldflags[#jln_ldflags+1] = "-fstack-protector"
          end
        end
        if compiler == "clang" then
          jln_cxflags[#jln_cxflags+1] = "-fsanitize=shadow-call-stack"
          jln_ldflags[#jln_ldflags+1] = "-fsanitize=shadow-call-stack"
        end
      end
    end
    if not ( values["relro"] == "") then
      if values["relro"] == "off" then
        jln_ldflags[#jln_ldflags+1] = "-Wl,-z,norelro"
      else
        if values["relro"] == "on" then
          jln_ldflags[#jln_ldflags+1] = "-Wl,-z,relro"
        else
          if values["relro"] == "full" then
            jln_ldflags[#jln_ldflags+1] = "-Wl,-z,relro,-z,now"
          end
        end
      end
    end
    if not ( values["pie"] == "") then
      if values["pie"] == "off" then
        jln_ldflags[#jln_ldflags+1] = "-no-pic"
      else
        if values["pie"] == "on" then
          jln_ldflags[#jln_ldflags+1] = "-pie"
        else
          if values["pie"] == "pic" then
            jln_cxflags[#jln_cxflags+1] = "-fPIC"
          end
        end
      end
    end
    if not ( values["shadow_warnings"] == "") then
      if values["shadow_warnings"] == "off" then
        jln_cxflags[#jln_cxflags+1] = "-Wno-shadow"
        if ( compiler == "clang" and not ( compversion < 800 ) ) then
          jln_cxflags[#jln_cxflags+1] = "-Wno-shadow-field"
        end
      else
        if values["shadow_warnings"] == "on" then
          jln_cxflags[#jln_cxflags+1] = "-Wshadow"
        else
          if values["shadow_warnings"] == "all" then
            if compiler == "clang" then
              jln_cxflags[#jln_cxflags+1] = "-Wshadow-all"
            else
              jln_cxflags[#jln_cxflags+1] = "-Wshadow"
            end
          else
            if ( compiler == "gcc" and not ( compversion < 701 ) ) then
              if values["shadow_warnings"] == "local" then
                jln_cxflags[#jln_cxflags+1] = "-Wshadow=local"
              else
                if values["shadow_warnings"] == "compatible_local" then
                  jln_cxflags[#jln_cxflags+1] = "-Wshadow=compatible-local"
                end
              end
            end
          end
        end
      end
    end
    if not ( values["exceptions"] == "") then
      if values["exceptions"] == "on" then
        jln_cxflags[#jln_cxflags+1] = "-fexceptions"
      else
        jln_cxflags[#jln_cxflags+1] = "-fno-exceptions"
      end
    end
    if not ( values["sanitizers_extra"] == "") then
      if values["sanitizers_extra"] == "thread" then
        jln_cxflags[#jln_cxflags+1] = "-fsanitize=thread"
      else
        if values["sanitizers_extra"] == "pointer" then
          if ( compiler == "gcc" and not ( compversion < 800 ) ) then
            jln_cxflags[#jln_cxflags+1] = "-fsanitize=pointer-compare"
            jln_cxflags[#jln_cxflags+1] = "-fsanitize=pointer-subtract"
          end
        end
      end
    end
  end
  if linker == "lld-link" then
    if not ( values["lto"] == "") then
      if values["lto"] == "off" then
        jln_cxflags[#jln_cxflags+1] = "-fno-lto"
      else
        if values["lto"] == "thin" then
          jln_cxflags[#jln_cxflags+1] = "-flto=thin"
        else
          jln_cxflags[#jln_cxflags+1] = "-flto"
          jln_ldflags[#jln_ldflags+1] = "-flto"
        end
      end
    end
    if not ( values["whole_program"] == "") then
      if values["whole_program"] == "off" then
        jln_cxflags[#jln_cxflags+1] = "-fno-whole-program"
      else
        if not ( values["lto"] == "") then
          if not ( values["lto"] == "off" ) then
            jln_cxflags[#jln_cxflags+1] = "-fwhole-program-vtables"
            jln_ldflags[#jln_ldflags+1] = "-fwhole-program-vtables"
          end
        end
      end
    end
  end
  if ( compiler == "msvc" or compiler == "clang-cl" ) then
    if not ( values["stl_fix"] == "") then
      if values["stl_fix"] == "on" then
        jln_cxflags[#jln_cxflags+1] = "/DNOMINMAX"
      end
    end
    if not ( values["debug"] == "") then
      if values["debug"] == "off" then
        jln_cxflags[#jln_cxflags+1] = "/DEBUG:NONE"
      else
        jln_cxflags[#jln_cxflags+1] = "/RTC1"
        jln_cxflags[#jln_cxflags+1] = "/Od"
        if values["debug"] == "on" then
          jln_cxflags[#jln_cxflags+1] = "/DEBUG"
        else
          if values["debug"] == "line_tables_only" then
            jln_cxflags[#jln_cxflags+1] = "/DEBUG:FASTLINK"
          end
        end
        if not ( values["optimization"] == "") then
          if values["optimization"] == "g" then
            jln_cxflags[#jln_cxflags+1] = "/Zi"
          else
            if not ( values["whole_program"] == "") then
              if values["whole_program"] == "off" then
                jln_cxflags[#jln_cxflags+1] = "/ZI"
              else
                jln_cxflags[#jln_cxflags+1] = "/Zi"
              end
            else
              jln_cxflags[#jln_cxflags+1] = "/ZI"
            end
          end
        else
          if not ( values["whole_program"] == "") then
            if values["whole_program"] == "off" then
              jln_cxflags[#jln_cxflags+1] = "/ZI"
            else
              jln_cxflags[#jln_cxflags+1] = "/Zi"
            end
          else
            jln_cxflags[#jln_cxflags+1] = "/ZI"
          end
        end
      end
    end
    if not ( values["exceptions"] == "") then
      if values["exceptions"] == "on" then
        jln_cxflags[#jln_cxflags+1] = "/EHsc"
        jln_cxflags[#jln_cxflags+1] = "/D_HAS_EXCEPTIONS=1"
      else
        jln_cxflags[#jln_cxflags+1] = "/EHs-"
        jln_cxflags[#jln_cxflags+1] = "/D_HAS_EXCEPTIONS=0"
      end
    end
    if not ( values["optimization"] == "") then
      if values["optimization"] == "0" then
        jln_cxflags[#jln_cxflags+1] = "/Ob0"
        jln_cxflags[#jln_cxflags+1] = "/Od"
        jln_cxflags[#jln_cxflags+1] = "/Oi-"
        jln_cxflags[#jln_cxflags+1] = "/Oy-"
      else
        if values["optimization"] == "g" then
          jln_cxflags[#jln_cxflags+1] = "/Ob1"
        else
          jln_cxflags[#jln_cxflags+1] = "/DNDEBUG"
          if values["optimization"] == "1" then
            jln_cxflags[#jln_cxflags+1] = "/O1"
          else
            if values["optimization"] == "2" then
              jln_cxflags[#jln_cxflags+1] = "/O2"
            else
              if values["optimization"] == "3" then
                jln_cxflags[#jln_cxflags+1] = "/O2"
              else
                if values["optimization"] == "size" then
                  jln_cxflags[#jln_cxflags+1] = "/O1"
                  jln_cxflags[#jln_cxflags+1] = "/Gw"
                else
                  if values["optimization"] == "fast" then
                    jln_cxflags[#jln_cxflags+1] = "/O2"
                    jln_cxflags[#jln_cxflags+1] = "/fp:fast"
                  end
                end
              end
            end
          end
        end
      end
    end
    if not ( values["whole_program"] == "") then
      if values["whole_program"] == "off" then
        jln_cxflags[#jln_cxflags+1] = "/GL-"
      else
        jln_cxflags[#jln_cxflags+1] = "/GL"
        jln_cxflags[#jln_cxflags+1] = "/Gw"
        jln_ldflags[#jln_ldflags+1] = "/LTCG"
        if values["whole_program"] == "strip_all" then
          jln_ldflags[#jln_ldflags+1] = "/OPT:REF"
        end
      end
    end
    if not ( values["pedantic"] == "") then
      if not ( values["pedantic"] == "off" ) then
        jln_cxflags[#jln_cxflags+1] = "/permissive-"
      end
    end
    if not ( values["rtti"] == "") then
      if values["rtti"] == "on" then
        jln_cxflags[#jln_cxflags+1] = "/GR"
      else
        jln_cxflags[#jln_cxflags+1] = "/GR-"
      end
    end
    if not ( values["stl_debug"] == "") then
      if values["stl_debug"] == "off" then
        jln_cxflags[#jln_cxflags+1] = "/D_HAS_ITERATOR_DEBUGGING=0"
      else
        jln_cxflags[#jln_cxflags+1] = "/D_DEBUG"
        jln_cxflags[#jln_cxflags+1] = "/D_HAS_ITERATOR_DEBUGGING=1"
      end
    end
    if not ( values["control_flow"] == "") then
      if values["control_flow"] == "off" then
        jln_cxflags[#jln_cxflags+1] = "/guard:cf-"
      else
        jln_cxflags[#jln_cxflags+1] = "/guard:cf"
      end
    end
    if not ( values["stack_protector"] == "") then
      if values["stack_protector"] == "off" then
        jln_cxflags[#jln_cxflags+1] = "/GS-"
      else
        jln_cxflags[#jln_cxflags+1] = "/GS"
        jln_cxflags[#jln_cxflags+1] = "/sdl"
        if values["stack_protector"] == "strong" then
          jln_cxflags[#jln_cxflags+1] = "/RTC1"
        else
          if values["stack_protector"] == "all" then
            jln_cxflags[#jln_cxflags+1] = "/RTC1"
            jln_cxflags[#jln_cxflags+1] = "/RTCc"
          end
        end
      end
    end
  end
  if compiler == "msvc" then
    if not ( values["msvc_isystem"] == "") then
      if values["msvc_isystem"] == "external_as_include_system_flag" then
        -- unimplementable
      else
        jln_cxflags[#jln_cxflags+1] = "/experimental:external"
        jln_cxflags[#jln_cxflags+1] = "/external:W0"
        if values["msvc_isystem"] == "anglebrackets" then
          jln_cxflags[#jln_cxflags+1] = "/external:anglebrackets"
        else
          jln_cxflags[#jln_cxflags+1] = "/external:env:INCLUDE"
          jln_cxflags[#jln_cxflags+1] = "/external:env:CAExcludePath"
        end
      end
      if not ( values["msvc_isystem_with_template_from_non_external"] == "") then
        if values["msvc_isystem_with_template_from_non_external"] == "off" then
          jln_cxflags[#jln_cxflags+1] = "/external:template"
        else
          jln_cxflags[#jln_cxflags+1] = "/external:template-"
        end
      end
      if not ( values["warnings"] == "") then
        if values["warnings"] == "off" then
          jln_cxflags[#jln_cxflags+1] = "/W0"
        else
          jln_cxflags[#jln_cxflags+1] = "/wd4710"
          jln_cxflags[#jln_cxflags+1] = "/wd4711"
          if not ( not ( compversion < 1921 ) ) then
            jln_cxflags[#jln_cxflags+1] = "/wd4774"
          end
          if values["warnings"] == "on" then
            jln_cxflags[#jln_cxflags+1] = "/W4"
            jln_cxflags[#jln_cxflags+1] = "/wd4514"
          else
            jln_cxflags[#jln_cxflags+1] = "/Wall"
            jln_cxflags[#jln_cxflags+1] = "/wd4514"
            jln_cxflags[#jln_cxflags+1] = "/wd4571"
            jln_cxflags[#jln_cxflags+1] = "/wd4355"
            jln_cxflags[#jln_cxflags+1] = "/wd4548"
            jln_cxflags[#jln_cxflags+1] = "/wd4577"
            jln_cxflags[#jln_cxflags+1] = "/wd4820"
            jln_cxflags[#jln_cxflags+1] = "/wd5039"
            jln_cxflags[#jln_cxflags+1] = "/wd4464"
            jln_cxflags[#jln_cxflags+1] = "/wd4868"
            jln_cxflags[#jln_cxflags+1] = "/wd5045"
            if values["warnings"] == "strict" then
              jln_cxflags[#jln_cxflags+1] = "/wd4583"
              jln_cxflags[#jln_cxflags+1] = "/wd4619"
            end
          end
        end
      end
      if not ( values["warnings_switch"] == "") then
        if values["warnings_switch"] == "on" then
          jln_cxflags[#jln_cxflags+1] = "/we4061"
        else
          if values["warnings_switch"] == "enum" then
            jln_cxflags[#jln_cxflags+1] = "/we4062"
          else
            if values["warnings_switch"] == "off" then
              jln_cxflags[#jln_cxflags+1] = "/wd4061"
              jln_cxflags[#jln_cxflags+1] = "/wd4062"
            end
          end
        end
      end
    else
      if not ( values["warnings"] == "") then
        if values["warnings"] == "off" then
          jln_cxflags[#jln_cxflags+1] = "/W0"
        else
          if values["warnings"] == "on" then
            jln_cxflags[#jln_cxflags+1] = "/W4"
            jln_cxflags[#jln_cxflags+1] = "/wd4514"
            jln_cxflags[#jln_cxflags+1] = "/wd4711"
          else
            jln_cxflags[#jln_cxflags+1] = "/Wall"
            jln_cxflags[#jln_cxflags+1] = "/wd4355"
            jln_cxflags[#jln_cxflags+1] = "/wd4514"
            jln_cxflags[#jln_cxflags+1] = "/wd4548"
            jln_cxflags[#jln_cxflags+1] = "/wd4571"
            jln_cxflags[#jln_cxflags+1] = "/wd4577"
            jln_cxflags[#jln_cxflags+1] = "/wd4625"
            jln_cxflags[#jln_cxflags+1] = "/wd4626"
            jln_cxflags[#jln_cxflags+1] = "/wd4668"
            jln_cxflags[#jln_cxflags+1] = "/wd4710"
            jln_cxflags[#jln_cxflags+1] = "/wd4711"
            if not ( not ( compversion < 1921 ) ) then
              jln_cxflags[#jln_cxflags+1] = "/wd4774"
            end
            jln_cxflags[#jln_cxflags+1] = "/wd4820"
            jln_cxflags[#jln_cxflags+1] = "/wd5026"
            jln_cxflags[#jln_cxflags+1] = "/wd5027"
            jln_cxflags[#jln_cxflags+1] = "/wd5039"
            jln_cxflags[#jln_cxflags+1] = "/wd4464"
            jln_cxflags[#jln_cxflags+1] = "/wd4868"
            jln_cxflags[#jln_cxflags+1] = "/wd5045"
            if values["warnings"] == "strict" then
              jln_cxflags[#jln_cxflags+1] = "/wd4061"
              jln_cxflags[#jln_cxflags+1] = "/wd4266"
              jln_cxflags[#jln_cxflags+1] = "/wd4583"
              jln_cxflags[#jln_cxflags+1] = "/wd4619"
              jln_cxflags[#jln_cxflags+1] = "/wd4623"
              jln_cxflags[#jln_cxflags+1] = "/wd5204"
            end
          end
        end
      end
    end
    if not ( values["conversion_warnings"] == "") then
      if values["conversion_warnings"] == "on" then
        jln_cxflags[#jln_cxflags+1] = "/w14244"
        jln_cxflags[#jln_cxflags+1] = "/w14245"
        jln_cxflags[#jln_cxflags+1] = "/w14388"
        jln_cxflags[#jln_cxflags+1] = "/w14365"
      else
        if values["conversion_warnings"] == "conversion" then
          jln_cxflags[#jln_cxflags+1] = "/w14244"
          jln_cxflags[#jln_cxflags+1] = "/w14365"
        else
          if values["conversion_warnings"] == "sign" then
            jln_cxflags[#jln_cxflags+1] = "/w14388"
            jln_cxflags[#jln_cxflags+1] = "/w14245"
          else
            jln_cxflags[#jln_cxflags+1] = "/wd4244"
            jln_cxflags[#jln_cxflags+1] = "/wd4365"
            jln_cxflags[#jln_cxflags+1] = "/wd4388"
            jln_cxflags[#jln_cxflags+1] = "/wd4245"
          end
        end
      end
    end
    if not ( values["shadow_warnings"] == "") then
      if values["shadow_warnings"] == "off" then
        jln_cxflags[#jln_cxflags+1] = "/wd4456"
        jln_cxflags[#jln_cxflags+1] = "/wd4459"
      else
        if ( values["shadow_warnings"] == "on" or values["shadow_warnings"] == "all" ) then
          jln_cxflags[#jln_cxflags+1] = "/w4456"
          jln_cxflags[#jln_cxflags+1] = "/w4459"
        else
          if values["shadow_warnings"] == "local" then
            jln_cxflags[#jln_cxflags+1] = "/w4456"
            jln_cxflags[#jln_cxflags+1] = "/wd4459"
          end
        end
      end
    end
    if not ( values["warnings_as_error"] == "") then
      if values["warnings_as_error"] == "on" then
        jln_cxflags[#jln_cxflags+1] = "/WX"
        jln_ldflags[#jln_ldflags+1] = "/WX"
      else
        if values["warnings_as_error"] == "off" then
          jln_cxflags[#jln_cxflags+1] = "/WX-"
        end
      end
    end
    if not ( values["lto"] == "") then
      if values["lto"] == "off" then
        jln_cxflags[#jln_cxflags+1] = "/LTCG:OFF"
      else
        jln_cxflags[#jln_cxflags+1] = "/GL"
        jln_ldflags[#jln_ldflags+1] = "/LTCG"
      end
    end
    if not ( values["sanitizers"] == "") then
      if values["sanitizers"] == "on" then
        jln_cxflags[#jln_cxflags+1] = "/sdl"
      else
        if not ( values["stack_protector"] == "") then
          if not ( values["stack_protector"] == "off" ) then
            jln_cxflags[#jln_cxflags+1] = "/sdl-"
          end
        end
      end
    end
  end
  return {cflags=jln_cxflags, ldflags=jln_ldflags}
end

