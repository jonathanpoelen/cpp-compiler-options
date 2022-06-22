-- File generated with https://github.com/jonathanpoelen/cpp-compiler-options

local _module_name = 'flags'

-- Registers new command-line options and set default values
-- `default_options` (see create_options())
-- `extra_options` = {
--   category :string|boolean = false -- add a category for option()
--   module_name: string = 'flags' -- default value for jln_c_rule()
-- }


function jln_c_init_options(default_options, extra_options)
local _extraopt_flag_names = {
  ["jln-cc"] = true,
  ["cc"] = true,
  ["jln-cc-version"] = true,
  ["cc_version"] = true,
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
  ["jln-ndebug"] = {["default"]="", ["off"]="off", ["on"]="on", ["with_optimization_1_or_above"]="with_optimization_1_or_above", [""]=""},
  ["ndebug"] = {["default"]="", ["off"]="off", ["on"]="on", ["with_optimization_1_or_above"]="with_optimization_1_or_above", [""]=""},
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
  ["jln-var-init"] = {["default"]="", ["pattern"]="pattern", [""]=""},
  ["var_init"] = {["default"]="", ["pattern"]="pattern", [""]=""},
  ["jln-warnings"] = {["default"]="", ["off"]="off", ["on"]="on", ["strict"]="strict", ["very_strict"]="very_strict", [""]=""},
  ["warnings"] = {["default"]="", ["off"]="off", ["on"]="on", ["strict"]="strict", ["very_strict"]="very_strict", [""]=""},
  ["jln-warnings-as-error"] = {["default"]="", ["off"]="off", ["on"]="on", ["basic"]="basic", [""]=""},
  ["warnings_as_error"] = {["default"]="", ["off"]="off", ["on"]="on", ["basic"]="basic", [""]=""},
  ["jln-whole-program"] = {["default"]="", ["off"]="off", ["on"]="on", ["strip_all"]="strip_all", [""]=""},
  ["whole_program"] = {["default"]="", ["off"]="off", ["on"]="on", ["strip_all"]="strip_all", [""]=""},
  ["jln-windows-bigobj"] = {["default"]="", ["on"]="on", [""]=""},
  ["windows_bigobj"] = {["default"]="", ["on"]="on", [""]=""},
}


  if default_options then
    for k,v in pairs(default_options) do
      local ref = _flag_names[k]
      if not ref then
        if not _extraopt_flag_names[k] then
          local msg = "Unknown '" .. k .. "' jln flag name"
          print(msg)
          error(msg)
        end
      elseif not ref[v] then
        local msg = "Unknown value '" .. v .. "' for '" .. k .. "'"
        print(msg)
        error(msg)
      end
    end
  else
    default_options = {}
  end

  local check_option = function(opt, optname)
    local value = get_config(opt)
    if not _flag_names[optname][value] then
      os.raise(vformat("${color.error}Unknown value '%s' for '%s'", value, opt))
    end
  end

  extra_options = extra_options or {}
  _module_name = extra_options.module_name or _module_name

  local category = extra_options.category
  category = category == true and 'jln_c_flags'
          or category
          or nil
    
  option("jln-analyzer", {
           showmenu=true,
           category=category,
           description="enables an static analysis of program flow which looks for “interesting” interprocedural paths through the code, and issues warnings for problems found on them (much more expensive than other GCC warnings)",
           values={"default", "off", "on", "taint"},
           default=default_options["analyzer"] or default_options["jln-analyzer"] or "default",
           after_check=function(option) check_option("jln-analyzer", "analyzer") end,
         })
  option("jln-analyzer-too-complex-warning", {
           showmenu=true,
           category=category,
           description="By default, the analysis silently stops if the code is too complicated for the analyzer to fully explore and it reaches an internal limit. This option warns if this occurs.",
           values={"default", "off", "on"},
           default=default_options["analyzer_too_complex_warning"] or default_options["jln-analyzer-too-complex-warning"] or "default",
           after_check=function(option) check_option("jln-analyzer-too-complex-warning", "analyzer_too_complex_warning") end,
         })
  option("jln-analyzer-verbosity", {
           showmenu=true,
           category=category,
           description="controls the complexity of the control flow paths that are emitted for analyzer diagnostics\\n - 0: At this level, interprocedural call and return events are displayed, along with the most pertinent state-change events relating to a diagnostic. For example, for a double-free diagnostic, both calls to free will be shown.\\n - 1: As per the previous level, but also show events for the entry to each function.\\n - 2: As per the previous level, but also show events relating to control flow that are significant to triggering the issue (e.g. “true path taken” at a conditional). This level is the default.\\n - 3: As per the previous level, but show all control flow events, not just significant ones.",
           values={"default", "0", "1", "2", "3"},
           default=default_options["analyzer_verbosity"] or default_options["jln-analyzer-verbosity"] or "default",
           after_check=function(option) check_option("jln-analyzer-verbosity", "analyzer_verbosity") end,
         })
  option("jln-color", {
           showmenu=true,
           category=category,
           description="",
           values={"default", "auto", "never", "always"},
           default=default_options["color"] or default_options["jln-color"] or "default",
           after_check=function(option) check_option("jln-color", "color") end,
         })
  option("jln-control-flow", {
           showmenu=true,
           category=category,
           description="insert extra runtime security checks to detect attempts to compromise your code",
           values={"default", "off", "on", "branch", "return", "allow_bugs"},
           default=default_options["control_flow"] or default_options["jln-control-flow"] or "default",
           after_check=function(option) check_option("jln-control-flow", "control_flow") end,
         })
  option("jln-conversion-warnings", {
           showmenu=true,
           category=category,
           description="warn for implicit conversions that may alter a value",
           values={"default", "off", "on", "sign", "conversion"},
           default=default_options["conversion_warnings"] or default_options["jln-conversion-warnings"] or "on",
           after_check=function(option) check_option("jln-conversion-warnings", "conversion_warnings") end,
         })
  option("jln-coverage", {
           showmenu=true,
           category=category,
           description="",
           values={"default", "off", "on"},
           default=default_options["coverage"] or default_options["jln-coverage"] or "default",
           after_check=function(option) check_option("jln-coverage", "coverage") end,
         })
  option("jln-covered-switch-default-warnings", {
           showmenu=true,
           category=category,
           description="warning for default label in switch which covers all enumeration values",
           values={"default", "on", "off"},
           default=default_options["covered_switch_default_warnings"] or default_options["jln-covered-switch-default-warnings"] or "on",
           after_check=function(option) check_option("jln-covered-switch-default-warnings", "covered_switch_default_warnings") end,
         })
  option("jln-cpu", {
           showmenu=true,
           category=category,
           description="",
           values={"default", "generic", "native"},
           default=default_options["cpu"] or default_options["jln-cpu"] or "default",
           after_check=function(option) check_option("jln-cpu", "cpu") end,
         })
  option("jln-debug", {
           showmenu=true,
           category=category,
           description="produce debugging information in the operating system\'s",
           values={"default", "off", "on", "line_tables_only", "gdb", "lldb", "sce"},
           default=default_options["debug"] or default_options["jln-debug"] or "default",
           after_check=function(option) check_option("jln-debug", "debug") end,
         })
  option("jln-diagnostics-format", {
           showmenu=true,
           category=category,
           description="emit fix-it hints in a machine-parseable format",
           values={"default", "fixits", "patch", "print_source_range_info"},
           default=default_options["diagnostics_format"] or default_options["jln-diagnostics-format"] or "default",
           after_check=function(option) check_option("jln-diagnostics-format", "diagnostics_format") end,
         })
  option("jln-exceptions", {
           showmenu=true,
           category=category,
           description="enable C++ exception",
           values={"default", "off", "on"},
           default=default_options["exceptions"] or default_options["jln-exceptions"] or "default",
           after_check=function(option) check_option("jln-exceptions", "exceptions") end,
         })
  option("jln-fix-compiler-error", {
           showmenu=true,
           category=category,
           description="transforms some warnings into errors to comply with the standard",
           values={"default", "off", "on"},
           default=default_options["fix_compiler_error"] or default_options["jln-fix-compiler-error"] or "on",
           after_check=function(option) check_option("jln-fix-compiler-error", "fix_compiler_error") end,
         })
  option("jln-float-sanitizers", {
           showmenu=true,
           category=category,
           description="",
           values={"default", "off", "on"},
           default=default_options["float_sanitizers"] or default_options["jln-float-sanitizers"] or "default",
           after_check=function(option) check_option("jln-float-sanitizers", "float_sanitizers") end,
         })
  option("jln-integer-sanitizers", {
           showmenu=true,
           category=category,
           description="",
           values={"default", "off", "on"},
           default=default_options["integer_sanitizers"] or default_options["jln-integer-sanitizers"] or "default",
           after_check=function(option) check_option("jln-integer-sanitizers", "integer_sanitizers") end,
         })
  option("jln-linker", {
           showmenu=true,
           category=category,
           description="configure linker",
           values={"default", "bfd", "gold", "lld", "native"},
           default=default_options["linker"] or default_options["jln-linker"] or "default",
           after_check=function(option) check_option("jln-linker", "linker") end,
         })
  option("jln-lto", {
           showmenu=true,
           category=category,
           description="enable Link Time Optimization",
           values={"default", "off", "on", "fat", "thin"},
           default=default_options["lto"] or default_options["jln-lto"] or "default",
           after_check=function(option) check_option("jln-lto", "lto") end,
         })
  option("jln-msvc-conformance", {
           showmenu=true,
           category=category,
           description="standard conformance options",
           values={"default", "all", "all_without_throwing_new"},
           default=default_options["msvc_conformance"] or default_options["jln-msvc-conformance"] or "all",
           after_check=function(option) check_option("jln-msvc-conformance", "msvc_conformance") end,
         })
  option("jln-msvc-crt-secure-no-warnings", {
           showmenu=true,
           category=category,
           description="disable CRT warnings",
           values={"default", "off", "on"},
           default=default_options["msvc_crt_secure_no_warnings"] or default_options["jln-msvc-crt-secure-no-warnings"] or "on",
           after_check=function(option) check_option("jln-msvc-crt-secure-no-warnings", "msvc_crt_secure_no_warnings") end,
         })
  option("jln-msvc-isystem", {
           showmenu=true,
           category=category,
           description="warnings concerning external header (https://devblogs.microsoft.com/cppblog/broken-warnings-theory)",
           values={"default", "anglebrackets", "include_and_caexcludepath"},
           default=default_options["msvc_isystem"] or default_options["jln-msvc-isystem"] or "default",
           after_check=function(option) check_option("jln-msvc-isystem", "msvc_isystem") end,
         })
  option("jln-ndebug", {
           showmenu=true,
           category=category,
           description="enable NDEBUG macro (disable assert macro)",
           values={"default", "off", "on", "with_optimization_1_or_above"},
           default=default_options["ndebug"] or default_options["jln-ndebug"] or "with_optimization_1_or_above",
           after_check=function(option) check_option("jln-ndebug", "ndebug") end,
         })
  option("jln-optimization", {
           showmenu=true,
           category=category,
           description="optimization level\\n - 0: not optimize\\n - g: enable debugging experience\\n - 1: optimize\\n - 2: optimize even more\\n - 3: optimize yet more\\n - fast: enables all optimization=3 and disregard strict standards compliance\\n - size: optimize for size\\n - z: optimize for size aggressively (/!\\ possible slow compilation)",
           values={"default", "0", "g", "1", "2", "3", "fast", "size", "z"},
           default=default_options["optimization"] or default_options["jln-optimization"] or "default",
           after_check=function(option) check_option("jln-optimization", "optimization") end,
         })
  option("jln-other-sanitizers", {
           showmenu=true,
           category=category,
           description="enable other sanitizers",
           values={"default", "off", "thread", "pointer", "memory"},
           default=default_options["other_sanitizers"] or default_options["jln-other-sanitizers"] or "default",
           after_check=function(option) check_option("jln-other-sanitizers", "other_sanitizers") end,
         })
  option("jln-pedantic", {
           showmenu=true,
           category=category,
           description="issue all the warnings demanded by strict ISO C and ISO C++",
           values={"default", "off", "on", "as_error"},
           default=default_options["pedantic"] or default_options["jln-pedantic"] or "on",
           after_check=function(option) check_option("jln-pedantic", "pedantic") end,
         })
  option("jln-pie", {
           showmenu=true,
           category=category,
           description="controls position-independent code generation",
           values={"default", "off", "on", "static", "fpic", "fPIC", "fpie", "fPIE"},
           default=default_options["pie"] or default_options["jln-pie"] or "default",
           after_check=function(option) check_option("jln-pie", "pie") end,
         })
  option("jln-relro", {
           showmenu=true,
           category=category,
           description="specifies a memory segment that should be made read-only after relocation, if supported.",
           values={"default", "off", "on", "full"},
           default=default_options["relro"] or default_options["jln-relro"] or "default",
           after_check=function(option) check_option("jln-relro", "relro") end,
         })
  option("jln-reproducible-build-warnings", {
           showmenu=true,
           category=category,
           description="warn when macros \"__TIME__\", \"__DATE__\" or \"__TIMESTAMP__\" are encountered as they might prevent bit-wise-identical reproducible compilations",
           values={"default", "off", "on"},
           default=default_options["reproducible_build_warnings"] or default_options["jln-reproducible-build-warnings"] or "default",
           after_check=function(option) check_option("jln-reproducible-build-warnings", "reproducible_build_warnings") end,
         })
  option("jln-sanitizers", {
           showmenu=true,
           category=category,
           description="enable sanitizers (asan, ubsan, etc)",
           values={"default", "off", "on"},
           default=default_options["sanitizers"] or default_options["jln-sanitizers"] or "default",
           after_check=function(option) check_option("jln-sanitizers", "sanitizers") end,
         })
  option("jln-shadow-warnings", {
           showmenu=true,
           category=category,
           description="",
           values={"default", "off", "on", "local", "compatible_local", "all"},
           default=default_options["shadow_warnings"] or default_options["jln-shadow-warnings"] or "off",
           after_check=function(option) check_option("jln-shadow-warnings", "shadow_warnings") end,
         })
  option("jln-stack-protector", {
           showmenu=true,
           category=category,
           description="emit extra code to check for buffer overflows, such as stack smashing attacks",
           values={"default", "off", "on", "strong", "all"},
           default=default_options["stack_protector"] or default_options["jln-stack-protector"] or "default",
           after_check=function(option) check_option("jln-stack-protector", "stack_protector") end,
         })
  option("jln-stl-fix", {
           showmenu=true,
           category=category,
           description="enable /DNOMINMAX with msvc",
           values={"default", "off", "on"},
           default=default_options["stl_fix"] or default_options["jln-stl-fix"] or "on",
           after_check=function(option) check_option("jln-stl-fix", "stl_fix") end,
         })
  option("jln-suggestions", {
           showmenu=true,
           category=category,
           description="warn for cases where adding an attribute may be beneficial",
           values={"default", "off", "on"},
           default=default_options["suggestions"] or default_options["jln-suggestions"] or "default",
           after_check=function(option) check_option("jln-suggestions", "suggestions") end,
         })
  option("jln-switch-warnings", {
           showmenu=true,
           category=category,
           description="warnings concerning the switch keyword",
           values={"default", "on", "off", "exhaustive_enum", "mandatory_default", "exhaustive_enum_and_mandatory_default"},
           default=default_options["switch_warnings"] or default_options["jln-switch-warnings"] or "on",
           after_check=function(option) check_option("jln-switch-warnings", "switch_warnings") end,
         })
  option("jln-var-init", {
           showmenu=true,
           category=category,
           description="initialize all stack variables implicitly, including padding",
           values={"default", "pattern"},
           default=default_options["var_init"] or default_options["jln-var-init"] or "default",
           after_check=function(option) check_option("jln-var-init", "var_init") end,
         })
  option("jln-warnings", {
           showmenu=true,
           category=category,
           description="warning level",
           values={"default", "off", "on", "strict", "very_strict"},
           default=default_options["warnings"] or default_options["jln-warnings"] or "on",
           after_check=function(option) check_option("jln-warnings", "warnings") end,
         })
  option("jln-warnings-as-error", {
           showmenu=true,
           category=category,
           description="make all or some warnings into errors",
           values={"default", "off", "on", "basic"},
           default=default_options["warnings_as_error"] or default_options["jln-warnings-as-error"] or "default",
           after_check=function(option) check_option("jln-warnings-as-error", "warnings_as_error") end,
         })
  option("jln-whole-program", {
           showmenu=true,
           category=category,
           description="Assume that the current compilation unit represents the whole program being compiled. This option should not be used in combination with lto.",
           values={"default", "off", "on", "strip_all"},
           default=default_options["whole_program"] or default_options["jln-whole-program"] or "default",
           after_check=function(option) check_option("jln-whole-program", "whole_program") end,
         })
  option("jln-windows-bigobj", {
           showmenu=true,
           category=category,
           description="increases that addressable sections capacity",
           values={"default", "on"},
           default=default_options["windows_bigobj"] or default_options["jln-windows-bigobj"] or "on",
           after_check=function(option) check_option("jln-windows-bigobj", "windows_bigobj") end,
         })
  option("jln-cc", {showmenu=true, description="Path or name of the compiler for jln functions", default=""})
  option("jln-cc-version", {showmenu=true, description="Force the compiler version for jln functions", default=""})
  option("jln-ld", {showmenu=true, description="Path or name of the linker for jln functions", default=""})
