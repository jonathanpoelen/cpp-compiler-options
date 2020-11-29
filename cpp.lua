--  ```lua
--  -- launch example: premake5 --jln-sanitizers=on
--  
--  include "cpp.lua"
--  
--  -- Registers new command-line options and set default values
--  jln_newoptions({warnings='very_strict'})
--  
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
--  
--  -- jln_getoptions(values = {}, disable_others = false, print_compiler = false)
--  -- `values`: table. ex: {warnings='on'}
--  -- `values` can have 3 additional fields:
--  --  - `cxx`: compiler name
--  --  - `cxx_version` (otherwise deducted from cxx)
--  --  - `ld`: linker name
--  -- `disable_others`: boolean
--  -- `print_compiler`: boolean
--  -- return {buildoptions=table, linkoptions=table}
--  -- Note: with C language, cxx and cxx_version become cc and cc_version
--  local mylib_options = jln_getoptions({elide_type='on'})
--  buildoptions(mylib_options.buildoptions)
--  linkoptions(mylib_options.linkoptions)
--  
--  -- or equivalent
--  jln_setoptions({elide_type='on'})
--  
--  -- returns the merge of the default values and new value table
--  local values = jln_tovalues({elide_type='on'}, --[[disable_others:bool]])
--  print(values)
--  
--  -- NOTE: for C, jln_ prefix function becomes jln_c_
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
--  cpu = default generic native
--  debug = default off on line_tables_only gdb lldb sce
--  diagnostics_format = default fixits patch print_source_range_info
--  diagnostics_show_template_tree = default off on
--  elide_type = default off on
--  exceptions = default off on
--  fix_compiler_error = on default off
--  linker = default bfd gold lld native
--  lto = default off on fat thin
--  microsoft_abi_compatibility_warning = off default on
--  msvc_isystem = default anglebrackets include_and_caexcludepath external_as_include_system_flag
--  msvc_isystem_with_template_from_non_external = default off on
--  optimization = default 0 g 1 2 3 fast size
--  pedantic = on default off as_error
--  pie = default off on pic
--  relro = default off on full
--  reproducible_build_warnings = default off on
--  rtti = default off on
--  sanitizers = default off on
--  sanitizers_extra = default off thread pointer
--  shadow_warnings = off default on local compatible_local all
--  stack_protector = default off on strong all
--  stl_debug = default off on allow_broken_abi allow_broken_abi_and_bugs assert_as_exception
--  stl_fix = on default off
--  suggestions = default off on
--  warnings = on default off strict very_strict
--  warnings_as_error = default off on basic
--  whole_program = default off on strip_all
--  ```
--  <!-- ./compiler-options.lua -->
--  
--  The value `default` does nothing.
--  
--  If not specified, `conversion_warnings`, `fix_compiler_error`, `pedantic`, `stl_fix` and `warnings` are `on` ; `microsoft_abi_compatibility_warning` and `shadow_warnings` are `off`.
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
--  security | `control_flow=on`<br>`relro=full`<br>`stack_protector=strong`
--  really strict warnings | `pedantic=as_error`<br>`shadow_warnings=local`<br>`suggestions=on`<br>`warnings=very_strict`
--  
--  

-- File generated with https://github.com/jonathanpoelen/cpp-compiler-options

local _jln_extraopt_flag_names = {
  ["jln-cxx"] = true,
  ["cxx"] = true,
  ["jln-cxx-version"] = true,
  ["cxx_version"] = true,
  ["jln-ld"] = true,
  ["ld"] = true,
}

local _jln_flag_names = {
  ["jln-color"] = true,
  ["color"] = true,
  ["jln-control-flow"] = true,
  ["control_flow"] = true,
  ["jln-conversion-warnings"] = true,
  ["conversion_warnings"] = true,
  ["jln-coverage"] = true,
  ["coverage"] = true,
  ["jln-cpu"] = true,
  ["cpu"] = true,
  ["jln-debug"] = true,
  ["debug"] = true,
  ["jln-diagnostics-format"] = true,
  ["diagnostics_format"] = true,
  ["jln-diagnostics-show-template-tree"] = true,
  ["diagnostics_show_template_tree"] = true,
  ["jln-elide-type"] = true,
  ["elide_type"] = true,
  ["jln-exceptions"] = true,
  ["exceptions"] = true,
  ["jln-fix-compiler-error"] = true,
  ["fix_compiler_error"] = true,
  ["jln-linker"] = true,
  ["linker"] = true,
  ["jln-lto"] = true,
  ["lto"] = true,
  ["jln-microsoft-abi-compatibility-warning"] = true,
  ["microsoft_abi_compatibility_warning"] = true,
  ["jln-msvc-isystem"] = true,
  ["msvc_isystem"] = true,
  ["jln-msvc-isystem-with-template-from-non-external"] = true,
  ["msvc_isystem_with_template_from_non_external"] = true,
  ["jln-optimization"] = true,
  ["optimization"] = true,
  ["jln-pedantic"] = true,
  ["pedantic"] = true,
  ["jln-pie"] = true,
  ["pie"] = true,
  ["jln-relro"] = true,
  ["relro"] = true,
  ["jln-reproducible-build-warnings"] = true,
  ["reproducible_build_warnings"] = true,
  ["jln-rtti"] = true,
  ["rtti"] = true,
  ["jln-sanitizers"] = true,
  ["sanitizers"] = true,
  ["jln-sanitizers-extra"] = true,
  ["sanitizers_extra"] = true,
  ["jln-shadow-warnings"] = true,
  ["shadow_warnings"] = true,
  ["jln-stack-protector"] = true,
  ["stack_protector"] = true,
  ["jln-stl-debug"] = true,
  ["stl_debug"] = true,
  ["jln-stl-fix"] = true,
  ["stl_fix"] = true,
  ["jln-suggestions"] = true,
  ["suggestions"] = true,
  ["jln-warnings"] = true,
  ["warnings"] = true,
  ["jln-warnings-as-error"] = true,
  ["warnings_as_error"] = true,
  ["jln-whole-program"] = true,
  ["whole_program"] = true,
}

local _jln_check_flag_names = function(t)
  for k in pairs(t) do
    if not _jln_flag_names[k]
    and not _jln_extraopt_flag_names[k] then
      error("unknown '" .. k .. "' jln flag name")
    end
  end
end

