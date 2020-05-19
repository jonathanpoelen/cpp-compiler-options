--  ```lua
--  -- launch example: premake5 --jln-sanitizers=on
--  
--  include "cpp.lua"
--  
--  -- Registers new command-line options and set default values
--  jln_newoptions({warnings='very_strict'})
--  
--  -- jln_getoptions(values, disable_others = nil, print_compiler = nil)
--  -- jln_getoptions(compiler, version = nil, values = nil, disable_others = nil, print_compiler = nil)
--  -- `= nil` indicates that the value is optional and can be nil
--  -- `compiler`: string. ex: 'gcc', 'g++', 'clang++', 'clang'. Or compiler and linker with semicolon separator. ex: 'clang-cl;lld-link'
--  -- `version`: string. Compiler version. ex: '7', '7.2'
--  -- `values`: table. ex: {warnings='on'}
--  -- `disable_others`: boolean
--  -- `print_compiler`: boolean
--  -- return {buildoptions=string, linkoptions=string}
--  local mylib_options = jln_getoptions({elide_type='on'})
--  buildoptions(mylib_options.buildoptions)
--  linkoptions(mylib_options.linkoptions)
--  
--  -- or equivalent
--  jln_setoptions({elide_type='on'})
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
--  msvc_isystem = default anglebrackets include_and_caexcludepath
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
--  If not specified, `fix_compiler_error`, `pedantic`, `stl_fix` and `warnings` are `on` ; `shadow_warnings` is `off`.
--  
--  - `control_flow=allow_bugs`
--    - clang: Can crash programs with "illegal hardware instruction" on totally unlikely lines. It can also cause link errors and force `-fvisibility=hidden` and `-flto`.
--  - `stl_debug=allow_broken_abi_and_bugs`
--    - clang: libc++ can crash on dynamic memory releases in the standard classes. This bug is fixed with the library associated with version 8.
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

local _jln_flag_names = {}
_jln_flag_names["jln-color"] = true
_jln_flag_names["color"] = true
_jln_flag_names["jln-control-flow"] = true
_jln_flag_names["control_flow"] = true
_jln_flag_names["jln-coverage"] = true
_jln_flag_names["coverage"] = true
_jln_flag_names["jln-cpu"] = true
_jln_flag_names["cpu"] = true
_jln_flag_names["jln-debug"] = true
_jln_flag_names["debug"] = true
_jln_flag_names["jln-diagnostics-format"] = true
_jln_flag_names["diagnostics_format"] = true
_jln_flag_names["jln-diagnostics-show-template-tree"] = true
_jln_flag_names["diagnostics_show_template_tree"] = true
_jln_flag_names["jln-elide-type"] = true
_jln_flag_names["elide_type"] = true
_jln_flag_names["jln-exceptions"] = true
_jln_flag_names["exceptions"] = true
_jln_flag_names["jln-fix-compiler-error"] = true
_jln_flag_names["fix_compiler_error"] = true
_jln_flag_names["jln-linker"] = true
_jln_flag_names["linker"] = true
_jln_flag_names["jln-lto"] = true
_jln_flag_names["lto"] = true
_jln_flag_names["jln-msvc-isystem"] = true
_jln_flag_names["msvc_isystem"] = true
_jln_flag_names["jln-msvc-isystem-with-template-from-non-external"] = true
_jln_flag_names["msvc_isystem_with_template_from_non_external"] = true
_jln_flag_names["jln-optimization"] = true
_jln_flag_names["optimization"] = true
_jln_flag_names["jln-pedantic"] = true
_jln_flag_names["pedantic"] = true
_jln_flag_names["jln-pie"] = true
_jln_flag_names["pie"] = true
_jln_flag_names["jln-relro"] = true
_jln_flag_names["relro"] = true
_jln_flag_names["jln-reproducible-build-warnings"] = true
_jln_flag_names["reproducible_build_warnings"] = true
_jln_flag_names["jln-rtti"] = true
_jln_flag_names["rtti"] = true
_jln_flag_names["jln-sanitizers"] = true
_jln_flag_names["sanitizers"] = true
_jln_flag_names["jln-sanitizers-extra"] = true
_jln_flag_names["sanitizers_extra"] = true
_jln_flag_names["jln-shadow-warnings"] = true
_jln_flag_names["shadow_warnings"] = true
_jln_flag_names["jln-stack-protector"] = true
_jln_flag_names["stack_protector"] = true
_jln_flag_names["jln-stl-debug"] = true
_jln_flag_names["stl_debug"] = true
_jln_flag_names["jln-stl-fix"] = true
_jln_flag_names["stl_fix"] = true
_jln_flag_names["jln-suggestions"] = true
_jln_flag_names["suggestions"] = true
_jln_flag_names["jln-warnings"] = true
_jln_flag_names["warnings"] = true
_jln_flag_names["jln-warnings-as-error"] = true
_jln_flag_names["warnings_as_error"] = true
_jln_flag_names["jln-whole-program"] = true
_jln_flag_names["whole_program"] = true

function jln_newoptions(defaults)
  if defaults then
    jln_check_flag_names(defaults)
  else
    defaults = {}
  end
  newoption{trigger="jln-color", allowed={{"default"}, {"auto"}, {"never"}, {"always"}}, description="color"}
  if not _OPTIONS["jln-color"] then _OPTIONS["jln-color"] = (defaults["color"] or defaults["jln-color"] or "default") end
  newoption{trigger="jln-control-flow", allowed={{"default"}, {"off"}, {"on"}, {"branch"}, {"return"}, {"allow_bugs"}}, description="control_flow"}
  if not _OPTIONS["jln-control-flow"] then _OPTIONS["jln-control-flow"] = (defaults["control_flow"] or defaults["jln-control-flow"] or "default") end
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
  if not _OPTIONS["jln-fix-compiler-error"] then _OPTIONS["jln-fix-compiler-error"] = (defaults["fix_compiler_error"] or defaults["jln-fix-compiler-error"] or "default") end
  newoption{trigger="jln-linker", allowed={{"default"}, {"bfd"}, {"gold"}, {"lld"}, {"native"}}, description="linker"}
  if not _OPTIONS["jln-linker"] then _OPTIONS["jln-linker"] = (defaults["linker"] or defaults["jln-linker"] or "default") end
  newoption{trigger="jln-lto", allowed={{"default"}, {"off"}, {"on"}, {"fat"}, {"thin"}}, description="lto"}
  if not _OPTIONS["jln-lto"] then _OPTIONS["jln-lto"] = (defaults["lto"] or defaults["jln-lto"] or "default") end
  newoption{trigger="jln-msvc-isystem", allowed={{"default"}, {"anglebrackets"}, {"include_and_caexcludepath"}}, description="msvc_isystem"}
  if not _OPTIONS["jln-msvc-isystem"] then _OPTIONS["jln-msvc-isystem"] = (defaults["msvc_isystem"] or defaults["jln-msvc-isystem"] or "default") end
  newoption{trigger="jln-msvc-isystem-with-template-from-non-external", allowed={{"default"}, {"off"}, {"on"}}, description="msvc_isystem_with_template_from_non_external"}
  if not _OPTIONS["jln-msvc-isystem-with-template-from-non-external"] then _OPTIONS["jln-msvc-isystem-with-template-from-non-external"] = (defaults["msvc_isystem_with_template_from_non_external"] or defaults["jln-msvc-isystem-with-template-from-non-external"] or "default") end
  newoption{trigger="jln-optimization", allowed={{"default"}, {"0"}, {"g"}, {"1"}, {"2"}, {"3"}, {"fast"}, {"size"}}, description="optimization"}
  if not _OPTIONS["jln-optimization"] then _OPTIONS["jln-optimization"] = (defaults["optimization"] or defaults["jln-optimization"] or "default") end
  newoption{trigger="jln-pedantic", allowed={{"default"}, {"off"}, {"on"}, {"as_error"}}, description="pedantic"}
  if not _OPTIONS["jln-pedantic"] then _OPTIONS["jln-pedantic"] = (defaults["pedantic"] or defaults["jln-pedantic"] or "default") end
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
  if not _OPTIONS["jln-shadow-warnings"] then _OPTIONS["jln-shadow-warnings"] = (defaults["shadow_warnings"] or defaults["jln-shadow-warnings"] or "default") end
  newoption{trigger="jln-stack-protector", allowed={{"default"}, {"off"}, {"on"}, {"strong"}, {"all"}}, description="stack_protector"}
  if not _OPTIONS["jln-stack-protector"] then _OPTIONS["jln-stack-protector"] = (defaults["stack_protector"] or defaults["jln-stack-protector"] or "default") end
  newoption{trigger="jln-stl-debug", allowed={{"default"}, {"off"}, {"on"}, {"allow_broken_abi"}, {"allow_broken_abi_and_bugs"}, {"assert_as_exception"}}, description="stl_debug"}
  if not _OPTIONS["jln-stl-debug"] then _OPTIONS["jln-stl-debug"] = (defaults["stl_debug"] or defaults["jln-stl-debug"] or "default") end
  newoption{trigger="jln-stl-fix", allowed={{"default"}, {"off"}, {"on"}}, description="stl_fix"}
  if not _OPTIONS["jln-stl-fix"] then _OPTIONS["jln-stl-fix"] = (defaults["stl_fix"] or defaults["jln-stl-fix"] or "default") end
  newoption{trigger="jln-suggestions", allowed={{"default"}, {"off"}, {"on"}}, description="suggestions"}
  if not _OPTIONS["jln-suggestions"] then _OPTIONS["jln-suggestions"] = (defaults["suggestions"] or defaults["jln-suggestions"] or "default") end
  newoption{trigger="jln-warnings", allowed={{"default"}, {"off"}, {"on"}, {"strict"}, {"very_strict"}}, description="warnings"}
  if not _OPTIONS["jln-warnings"] then _OPTIONS["jln-warnings"] = (defaults["warnings"] or defaults["jln-warnings"] or "default") end
  newoption{trigger="jln-warnings-as-error", allowed={{"default"}, {"off"}, {"on"}, {"basic"}}, description="warnings_as_error"}
  if not _OPTIONS["jln-warnings-as-error"] then _OPTIONS["jln-warnings-as-error"] = (defaults["warnings_as_error"] or defaults["jln-warnings-as-error"] or "default") end
  newoption{trigger="jln-whole-program", allowed={{"default"}, {"off"}, {"on"}, {"strip_all"}}, description="whole_program"}
  if not _OPTIONS["jln-whole-program"] then _OPTIONS["jln-whole-program"] = (defaults["whole_program"] or defaults["jln-whole-program"] or "default") end
  newoption{trigger="jln-compiler", description="Path or name of the compiler"}
  newoption{trigger="jln-compiler-version", description="Force the compiler version"}
end

function jln_check_flag_names(t)
  for k in pairs(t) do
    if not _jln_flag_names[k] then
      error("unknown '" .. k .. "' jln flag name")
    end
  end
end

-- same as jln_getoptions
function jln_setoptions(compiler, version, values, disable_others, print_compiler)
  local options = jln_getoptions(compiler, version, values, disable_others, print_compiler)
  buildoptions(options.buildoptions)
  linkoptions(options.linkoptions)
  return options
end

-- jln_getoptions(values, disable_others = nil, print_compiler = nil)
-- jln_getoptions(compiler, version = nil, values = nil, disable_others = nil, print_compiler = nil)
-- `= nil` indicates that the value is optional and can be nil
-- `compiler`: string. ex: 'gcc', 'g++', 'clang++', 'clang'. Or compiler and linker with semicolon separator. ex: 'clang-cl;lld-link'
-- `version`: string. Compiler version. ex: '7', '7.2'
-- `values`: table. ex: {warnings='on'}
-- `disable_others`: boolean
-- `print_compiler`: boolean
-- return {buildoptions=string, linkoptions=string}
function jln_getoptions(compiler, version, values, disable_others, print_compiler)
  local linker

  if compiler and type(compiler) ~= 'string' then
    values, disable_others, print_compiler, compiler, version = compiler, version, values, nil, nil
  end

  if not compiler then
    compiler = _OPTIONS['jln-compiler'] or _OPTIONS['cc'] or 'g++'
    version = _OPTIONS['jln-compiler-version'] or nil
  else
    local s, new_compiler, new_linker = compiler:match'(([^;]);(.*))'
    if s then
      compiler = new_compiler
      linker = new_linker
    end
  end

  local compversion = {}
  if not version then
     local output = os.outputof(compiler .. " --version")
     if output then
       output = output:sub(0, output:find('\n') or #output)
       version = output:gsub(".*(%d+%.%d+%.%d+).*", "%1")
     else
       printf("WARNING: `%s --version` failed", compiler)
       output = compiler:gmatch(".*%-(%d+%.?%d*%.?%d*)$")()
       if output then
         version = output
         printf("Extract version %s of the compiler name", version)
       end
     end
  end

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

  if not compiler then
    printf("WARNING: unknown compiler")
    return {buildoptions='', linkoptions=''}
  end

  if not version then
    version = tostring(tonumber(os.date("%y")) - (compiler == 'clang' and 14 or 12))
  end

  if print_compiler then
    printf("getoptions: compiler: %s, version: %s", compiler, version)
  end

  for i in version:gmatch("%d+") do
    compversion[#compversion+1] = tonumber(i)
  end
  if not compversion[1] then
    printf("WARNING: wrong version format")
    return {buildoptions='', linkoptions=''}
  end
  compversion = compversion[1] * 100 + (compversion[2] or 0)

  if values then
    jln_check_flag_names(values)
    local name_list = {}
    local new_value = {}
    name_list["jln-color"] = true
    name_list["color"] = true
    new_value["jln-color"] = values["color"] or values["jln-color"] or (disable_others and "default" or _OPTIONS["jln-color"])
    name_list["jln-control-flow"] = true
    name_list["control_flow"] = true
    new_value["jln-control-flow"] = values["control_flow"] or values["jln-control-flow"] or (disable_others and "default" or _OPTIONS["jln-control-flow"])
    name_list["jln-coverage"] = true
    name_list["coverage"] = true
    new_value["jln-coverage"] = values["coverage"] or values["jln-coverage"] or (disable_others and "default" or _OPTIONS["jln-coverage"])
    name_list["jln-cpu"] = true
    name_list["cpu"] = true
    new_value["jln-cpu"] = values["cpu"] or values["jln-cpu"] or (disable_others and "default" or _OPTIONS["jln-cpu"])
    name_list["jln-debug"] = true
    name_list["debug"] = true
    new_value["jln-debug"] = values["debug"] or values["jln-debug"] or (disable_others and "default" or _OPTIONS["jln-debug"])
    name_list["jln-diagnostics-format"] = true
    name_list["diagnostics_format"] = true
    new_value["jln-diagnostics-format"] = values["diagnostics_format"] or values["jln-diagnostics-format"] or (disable_others and "default" or _OPTIONS["jln-diagnostics-format"])
    name_list["jln-diagnostics-show-template-tree"] = true
    name_list["diagnostics_show_template_tree"] = true
    new_value["jln-diagnostics-show-template-tree"] = values["diagnostics_show_template_tree"] or values["jln-diagnostics-show-template-tree"] or (disable_others and "default" or _OPTIONS["jln-diagnostics-show-template-tree"])
    name_list["jln-elide-type"] = true
    name_list["elide_type"] = true
    new_value["jln-elide-type"] = values["elide_type"] or values["jln-elide-type"] or (disable_others and "default" or _OPTIONS["jln-elide-type"])
    name_list["jln-exceptions"] = true
    name_list["exceptions"] = true
    new_value["jln-exceptions"] = values["exceptions"] or values["jln-exceptions"] or (disable_others and "default" or _OPTIONS["jln-exceptions"])
    name_list["jln-fix-compiler-error"] = true
    name_list["fix_compiler_error"] = true
    new_value["jln-fix-compiler-error"] = values["fix_compiler_error"] or values["jln-fix-compiler-error"] or (disable_others and "default" or _OPTIONS["jln-fix-compiler-error"])
    name_list["jln-linker"] = true
    name_list["linker"] = true
    new_value["jln-linker"] = values["linker"] or values["jln-linker"] or (disable_others and "default" or _OPTIONS["jln-linker"])
    name_list["jln-lto"] = true
    name_list["lto"] = true
    new_value["jln-lto"] = values["lto"] or values["jln-lto"] or (disable_others and "default" or _OPTIONS["jln-lto"])
    name_list["jln-msvc-isystem"] = true
    name_list["msvc_isystem"] = true
    new_value["jln-msvc-isystem"] = values["msvc_isystem"] or values["jln-msvc-isystem"] or (disable_others and "default" or _OPTIONS["jln-msvc-isystem"])
    name_list["jln-msvc-isystem-with-template-from-non-external"] = true
    name_list["msvc_isystem_with_template_from_non_external"] = true
    new_value["jln-msvc-isystem-with-template-from-non-external"] = values["msvc_isystem_with_template_from_non_external"] or values["jln-msvc-isystem-with-template-from-non-external"] or (disable_others and "default" or _OPTIONS["jln-msvc-isystem-with-template-from-non-external"])
    name_list["jln-optimization"] = true
    name_list["optimization"] = true
    new_value["jln-optimization"] = values["optimization"] or values["jln-optimization"] or (disable_others and "default" or _OPTIONS["jln-optimization"])
    name_list["jln-pedantic"] = true
    name_list["pedantic"] = true
    new_value["jln-pedantic"] = values["pedantic"] or values["jln-pedantic"] or (disable_others and "default" or _OPTIONS["jln-pedantic"])
    name_list["jln-pie"] = true
    name_list["pie"] = true
    new_value["jln-pie"] = values["pie"] or values["jln-pie"] or (disable_others and "default" or _OPTIONS["jln-pie"])
    name_list["jln-relro"] = true
    name_list["relro"] = true
    new_value["jln-relro"] = values["relro"] or values["jln-relro"] or (disable_others and "default" or _OPTIONS["jln-relro"])
    name_list["jln-reproducible-build-warnings"] = true
    name_list["reproducible_build_warnings"] = true
    new_value["jln-reproducible-build-warnings"] = values["reproducible_build_warnings"] or values["jln-reproducible-build-warnings"] or (disable_others and "default" or _OPTIONS["jln-reproducible-build-warnings"])
    name_list["jln-rtti"] = true
    name_list["rtti"] = true
    new_value["jln-rtti"] = values["rtti"] or values["jln-rtti"] or (disable_others and "default" or _OPTIONS["jln-rtti"])
    name_list["jln-sanitizers"] = true
    name_list["sanitizers"] = true
    new_value["jln-sanitizers"] = values["sanitizers"] or values["jln-sanitizers"] or (disable_others and "default" or _OPTIONS["jln-sanitizers"])
    name_list["jln-sanitizers-extra"] = true
    name_list["sanitizers_extra"] = true
    new_value["jln-sanitizers-extra"] = values["sanitizers_extra"] or values["jln-sanitizers-extra"] or (disable_others and "default" or _OPTIONS["jln-sanitizers-extra"])
    name_list["jln-shadow-warnings"] = true
    name_list["shadow_warnings"] = true
    new_value["jln-shadow-warnings"] = values["shadow_warnings"] or values["jln-shadow-warnings"] or (disable_others and "default" or _OPTIONS["jln-shadow-warnings"])
    name_list["jln-stack-protector"] = true
    name_list["stack_protector"] = true
    new_value["jln-stack-protector"] = values["stack_protector"] or values["jln-stack-protector"] or (disable_others and "default" or _OPTIONS["jln-stack-protector"])
    name_list["jln-stl-debug"] = true
    name_list["stl_debug"] = true
    new_value["jln-stl-debug"] = values["stl_debug"] or values["jln-stl-debug"] or (disable_others and "default" or _OPTIONS["jln-stl-debug"])
    name_list["jln-stl-fix"] = true
    name_list["stl_fix"] = true
    new_value["jln-stl-fix"] = values["stl_fix"] or values["jln-stl-fix"] or (disable_others and "default" or _OPTIONS["jln-stl-fix"])
    name_list["jln-suggestions"] = true
    name_list["suggestions"] = true
    new_value["jln-suggestions"] = values["suggestions"] or values["jln-suggestions"] or (disable_others and "default" or _OPTIONS["jln-suggestions"])
    name_list["jln-warnings"] = true
    name_list["warnings"] = true
    new_value["jln-warnings"] = values["warnings"] or values["jln-warnings"] or (disable_others and "default" or _OPTIONS["jln-warnings"])
    name_list["jln-warnings-as-error"] = true
    name_list["warnings_as_error"] = true
    new_value["jln-warnings-as-error"] = values["warnings_as_error"] or values["jln-warnings-as-error"] or (disable_others and "default" or _OPTIONS["jln-warnings-as-error"])
    name_list["jln-whole-program"] = true
    name_list["whole_program"] = true
    new_value["jln-whole-program"] = values["whole_program"] or values["jln-whole-program"] or (disable_others and "default" or _OPTIONS["jln-whole-program"])
    values = new_value
  else
    values = _OPTIONS
  end

  local jln_buildoptions, jln_linkoptions = '', ''

  if ( compiler == "gcc" or compiler == "clang" or compiler == "clang-cl" ) then
    if not ( values["jln-warnings"] == "default") then
      if values["jln-warnings"] == "off" then
        jln_buildoptions = jln_buildoptions .. " -w"
      else
        if compiler == "gcc" then
          jln_buildoptions = jln_buildoptions .. " -Wall -Wextra -Wcast-align=strict -Wcast-qual -Wdisabled-optimization -Wfloat-equal -Wformat-security -Wformat=2 -Wmissing-include-dirs -Wpacked -Wredundant-decls -Wundef -Wunused-macros -Winvalid-pch -Wpointer-arith -Wmissing-declarations -Wnon-virtual-dtor -Wold-style-cast -Woverloaded-virtual"
          if not ( compversion < 407 ) then
            jln_buildoptions = jln_buildoptions .. " -Wsuggest-attribute=noreturn -Wzero-as-null-pointer-constant -Wlogical-op -Wvector-operation-performance -Wdouble-promotion -Wtrampolines"
            if not ( compversion < 408 ) then
              jln_buildoptions = jln_buildoptions .. " -Wuseless-cast"
              if not ( compversion < 409 ) then
                jln_buildoptions = jln_buildoptions .. " -Wconditionally-supported -Wfloat-conversion"
                if not ( compversion < 501 ) then
                  jln_buildoptions = jln_buildoptions .. " -Wformat-signedness -Warray-bounds=2 -Wstrict-null-sentinel -Wsuggest-override"
                  if not ( compversion < 601 ) then
                    jln_buildoptions = jln_buildoptions .. " -Wduplicated-cond -Wnull-dereference"
                    if not ( compversion < 700 ) then
                      jln_buildoptions = jln_buildoptions .. " -Waligned-new"
                      if not ( compversion < 701 ) then
                        jln_buildoptions = jln_buildoptions .. " -Walloc-zero -Walloca -Wformat-overflow=2 -Wduplicated-branches"
                        if not ( compversion < 800 ) then
                          jln_buildoptions = jln_buildoptions .. " -Wclass-memaccess"
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
            jln_buildoptions = jln_buildoptions .. " -Weverything -Wno-documentation -Wno-documentation-unknown-command -Wno-newline-eof -Wno-c++98-compat -Wno-c++98-compat-pedantic -Wno-mismatched-tags -Wno-padded -Wno-global-constructors -Wno-weak-vtables -Wno-exit-time-destructors -Wno-covered-switch-default -Wno-switch-default -Wno-switch-enum"
            if not ( compversion < 309 ) then
              jln_buildoptions = jln_buildoptions .. " -Wno-undefined-var-template"
              if not ( compversion < 500 ) then
                jln_buildoptions = jln_buildoptions .. " -Wno-inconsistent-missing-destructor-override"
                if not ( compversion < 900 ) then
                  jln_buildoptions = jln_buildoptions .. " -Wno-ctad-maybe-unsupported"
                end
              end
            end
          end
        end
        if ( values["jln-warnings"] == "strict" or values["jln-warnings"] == "very-strict" ) then
          jln_buildoptions = jln_buildoptions .. " -Wconversion"
          if ( compiler == "gcc" and not ( compversion < 800 ) ) then
            jln_buildoptions = jln_buildoptions .. " -Wcast-align=strict"
          end
        else
          if ( compiler == "clang" or compiler == "clang-cl" ) then
            jln_buildoptions = jln_buildoptions .. " -Wno-conversion -Wno-sign-conversion"
          end
        end
      end
    end
    if not ( values["jln-warnings-as-error"] == "default") then
      if values["jln-warnings-as-error"] == "on" then
        jln_buildoptions = jln_buildoptions .. " -Werror"
      else
        if values["jln-warnings-as-error"] == "basic" then
          jln_buildoptions = jln_buildoptions .. " -Werror=return-type -Werror=init-self"
          if ( compiler == "gcc" and not ( compversion < 501 ) ) then
            jln_buildoptions = jln_buildoptions .. " -Werror=array-bounds -Werror=logical-op -Werror=logical-not-parentheses"
          else
            if ( compiler == "clang" or compiler == "clang-cl" ) then
              jln_buildoptions = jln_buildoptions .. " -Werror=array-bounds -Werror=division-by-zero"
              if not ( compversion < 304 ) then
                jln_buildoptions = jln_buildoptions .. " -Werror=logical-not-parentheses"
                if not ( compversion < 306 ) then
                  jln_buildoptions = jln_buildoptions .. " -Werror=delete-incomplete"
                  if not ( compversion < 700 ) then
                    jln_buildoptions = jln_buildoptions .. " -Werror=dynamic-class-memaccess"
                  end
                end
              end
            end
          end
        else
          jln_buildoptions = jln_buildoptions .. " -Wno-error"
        end
      end
    end
    if not ( values["jln-suggestions"] == "default") then
      if not ( values["jln-suggestions"] == "off" ) then
        if compiler == "gcc" then
          jln_buildoptions = jln_buildoptions .. " -Wsuggest-attribute=pure -Wsuggest-attribute=const"
          if not ( compversion < 500 ) then
            jln_buildoptions = jln_buildoptions .. " -Wsuggest-final-types -Wsuggest-final-methods"
            if not ( compversion < 501 ) then
              jln_buildoptions = jln_buildoptions .. " -Wnoexcept"
            end
          end
        end
      end
    end
    if not ( values["jln-sanitizers"] == "default") then
      if values["jln-sanitizers"] == "off" then
        jln_buildoptions = jln_buildoptions .. " -fno-sanitize=all"
        jln_linkoptions = jln_linkoptions .. " -fno-sanitize=all"
      else
        if compiler == "clang-cl" then
          jln_buildoptions = jln_buildoptions .. " -fsanitize=undefined -fsanitize=address -fsanitize-address-use-after-scope"
        else
          if compiler == "clang" then
            if not ( compversion < 301 ) then
              jln_buildoptions = jln_buildoptions .. " -fsanitize=undefined -fsanitize=address -fsanitize-address-use-after-scope -fno-omit-frame-pointer -fno-optimize-sibling-calls"
              jln_linkoptions = jln_linkoptions .. " -fsanitize=undefined -fsanitize=address"
              if not ( compversion < 304 ) then
                jln_buildoptions = jln_buildoptions .. " -fsanitize=leak"
                jln_linkoptions = jln_linkoptions .. " -fsanitize=leak"
              end
            end
          else
            if compiler == "gcc" then
              if not ( compversion < 408 ) then
                jln_buildoptions = jln_buildoptions .. " -fsanitize=address -fno-omit-frame-pointer -fno-optimize-sibling-calls"
                jln_linkoptions = jln_linkoptions .. " -fsanitize=address"
                if not ( compversion < 409 ) then
                  jln_buildoptions = jln_buildoptions .. " -fsanitize=undefined -fsanitize=leak"
                  jln_linkoptions = jln_linkoptions .. " -fsanitize=undefined -fsanitize=leak"
                end
              end
            end
          end
        end
      end
    end
    if not ( values["jln-control-flow"] == "default") then
      if values["jln-control-flow"] == "off" then
        if ( compiler == "gcc" and not ( compversion < 800 ) ) then
          jln_buildoptions = jln_buildoptions .. " -fcf-protection=none"
        else
          if compiler == "clang-cl" then
            jln_buildoptions = jln_buildoptions .. " -fcf-protection=none -fno-sanitize-cfi-cross-dso"
          end
        end
        if compiler == "clang" then
          jln_buildoptions = jln_buildoptions .. " -fno-sanitize=cfi"
          jln_linkoptions = jln_linkoptions .. " -fno-sanitize=cfi"
        end
      else
        if ( ( compiler == "gcc" and not ( compversion < 800 ) ) or compiler == "clang-cl" ) then
          if values["jln-control-flow"] == "branch" then
            jln_buildoptions = jln_buildoptions .. " -fcf-protection=branch"
          else
            if values["jln-control-flow"] == "return" then
              jln_buildoptions = jln_buildoptions .. " -fcf-protection=return"
            else
              jln_buildoptions = jln_buildoptions .. " -fcf-protection=full"
            end
          end
        else
          if ( values["jln-control-flow"] == "allow-bugs" and compiler == "clang" ) then
            jln_buildoptions = jln_buildoptions .. " -fsanitize=cfi -fvisibility=hidden -flto"
            jln_linkoptions = jln_linkoptions .. " -fsanitize=cfi -flto"
          end
        end
      end
    end
    if not ( values["jln-color"] == "default") then
      if ( ( compiler == "gcc" and not ( compversion < 409 ) ) or compiler == "clang" or compiler == "clang-cl" ) then
        if values["jln-color"] == "auto" then
          jln_buildoptions = jln_buildoptions .. " -fdiagnostics-color=auto"
        else
          if values["jln-color"] == "never" then
            jln_buildoptions = jln_buildoptions .. " -fdiagnostics-color=never"
          else
            if values["jln-color"] == "always" then
              jln_buildoptions = jln_buildoptions .. " -fdiagnostics-color=always"
            end
          end
        end
      end
    end
    if not ( values["jln-reproducible-build-warnings"] == "default") then
      if ( compiler == "gcc" and not ( compversion < 409 ) ) then
        if values["jln-reproducible-build-warnings"] == "on" then
          jln_buildoptions = jln_buildoptions .. " -Wdate-time"
        else
          jln_buildoptions = jln_buildoptions .. " -Wno-date-time"
        end
      end
    end
    if not ( values["jln-diagnostics-format"] == "default") then
      if values["jln-diagnostics-format"] == "fixits" then
        if ( ( compiler == "gcc" and not ( compversion < 700 ) ) or ( compiler == "clang" and not ( compversion < 500 ) ) or ( compiler == "clang-cl" and not ( compversion < 500 ) ) ) then
          jln_buildoptions = jln_buildoptions .. " -fdiagnostics-parseable-fixits"
        end
      else
        if values["jln-diagnostics-format"] == "patch" then
          if ( compiler == "gcc" and not ( compversion < 700 ) ) then
            jln_buildoptions = jln_buildoptions .. " -fdiagnostics-generate-patch"
          end
        else
          if values["jln-diagnostics-format"] == "print-source-range-info" then
            if compiler == "clang" then
              jln_buildoptions = jln_buildoptions .. " -fdiagnostics-print-source-range-info"
            end
          end
        end
      end
    end
    if not ( values["jln-fix-compiler-error"] == "default") then
      if values["jln-fix-compiler-error"] == "on" then
        if compiler == "gcc" then
          if not ( compversion < 407 ) then
            jln_buildoptions = jln_buildoptions .. " -Werror=narrowing"
            if not ( compversion < 701 ) then
              jln_buildoptions = jln_buildoptions .. " -Werror=literal-suffix"
            end
          end
        end
        jln_buildoptions = jln_buildoptions .. " -Werror=write-strings"
      else
        if ( compiler == "clang" or compiler == "clang-cl" ) then
          jln_buildoptions = jln_buildoptions .. " -Wno-error=c++11-narrowing -Wno-reserved-user-defined-literal"
        end
      end
    end
  end
  if ( compiler == "gcc" or compiler == "clang" ) then
    if not ( values["jln-coverage"] == "default") then
      if values["jln-coverage"] == "on" then
        jln_buildoptions = jln_buildoptions .. " --coverage"
        jln_linkoptions = jln_linkoptions .. " --coverage"
        if compiler == "clang" then
          jln_linkoptions = jln_linkoptions .. " -lprofile_rt"
        end
      end
    end
    if not ( values["jln-debug"] == "default") then
      if values["jln-debug"] == "off" then
        jln_buildoptions = jln_buildoptions .. " -g0"
      else
        if values["jln-debug"] == "gdb" then
          jln_buildoptions = jln_buildoptions .. " -ggdb"
        else
          if compiler == "clang" then
            if values["jln-debug"] == "line-tables-only" then
              jln_buildoptions = jln_buildoptions .. " -gline-tables-only"
            end
            if values["jln-debug"] == "lldb" then
              jln_buildoptions = jln_buildoptions .. " -glldb"
            else
              if values["jln-debug"] == "sce" then
                jln_buildoptions = jln_buildoptions .. " -gsce"
              else
                jln_buildoptions = jln_buildoptions .. " -g"
              end
            end
          else
            jln_buildoptions = jln_buildoptions .. " -g"
          end
        end
      end
    end
    if not ( values["jln-linker"] == "default") then
      if values["jln-linker"] == "native" then
        if compiler == "gcc" then
          jln_linkoptions = jln_linkoptions .. " -fuse-ld=gold"
        else
          jln_linkoptions = jln_linkoptions .. " -fuse-ld=lld"
        end
      else
        if values["jln-linker"] == "bfd" then
          jln_linkoptions = jln_linkoptions .. " -fuse-ld=bfd"
        else
          if ( values["jln-linker"] == "gold" or ( compiler == "gcc" and not ( not ( compversion < 900 ) ) ) ) then
            jln_linkoptions = jln_linkoptions .. " -fuse-ld=gold"
          else
            if not ( values["jln-lto"] == "default") then
              if ( not ( values["jln-lto"] == "off" ) and compiler == "gcc" ) then
                jln_linkoptions = jln_linkoptions .. " -fuse-ld=gold"
              else
                jln_linkoptions = jln_linkoptions .. " -fuse-ld=lld"
              end
            else
              jln_linkoptions = jln_linkoptions .. " -fuse-ld=lld"
            end
          end
        end
      end
    end
    if not ( values["jln-lto"] == "default") then
      if values["jln-lto"] == "off" then
        jln_buildoptions = jln_buildoptions .. " -fno-lto"
        jln_linkoptions = jln_linkoptions .. " -fno-lto"
      else
        if compiler == "gcc" then
          jln_buildoptions = jln_buildoptions .. " -flto"
          jln_linkoptions = jln_linkoptions .. " -flto"
          if not ( compversion < 500 ) then
            if not ( values["jln-warnings"] == "default") then
              if not ( values["jln-warnings"] == "off" ) then
                jln_buildoptions = jln_buildoptions .. " -flto-odr-type-merging"
                jln_linkoptions = jln_linkoptions .. " -flto-odr-type-merging"
              end
            end
            if values["jln-lto"] == "fat" then
              jln_buildoptions = jln_buildoptions .. " -ffat-lto-objects"
            else
              if values["jln-lto"] == "thin" then
                jln_linkoptions = jln_linkoptions .. " -fuse-linker-plugin"
              end
            end
          end
        else
          if ( values["jln-lto"] == "thin" and compiler == "clang" and not ( compversion < 600 ) ) then
            jln_buildoptions = jln_buildoptions .. " -flto=thin"
            jln_linkoptions = jln_linkoptions .. " -flto=thin"
          else
            jln_buildoptions = jln_buildoptions .. " -flto"
            jln_linkoptions = jln_linkoptions .. " -flto"
          end
        end
      end
    end
    if not ( values["jln-optimization"] == "default") then
      if values["jln-optimization"] == "0" then
        jln_buildoptions = jln_buildoptions .. " -O0"
        jln_linkoptions = jln_linkoptions .. " -O0"
      else
        if values["jln-optimization"] == "g" then
          jln_buildoptions = jln_buildoptions .. " -Og"
          jln_linkoptions = jln_linkoptions .. " -Og"
        else
          jln_buildoptions = jln_buildoptions .. " -DNDEBUG"
          if values["jln-optimization"] == "size" then
            jln_buildoptions = jln_buildoptions .. " -Os"
            jln_linkoptions = jln_linkoptions .. " -Os"
          else
            if values["jln-optimization"] == "fast" then
              jln_buildoptions = jln_buildoptions .. " -Ofast"
              jln_linkoptions = jln_linkoptions .. " -Ofast"
            else
              if values["jln-optimization"] == "1" then
                jln_buildoptions = jln_buildoptions .. " -O1"
                jln_linkoptions = jln_linkoptions .. " -O1"
              else
                if values["jln-optimization"] == "2" then
                  jln_buildoptions = jln_buildoptions .. " -O2"
                  jln_linkoptions = jln_linkoptions .. " -O2"
                else
                  if values["jln-optimization"] == "3" then
                    jln_buildoptions = jln_buildoptions .. " -O3"
                    jln_linkoptions = jln_linkoptions .. " -O3"
                  end
                end
              end
            end
          end
        end
      end
    end
    if not ( values["jln-cpu"] == "default") then
      if values["jln-cpu"] == "generic" then
        jln_buildoptions = jln_buildoptions .. " -mtune=generic"
        jln_linkoptions = jln_linkoptions .. " -mtune=generic"
      else
        jln_buildoptions = jln_buildoptions .. " -march=native -mtune=native"
        jln_linkoptions = jln_linkoptions .. " -march=native -mtune=native"
      end
    end
    if not ( values["jln-whole-program"] == "default") then
      if values["jln-whole-program"] == "off" then
        jln_buildoptions = jln_buildoptions .. " -fno-whole-program"
        if ( compiler == "clang" and not ( compversion < 309 ) ) then
          jln_buildoptions = jln_buildoptions .. " -fno-whole-program-vtables"
          jln_linkoptions = jln_linkoptions .. " -fno-whole-program-vtables"
        end
      else
        if linker == "ld64" then
          jln_linkoptions = jln_linkoptions .. " -Wl,-dead_strip -Wl,-S"
        else
          jln_linkoptions = jln_linkoptions .. " -s"
          if values["jln-whole-program"] == "strip-all" then
            jln_linkoptions = jln_linkoptions .. " -Wl,--gc-sections -Wl,--strip-all"
          end
        end
        if compiler == "gcc" then
          jln_buildoptions = jln_buildoptions .. " -fwhole-program"
          jln_linkoptions = jln_linkoptions .. " -fwhole-program"
        else
          if compiler == "clang" then
            if not ( compversion < 309 ) then
              if not ( values["jln-lto"] == "default") then
                if not ( values["jln-lto"] == "off" ) then
                  jln_buildoptions = jln_buildoptions .. " -fwhole-program-vtables"
                  jln_linkoptions = jln_linkoptions .. " -fwhole-program-vtables"
                end
              end
              if not ( compversion < 700 ) then
                jln_buildoptions = jln_buildoptions .. " -fforce-emit-vtables"
                jln_linkoptions = jln_linkoptions .. " -fforce-emit-vtables"
              end
            end
          end
        end
      end
    end
    if not ( values["jln-pedantic"] == "default") then
      if not ( values["jln-pedantic"] == "off" ) then
        jln_buildoptions = jln_buildoptions .. " -pedantic"
        if values["jln-pedantic"] == "as-error" then
          jln_buildoptions = jln_buildoptions .. " -pedantic-errors"
        end
      end
    end
    if not ( values["jln-stack-protector"] == "default") then
      if values["jln-stack-protector"] == "off" then
        jln_buildoptions = jln_buildoptions .. " -Wno-stack-protector -U_FORTIFY_SOURCE"
        jln_linkoptions = jln_linkoptions .. " -Wno-stack-protector"
      else
        jln_buildoptions = jln_buildoptions .. " -D_FORTIFY_SOURCE=2 -Wstack-protector"
        if values["jln-stack-protector"] == "strong" then
          if ( compiler == "gcc" and not ( compversion < 409 ) ) then
            jln_buildoptions = jln_buildoptions .. " -fstack-protector-strong"
            jln_linkoptions = jln_linkoptions .. " -fstack-protector-strong"
          else
            if compiler == "clang" then
              jln_buildoptions = jln_buildoptions .. " -fstack-protector-strong -fsanitize=safe-stack"
              jln_linkoptions = jln_linkoptions .. " -fstack-protector-strong -fsanitize=safe-stack"
            end
          end
        else
          if values["jln-stack-protector"] == "all" then
            jln_buildoptions = jln_buildoptions .. " -fstack-protector-all"
            jln_linkoptions = jln_linkoptions .. " -fstack-protector-all"
            if compiler == "clang" then
              jln_buildoptions = jln_buildoptions .. " -fsanitize=safe-stack"
              jln_linkoptions = jln_linkoptions .. " -fsanitize=safe-stack"
              if not ( compversion < 1100 ) then
                jln_buildoptions = jln_buildoptions .. " -fstack-clash-protection"
                jln_linkoptions = jln_linkoptions .. " -fstack-clash-protection"
              end
            end
          else
            jln_buildoptions = jln_buildoptions .. " -fstack-protector"
            jln_linkoptions = jln_linkoptions .. " -fstack-protector"
          end
        end
        if compiler == "clang" then
          jln_buildoptions = jln_buildoptions .. " -fsanitize=shadow-call-stack"
          jln_linkoptions = jln_linkoptions .. " -fsanitize=shadow-call-stack"
        end
      end
    end
    if not ( values["jln-relro"] == "default") then
      if values["jln-relro"] == "off" then
        jln_linkoptions = jln_linkoptions .. " -Wl,-z,norelro"
      else
        if values["jln-relro"] == "on" then
          jln_linkoptions = jln_linkoptions .. " -Wl,-z,relro"
        else
          if values["jln-relro"] == "full" then
            jln_linkoptions = jln_linkoptions .. " -Wl,-z,relro,-z,now"
          end
        end
      end
    end
    if not ( values["jln-pie"] == "default") then
      if values["jln-pie"] == "off" then
        jln_linkoptions = jln_linkoptions .. " -no-pic"
      else
        if values["jln-pie"] == "on" then
          jln_linkoptions = jln_linkoptions .. " -pie"
        else
          if values["jln-pie"] == "pic" then
            jln_buildoptions = jln_buildoptions .. " -fPIC"
          end
        end
      end
    end
    if not ( values["jln-stl-debug"] == "default") then
      if not ( values["jln-stl-debug"] == "off" ) then
        if values["jln-stl-debug"] == "assert-as-exception" then
          jln_buildoptions = jln_buildoptions .. " -D_LIBCPP_DEBUG_USE_EXCEPTIONS"
        end
        if ( values["jln-stl-debug"] == "allow-broken-abi" or values["jln-stl-debug"] == "allow-broken-abi-and-bugs" ) then
          if compiler == "clang" then
            if ( not ( compversion < 800 ) or values["jln-stl-debug"] == "allow-broken-abi-and-bugs" ) then
              jln_buildoptions = jln_buildoptions .. " -D_LIBCPP_DEBUG=1"
            end
          end
          jln_buildoptions = jln_buildoptions .. " -D_GLIBCXX_DEBUG"
        else
          jln_buildoptions = jln_buildoptions .. " -D_GLIBCXX_ASSERTIONS"
        end
        if not ( values["jln-pedantic"] == "default") then
          if not ( values["jln-pedantic"] == "off" ) then
            jln_buildoptions = jln_buildoptions .. " -D_GLIBCXX_DEBUG_PEDANTIC"
          end
        end
      end
    end
    if not ( values["jln-shadow-warnings"] == "default") then
      if values["jln-shadow-warnings"] == "off" then
        jln_buildoptions = jln_buildoptions .. " -Wno-shadow"
        if ( compiler == "clang" and not ( compversion < 800 ) ) then
          jln_buildoptions = jln_buildoptions .. " -Wno-shadow-field"
        end
      else
        if values["jln-shadow-warnings"] == "on" then
          jln_buildoptions = jln_buildoptions .. " -Wshadow"
        else
          if values["jln-shadow-warnings"] == "all" then
            if compiler == "clang" then
              jln_buildoptions = jln_buildoptions .. " -Wshadow-all"
            else
              jln_buildoptions = jln_buildoptions .. " -Wshadow"
            end
          else
            if ( compiler == "gcc" and not ( compversion < 701 ) ) then
              if values["jln-shadow-warnings"] == "local" then
                jln_buildoptions = jln_buildoptions .. " -Wshadow=local"
              else
                if values["jln-shadow-warnings"] == "compatible-local" then
                  jln_buildoptions = jln_buildoptions .. " -Wshadow=compatible-local"
                end
              end
            end
          end
        end
      end
    end
    if not ( values["jln-elide-type"] == "default") then
      if values["jln-elide-type"] == "on" then
        if ( compiler == "gcc" and not ( compversion < 800 ) ) then
          jln_buildoptions = jln_buildoptions .. " -felide-type"
        end
      else
        if ( ( compiler == "gcc" and not ( compversion < 800 ) ) or ( compiler == "clang" and not ( compversion < 304 ) ) ) then
          jln_buildoptions = jln_buildoptions .. " -fno-elide-type"
        end
      end
    end
    if not ( values["jln-exceptions"] == "default") then
      if values["jln-exceptions"] == "on" then
        jln_buildoptions = jln_buildoptions .. " -fexceptions"
      else
        jln_buildoptions = jln_buildoptions .. " -fno-exceptions"
      end
    end
    if not ( values["jln-rtti"] == "default") then
      if values["jln-rtti"] == "on" then
        jln_buildoptions = jln_buildoptions .. " -frtti"
      else
        jln_buildoptions = jln_buildoptions .. " -fno-rtti"
      end
    end
    if not ( values["jln-diagnostics-show-template-tree"] == "default") then
      if ( ( compiler == "gcc" and not ( compversion < 800 ) ) or compiler == "clang" ) then
        if values["jln-diagnostics-show-template-tree"] == "on" then
          jln_buildoptions = jln_buildoptions .. " -fdiagnostics-show-template-tree"
        else
          jln_buildoptions = jln_buildoptions .. " -fno-diagnostics-show-template-tree"
        end
      end
    end
    if not ( values["jln-sanitizers-extra"] == "default") then
      if values["jln-sanitizers-extra"] == "thread" then
        jln_buildoptions = jln_buildoptions .. " -fsanitize=thread"
      else
        if values["jln-sanitizers-extra"] == "pointer" then
          if ( compiler == "gcc" and not ( compversion < 800 ) ) then
            jln_buildoptions = jln_buildoptions .. " -fsanitize=pointer-compare -fsanitize=pointer-subtract"
          end
        end
      end
    end
  end
  if linker == "lld-link" then
    if not ( values["jln-lto"] == "default") then
      if values["jln-lto"] == "off" then
        jln_buildoptions = jln_buildoptions .. " -fno-lto"
      else
        if values["jln-lto"] == "thin" then
          jln_buildoptions = jln_buildoptions .. " -flto=thin"
        else
          jln_buildoptions = jln_buildoptions .. " -flto"
          jln_linkoptions = jln_linkoptions .. " -flto"
        end
      end
    end
    if not ( values["jln-whole-program"] == "default") then
      if values["jln-whole-program"] == "off" then
        jln_buildoptions = jln_buildoptions .. " -fno-whole-program"
      else
        if not ( values["jln-lto"] == "default") then
          if not ( values["jln-lto"] == "off" ) then
            jln_buildoptions = jln_buildoptions .. " -fwhole-program-vtables"
            jln_linkoptions = jln_linkoptions .. " -fwhole-program-vtables"
          end
        end
      end
    end
  end
  if ( compiler == "msvc" or compiler == "clang-cl" ) then
    if not ( values["jln-stl-fix"] == "default") then
      if values["jln-stl-fix"] == "on" then
        jln_buildoptions = jln_buildoptions .. " /DNOMINMAX"
      end
    end
    if not ( values["jln-debug"] == "default") then
      if values["jln-debug"] == "off" then
        jln_buildoptions = jln_buildoptions .. " /DEBUG:NONE"
      else
        jln_buildoptions = jln_buildoptions .. " /RTC1 /Od"
        if values["jln-debug"] == "on" then
          jln_buildoptions = jln_buildoptions .. " /DEBUG"
        else
          if values["jln-debug"] == "line-tables-only" then
            jln_buildoptions = jln_buildoptions .. " /DEBUG:FASTLINK"
          end
        end
        if not ( values["jln-optimization"] == "default") then
          if values["jln-optimization"] == "g" then
            jln_buildoptions = jln_buildoptions .. " /Zi"
          else
            if not ( values["jln-whole-program"] == "default") then
              if values["jln-whole-program"] == "off" then
                jln_buildoptions = jln_buildoptions .. " /ZI"
              else
                jln_buildoptions = jln_buildoptions .. " /Zi"
              end
            else
              jln_buildoptions = jln_buildoptions .. " /ZI"
            end
          end
        else
          if not ( values["jln-whole-program"] == "default") then
            if values["jln-whole-program"] == "off" then
              jln_buildoptions = jln_buildoptions .. " /ZI"
            else
              jln_buildoptions = jln_buildoptions .. " /Zi"
            end
          else
            jln_buildoptions = jln_buildoptions .. " /ZI"
          end
        end
      end
    end
    if not ( values["jln-exceptions"] == "default") then
      if values["jln-exceptions"] == "on" then
        jln_buildoptions = jln_buildoptions .. " /EHsc /D_HAS_EXCEPTIONS=1"
      else
        jln_buildoptions = jln_buildoptions .. " /EHs- /D_HAS_EXCEPTIONS=0"
      end
    end
    if not ( values["jln-optimization"] == "default") then
      if values["jln-optimization"] == "0" then
        jln_buildoptions = jln_buildoptions .. " /Ob0 /Od /Oi- /Oy-"
      else
        if values["jln-optimization"] == "g" then
          jln_buildoptions = jln_buildoptions .. " /Ob1"
        else
          jln_buildoptions = jln_buildoptions .. " /DNDEBUG"
          if values["jln-optimization"] == "1" then
            jln_buildoptions = jln_buildoptions .. " /O1"
          else
            if values["jln-optimization"] == "2" then
              jln_buildoptions = jln_buildoptions .. " /O2"
            else
              if values["jln-optimization"] == "3" then
                jln_buildoptions = jln_buildoptions .. " /O2"
              else
                if values["jln-optimization"] == "size" then
                  jln_buildoptions = jln_buildoptions .. " /O1 /Gw"
                else
                  if values["jln-optimization"] == "fast" then
                    jln_buildoptions = jln_buildoptions .. " /O2 /fp:fast"
                  end
                end
              end
            end
          end
        end
      end
    end
    if not ( values["jln-whole-program"] == "default") then
      if values["jln-whole-program"] == "off" then
        jln_buildoptions = jln_buildoptions .. " /GL-"
      else
        jln_buildoptions = jln_buildoptions .. " /GL /Gw"
        jln_linkoptions = jln_linkoptions .. " /LTCG"
        if values["jln-whole-program"] == "strip-all" then
          jln_linkoptions = jln_linkoptions .. " /OPT:REF"
        end
      end
    end
    if not ( values["jln-pedantic"] == "default") then
      if not ( values["jln-pedantic"] == "off" ) then
        jln_buildoptions = jln_buildoptions .. " /permissive- /Zc:__cplusplus"
      end
    end
    if not ( values["jln-rtti"] == "default") then
      if values["jln-rtti"] == "on" then
        jln_buildoptions = jln_buildoptions .. " /GR"
      else
        jln_buildoptions = jln_buildoptions .. " /GR-"
      end
    end
    if not ( values["jln-stl-debug"] == "default") then
      if values["jln-stl-debug"] == "off" then
        jln_buildoptions = jln_buildoptions .. " /D_HAS_ITERATOR_DEBUGGING=0"
      else
        jln_buildoptions = jln_buildoptions .. " /D_DEBUG /D_HAS_ITERATOR_DEBUGGING=1"
      end
    end
    if not ( values["jln-control-flow"] == "default") then
      if values["jln-control-flow"] == "off" then
        jln_buildoptions = jln_buildoptions .. " /guard:cf-"
      else
        jln_buildoptions = jln_buildoptions .. " /guard:cf"
      end
    end
    if not ( values["jln-stack-protector"] == "default") then
      if values["jln-stack-protector"] == "off" then
        jln_buildoptions = jln_buildoptions .. " /GS-"
      else
        jln_buildoptions = jln_buildoptions .. " /GS /sdl"
        if values["jln-stack-protector"] == "strong" then
          jln_buildoptions = jln_buildoptions .. " /RTC1"
        else
          if values["jln-stack-protector"] == "all" then
            jln_buildoptions = jln_buildoptions .. " /RTC1 /RTCc"
          end
        end
      end
    end
  end
  if compiler == "msvc" then
    if not ( values["jln-msvc-isystem"] == "default") then
      jln_buildoptions = jln_buildoptions .. " /experimental:external /external:W0"
      if values["jln-msvc-isystem"] == "anglebrackets" then
        jln_buildoptions = jln_buildoptions .. " /external:anglebrackets"
      else
        jln_buildoptions = jln_buildoptions .. " /external:env:INCLUDE /external:env:CAExcludePath"
      end
      if not ( values["jln-msvc-isystem-with-template-from-non-external"] == "default") then
        if values["jln-msvc-isystem-with-template-from-non-external"] == "off" then
          jln_buildoptions = jln_buildoptions .. " /external:template"
        else
          jln_buildoptions = jln_buildoptions .. " /external:template-"
        end
      end
      if not ( values["jln-warnings"] == "default") then
        if values["jln-warnings"] == "off" then
          jln_buildoptions = jln_buildoptions .. " /W0"
        else
          jln_buildoptions = jln_buildoptions .. " /wd4710 /wd4711"
          if not ( not ( compversion < 1921 ) ) then
            jln_buildoptions = jln_buildoptions .. " /wd4774"
          end
          if values["jln-warnings"] == "on" then
            jln_buildoptions = jln_buildoptions .. " /W4 /wd4244 /wd4245"
          else
            jln_buildoptions = jln_buildoptions .. " /Wall /wd4571 /wd4355 /wd4548 /wd4577 /wd4820 /wd5039 /wd4464 /wd4868 /wd5045"
            if values["jln-warnings"] == "strict" then
              jln_buildoptions = jln_buildoptions .. " /wd4583 /wd4619"
            end
          end
        end
      end
    else
      if not ( values["jln-warnings"] == "default") then
        if values["jln-warnings"] == "off" then
          jln_buildoptions = jln_buildoptions .. " /W0"
        else
          if values["jln-warnings"] == "on" then
            jln_buildoptions = jln_buildoptions .. " /W4 /wd4244 /wd4245 /wd4711"
          else
            jln_buildoptions = jln_buildoptions .. " /Wall /wd4355 /wd4365 /wd4514 /wd4548 /wd4571 /wd4577 /wd4625 /wd4626 /wd4668 /wd4710 /wd4711"
            if not ( not ( compversion < 1921 ) ) then
              jln_buildoptions = jln_buildoptions .. " /wd4774"
            end
            jln_buildoptions = jln_buildoptions .. " /wd4820 /wd5026 /wd5027 /wd5039 /wd4464 /wd4868 /wd5045"
            if values["jln-warnings"] == "strict" then
              jln_buildoptions = jln_buildoptions .. " /wd4061 /wd4266 /wd4388 /wd4583 /wd4619 /wd4623 /wd5204"
            end
          end
        end
      end
    end
    if not ( values["jln-shadow-warnings"] == "default") then
      if values["jln-shadow-warnings"] == "off" then
        jln_buildoptions = jln_buildoptions .. " /wd4456 /wd4459"
      else
        if ( values["jln-shadow-warnings"] == "on" or values["jln-shadow-warnings"] == "all" ) then
          jln_buildoptions = jln_buildoptions .. " /w4456 /w4459"
        else
          if values["jln-shadow-warnings"] == "local" then
            jln_buildoptions = jln_buildoptions .. " /w4456 /wd4459"
          end
        end
      end
    end
    if not ( values["jln-warnings-as-error"] == "default") then
      if values["jln-warnings-as-error"] == "on" then
        jln_buildoptions = jln_buildoptions .. " /WX"
        jln_linkoptions = jln_linkoptions .. " /WX"
      else
        if values["jln-warnings-as-error"] == "off" then
          jln_buildoptions = jln_buildoptions .. " /WX-"
        end
      end
    end
    if not ( values["jln-lto"] == "default") then
      if values["jln-lto"] == "off" then
        jln_buildoptions = jln_buildoptions .. " /LTCG:OFF"
      else
        jln_buildoptions = jln_buildoptions .. " /GL"
        jln_linkoptions = jln_linkoptions .. " /LTCG"
      end
    end
    if not ( values["jln-sanitizers"] == "default") then
      if values["jln-sanitizers"] == "on" then
        jln_buildoptions = jln_buildoptions .. " /sdl"
      else
        if not ( values["jln-stack-protector"] == "default") then
          if not ( values["jln-stack-protector"] == "off" ) then
            jln_buildoptions = jln_buildoptions .. " /sdl-"
          end
        end
      end
    end
  end
  return {buildoptions=jln_buildoptions, linkoptions=jln_linkoptions}
end