end

jln_c_default_options_by_modes = {
  debug={
    control_flow='on',
    debug='on',
    sanitizers='on',
    stl_debug='on',
  },
  releasedbg={
    debug='on',
    linker='native',
    lto='on',
    optimization='g',
  },
  minsizerel={
    linker='native',
    lto='on',
    optimization='size',
  },
  release={
    linker='native',
    lto='on',
    optimization='3',
  },
}

-- Set options for a specific mode (see also jln_c_rule()).
-- If options_by_modes is nil, a default configuration is used.
-- `options_by_modes` = {
--   [modename]: {
--     function() ... end, -- optional callback
--     stl_debug='on', ... -- options (see create_options())
--   }
-- }
-- `extra_options` = {
--   rulename :string = name for current mode (default value is '__jln_c_flags__')
--   other options are sent to jln_c_rule()
-- }
function jln_c_init_modes(options_by_modes, extra_options)
  extra_options = extra_options or {}
  local rulename = extra_options.rulename or '__jln_c_flags__'

  for mode,options in pairs(options_by_modes or jln_c_default_options_by_modes) do
    if is_mode(mode) then
      local callback = options[1]
      if callback then
        options[1] = nil
      end
      jln_c_rule(rulename, options, extra_options)
      if callback then
        options[1] = callback
        callback()
      end
      add_rules(rulename)
      return
    end
  end

  jln_c_rule(rulename, {}, extra_options)
  add_rules(rulename)
end


local cached_flags = {}
local current_path = os.scriptdir()

-- Create a new rule. Options are added to the current configuration (see create_options())
-- `options`: same as create_options()
-- `extra_options` = {
--   module_name :string = module name used by on_load() in jln_c_rule()
--   clone_options :boolean = make an internal copy of options
--                            which prevents changing it after the call to jln_c_rule().
--                            (default: false)
--   other options are sent to get_flags()
-- }
function jln_c_rule(rulename, options, extra_options)
  extra_options = extra_options or {}
  local module_name = extra_options.module_name or _module_name

  if extra_options.clone_options then
    local cloned = {}
    for k, v in pairs(options) do
      cloned[k] = v
    end
    options = cloned
  end

  rule(rulename)
    on_load(function(target)
      local cached = cached_flags[rulename]
      if not cached then
        import(module_name, {rootdir=current_path})
        cached = flags.get_flags(options, extra_options)
        table.insert(cached.cxxflags, {force=true})
        table.insert(cached.ldflags, {force=true})
        cached_flags[rulename] = cached
      end
      target:add('cxxflags', table.unpack(cached.cxxflags))
      target:add('ldflags', table.unpack(cached.ldflags))
    end)
  rule_end()
end