function jln_newoptions(defaults)
  if defaults then
    _jln_check_flag_names(defaults)
  else
    defaults = {}
  end
  newoption{trigger="jln-color", allowed={{"default"}, {"auto"}, {"never"}, {"always"}}, description="color"}
  if not _OPTIONS["jln-color"] then _OPTIONS["jln-color"] = (defaults["color"] or defaults["jln-color"] or "default") end
  newoption{trigger="jln-control-flow", allowed={{"default"}, {"off"}, {"on"}, {"branch"}, {"return"}, {"allow_bugs"}}, description="control_flow"}
  if not _OPTIONS["jln-control-flow"] then _OPTIONS["jln-control-flow"] = (defaults["control_flow"] or defaults["jln-control-flow"] or "default") end
  newoption{trigger="jln-conversion-warnings", allowed={{"default"}, {"off"}, {"on"}, {"sign"}, {"conversion"}}, description="conversion_warnings"}
  if not _OPTIONS["jln-conversion-warnings"] then _OPTIONS["jln-conversion-warnings"] = (defaults["conversion_warnings"] or defaults["jln-conversion-warnings"] or "on") end
  newoption{trigger="jln-coverage", allowed={{"default"}, {"off"}, {"on"}}, description="coverage"}
  if not _OPTIONS["jln-coverage"] then _OPTIONS["jln-coverage"] = (defaults["coverage"] or defaults["jln-coverage"] or "default") end
  newoption{trigger="jln-cpu", allowed={{"default"}, {"generic"}, {"native"}}, description="cpu"}
  if not _OPTIONS["jln-cpu"] then _OPTIONS["jln-cpu"] = (defaults["cpu"] or defaults["jln-cpu"] or "default") end
  newoption{trigger="jln-debug", allowed={{"default"}, {"off"}, {"on"}, {"line_tables_only"}, {"gdb"}, {"lldb"}, {"sce"}}, description="debug"}
  if not _OPTIONS["jln-debug"] then _OPTIONS["jln-debug"] = (defaults["debug"] or defaults["jln-debug"] or "default") end
  newoption{trigger="jln-diagnostics-format", allowed={{"default"}, {"fixits"}, {"patch"}, {"print_source_range_info"}}, description="diagnostics_format"}
  if not _OPTIONS["jln-diagnostics-format"] then _OPTIONS["jln-diagnostics-format"] = (defaults["diagnostics_format"] or defaults["jln-diagnostics-format"] or "default") end
  newoption{trigger="jln-diagnostics-show-template-tree", allowed={{"default"}, {"off"}, {"on"}}, description="diagnostics_show_template_tree"}
  if not _OPTIONS["jln-diagnostics-show-template-tree"] then _OPTIONS["jln-diagnostics-show-template-tree"] = (defaults["diagnostics_show_template_tree"] or defaults["jln-diagnostics-show-template-tree"] or "default") end
  newoption{trigger="jln-elide-type", allowed={{"default"}, {"off"}, {"on"}}, description="elide_type"}
  if not _OPTIONS["jln-elide-type"] then _OPTIONS["jln-elide-type"] = (defaults["elide_type"] or defaults["jln-elide-type"] or "default") end
  newoption{trigger="jln-exceptions", allowed={{"default"}, {"off"}, {"on"}}, description="exceptions"}
  if not _OPTIONS["jln-exceptions"] then _OPTIONS["jln-exceptions"] = (defaults["exceptions"] or defaults["jln-exceptions"] or "default") end
  newoption{trigger="jln-fix-compiler-error", allowed={{"default"}, {"off"}, {"on"}}, description="fix_compiler_error"}
  if not _OPTIONS["jln-fix-compiler-error"] then _OPTIONS["jln-fix-compiler-error"] = (defaults["fix_compiler_error"] or defaults["jln-fix-compiler-error"] or "on") end
  newoption{trigger="jln-linker", allowed={{"default"}, {"bfd"}, {"gold"}, {"lld"}, {"native"}}, description="linker"}
  if not _OPTIONS["jln-linker"] then _OPTIONS["jln-linker"] = (defaults["linker"] or defaults["jln-linker"] or "default") end
  newoption{trigger="jln-lto", allowed={{"default"}, {"off"}, {"on"}, {"fat"}, {"thin"}}, description="lto"}
  if not _OPTIONS["jln-lto"] then _OPTIONS["jln-lto"] = (defaults["lto"] or defaults["jln-lto"] or "default") end
  newoption{trigger="jln-microsoft-abi-compatibility-warning", allowed={{"default"}, {"off"}, {"on"}}, description="microsoft_abi_compatibility_warning"}
  if not _OPTIONS["jln-microsoft-abi-compatibility-warning"] then _OPTIONS["jln-microsoft-abi-compatibility-warning"] = (defaults["microsoft_abi_compatibility_warning"] or defaults["jln-microsoft-abi-compatibility-warning"] or "off") end
  newoption{trigger="jln-msvc-isystem", allowed={{"default"}, {"anglebrackets"}, {"include_and_caexcludepath"}, {"external_as_include_system_flag"}}, description="msvc_isystem"}
  if not _OPTIONS["jln-msvc-isystem"] then _OPTIONS["jln-msvc-isystem"] = (defaults["msvc_isystem"] or defaults["jln-msvc-isystem"] or "default") end
  newoption{trigger="jln-msvc-isystem-with-template-from-non-external", allowed={{"default"}, {"off"}, {"on"}}, description="msvc_isystem_with_template_from_non_external"}
  if not _OPTIONS["jln-msvc-isystem-with-template-from-non-external"] then _OPTIONS["jln-msvc-isystem-with-template-from-non-external"] = (defaults["msvc_isystem_with_template_from_non_external"] or defaults["jln-msvc-isystem-with-template-from-non-external"] or "default") end
  newoption{trigger="jln-optimization", allowed={{"default"}, {"0"}, {"g"}, {"1"}, {"2"}, {"3"}, {"fast"}, {"size"}}, description="optimization"}
  if not _OPTIONS["jln-optimization"] then _OPTIONS["jln-optimization"] = (defaults["optimization"] or defaults["jln-optimization"] or "default") end
  newoption{trigger="jln-pedantic", allowed={{"default"}, {"off"}, {"on"}, {"as_error"}}, description="pedantic"}
  if not _OPTIONS["jln-pedantic"] then _OPTIONS["jln-pedantic"] = (defaults["pedantic"] or defaults["jln-pedantic"] or "on") end
  newoption{trigger="jln-pie", allowed={{"default"}, {"off"}, {"on"}, {"pic"}}, description="pie"}
  if not _OPTIONS["jln-pie"] then _OPTIONS["jln-pie"] = (defaults["pie"] or defaults["jln-pie"] or "default") end
  newoption{trigger="jln-relro", allowed={{"default"}, {"off"}, {"on"}, {"full"}}, description="relro"}
  if not _OPTIONS["jln-relro"] then _OPTIONS["jln-relro"] = (defaults["relro"] or defaults["jln-relro"] or "default") end
  newoption{trigger="jln-reproducible-build-warnings", allowed={{"default"}, {"off"}, {"on"}}, description="reproducible_build_warnings"}
  if not _OPTIONS["jln-reproducible-build-warnings"] then _OPTIONS["jln-reproducible-build-warnings"] = (defaults["reproducible_build_warnings"] or defaults["jln-reproducible-build-warnings"] or "default") end
  newoption{trigger="jln-rtti", allowed={{"default"}, {"off"}, {"on"}}, description="rtti"}
  if not _OPTIONS["jln-rtti"] then _OPTIONS["jln-rtti"] = (defaults["rtti"] or defaults["jln-rtti"] or "default") end
  newoption{trigger="jln-sanitizers", allowed={{"default"}, {"off"}, {"on"}}, description="sanitizers"}
  if not _OPTIONS["jln-sanitizers"] then _OPTIONS["jln-sanitizers"] = (defaults["sanitizers"] or defaults["jln-sanitizers"] or "default") end
  newoption{trigger="jln-sanitizers-extra", allowed={{"default"}, {"off"}, {"thread"}, {"pointer"}}, description="sanitizers_extra"}
  if not _OPTIONS["jln-sanitizers-extra"] then _OPTIONS["jln-sanitizers-extra"] = (defaults["sanitizers_extra"] or defaults["jln-sanitizers-extra"] or "default") end
  newoption{trigger="jln-shadow-warnings", allowed={{"default"}, {"off"}, {"on"}, {"local"}, {"compatible_local"}, {"all"}}, description="shadow_warnings"}
  if not _OPTIONS["jln-shadow-warnings"] then _OPTIONS["jln-shadow-warnings"] = (defaults["shadow_warnings"] or defaults["jln-shadow-warnings"] or "off") end
  newoption{trigger="jln-stack-protector", allowed={{"default"}, {"off"}, {"on"}, {"strong"}, {"all"}}, description="stack_protector"}
  if not _OPTIONS["jln-stack-protector"] then _OPTIONS["jln-stack-protector"] = (defaults["stack_protector"] or defaults["jln-stack-protector"] or "default") end
  newoption{trigger="jln-stl-debug", allowed={{"default"}, {"off"}, {"on"}, {"allow_broken_abi"}, {"allow_broken_abi_and_bugs"}, {"assert_as_exception"}}, description="stl_debug"}
  if not _OPTIONS["jln-stl-debug"] then _OPTIONS["jln-stl-debug"] = (defaults["stl_debug"] or defaults["jln-stl-debug"] or "default") end
  newoption{trigger="jln-stl-fix", allowed={{"default"}, {"off"}, {"on"}}, description="stl_fix"}
  if not _OPTIONS["jln-stl-fix"] then _OPTIONS["jln-stl-fix"] = (defaults["stl_fix"] or defaults["jln-stl-fix"] or "on") end
  newoption{trigger="jln-suggestions", allowed={{"default"}, {"off"}, {"on"}}, description="suggestions"}
  if not _OPTIONS["jln-suggestions"] then _OPTIONS["jln-suggestions"] = (defaults["suggestions"] or defaults["jln-suggestions"] or "default") end
  newoption{trigger="jln-warnings", allowed={{"default"}, {"off"}, {"on"}, {"strict"}, {"very_strict"}}, description="warnings"}
  if not _OPTIONS["jln-warnings"] then _OPTIONS["jln-warnings"] = (defaults["warnings"] or defaults["jln-warnings"] or "on") end
  newoption{trigger="jln-warnings-as-error", allowed={{"default"}, {"off"}, {"on"}, {"basic"}}, description="warnings_as_error"}
  if not _OPTIONS["jln-warnings-as-error"] then _OPTIONS["jln-warnings-as-error"] = (defaults["warnings_as_error"] or defaults["jln-warnings-as-error"] or "default") end
  newoption{trigger="jln-whole-program", allowed={{"default"}, {"off"}, {"on"}, {"strip_all"}}, description="whole_program"}
  if not _OPTIONS["jln-whole-program"] then _OPTIONS["jln-whole-program"] = (defaults["whole_program"] or defaults["jln-whole-program"] or "default") end
  newoption{trigger="jln-cxx", description="Path or name of the compiler for jln functions"}
  newoption{trigger="jln-cxx-version", description="Force the compiler version for jln functions"}
  newoption{trigger="jln-ld", description="Path or name of the linker for jln functions"}
end

-- same as jln_getoptions
function jln_setoptions(compiler, version, values, disable_others, print_compiler)
  local options = jln_getoptions(compiler, version, values, disable_others, print_compiler)
  buildoptions(options.buildoptions)
  linkoptions(options.linkoptions)
  return options
end

local _jln_compiler_by_os = {
  windows='msvc',
  linux='g++',
  cygwin='g++',
  mingw='g++',
  bsd='g++',
  macosx='clang++',
}

local _jln_default_compiler = 'g++'
local _jln_comp_cache = {}

local _get_extra = function(opt)
  local x = _OPTIONS[opt]
  return x ~= '' and x or nil
end

