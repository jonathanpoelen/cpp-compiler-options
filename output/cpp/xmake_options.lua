-- File generated with https://github.com/jonathanpoelen/cpp-compiler-options


function jln_cxx_init_options(defaults, category --[[string|boolean=false]])
local _extraopt_flag_names = {
  ["jln-cxx"] = true,
  ["cxx"] = true,
  ["jln-cxx-version"] = true,
  ["cxx_version"] = true,
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
  ["jln-lto"] = {["default"]="", ["off"]="off", ["on"]="on", ["fat"]="fat", ["thin"]="thin", [""]=""},
  ["lto"] = {["default"]="", ["off"]="off", ["on"]="on", ["fat"]="fat", ["thin"]="thin", [""]=""},
  ["jln-msvc-conformance"] = {["default"]="", ["all"]="all", ["all_without_throwing_new"]="all_without_throwing_new", [""]=""},
  ["msvc_conformance"] = {["default"]="", ["all"]="all", ["all_without_throwing_new"]="all_without_throwing_new", [""]=""},
  ["jln-msvc-crt-secure-no-warnings"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["msvc_crt_secure_no_warnings"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["jln-msvc-isystem"] = {["default"]="", ["anglebrackets"]="anglebrackets", ["include_and_caexcludepath"]="include_and_caexcludepath", [""]=""},
  ["msvc_isystem"] = {["default"]="", ["anglebrackets"]="anglebrackets", ["include_and_caexcludepath"]="include_and_caexcludepath", [""]=""},
  ["jln-msvc-isystem-with-template-from-non-external"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["msvc_isystem_with_template_from_non_external"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
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


  if defaults then
    for k,v in pairs(defaults) do
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
    defaults = {}
  end

  local check_option = function(opt, optname)
    local value = get_config(opt)
    if not _flag_names[optname][value] then
      os.raise(vformat("${color.error}Unknown value '%s' for '%s'", value, opt))
    end
  end

  category = category == true and "jln_cxx"
          or category
          or nil
    
  option("jln-color", {
           showmenu=true,
           category=category,
           description="",
           values={"default", "auto", "never", "always"},
           default=defaults["color"] or defaults["jln-color"] or "default",
           after_check=function(option) check_option("jln-color", "color") end,
         })
  option("jln-control-flow", {
           showmenu=true,
           category=category,
           description="insert extra runtime security checks to detect attempts to compromise your code",
           values={"default", "off", "on", "branch", "return", "allow_bugs"},
           default=defaults["control_flow"] or defaults["jln-control-flow"] or "default",
           after_check=function(option) check_option("jln-control-flow", "control_flow") end,
         })
  option("jln-conversion-warnings", {
           showmenu=true,
           category=category,
           description="warn for implicit conversions that may alter a value",
           values={"default", "off", "on", "sign", "conversion"},
           default=defaults["conversion_warnings"] or defaults["jln-conversion-warnings"] or "on",
           after_check=function(option) check_option("jln-conversion-warnings", "conversion_warnings") end,
         })
  option("jln-coverage", {
           showmenu=true,
           category=category,
           description="",
           values={"default", "off", "on"},
           default=defaults["coverage"] or defaults["jln-coverage"] or "default",
           after_check=function(option) check_option("jln-coverage", "coverage") end,
         })
  option("jln-covered-switch-default-warnings", {
           showmenu=true,
           category=category,
           description="warning for default label in switch which covers all enumeration values",
           values={"default", "on", "off"},
           default=defaults["covered_switch_default_warnings"] or defaults["jln-covered-switch-default-warnings"] or "on",
           after_check=function(option) check_option("jln-covered-switch-default-warnings", "covered_switch_default_warnings") end,
         })
  option("jln-cpu", {
           showmenu=true,
           category=category,
           description="",
           values={"default", "generic", "native"},
           default=defaults["cpu"] or defaults["jln-cpu"] or "default",
           after_check=function(option) check_option("jln-cpu", "cpu") end,
         })
  option("jln-debug", {
           showmenu=true,
           category=category,
           description="produce debugging information in the operating system\'s",
           values={"default", "off", "on", "line_tables_only", "gdb", "lldb", "sce"},
           default=defaults["debug"] or defaults["jln-debug"] or "default",
           after_check=function(option) check_option("jln-debug", "debug") end,
         })
  option("jln-diagnostics-format", {
           showmenu=true,
           category=category,
           description="emit fix-it hints in a machine-parseable format",
           values={"default", "fixits", "patch", "print_source_range_info"},
           default=defaults["diagnostics_format"] or defaults["jln-diagnostics-format"] or "default",
           after_check=function(option) check_option("jln-diagnostics-format", "diagnostics_format") end,
         })
  option("jln-diagnostics-show-template-tree", {
           showmenu=true,
           category=category,
           description="enables printing a tree-like structure showing the common and differing parts of the types",
           values={"default", "off", "on"},
           default=defaults["diagnostics_show_template_tree"] or defaults["jln-diagnostics-show-template-tree"] or "default",
           after_check=function(option) check_option("jln-diagnostics-show-template-tree", "diagnostics_show_template_tree") end,
         })
  option("jln-elide-type", {
           showmenu=true,
           category=category,
           description="prints diagnostics showing common parts of template types as \"[...]\"",
           values={"default", "off", "on"},
           default=defaults["elide_type"] or defaults["jln-elide-type"] or "default",
           after_check=function(option) check_option("jln-elide-type", "elide_type") end,
         })
  option("jln-exceptions", {
           showmenu=true,
           category=category,
           description="enable C++ exception",
           values={"default", "off", "on"},
           default=defaults["exceptions"] or defaults["jln-exceptions"] or "default",
           after_check=function(option) check_option("jln-exceptions", "exceptions") end,
         })
  option("jln-fix-compiler-error", {
           showmenu=true,
           category=category,
           description="transforms some warnings into errors to comply with the standard",
           values={"default", "off", "on"},
           default=defaults["fix_compiler_error"] or defaults["jln-fix-compiler-error"] or "on",
           after_check=function(option) check_option("jln-fix-compiler-error", "fix_compiler_error") end,
         })
  option("jln-float-sanitizers", {
           showmenu=true,
           category=category,
           description="",
           values={"default", "off", "on"},
           default=defaults["float_sanitizers"] or defaults["jln-float-sanitizers"] or "default",
           after_check=function(option) check_option("jln-float-sanitizers", "float_sanitizers") end,
         })
  option("jln-integer-sanitizers", {
           showmenu=true,
           category=category,
           description="",
           values={"default", "off", "on"},
           default=defaults["integer_sanitizers"] or defaults["jln-integer-sanitizers"] or "default",
           after_check=function(option) check_option("jln-integer-sanitizers", "integer_sanitizers") end,
         })
  option("jln-linker", {
           showmenu=true,
           category=category,
           description="configure linker",
           values={"default", "bfd", "gold", "lld", "native"},
           default=defaults["linker"] or defaults["jln-linker"] or "default",
           after_check=function(option) check_option("jln-linker", "linker") end,
         })
  option("jln-lto", {
           showmenu=true,
           category=category,
           description="enable Link Time Optimization",
           values={"default", "off", "on", "fat", "thin"},
           default=defaults["lto"] or defaults["jln-lto"] or "default",
           after_check=function(option) check_option("jln-lto", "lto") end,
         })
  option("jln-msvc-conformance", {
           showmenu=true,
           category=category,
           description="standard conformance options",
           values={"default", "all", "all_without_throwing_new"},
           default=defaults["msvc_conformance"] or defaults["jln-msvc-conformance"] or "all",
           after_check=function(option) check_option("jln-msvc-conformance", "msvc_conformance") end,
         })
  option("jln-msvc-crt-secure-no-warnings", {
           showmenu=true,
           category=category,
           description="disable CRT warnings",
           values={"default", "off", "on"},
           default=defaults["msvc_crt_secure_no_warnings"] or defaults["jln-msvc-crt-secure-no-warnings"] or "on",
           after_check=function(option) check_option("jln-msvc-crt-secure-no-warnings", "msvc_crt_secure_no_warnings") end,
         })
  option("jln-msvc-isystem", {
           showmenu=true,
           category=category,
           description="warnings concerning external header (https://devblogs.microsoft.com/cppblog/broken-warnings-theory)",
           values={"default", "anglebrackets", "include_and_caexcludepath"},
           default=defaults["msvc_isystem"] or defaults["jln-msvc-isystem"] or "default",
           after_check=function(option) check_option("jln-msvc-isystem", "msvc_isystem") end,
         })
  option("jln-msvc-isystem-with-template-from-non-external", {
           showmenu=true,
           category=category,
           description="warnings concerning template in an external header (requires msvc_isystem)",
           values={"default", "off", "on"},
           default=defaults["msvc_isystem_with_template_from_non_external"] or defaults["jln-msvc-isystem-with-template-from-non-external"] or "default",
           after_check=function(option) check_option("jln-msvc-isystem-with-template-from-non-external", "msvc_isystem_with_template_from_non_external") end,
         })
  option("jln-noexcept-warnings", {
           showmenu=true,
           category=category,
           description="Warn when a noexcept-expression evaluates to false because of a call to a function that does not have a non-throwing exception specification (i.e. \"throw()\" or \"noexcept\") but is known by the compiler to never throw an exception.",
           values={"default", "off", "on"},
           default=defaults["noexcept_warnings"] or defaults["jln-noexcept-warnings"] or "default",
           after_check=function(option) check_option("jln-noexcept-warnings", "noexcept_warnings") end,
         })
  option("jln-optimization", {
           showmenu=true,
           category=category,
           description="optimization level\\n - 0: not optimize\\n - g: enable debugging experience\\n - 1: optimize\\n - 2: optimize even more\\n - 3: optimize yet more\\n - fast: enables all optimization=3 and disregard strict standards compliance\\n - size: optimize for size\\n - z: optimize for size aggressively (/!\\ possible slow compilation)",
           values={"default", "0", "g", "1", "2", "3", "fast", "size", "z"},
           default=defaults["optimization"] or defaults["jln-optimization"] or "default",
           after_check=function(option) check_option("jln-optimization", "optimization") end,
         })
  option("jln-other-sanitizers", {
           showmenu=true,
           category=category,
           description="enable other sanitizers",
           values={"default", "off", "thread", "pointer", "memory"},
           default=defaults["other_sanitizers"] or defaults["jln-other-sanitizers"] or "default",
           after_check=function(option) check_option("jln-other-sanitizers", "other_sanitizers") end,
         })
  option("jln-pedantic", {
           showmenu=true,
           category=category,
           description="issue all the warnings demanded by strict ISO C and ISO C++",
           values={"default", "off", "on", "as_error"},
           default=defaults["pedantic"] or defaults["jln-pedantic"] or "on",
           after_check=function(option) check_option("jln-pedantic", "pedantic") end,
         })
  option("jln-pie", {
           showmenu=true,
           category=category,
           description="controls position-independent code generation",
           values={"default", "off", "on", "static", "fpic", "fPIC", "fpie", "fPIE"},
           default=defaults["pie"] or defaults["jln-pie"] or "default",
           after_check=function(option) check_option("jln-pie", "pie") end,
         })
  option("jln-relro", {
           showmenu=true,
           category=category,
           description="specifies a memory segment that should be made read-only after relocation, if supported.",
           values={"default", "off", "on", "full"},
           default=defaults["relro"] or defaults["jln-relro"] or "default",
           after_check=function(option) check_option("jln-relro", "relro") end,
         })
  option("jln-reproducible-build-warnings", {
           showmenu=true,
           category=category,
           description="warn when macros \"__TIME__\", \"__DATE__\" or \"__TIMESTAMP__\" are encountered as they might prevent bit-wise-identical reproducible compilations",
           values={"default", "off", "on"},
           default=defaults["reproducible_build_warnings"] or defaults["jln-reproducible-build-warnings"] or "default",
           after_check=function(option) check_option("jln-reproducible-build-warnings", "reproducible_build_warnings") end,
         })
  option("jln-rtti", {
           showmenu=true,
           category=category,
           description="disable generation of information about every class with virtual functions for use by the C++ run-time type identification features (\"dynamic_cast\" and \"typeid\")",
           values={"default", "off", "on"},
           default=defaults["rtti"] or defaults["jln-rtti"] or "default",
           after_check=function(option) check_option("jln-rtti", "rtti") end,
         })
  option("jln-sanitizers", {
           showmenu=true,
           category=category,
           description="enable sanitizers (asan, ubsan, etc)",
           values={"default", "off", "on"},
           default=defaults["sanitizers"] or defaults["jln-sanitizers"] or "default",
           after_check=function(option) check_option("jln-sanitizers", "sanitizers") end,
         })
  option("jln-shadow-warnings", {
           showmenu=true,
           category=category,
           description="",
           values={"default", "off", "on", "local", "compatible_local", "all"},
           default=defaults["shadow_warnings"] or defaults["jln-shadow-warnings"] or "off",
           after_check=function(option) check_option("jln-shadow-warnings", "shadow_warnings") end,
         })
  option("jln-stack-protector", {
           showmenu=true,
           category=category,
           description="emit extra code to check for buffer overflows, such as stack smashing attacks",
           values={"default", "off", "on", "strong", "all"},
           default=defaults["stack_protector"] or defaults["jln-stack-protector"] or "default",
           after_check=function(option) check_option("jln-stack-protector", "stack_protector") end,
         })
  option("jln-stl-debug", {
           showmenu=true,
           category=category,
           description="controls the debug level of the STL",
           values={"default", "off", "on", "allow_broken_abi", "allow_broken_abi_and_bugs", "assert_as_exception"},
           default=defaults["stl_debug"] or defaults["jln-stl-debug"] or "default",
           after_check=function(option) check_option("jln-stl-debug", "stl_debug") end,
         })
  option("jln-stl-fix", {
           showmenu=true,
           category=category,
           description="enable /DNOMINMAX with msvc",
           values={"default", "off", "on"},
           default=defaults["stl_fix"] or defaults["jln-stl-fix"] or "on",
           after_check=function(option) check_option("jln-stl-fix", "stl_fix") end,
         })
  option("jln-suggestions", {
           showmenu=true,
           category=category,
           description="warn for cases where adding an attribute may be beneficial",
           values={"default", "off", "on"},
           default=defaults["suggestions"] or defaults["jln-suggestions"] or "default",
           after_check=function(option) check_option("jln-suggestions", "suggestions") end,
         })
  option("jln-switch-warnings", {
           showmenu=true,
           category=category,
           description="warnings concerning the switch keyword",
           values={"default", "on", "off", "exhaustive_enum", "mandatory_default", "exhaustive_enum_and_mandatory_default"},
           default=defaults["switch_warnings"] or defaults["jln-switch-warnings"] or "on",
           after_check=function(option) check_option("jln-switch-warnings", "switch_warnings") end,
         })
  option("jln-warnings", {
           showmenu=true,
           category=category,
           description="warning level",
           values={"default", "off", "on", "strict", "very_strict"},
           default=defaults["warnings"] or defaults["jln-warnings"] or "on",
           after_check=function(option) check_option("jln-warnings", "warnings") end,
         })
  option("jln-warnings-as-error", {
           showmenu=true,
           category=category,
           description="make all or some warnings into errors",
           values={"default", "off", "on", "basic"},
           default=defaults["warnings_as_error"] or defaults["jln-warnings-as-error"] or "default",
           after_check=function(option) check_option("jln-warnings-as-error", "warnings_as_error") end,
         })
  option("jln-whole-program", {
           showmenu=true,
           category=category,
           description="Assume that the current compilation unit represents the whole program being compiled. This option should not be used in combination with lto.",
           values={"default", "off", "on", "strip_all"},
           default=defaults["whole_program"] or defaults["jln-whole-program"] or "default",
           after_check=function(option) check_option("jln-whole-program", "whole_program") end,
         })
  option("jln-windows-abi-compatibility-warnings", {
           showmenu=true,
           category=category,
           description="In code that is intended to be portable to Windows-based compilers the warning helps prevent unresolved references due to the difference in the mangling of symbols declared with different class-keys",
           values={"default", "off", "on"},
           default=defaults["windows_abi_compatibility_warnings"] or defaults["jln-windows-abi-compatibility-warnings"] or "off",
           after_check=function(option) check_option("jln-windows-abi-compatibility-warnings", "windows_abi_compatibility_warnings") end,
         })
  option("jln-windows-bigobj", {
           showmenu=true,
           category=category,
           description="increases that addressable sections capacity",
           values={"default", "on"},
           default=defaults["windows_bigobj"] or defaults["jln-windows-bigobj"] or "on",
           after_check=function(option) check_option("jln-windows-bigobj", "windows_bigobj") end,
         })
  option("jln-cxx", {showmenu=true, description="Path or name of the compiler for jln functions", default=""})
  option("jln-cxx-version", {showmenu=true, description="Force the compiler version for jln functions", default=""})
  option("jln-ld", {showmenu=true, description="Path or name of the linker for jln functions", default=""})
end

-- `options_by_modes`: {
--    [modename]: {
--      function() ... end, -- optional callback
--      stl_debug='on', ... -- options (see tovalues())
--    }
--  }
-- `func_options`: {
--    rulename = name for current mode (default value is '__jln_cxx__flags__')
--    disable_other_options = see jln_cxx_rule
--    imported = see jln_cxx_rule
-- }
function jln_cxx_init_modes(options_by_modes, func_options)
  for mode,options in pairs(options_by_modes) do
    if is_mode(mode) then
      func_options = func_options or {}
      local rulename = func_options.rulename or '__jln_cxx__flags__'
      local callback = options[1]
      if callback then
        options[1] = nil
      end
      jln_cxx_rule(rulename, options, func_options.disable_other_options, func_options.imported)
      if callback then
        options[1] = callback
      end
      callback()
      add_rules(rulename)
      return
    end
  end
end


local cached_flags = {}

-- Create a new rule. Options are added to the current configuration (see tovalues())
function jln_cxx_rule(rulename, options, disable_other_options, imported)
  imported = imported or 'cpp.flags'

  rule(rulename)
    on_load(function(target)
      local cached = cached_flags[rulename]
      if not cached then
        import(imported)
        cached = flags.getoptions(options, disable_other_options)
        table.insert(cached.cxxflags, {force=true})
        table.insert(cached.ldflags, {force=true})
        cached_flags[rulename] = cached
      end
      target:add('cxxflags', table.unpack(cached.cxxflags))
      target:add('ldflags', table.unpack(cached.ldflags))
    end)
  rule_end()
end