-- Returns the merge of the default values and new value table
-- jln_tovalues(table, disable_others = false)
-- `values`: table. ex: {warnings='on'}
-- `values` can have 3 additional fields:
--  - `cxx`: compiler name (otherwise deducted from --cxx and --toolchain)
--  - `cxx_version`: compiler version (otherwise deducted from cxx). ex: '7', '7.2'
--  - `ld`: linker name
function jln_tovalues(values, disable_others)
  if values then
    _jln_check_flag_names(values)
    return {
      ["color"] = values["color"] or values["jln-color"] or (disable_others and "default" or _OPTIONS["jln-color"]),
      ["control_flow"] = values["control_flow"] or values["jln-control-flow"] or (disable_others and "default" or _OPTIONS["jln-control-flow"]),
      ["conversion_warnings"] = values["conversion_warnings"] or values["jln-conversion-warnings"] or (disable_others and "default" or _OPTIONS["jln-conversion-warnings"]),
      ["coverage"] = values["coverage"] or values["jln-coverage"] or (disable_others and "default" or _OPTIONS["jln-coverage"]),
      ["cpu"] = values["cpu"] or values["jln-cpu"] or (disable_others and "default" or _OPTIONS["jln-cpu"]),
      ["debug"] = values["debug"] or values["jln-debug"] or (disable_others and "default" or _OPTIONS["jln-debug"]),
      ["diagnostics_format"] = values["diagnostics_format"] or values["jln-diagnostics-format"] or (disable_others and "default" or _OPTIONS["jln-diagnostics-format"]),
      ["diagnostics_show_template_tree"] = values["diagnostics_show_template_tree"] or values["jln-diagnostics-show-template-tree"] or (disable_others and "default" or _OPTIONS["jln-diagnostics-show-template-tree"]),
      ["elide_type"] = values["elide_type"] or values["jln-elide-type"] or (disable_others and "default" or _OPTIONS["jln-elide-type"]),
      ["exceptions"] = values["exceptions"] or values["jln-exceptions"] or (disable_others and "default" or _OPTIONS["jln-exceptions"]),
      ["fix_compiler_error"] = values["fix_compiler_error"] or values["jln-fix-compiler-error"] or (disable_others and "default" or _OPTIONS["jln-fix-compiler-error"]),
      ["linker"] = values["linker"] or values["jln-linker"] or (disable_others and "default" or _OPTIONS["jln-linker"]),
      ["lto"] = values["lto"] or values["jln-lto"] or (disable_others and "default" or _OPTIONS["jln-lto"]),
      ["microsoft_abi_compatibility_warning"] = values["microsoft_abi_compatibility_warning"] or values["jln-microsoft-abi-compatibility-warning"] or (disable_others and "default" or _OPTIONS["jln-microsoft-abi-compatibility-warning"]),
      ["msvc_isystem"] = values["msvc_isystem"] or values["jln-msvc-isystem"] or (disable_others and "default" or _OPTIONS["jln-msvc-isystem"]),
      ["msvc_isystem_with_template_from_non_external"] = values["msvc_isystem_with_template_from_non_external"] or values["jln-msvc-isystem-with-template-from-non-external"] or (disable_others and "default" or _OPTIONS["jln-msvc-isystem-with-template-from-non-external"]),
      ["optimization"] = values["optimization"] or values["jln-optimization"] or (disable_others and "default" or _OPTIONS["jln-optimization"]),
      ["pedantic"] = values["pedantic"] or values["jln-pedantic"] or (disable_others and "default" or _OPTIONS["jln-pedantic"]),
      ["pie"] = values["pie"] or values["jln-pie"] or (disable_others and "default" or _OPTIONS["jln-pie"]),
      ["relro"] = values["relro"] or values["jln-relro"] or (disable_others and "default" or _OPTIONS["jln-relro"]),
      ["reproducible_build_warnings"] = values["reproducible_build_warnings"] or values["jln-reproducible-build-warnings"] or (disable_others and "default" or _OPTIONS["jln-reproducible-build-warnings"]),
      ["rtti"] = values["rtti"] or values["jln-rtti"] or (disable_others and "default" or _OPTIONS["jln-rtti"]),
      ["sanitizers"] = values["sanitizers"] or values["jln-sanitizers"] or (disable_others and "default" or _OPTIONS["jln-sanitizers"]),
      ["sanitizers_extra"] = values["sanitizers_extra"] or values["jln-sanitizers-extra"] or (disable_others and "default" or _OPTIONS["jln-sanitizers-extra"]),
      ["shadow_warnings"] = values["shadow_warnings"] or values["jln-shadow-warnings"] or (disable_others and "default" or _OPTIONS["jln-shadow-warnings"]),
      ["stack_protector"] = values["stack_protector"] or values["jln-stack-protector"] or (disable_others and "default" or _OPTIONS["jln-stack-protector"]),
      ["stl_debug"] = values["stl_debug"] or values["jln-stl-debug"] or (disable_others and "default" or _OPTIONS["jln-stl-debug"]),
      ["stl_fix"] = values["stl_fix"] or values["jln-stl-fix"] or (disable_others and "default" or _OPTIONS["jln-stl-fix"]),
      ["suggestions"] = values["suggestions"] or values["jln-suggestions"] or (disable_others and "default" or _OPTIONS["jln-suggestions"]),
      ["warnings"] = values["warnings"] or values["jln-warnings"] or (disable_others and "default" or _OPTIONS["jln-warnings"]),
      ["warnings_as_error"] = values["warnings_as_error"] or values["jln-warnings-as-error"] or (disable_others and "default" or _OPTIONS["jln-warnings-as-error"]),
      ["whole_program"] = values["whole_program"] or values["jln-whole-program"] or (disable_others and "default" or _OPTIONS["jln-whole-program"]),
      ["cxx"] = values["cxx"] or (not disable_others and _get_extra("jln-cxx")) or nil,
      ["cxx_version"] = values["cxx_version"] or (not disable_others and _get_extra("jln-cxx-version")) or nil,
      ["ld"] = values["ld"] or (not disable_others and _get_extra("jln-ld")) or nil,
}
  else
    return {
      ["color"] = _OPTIONS["jln-color"],
      ["control_flow"] = _OPTIONS["jln-control-flow"],
      ["conversion_warnings"] = _OPTIONS["jln-conversion-warnings"],
      ["coverage"] = _OPTIONS["jln-coverage"],
      ["cpu"] = _OPTIONS["jln-cpu"],
      ["debug"] = _OPTIONS["jln-debug"],
      ["diagnostics_format"] = _OPTIONS["jln-diagnostics-format"],
      ["diagnostics_show_template_tree"] = _OPTIONS["jln-diagnostics-show-template-tree"],
      ["elide_type"] = _OPTIONS["jln-elide-type"],
      ["exceptions"] = _OPTIONS["jln-exceptions"],
      ["fix_compiler_error"] = _OPTIONS["jln-fix-compiler-error"],
      ["linker"] = _OPTIONS["jln-linker"],
      ["lto"] = _OPTIONS["jln-lto"],
      ["microsoft_abi_compatibility_warning"] = _OPTIONS["jln-microsoft-abi-compatibility-warning"],
      ["msvc_isystem"] = _OPTIONS["jln-msvc-isystem"],
      ["msvc_isystem_with_template_from_non_external"] = _OPTIONS["jln-msvc-isystem-with-template-from-non-external"],
      ["optimization"] = _OPTIONS["jln-optimization"],
      ["pedantic"] = _OPTIONS["jln-pedantic"],
      ["pie"] = _OPTIONS["jln-pie"],
      ["relro"] = _OPTIONS["jln-relro"],
      ["reproducible_build_warnings"] = _OPTIONS["jln-reproducible-build-warnings"],
      ["rtti"] = _OPTIONS["jln-rtti"],
      ["sanitizers"] = _OPTIONS["jln-sanitizers"],
      ["sanitizers_extra"] = _OPTIONS["jln-sanitizers-extra"],
      ["shadow_warnings"] = _OPTIONS["jln-shadow-warnings"],
      ["stack_protector"] = _OPTIONS["jln-stack-protector"],
      ["stl_debug"] = _OPTIONS["jln-stl-debug"],
      ["stl_fix"] = _OPTIONS["jln-stl-fix"],
      ["suggestions"] = _OPTIONS["jln-suggestions"],
      ["warnings"] = _OPTIONS["jln-warnings"],
      ["warnings_as_error"] = _OPTIONS["jln-warnings-as-error"],
      ["whole_program"] = _OPTIONS["jln-whole-program"],
      ["cxx"] = _get_extra("jln-cxx"),
      ["cxx_version"] = _get_extra("jln-cxx-version"),
      ["ld"] = _get_extra("jln-ld"),
}
  end
end

-- jln_getoptions(values = {}, disable_others = false, print_compiler = false)
-- `values`: same as jln_tovalue()
-- `disable_others`: boolean
-- `print_compiler`: boolean
-- return {buildoptions={}, linkoptions={}}
function jln_getoptions(values, disable_others, print_compiler)
  local compversion

  values = jln_tovalues(values, disable_others)
  local compiler = values.cxx  local version = values.cxx_version
  local linker = values.ld or (not disable_others and _OPTIONS['ld']) or nil

  local cache = _jln_comp_cache
  local original_compiler = compiler or ''
  local compcache = cache[original_compiler]

  if compcache then
    compiler = compcache[1]
    version = compcache[2]
    compversion = compcache[3]
    if not compiler then
      -- printf("WARNING: unknown compiler")
      return {buildoptions={}, linkoptions={}}
    end
  else
    cache[original_compiler] = {}

    if not compiler then
      compiler = _OPTIONS['jln-compiler']
              or _OPTIONS['cc']
              or _jln_compiler_by_os[os.target()]
              or _jln_default_compiler
      version = _OPTIONS['jln-compiler-version'] or nil
    end

    local compiler_path = compiler
    if compiler then
      compiler = (compiler:find('clang-cl', 1, true) and 'clang-cl') or
                 (compiler:find('clang', 1, true) and 'clang') or
                 ((compiler:find('msvc', 1, true) or
                   compiler:find('MSVC', 1, true) or
                   compiler:find('^vs%d') or
                   compiler:find('^VS%d')
                  ) and 'msvc') or
                 ((compiler:find('g++', 1, true) or
                   compiler:find('gcc', 1, true) or
                   compiler:find('GCC', 1, true) or
                   compiler:find('MinGW', 1, true) or
                   compiler:find('mingw', 1, true)
                  ) and 'gcc') or
                 nil
    end

    if not compiler then
      -- printf("WARNING: unknown compiler")
      return {buildoptions={}, linkoptions={}}
    end

    if not version then
      local output = os.outputof(compiler_path .. " --version")
      if output then
        output = output:sub(0, output:find('\n') or #output)
        version = output:match("%d+%.%d+%.%d+")
      else
        printf("WARNING: `%s --version` failed", compiler)
        output = original_compiler:match("%d+%.?%d*%.?%d*$")
        if output then
          version = output
          printf("Extract version %s of the compiler name", version)
        end
      end

      if not version then
        version = tostring(tonumber(os.date("%y")) - (compiler:sub(0, 5) == 'clang' and 14 or 12))
      end
    end

    compversion = {}
    for i in version:gmatch("%d+") do
      compversion[#compversion+1] = tonumber(i)
    end
    if not compversion[1] then
      printf("WARNING: wrong version format")
      return {buildoptions={}, linkoptions={}}
    end
    compversion = compversion[1] * 100 + (compversion[2] or 0)

    cache[original_compiler] = {compiler, version, compversion}
  end

  if print_compiler then
    printf("jln_getoptions: compiler: %s, version: %s", compiler, version)
  end

  local jln_buildoptions, jln_linkoptions = {}, {}

  if ( compiler == "gcc" or compiler == "clang" or compiler == "clang-cl" ) then
    if not ( values["warnings"] == "default") then
      if values["warnings"] == "off" then
        jln_buildoptions[#jln_buildoptions+1] = "-w"
      else
        if compiler == "gcc" then
          jln_buildoptions[#jln_buildoptions+1] = "-Wall"
          jln_buildoptions[#jln_buildoptions+1] = "-Wextra"
          jln_buildoptions[#jln_buildoptions+1] = "-Wcast-align"
          jln_buildoptions[#jln_buildoptions+1] = "-Wcast-qual"
          jln_buildoptions[#jln_buildoptions+1] = "-Wdisabled-optimization"
          jln_buildoptions[#jln_buildoptions+1] = "-Wfloat-equal"
          jln_buildoptions[#jln_buildoptions+1] = "-Wformat-security"
          jln_buildoptions[#jln_buildoptions+1] = "-Wformat=2"
          jln_buildoptions[#jln_buildoptions+1] = "-Wmissing-include-dirs"
          jln_buildoptions[#jln_buildoptions+1] = "-Wpacked"
          jln_buildoptions[#jln_buildoptions+1] = "-Wredundant-decls"
          jln_buildoptions[#jln_buildoptions+1] = "-Wundef"
          jln_buildoptions[#jln_buildoptions+1] = "-Wunused-macros"
          jln_buildoptions[#jln_buildoptions+1] = "-Winvalid-pch"
          jln_buildoptions[#jln_buildoptions+1] = "-Wpointer-arith"
          jln_buildoptions[#jln_buildoptions+1] = "-Wmissing-declarations"
          jln_buildoptions[#jln_buildoptions+1] = "-Wnon-virtual-dtor"
          jln_buildoptions[#jln_buildoptions+1] = "-Wold-style-cast"
          jln_buildoptions[#jln_buildoptions+1] = "-Woverloaded-virtual"
          if not ( compversion < 407 ) then
            jln_buildoptions[#jln_buildoptions+1] = "-Wsuggest-attribute=noreturn"
            jln_buildoptions[#jln_buildoptions+1] = "-Wzero-as-null-pointer-constant"
            jln_buildoptions[#jln_buildoptions+1] = "-Wlogical-op"
            jln_buildoptions[#jln_buildoptions+1] = "-Wvector-operation-performance"
            jln_buildoptions[#jln_buildoptions+1] = "-Wdouble-promotion"
            jln_buildoptions[#jln_buildoptions+1] = "-Wtrampolines"
            if not ( compversion < 408 ) then
              jln_buildoptions[#jln_buildoptions+1] = "-Wuseless-cast"
              if not ( compversion < 409 ) then
                jln_buildoptions[#jln_buildoptions+1] = "-Wconditionally-supported"
                jln_buildoptions[#jln_buildoptions+1] = "-Wfloat-conversion"
                if not ( compversion < 501 ) then
                  jln_buildoptions[#jln_buildoptions+1] = "-Wformat-signedness"
                  jln_buildoptions[#jln_buildoptions+1] = "-Warray-bounds=2"
                  jln_buildoptions[#jln_buildoptions+1] = "-Wstrict-null-sentinel"
                  jln_buildoptions[#jln_buildoptions+1] = "-Wsuggest-override"
                  if not ( compversion < 601 ) then
                    jln_buildoptions[#jln_buildoptions+1] = "-Wduplicated-cond"
                    jln_buildoptions[#jln_buildoptions+1] = "-Wnull-dereference"
                    if not ( compversion < 700 ) then
                      jln_buildoptions[#jln_buildoptions+1] = "-Waligned-new"
                      if not ( compversion < 701 ) then
                        jln_buildoptions[#jln_buildoptions+1] = "-Walloc-zero"
                        jln_buildoptions[#jln_buildoptions+1] = "-Walloca"
                        jln_buildoptions[#jln_buildoptions+1] = "-Wformat-overflow=2"
                        jln_buildoptions[#jln_buildoptions+1] = "-Wduplicated-branches"
                        if not ( compversion < 800 ) then
                          jln_buildoptions[#jln_buildoptions+1] = "-Wclass-memaccess"
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        else
          if ( compiler == "clang" or compiler == "clang-cl" ) then
            jln_buildoptions[#jln_buildoptions+1] = "-Weverything"
            jln_buildoptions[#jln_buildoptions+1] = "-Wno-documentation"
            jln_buildoptions[#jln_buildoptions+1] = "-Wno-documentation-unknown-command"
            jln_buildoptions[#jln_buildoptions+1] = "-Wno-newline-eof"
            jln_buildoptions[#jln_buildoptions+1] = "-Wno-c++98-compat"
            jln_buildoptions[#jln_buildoptions+1] = "-Wno-c++98-compat-pedantic"
            jln_buildoptions[#jln_buildoptions+1] = "-Wno-padded"
            jln_buildoptions[#jln_buildoptions+1] = "-Wno-global-constructors"
            jln_buildoptions[#jln_buildoptions+1] = "-Wno-weak-vtables"
            jln_buildoptions[#jln_buildoptions+1] = "-Wno-exit-time-destructors"
            jln_buildoptions[#jln_buildoptions+1] = "-Wno-covered-switch-default"
            jln_buildoptions[#jln_buildoptions+1] = "-Wno-switch-default"
            jln_buildoptions[#jln_buildoptions+1] = "-Wno-switch-enum"
            if not ( compversion < 309 ) then
              jln_buildoptions[#jln_buildoptions+1] = "-Wno-undefined-var-template"
              if not ( compversion < 500 ) then
                jln_buildoptions[#jln_buildoptions+1] = "-Wno-inconsistent-missing-destructor-override"
                if not ( compversion < 900 ) then
                  jln_buildoptions[#jln_buildoptions+1] = "-Wno-ctad-maybe-unsupported"
                  if not ( compversion < 1100 ) then
                    jln_buildoptions[#jln_buildoptions+1] = "-Wno-suggest-destructor-override"
                  end
                end
              end
            end
          end
        end
        if ( values["warnings"] == "strict" or values["warnings"] == "very_strict" ) then
          if ( compiler == "gcc" and not ( compversion < 800 ) ) then
            jln_buildoptions[#jln_buildoptions+1] = "-Wcast-align=strict"
          end
        end
      end
    end
    if not ( values["conversion_warnings"] == "default") then
      if values["conversion_warnings"] == "on" then
        jln_buildoptions[#jln_buildoptions+1] = "-Wconversion"
        jln_buildoptions[#jln_buildoptions+1] = "-Wsign-compare"
        jln_buildoptions[#jln_buildoptions+1] = "-Wsign-conversion"
      else
        if values["conversion_warnings"] == "conversion" then
          jln_buildoptions[#jln_buildoptions+1] = "-Wconversion"
        else
          if values["conversion_warnings"] == "sign" then
            jln_buildoptions[#jln_buildoptions+1] = "-Wsign-compare"
            jln_buildoptions[#jln_buildoptions+1] = "-Wsign-conversion"
          else
            jln_buildoptions[#jln_buildoptions+1] = "-Wno-conversion"
            jln_buildoptions[#jln_buildoptions+1] = "-Wno-sign-compare"
            jln_buildoptions[#jln_buildoptions+1] = "-Wno-sign-conversion"
          end
        end
      end
    end
    if not ( values["microsoft_abi_compatibility_warning"] == "default") then
      if values["microsoft_abi_compatibility_warning"] == "on" then
        if ( ( compiler == "gcc" and not ( compversion < 1000 ) ) or compiler == "clang" or compiler == "clang-cl" ) then
          jln_buildoptions[#jln_buildoptions+1] = "-Wmismatched-tags"
        end
      else
        if ( ( compiler == "gcc" and not ( compversion < 1000 ) ) or compiler == "clang" or compiler == "clang-cl" ) then
          jln_buildoptions[#jln_buildoptions+1] = "-Wno-mismatched-tags"
        end
      end
    end
    if not ( values["warnings_as_error"] == "default") then
      if values["warnings_as_error"] == "on" then
        jln_buildoptions[#jln_buildoptions+1] = "-Werror"
      else
        if values["warnings_as_error"] == "basic" then
          jln_buildoptions[#jln_buildoptions+1] = "-Werror=return-type"
          jln_buildoptions[#jln_buildoptions+1] = "-Werror=init-self"
          if ( compiler == "gcc" and not ( compversion < 501 ) ) then
            jln_buildoptions[#jln_buildoptions+1] = "-Werror=array-bounds"
            jln_buildoptions[#jln_buildoptions+1] = "-Werror=logical-op"
            jln_buildoptions[#jln_buildoptions+1] = "-Werror=logical-not-parentheses"
          else
            if ( compiler == "clang" or compiler == "clang-cl" ) then
              jln_buildoptions[#jln_buildoptions+1] = "-Werror=array-bounds"
              jln_buildoptions[#jln_buildoptions+1] = "-Werror=division-by-zero"
              if not ( compversion < 304 ) then
                jln_buildoptions[#jln_buildoptions+1] = "-Werror=logical-not-parentheses"
                if not ( compversion < 306 ) then
                  jln_buildoptions[#jln_buildoptions+1] = "-Werror=delete-incomplete"
                  if not ( compversion < 700 ) then
                    jln_buildoptions[#jln_buildoptions+1] = "-Werror=dynamic-class-memaccess"
                  end
                end
              end
            end
          end
        else
          jln_buildoptions[#jln_buildoptions+1] = "-Wno-error"
        end
      end
    end
    if not ( values["suggestions"] == "default") then
      if not ( values["suggestions"] == "off" ) then
        if compiler == "gcc" then
          jln_buildoptions[#jln_buildoptions+1] = "-Wsuggest-attribute=pure"
          jln_buildoptions[#jln_buildoptions+1] = "-Wsuggest-attribute=const"
          if not ( compversion < 500 ) then
            jln_buildoptions[#jln_buildoptions+1] = "-Wsuggest-final-types"
            jln_buildoptions[#jln_buildoptions+1] = "-Wsuggest-final-methods"
            if not ( compversion < 501 ) then
              jln_buildoptions[#jln_buildoptions+1] = "-Wnoexcept"
            end
          end
        end
      end
    end
    if not ( values["sanitizers"] == "default") then
      if values["sanitizers"] == "off" then
        jln_buildoptions[#jln_buildoptions+1] = "-fno-sanitize=all"
        jln_linkoptions[#jln_linkoptions+1] = "-fno-sanitize=all"
      else
        if compiler == "clang-cl" then
          jln_buildoptions[#jln_buildoptions+1] = "-fsanitize=undefined"
          jln_buildoptions[#jln_buildoptions+1] = "-fsanitize=address"
          jln_buildoptions[#jln_buildoptions+1] = "-fsanitize-address-use-after-scope"
        else
          if compiler == "clang" then
            if not ( compversion < 301 ) then
              jln_buildoptions[#jln_buildoptions+1] = "-fsanitize=undefined"
              jln_buildoptions[#jln_buildoptions+1] = "-fsanitize=address"
              jln_buildoptions[#jln_buildoptions+1] = "-fsanitize-address-use-after-scope"
              jln_buildoptions[#jln_buildoptions+1] = "-fno-omit-frame-pointer"
              jln_buildoptions[#jln_buildoptions+1] = "-fno-optimize-sibling-calls"
              jln_linkoptions[#jln_linkoptions+1] = "-fsanitize=undefined"
              jln_linkoptions[#jln_linkoptions+1] = "-fsanitize=address"
              if not ( compversion < 304 ) then
                jln_buildoptions[#jln_buildoptions+1] = "-fsanitize=leak"
                jln_linkoptions[#jln_linkoptions+1] = "-fsanitize=leak"
              end
            end
          else
            if compiler == "gcc" then
              if not ( compversion < 408 ) then
                jln_buildoptions[#jln_buildoptions+1] = "-fsanitize=address"
                jln_buildoptions[#jln_buildoptions+1] = "-fno-omit-frame-pointer"
                jln_buildoptions[#jln_buildoptions+1] = "-fno-optimize-sibling-calls"
                jln_linkoptions[#jln_linkoptions+1] = "-fsanitize=address"
                if not ( compversion < 409 ) then
                  jln_buildoptions[#jln_buildoptions+1] = "-fsanitize=undefined"
                  jln_buildoptions[#jln_buildoptions+1] = "-fsanitize=leak"
                  jln_linkoptions[#jln_linkoptions+1] = "-fsanitize=undefined"
                  jln_linkoptions[#jln_linkoptions+1] = "-fsanitize=leak"
                end
              end
            end
          end
        end
      end
    end
    if not ( values["control_flow"] == "default") then
      if values["control_flow"] == "off" then
        if ( compiler == "gcc" and not ( compversion < 800 ) ) then
          jln_buildoptions[#jln_buildoptions+1] = "-fcf-protection=none"
        else
          if compiler == "clang-cl" then
            jln_buildoptions[#jln_buildoptions+1] = "-fcf-protection=none"
            jln_buildoptions[#jln_buildoptions+1] = "-fno-sanitize-cfi-cross-dso"
          end
        end
        if compiler == "clang" then
          jln_buildoptions[#jln_buildoptions+1] = "-fno-sanitize=cfi"
          jln_linkoptions[#jln_linkoptions+1] = "-fno-sanitize=cfi"
        end
      else
        if ( ( compiler == "gcc" and not ( compversion < 800 ) ) or compiler == "clang-cl" ) then
          if values["control_flow"] == "branch" then
            jln_buildoptions[#jln_buildoptions+1] = "-fcf-protection=branch"
          else
            if values["control_flow"] == "return" then
              jln_buildoptions[#jln_buildoptions+1] = "-fcf-protection=return"
            else
              jln_buildoptions[#jln_buildoptions+1] = "-fcf-protection=full"
            end
          end
        else
          if ( values["control_flow"] == "allow_bugs" and compiler == "clang" ) then
            jln_buildoptions[#jln_buildoptions+1] = "-fsanitize=cfi"
            jln_buildoptions[#jln_buildoptions+1] = "-fvisibility=hidden"
            jln_buildoptions[#jln_buildoptions+1] = "-flto"
            jln_linkoptions[#jln_linkoptions+1] = "-fsanitize=cfi"
            jln_linkoptions[#jln_linkoptions+1] = "-flto"
          end
        end
      end
    end
    if not ( values["color"] == "default") then
      if ( ( compiler == "gcc" and not ( compversion < 409 ) ) or compiler == "clang" or compiler == "clang-cl" ) then
        if values["color"] == "auto" then
          jln_buildoptions[#jln_buildoptions+1] = "-fdiagnostics-color=auto"
        else
          if values["color"] == "never" then
            jln_buildoptions[#jln_buildoptions+1] = "-fdiagnostics-color=never"
          else
            if values["color"] == "always" then
              jln_buildoptions[#jln_buildoptions+1] = "-fdiagnostics-color=always"
            end
          end
        end
      end
    end
    if not ( values["reproducible_build_warnings"] == "default") then
      if ( compiler == "gcc" and not ( compversion < 409 ) ) then
        if values["reproducible_build_warnings"] == "on" then
          jln_buildoptions[#jln_buildoptions+1] = "-Wdate-time"
        else
          jln_buildoptions[#jln_buildoptions+1] = "-Wno-date-time"
        end
      end
    end
    if not ( values["diagnostics_format"] == "default") then
      if values["diagnostics_format"] == "fixits" then
        if ( ( compiler == "gcc" and not ( compversion < 700 ) ) or ( compiler == "clang" and not ( compversion < 500 ) ) or ( compiler == "clang-cl" and not ( compversion < 500 ) ) ) then
          jln_buildoptions[#jln_buildoptions+1] = "-fdiagnostics-parseable-fixits"
        end
      else
        if values["diagnostics_format"] == "patch" then
          if ( compiler == "gcc" and not ( compversion < 700 ) ) then
            jln_buildoptions[#jln_buildoptions+1] = "-fdiagnostics-generate-patch"
          end
        else
          if values["diagnostics_format"] == "print_source_range_info" then
            if compiler == "clang" then
              jln_buildoptions[#jln_buildoptions+1] = "-fdiagnostics-print-source-range-info"
            end
          end
        end
      end
    end
    if not ( values["fix_compiler_error"] == "default") then
      if values["fix_compiler_error"] == "on" then
        if compiler == "gcc" then
          if not ( compversion < 407 ) then
            jln_buildoptions[#jln_buildoptions+1] = "-Werror=narrowing"
            if not ( compversion < 701 ) then
              jln_buildoptions[#jln_buildoptions+1] = "-Werror=literal-suffix"
            end
          end
        end
        jln_buildoptions[#jln_buildoptions+1] = "-Werror=write-strings"
      else
        if ( compiler == "clang" or compiler == "clang-cl" ) then
          jln_buildoptions[#jln_buildoptions+1] = "-Wno-error=c++11-narrowing"
          jln_buildoptions[#jln_buildoptions+1] = "-Wno-reserved-user-defined-literal"
        end
      end
    end
  end
  if ( compiler == "gcc" or compiler == "clang" ) then
    if not ( values["coverage"] == "default") then
      if values["coverage"] == "on" then
        jln_buildoptions[#jln_buildoptions+1] = "--coverage"
        jln_linkoptions[#jln_linkoptions+1] = "--coverage"
        if compiler == "clang" then
          jln_linkoptions[#jln_linkoptions+1] = "-lprofile_rt"
        end
      end
    end
    if not ( values["debug"] == "default") then
      if values["debug"] == "off" then
        jln_buildoptions[#jln_buildoptions+1] = "-g0"
      else
        if values["debug"] == "gdb" then
          jln_buildoptions[#jln_buildoptions+1] = "-ggdb"
        else
          if compiler == "clang" then
            if values["debug"] == "line_tables_only" then
              jln_buildoptions[#jln_buildoptions+1] = "-gline-tables-only"
            end
            if values["debug"] == "lldb" then
              jln_buildoptions[#jln_buildoptions+1] = "-glldb"
            else
              if values["debug"] == "sce" then
                jln_buildoptions[#jln_buildoptions+1] = "-gsce"
              else
                jln_buildoptions[#jln_buildoptions+1] = "-g"
              end
            end
          else
            jln_buildoptions[#jln_buildoptions+1] = "-g"
          end
        end
      end
    end
    if not ( values["linker"] == "default") then
      if values["linker"] == "native" then
        if compiler == "gcc" then
          jln_linkoptions[#jln_linkoptions+1] = "-fuse-ld=gold"
        else
          jln_linkoptions[#jln_linkoptions+1] = "-fuse-ld=lld"
        end
      else
        if values["linker"] == "bfd" then
          jln_linkoptions[#jln_linkoptions+1] = "-fuse-ld=bfd"
        else
          if ( values["linker"] == "gold" or ( compiler == "gcc" and not ( not ( compversion < 900 ) ) ) ) then
            jln_linkoptions[#jln_linkoptions+1] = "-fuse-ld=gold"
          else
            if not ( values["lto"] == "default") then
              if ( not ( values["lto"] == "off" ) and compiler == "gcc" ) then
                jln_linkoptions[#jln_linkoptions+1] = "-fuse-ld=gold"
              else
                jln_linkoptions[#jln_linkoptions+1] = "-fuse-ld=lld"
              end
            else
              jln_linkoptions[#jln_linkoptions+1] = "-fuse-ld=lld"
            end
          end
        end
      end
    end
    if not ( values["lto"] == "default") then
      if values["lto"] == "off" then
        jln_buildoptions[#jln_buildoptions+1] = "-fno-lto"
        jln_linkoptions[#jln_linkoptions+1] = "-fno-lto"
      else
        if compiler == "gcc" then
          jln_buildoptions[#jln_buildoptions+1] = "-flto"
          jln_linkoptions[#jln_linkoptions+1] = "-flto"
          if not ( compversion < 500 ) then
            if not ( values["warnings"] == "default") then
              if not ( values["warnings"] == "off" ) then
                jln_buildoptions[#jln_buildoptions+1] = "-flto-odr-type-merging"
                jln_linkoptions[#jln_linkoptions+1] = "-flto-odr-type-merging"
              end
            end
            if values["lto"] == "fat" then
              jln_buildoptions[#jln_buildoptions+1] = "-ffat-lto-objects"
            else
              if values["lto"] == "thin" then
                jln_linkoptions[#jln_linkoptions+1] = "-fuse-linker-plugin"
              end
            end
          end
        else
          if ( values["lto"] == "thin" and compiler == "clang" and not ( compversion < 600 ) ) then
            jln_buildoptions[#jln_buildoptions+1] = "-flto=thin"
            jln_linkoptions[#jln_linkoptions+1] = "-flto=thin"
          else
            jln_buildoptions[#jln_buildoptions+1] = "-flto"
            jln_linkoptions[#jln_linkoptions+1] = "-flto"
          end
        end
      end
    end
    if not ( values["optimization"] == "default") then
      if values["optimization"] == "0" then
        jln_buildoptions[#jln_buildoptions+1] = "-O0"
        jln_linkoptions[#jln_linkoptions+1] = "-O0"
      else
        if values["optimization"] == "g" then
          jln_buildoptions[#jln_buildoptions+1] = "-Og"
          jln_linkoptions[#jln_linkoptions+1] = "-Og"
        else
          jln_buildoptions[#jln_buildoptions+1] = "-DNDEBUG"
          jln_linkoptions[#jln_linkoptions+1] = "-Wl,-O1"
          if values["optimization"] == "size" then
            jln_buildoptions[#jln_buildoptions+1] = "-Os"
            jln_linkoptions[#jln_linkoptions+1] = "-Os"
          else
            if values["optimization"] == "fast" then
              jln_buildoptions[#jln_buildoptions+1] = "-Ofast"
              jln_linkoptions[#jln_linkoptions+1] = "-Ofast"
            else
              if values["optimization"] == "1" then
                jln_buildoptions[#jln_buildoptions+1] = "-O1"
                jln_linkoptions[#jln_linkoptions+1] = "-O1"
              else
                if values["optimization"] == "2" then
                  jln_buildoptions[#jln_buildoptions+1] = "-O2"
                  jln_linkoptions[#jln_linkoptions+1] = "-O2"
                else
                  if values["optimization"] == "3" then
                    jln_buildoptions[#jln_buildoptions+1] = "-O3"
                    jln_linkoptions[#jln_linkoptions+1] = "-O3"
                  end
                end
              end
            end
          end
        end
      end
    end
    if not ( values["cpu"] == "default") then
      if values["cpu"] == "generic" then
        jln_buildoptions[#jln_buildoptions+1] = "-mtune=generic"
        jln_linkoptions[#jln_linkoptions+1] = "-mtune=generic"
      else
        jln_buildoptions[#jln_buildoptions+1] = "-march=native"
        jln_buildoptions[#jln_buildoptions+1] = "-mtune=native"
        jln_linkoptions[#jln_linkoptions+1] = "-march=native"
        jln_linkoptions[#jln_linkoptions+1] = "-mtune=native"
      end
    end
    if not ( values["whole_program"] == "default") then
      if values["whole_program"] == "off" then
        jln_buildoptions[#jln_buildoptions+1] = "-fno-whole-program"
        if ( compiler == "clang" and not ( compversion < 309 ) ) then
          jln_buildoptions[#jln_buildoptions+1] = "-fno-whole-program-vtables"
          jln_linkoptions[#jln_linkoptions+1] = "-fno-whole-program-vtables"
        end
      else
        if linker == "ld64" then
          jln_linkoptions[#jln_linkoptions+1] = "-Wl,-dead_strip"
          jln_linkoptions[#jln_linkoptions+1] = "-Wl,-S"
        else
          jln_linkoptions[#jln_linkoptions+1] = "-s"
          if values["whole_program"] == "strip_all" then
            jln_linkoptions[#jln_linkoptions+1] = "-Wl,--gc-sections"
            jln_linkoptions[#jln_linkoptions+1] = "-Wl,--strip-all"
          end
        end
        if compiler == "gcc" then
          jln_buildoptions[#jln_buildoptions+1] = "-fwhole-program"
          jln_linkoptions[#jln_linkoptions+1] = "-fwhole-program"
        else
          if compiler == "clang" then
            if not ( compversion < 309 ) then
              if not ( values["lto"] == "default") then
                if not ( values["lto"] == "off" ) then
                  jln_buildoptions[#jln_buildoptions+1] = "-fwhole-program-vtables"
                  jln_linkoptions[#jln_linkoptions+1] = "-fwhole-program-vtables"
                end
              end
              if not ( compversion < 700 ) then
                jln_buildoptions[#jln_buildoptions+1] = "-fforce-emit-vtables"
                jln_linkoptions[#jln_linkoptions+1] = "-fforce-emit-vtables"
              end
            end
          end
        end
      end
    end
    if not ( values["pedantic"] == "default") then
      if not ( values["pedantic"] == "off" ) then
        jln_buildoptions[#jln_buildoptions+1] = "-pedantic"
        if values["pedantic"] == "as_error" then
          jln_buildoptions[#jln_buildoptions+1] = "-pedantic-errors"
        end
      end
    end
    if not ( values["stack_protector"] == "default") then
      if values["stack_protector"] == "off" then
        jln_buildoptions[#jln_buildoptions+1] = "-Wno-stack-protector"
        jln_buildoptions[#jln_buildoptions+1] = "-U_FORTIFY_SOURCE"
        jln_linkoptions[#jln_linkoptions+1] = "-Wno-stack-protector"
      else
        jln_buildoptions[#jln_buildoptions+1] = "-D_FORTIFY_SOURCE=2"
        jln_buildoptions[#jln_buildoptions+1] = "-Wstack-protector"
        if values["stack_protector"] == "strong" then
          if ( compiler == "gcc" and not ( compversion < 409 ) ) then
            jln_buildoptions[#jln_buildoptions+1] = "-fstack-protector-strong"
            jln_linkoptions[#jln_linkoptions+1] = "-fstack-protector-strong"
          else
            if compiler == "clang" then
              jln_buildoptions[#jln_buildoptions+1] = "-fstack-protector-strong"
              jln_buildoptions[#jln_buildoptions+1] = "-fsanitize=safe-stack"
              jln_linkoptions[#jln_linkoptions+1] = "-fstack-protector-strong"
              jln_linkoptions[#jln_linkoptions+1] = "-fsanitize=safe-stack"
            end
          end
        else
          if values["stack_protector"] == "all" then
            jln_buildoptions[#jln_buildoptions+1] = "-fstack-protector-all"
            jln_linkoptions[#jln_linkoptions+1] = "-fstack-protector-all"
            if compiler == "clang" then
              jln_buildoptions[#jln_buildoptions+1] = "-fsanitize=safe-stack"
              jln_linkoptions[#jln_linkoptions+1] = "-fsanitize=safe-stack"
              if not ( compversion < 1100 ) then
                jln_buildoptions[#jln_buildoptions+1] = "-fstack-clash-protection"
                jln_linkoptions[#jln_linkoptions+1] = "-fstack-clash-protection"
              end
            end
          else
            jln_buildoptions[#jln_buildoptions+1] = "-fstack-protector"
            jln_linkoptions[#jln_linkoptions+1] = "-fstack-protector"
          end
        end
        if compiler == "clang" then
          jln_buildoptions[#jln_buildoptions+1] = "-fsanitize=shadow-call-stack"
          jln_linkoptions[#jln_linkoptions+1] = "-fsanitize=shadow-call-stack"
        end
      end
    end
    if not ( values["relro"] == "default") then
      if values["relro"] == "off" then
        jln_linkoptions[#jln_linkoptions+1] = "-Wl,-z,norelro"
      else
        if values["relro"] == "on" then
          jln_linkoptions[#jln_linkoptions+1] = "-Wl,-z,relro"
        else
          if values["relro"] == "full" then
            jln_linkoptions[#jln_linkoptions+1] = "-Wl,-z,relro,-z,now"
          end
        end
      end
    end
    if not ( values["pie"] == "default") then
      if values["pie"] == "off" then
        jln_linkoptions[#jln_linkoptions+1] = "-no-pic"
      else
        if values["pie"] == "on" then
          jln_linkoptions[#jln_linkoptions+1] = "-pie"
        else
          if values["pie"] == "pic" then
            jln_buildoptions[#jln_buildoptions+1] = "-fPIC"
          end
        end
      end
    end
    if not ( values["stl_debug"] == "default") then
      if not ( values["stl_debug"] == "off" ) then
        if values["stl_debug"] == "assert_as_exception" then
          jln_buildoptions[#jln_buildoptions+1] = "-D_LIBCPP_DEBUG_USE_EXCEPTIONS"
        end
        if ( values["stl_debug"] == "allow_broken_abi" or values["stl_debug"] == "allow_broken_abi_and_bugs" ) then
          if compiler == "clang" then
            if ( not ( compversion < 800 ) or values["stl_debug"] == "allow_broken_abi_and_bugs" ) then
              jln_buildoptions[#jln_buildoptions+1] = "-D_LIBCPP_DEBUG=1"
            end
          end
          jln_buildoptions[#jln_buildoptions+1] = "-D_GLIBCXX_DEBUG"
        else
          jln_buildoptions[#jln_buildoptions+1] = "-D_GLIBCXX_ASSERTIONS"
        end
        if not ( values["pedantic"] == "default") then
          if not ( values["pedantic"] == "off" ) then
            jln_buildoptions[#jln_buildoptions+1] = "-D_GLIBCXX_DEBUG_PEDANTIC"
          end
        end
      end
    end
    if not ( values["shadow_warnings"] == "default") then
      if values["shadow_warnings"] == "off" then
        jln_buildoptions[#jln_buildoptions+1] = "-Wno-shadow"
        if ( compiler == "clang" and not ( compversion < 800 ) ) then
          jln_buildoptions[#jln_buildoptions+1] = "-Wno-shadow-field"
        end
      else
        if values["shadow_warnings"] == "on" then
          jln_buildoptions[#jln_buildoptions+1] = "-Wshadow"
        else
          if values["shadow_warnings"] == "all" then
            if compiler == "clang" then
              jln_buildoptions[#jln_buildoptions+1] = "-Wshadow-all"
            else
              jln_buildoptions[#jln_buildoptions+1] = "-Wshadow"
            end
          else
            if ( compiler == "gcc" and not ( compversion < 701 ) ) then
              if values["shadow_warnings"] == "local" then
                jln_buildoptions[#jln_buildoptions+1] = "-Wshadow=local"
              else
                if values["shadow_warnings"] == "compatible_local" then
                  jln_buildoptions[#jln_buildoptions+1] = "-Wshadow=compatible-local"
                end
              end
            end
          end
        end
      end
    end
    if not ( values["elide_type"] == "default") then
      if values["elide_type"] == "on" then
        if ( compiler == "gcc" and not ( compversion < 800 ) ) then
          jln_buildoptions[#jln_buildoptions+1] = "-felide-type"
        end
      else
        if ( ( compiler == "gcc" and not ( compversion < 800 ) ) or ( compiler == "clang" and not ( compversion < 304 ) ) ) then
          jln_buildoptions[#jln_buildoptions+1] = "-fno-elide-type"
        end
      end
    end
    if not ( values["exceptions"] == "default") then
      if values["exceptions"] == "on" then
        jln_buildoptions[#jln_buildoptions+1] = "-fexceptions"
      else
        jln_buildoptions[#jln_buildoptions+1] = "-fno-exceptions"
      end
    end
    if not ( values["rtti"] == "default") then
      if values["rtti"] == "on" then
        jln_buildoptions[#jln_buildoptions+1] = "-frtti"
      else
        jln_buildoptions[#jln_buildoptions+1] = "-fno-rtti"
      end
    end
    if not ( values["diagnostics_show_template_tree"] == "default") then
      if ( ( compiler == "gcc" and not ( compversion < 800 ) ) or compiler == "clang" ) then
        if values["diagnostics_show_template_tree"] == "on" then
          jln_buildoptions[#jln_buildoptions+1] = "-fdiagnostics-show-template-tree"
        else
          jln_buildoptions[#jln_buildoptions+1] = "-fno-diagnostics-show-template-tree"
        end
      end
    end
    if not ( values["sanitizers_extra"] == "default") then
      if values["sanitizers_extra"] == "thread" then
        jln_buildoptions[#jln_buildoptions+1] = "-fsanitize=thread"
      else
        if values["sanitizers_extra"] == "pointer" then
          if ( compiler == "gcc" and not ( compversion < 800 ) ) then
            jln_buildoptions[#jln_buildoptions+1] = "-fsanitize=pointer-compare"
            jln_buildoptions[#jln_buildoptions+1] = "-fsanitize=pointer-subtract"
          end
        end
      end
    end
  end
  if linker == "lld-link" then
    if not ( values["lto"] == "default") then
      if values["lto"] == "off" then
        jln_buildoptions[#jln_buildoptions+1] = "-fno-lto"
      else
        if values["lto"] == "thin" then
          jln_buildoptions[#jln_buildoptions+1] = "-flto=thin"
        else
          jln_buildoptions[#jln_buildoptions+1] = "-flto"
          jln_linkoptions[#jln_linkoptions+1] = "-flto"
        end
      end
    end
    if not ( values["whole_program"] == "default") then
      if values["whole_program"] == "off" then
        jln_buildoptions[#jln_buildoptions+1] = "-fno-whole-program"
      else
        if not ( values["lto"] == "default") then
          if not ( values["lto"] == "off" ) then
            jln_buildoptions[#jln_buildoptions+1] = "-fwhole-program-vtables"
            jln_linkoptions[#jln_linkoptions+1] = "-fwhole-program-vtables"
          end
        end
      end
    end
  end
  if ( compiler == "msvc" or compiler == "clang-cl" ) then
    if not ( values["stl_fix"] == "default") then
      if values["stl_fix"] == "on" then
        jln_buildoptions[#jln_buildoptions+1] = "/DNOMINMAX"
      end
    end
    if not ( values["debug"] == "default") then
      if values["debug"] == "off" then
        jln_buildoptions[#jln_buildoptions+1] = "/DEBUG:NONE"
      else
        jln_buildoptions[#jln_buildoptions+1] = "/RTC1"
        jln_buildoptions[#jln_buildoptions+1] = "/Od"
        if values["debug"] == "on" then
          jln_buildoptions[#jln_buildoptions+1] = "/DEBUG"
        else
          if values["debug"] == "line_tables_only" then
            jln_buildoptions[#jln_buildoptions+1] = "/DEBUG:FASTLINK"
          end
        end
        if not ( values["optimization"] == "default") then
          if values["optimization"] == "g" then
            jln_buildoptions[#jln_buildoptions+1] = "/Zi"
          else
            if not ( values["whole_program"] == "default") then
              if values["whole_program"] == "off" then
                jln_buildoptions[#jln_buildoptions+1] = "/ZI"
              else
                jln_buildoptions[#jln_buildoptions+1] = "/Zi"
              end
            else
              jln_buildoptions[#jln_buildoptions+1] = "/ZI"
            end
          end
        else
          if not ( values["whole_program"] == "default") then
            if values["whole_program"] == "off" then
              jln_buildoptions[#jln_buildoptions+1] = "/ZI"
            else
              jln_buildoptions[#jln_buildoptions+1] = "/Zi"
            end
          else
            jln_buildoptions[#jln_buildoptions+1] = "/ZI"
          end
        end
      end
    end
    if not ( values["exceptions"] == "default") then
      if values["exceptions"] == "on" then
        jln_buildoptions[#jln_buildoptions+1] = "/EHsc"
        jln_buildoptions[#jln_buildoptions+1] = "/D_HAS_EXCEPTIONS=1"
      else
        jln_buildoptions[#jln_buildoptions+1] = "/EHs-"
        jln_buildoptions[#jln_buildoptions+1] = "/D_HAS_EXCEPTIONS=0"
      end
    end
    if not ( values["optimization"] == "default") then
      if values["optimization"] == "0" then
        jln_buildoptions[#jln_buildoptions+1] = "/Ob0"
        jln_buildoptions[#jln_buildoptions+1] = "/Od"
        jln_buildoptions[#jln_buildoptions+1] = "/Oi-"
        jln_buildoptions[#jln_buildoptions+1] = "/Oy-"
      else
        if values["optimization"] == "g" then
          jln_buildoptions[#jln_buildoptions+1] = "/Ob1"
        else
          jln_buildoptions[#jln_buildoptions+1] = "/DNDEBUG"
          if values["optimization"] == "1" then
            jln_buildoptions[#jln_buildoptions+1] = "/O1"
          else
            if values["optimization"] == "2" then
              jln_buildoptions[#jln_buildoptions+1] = "/O2"
            else
              if values["optimization"] == "3" then
                jln_buildoptions[#jln_buildoptions+1] = "/O2"
              else
                if values["optimization"] == "size" then
                  jln_buildoptions[#jln_buildoptions+1] = "/O1"
                  jln_buildoptions[#jln_buildoptions+1] = "/Gw"
                else
                  if values["optimization"] == "fast" then
                    jln_buildoptions[#jln_buildoptions+1] = "/O2"
                    jln_buildoptions[#jln_buildoptions+1] = "/fp:fast"
                  end
                end
              end
            end
          end
        end
      end
    end
    if not ( values["whole_program"] == "default") then
      if values["whole_program"] == "off" then
        jln_buildoptions[#jln_buildoptions+1] = "/GL-"
      else
        jln_buildoptions[#jln_buildoptions+1] = "/GL"
        jln_buildoptions[#jln_buildoptions+1] = "/Gw"
        jln_linkoptions[#jln_linkoptions+1] = "/LTCG"
        if values["whole_program"] == "strip_all" then
          jln_linkoptions[#jln_linkoptions+1] = "/OPT:REF"
        end
      end
    end
    if not ( values["pedantic"] == "default") then
      if not ( values["pedantic"] == "off" ) then
        jln_buildoptions[#jln_buildoptions+1] = "/permissive-"
        jln_buildoptions[#jln_buildoptions+1] = "/Zc:__cplusplus"
      end
    end
    if not ( values["rtti"] == "default") then
      if values["rtti"] == "on" then
        jln_buildoptions[#jln_buildoptions+1] = "/GR"
      else
        jln_buildoptions[#jln_buildoptions+1] = "/GR-"
      end
    end
    if not ( values["stl_debug"] == "default") then
      if values["stl_debug"] == "off" then
        jln_buildoptions[#jln_buildoptions+1] = "/D_HAS_ITERATOR_DEBUGGING=0"
      else
        jln_buildoptions[#jln_buildoptions+1] = "/D_DEBUG"
        jln_buildoptions[#jln_buildoptions+1] = "/D_HAS_ITERATOR_DEBUGGING=1"
      end
    end
    if not ( values["control_flow"] == "default") then
      if values["control_flow"] == "off" then
        jln_buildoptions[#jln_buildoptions+1] = "/guard:cf-"
      else
        jln_buildoptions[#jln_buildoptions+1] = "/guard:cf"
      end
    end
    if not ( values["stack_protector"] == "default") then
      if values["stack_protector"] == "off" then
        jln_buildoptions[#jln_buildoptions+1] = "/GS-"
      else
        jln_buildoptions[#jln_buildoptions+1] = "/GS"
        jln_buildoptions[#jln_buildoptions+1] = "/sdl"
        if values["stack_protector"] == "strong" then
          jln_buildoptions[#jln_buildoptions+1] = "/RTC1"
        else
          if values["stack_protector"] == "all" then
            jln_buildoptions[#jln_buildoptions+1] = "/RTC1"
            jln_buildoptions[#jln_buildoptions+1] = "/RTCc"
          end
        end
      end
    end
  end
  if compiler == "msvc" then
    if not ( values["msvc_isystem"] == "default") then
      if values["msvc_isystem"] == "external_as_include_system_flag" then
        -- unimplementable
      else
        jln_buildoptions[#jln_buildoptions+1] = "/experimental:external"
        jln_buildoptions[#jln_buildoptions+1] = "/external:W0"
        if values["msvc_isystem"] == "anglebrackets" then
          jln_buildoptions[#jln_buildoptions+1] = "/external:anglebrackets"
        else
          jln_buildoptions[#jln_buildoptions+1] = "/external:env:INCLUDE"
          jln_buildoptions[#jln_buildoptions+1] = "/external:env:CAExcludePath"
        end
      end
      if not ( values["msvc_isystem_with_template_from_non_external"] == "default") then
        if values["msvc_isystem_with_template_from_non_external"] == "off" then
          jln_buildoptions[#jln_buildoptions+1] = "/external:template"
        else
          jln_buildoptions[#jln_buildoptions+1] = "/external:template-"
        end
      end
      if not ( values["warnings"] == "default") then
        if values["warnings"] == "off" then
          jln_buildoptions[#jln_buildoptions+1] = "/W0"
        else
          jln_buildoptions[#jln_buildoptions+1] = "/wd4710"
          jln_buildoptions[#jln_buildoptions+1] = "/wd4711"
          if not ( not ( compversion < 1921 ) ) then
            jln_buildoptions[#jln_buildoptions+1] = "/wd4774"
          end
          if values["warnings"] == "on" then
            jln_buildoptions[#jln_buildoptions+1] = "/W4"
          else
            jln_buildoptions[#jln_buildoptions+1] = "/Wall"
            jln_buildoptions[#jln_buildoptions+1] = "/wd4571"
            jln_buildoptions[#jln_buildoptions+1] = "/wd4355"
            jln_buildoptions[#jln_buildoptions+1] = "/wd4548"
            jln_buildoptions[#jln_buildoptions+1] = "/wd4577"
            jln_buildoptions[#jln_buildoptions+1] = "/wd4820"
            jln_buildoptions[#jln_buildoptions+1] = "/wd5039"
            jln_buildoptions[#jln_buildoptions+1] = "/wd4464"
            jln_buildoptions[#jln_buildoptions+1] = "/wd4868"
            jln_buildoptions[#jln_buildoptions+1] = "/wd5045"
            if values["warnings"] == "strict" then
              jln_buildoptions[#jln_buildoptions+1] = "/wd4583"
              jln_buildoptions[#jln_buildoptions+1] = "/wd4619"
            end
          end
        end
      end
    else
      if not ( values["warnings"] == "default") then
        if values["warnings"] == "off" then
          jln_buildoptions[#jln_buildoptions+1] = "/W0"
        else
          if values["warnings"] == "on" then
            jln_buildoptions[#jln_buildoptions+1] = "/W4"
            jln_buildoptions[#jln_buildoptions+1] = "/wd4711"
          else
            jln_buildoptions[#jln_buildoptions+1] = "/Wall"
            jln_buildoptions[#jln_buildoptions+1] = "/wd4355"
            jln_buildoptions[#jln_buildoptions+1] = "/wd4514"
            jln_buildoptions[#jln_buildoptions+1] = "/wd4548"
            jln_buildoptions[#jln_buildoptions+1] = "/wd4571"
            jln_buildoptions[#jln_buildoptions+1] = "/wd4577"
            jln_buildoptions[#jln_buildoptions+1] = "/wd4625"
            jln_buildoptions[#jln_buildoptions+1] = "/wd4626"
            jln_buildoptions[#jln_buildoptions+1] = "/wd4668"
            jln_buildoptions[#jln_buildoptions+1] = "/wd4710"
            jln_buildoptions[#jln_buildoptions+1] = "/wd4711"
            if not ( not ( compversion < 1921 ) ) then
              jln_buildoptions[#jln_buildoptions+1] = "/wd4774"
            end
            jln_buildoptions[#jln_buildoptions+1] = "/wd4820"
            jln_buildoptions[#jln_buildoptions+1] = "/wd5026"
            jln_buildoptions[#jln_buildoptions+1] = "/wd5027"
            jln_buildoptions[#jln_buildoptions+1] = "/wd5039"
            jln_buildoptions[#jln_buildoptions+1] = "/wd4464"
            jln_buildoptions[#jln_buildoptions+1] = "/wd4868"
            jln_buildoptions[#jln_buildoptions+1] = "/wd5045"
            if values["warnings"] == "strict" then
              jln_buildoptions[#jln_buildoptions+1] = "/wd4061"
              jln_buildoptions[#jln_buildoptions+1] = "/wd4266"
              jln_buildoptions[#jln_buildoptions+1] = "/wd4583"
              jln_buildoptions[#jln_buildoptions+1] = "/wd4619"
              jln_buildoptions[#jln_buildoptions+1] = "/wd4623"
              jln_buildoptions[#jln_buildoptions+1] = "/wd5204"
            end
          end
        end
      end
    end
    if not ( values["conversion_warnings"] == "default") then
      if values["conversion_warnings"] == "on" then
        jln_buildoptions[#jln_buildoptions+1] = "/w14244"
        jln_buildoptions[#jln_buildoptions+1] = "/w14245"
        jln_buildoptions[#jln_buildoptions+1] = "/w14388"
        jln_buildoptions[#jln_buildoptions+1] = "/w14365"
      else
        if values["conversion_warnings"] == "conversion" then
          jln_buildoptions[#jln_buildoptions+1] = "/w14244"
          jln_buildoptions[#jln_buildoptions+1] = "/w14365"
        else
          if values["conversion_warnings"] == "sign" then
            jln_buildoptions[#jln_buildoptions+1] = "/w14388"
            jln_buildoptions[#jln_buildoptions+1] = "/w14245"
          else
            jln_buildoptions[#jln_buildoptions+1] = "/wd4244"
            jln_buildoptions[#jln_buildoptions+1] = "/wd4365"
            jln_buildoptions[#jln_buildoptions+1] = "/wd4388"
            jln_buildoptions[#jln_buildoptions+1] = "/wd4245"
          end
        end
      end
    end
    if not ( values["shadow_warnings"] == "default") then
      if values["shadow_warnings"] == "off" then
        jln_buildoptions[#jln_buildoptions+1] = "/wd4456"
        jln_buildoptions[#jln_buildoptions+1] = "/wd4459"
      else
        if ( values["shadow_warnings"] == "on" or values["shadow_warnings"] == "all" ) then
          jln_buildoptions[#jln_buildoptions+1] = "/w4456"
          jln_buildoptions[#jln_buildoptions+1] = "/w4459"
        else
          if values["shadow_warnings"] == "local" then
            jln_buildoptions[#jln_buildoptions+1] = "/w4456"
            jln_buildoptions[#jln_buildoptions+1] = "/wd4459"
          end
        end
      end
    end
    if not ( values["warnings_as_error"] == "default") then
      if values["warnings_as_error"] == "on" then
        jln_buildoptions[#jln_buildoptions+1] = "/WX"
        jln_linkoptions[#jln_linkoptions+1] = "/WX"
      else
        if values["warnings_as_error"] == "off" then
          jln_buildoptions[#jln_buildoptions+1] = "/WX-"
        end
      end
    end
    if not ( values["lto"] == "default") then
      if values["lto"] == "off" then
        jln_buildoptions[#jln_buildoptions+1] = "/LTCG:OFF"
      else
        jln_buildoptions[#jln_buildoptions+1] = "/GL"
        jln_linkoptions[#jln_linkoptions+1] = "/LTCG"
      end
    end
    if not ( values["sanitizers"] == "default") then
      if values["sanitizers"] == "on" then
        jln_buildoptions[#jln_buildoptions+1] = "/sdl"
      else
        if not ( values["stack_protector"] == "default") then
          if not ( values["stack_protector"] == "off" ) then
            jln_buildoptions[#jln_buildoptions+1] = "/sdl-"
          end
        end
      end
    end
  end
  return {buildoptions=jln_buildoptions, linkoptions=jln_linkoptions}
end

