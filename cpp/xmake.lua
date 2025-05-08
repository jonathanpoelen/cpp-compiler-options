-- File generated with https://github.com/jonathanpoelen/cpp-compiler-options

local _module_name = 'flags'

-- Registers new command-line options and set default values
-- `default_options` (see create_options())
-- `extra_options` = {
--   category :string|boolean = false -- add a category for option()
--   module_name: string = 'flags' -- default value for jln_cxx_rule()
-- }
function jln_cxx_init_options(default_options, extra_options)
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
  ["jln-color"] = {["default"]="", ["auto"]="auto", ["never"]="never", ["always"]="always", [""]=""},
  ["color"] = {["default"]="", ["auto"]="auto", ["never"]="never", ["always"]="always", [""]=""},
  ["jln-control-flow"] = {["default"]="", ["off"]="off", ["on"]="on", ["branch"]="branch", ["return"]="return", ["allow_bugs"]="allow_bugs", [""]=""},
  ["control_flow"] = {["default"]="", ["off"]="off", ["on"]="on", ["branch"]="branch", ["return"]="return", ["allow_bugs"]="allow_bugs", [""]=""},
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
  ["jln-exceptions"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["exceptions"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
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
  ["jln-pie"] = {["default"]="", ["off"]="off", ["on"]="on", ["static"]="static", ["fpic"]="fpic", ["fPIC"]="fPIC", ["fpie"]="fpie", ["fPIE"]="fPIE", [""]=""},
  ["pie"] = {["default"]="", ["off"]="off", ["on"]="on", ["static"]="static", ["fpic"]="fpic", ["fPIC"]="fPIC", ["fpie"]="fpie", ["fPIE"]="fPIE", [""]=""},
  ["jln-relro"] = {["default"]="", ["off"]="off", ["on"]="on", ["full"]="full", [""]=""},
  ["relro"] = {["default"]="", ["off"]="off", ["on"]="on", ["full"]="full", [""]=""},
  ["jln-reproducible-build-warnings"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["reproducible_build_warnings"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["jln-rtti"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["rtti"] = {["default"]="", ["off"]="off", ["on"]="on", [""]=""},
  ["jln-sanitizers"] = {["default"]="", ["off"]="off", ["on"]="on", ["extra"]="extra", ["address"]="address", ["kernel"]="kernel", ["kernel_extra"]="kernel_extra", ["kernel_extra"]="kernel_extra", ["kernel_address"]="kernel_address", ["thread"]="thread", ["undefined"]="undefined", ["undefined_minimal_runtime"]="undefined_minimal_runtime", ["scudo_hardened_allocator"]="scudo_hardened_allocator", [""]=""},
  ["sanitizers"] = {["default"]="", ["off"]="off", ["on"]="on", ["extra"]="extra", ["address"]="address", ["kernel"]="kernel", ["kernel_extra"]="kernel_extra", ["kernel_extra"]="kernel_extra", ["kernel_address"]="kernel_address", ["thread"]="thread", ["undefined"]="undefined", ["undefined_minimal_runtime"]="undefined_minimal_runtime", ["scudo_hardened_allocator"]="scudo_hardened_allocator", [""]=""},
  ["jln-shadow-warnings"] = {["default"]="", ["off"]="off", ["on"]="on", ["local"]="local", ["compatible_local"]="compatible_local", ["all"]="all", [""]=""},
  ["shadow_warnings"] = {["default"]="", ["off"]="off", ["on"]="on", ["local"]="local", ["compatible_local"]="compatible_local", ["all"]="all", [""]=""},
  ["jln-stack-protector"] = {["default"]="", ["off"]="off", ["on"]="on", ["strong"]="strong", ["all"]="all", [""]=""},
  ["stack_protector"] = {["default"]="", ["off"]="off", ["on"]="on", ["strong"]="strong", ["all"]="all", [""]=""},
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
  category = category == true and 'jln_cxx_flags'
          or category
          or nil
    
  option("jln-analyzer", {
           showmenu=true,
           category=category,
           description="Enables an static analysis. It can have false positives and false negatives. It is a bug-finding tool, rather than a tool for proving program correctness. Available only with GCC and MSVC.",
           values={"default", "off", "on", "with_external_headers"},
           default=default_options["analyzer"] or default_options["jln-analyzer"] or "default",
           after_check=function(option) check_option("jln-analyzer", "analyzer") end,
         })
  option("jln-analyzer-too-complex-warning", {
           showmenu=true,
           category=category,
           description="By default, the analysis silently stops if the code is too complicated for the analyzer to fully explore and it reaches an internal limit. This option warns if this occurs. Available only with GCC.",
           values={"default", "off", "on"},
           default=default_options["analyzer_too_complex_warning"] or default_options["jln-analyzer-too-complex-warning"] or "default",
           after_check=function(option) check_option("jln-analyzer-too-complex-warning", "analyzer_too_complex_warning") end,
         })
  option("jln-analyzer-verbosity", {
           showmenu=true,
           category=category,
           description="Controls the complexity of the control flow paths that are emitted for analyzer diagnostics. Available only with GCC.\\n - 0: At this level, interprocedural call and return events are displayed, along with the most pertinent state-change events relating to a diagnostic. For example, for a double-free diagnostic, both calls to free will be shown.\\n - 1: As per the previous level, but also show events for the entry to each function.\\n - 2: As per the previous level, but also show events relating to control flow that are significant to triggering the issue (e.g. “true path taken” at a conditional). This level is the default.\\n - 3: As per the previous level, but show all control flow events, not just significant ones.",
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
           description="Insert extra runtime security checks to detect attempts to compromise your code.",
           values={"default", "off", "on", "branch", "return", "allow_bugs"},
           default=default_options["control_flow"] or default_options["jln-control-flow"] or "default",
           after_check=function(option) check_option("jln-control-flow", "control_flow") end,
         })
  option("jln-conversion-warnings", {
           showmenu=true,
           category=category,
           description="Warn for implicit conversions that may alter a value.\\n - on: Combine conversion and sign value\\n - sign: Warn for implicit conversions that may change the sign (lke `unsigned_integer = signed_integer`) or a comparison between signed and unsigned values could produce an incorrect result when the signed value is converted to unsigned.\\n - float: Warn for implicit conversions that reduce the precision of a real value.\\n - conversion: Warn for implicit conversions that may alter a value.\\n - all: Like conversion and also warn about implicit conversions from arithmetic operations even when conversion of the operands to the same type cannot change their values.",
           values={"default", "off", "on", "sign", "float", "conversion", "all"},
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
           description="Warning for default label in switch which covers all enumeration values.",
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
  option("jln-diagnostics-format", {
           showmenu=true,
           category=category,
           description="Emit fix-it hints in a machine-parseable format.",
           values={"default", "fixits", "patch", "print_source_range_info"},
           default=default_options["diagnostics_format"] or default_options["jln-diagnostics-format"] or "default",
           after_check=function(option) check_option("jln-diagnostics-format", "diagnostics_format") end,
         })
  option("jln-diagnostics-show-template", {
           showmenu=true,
           category=category,
           description="Configures how templates with incompatible types are displayed (Clang and GCC only).\\n - tree: Enables printing a tree-like structure showing the common and differing parts of the types\\n - without_elided_types: Disables printing diagnostics showing common parts of template types as \"[...]\".\\n - tree_without_elided_types: Prints a tree-like without replacing common types. Mergeing tree and without_elided_types.",
           values={"default", "tree", "without_elided_types", "tree_without_elided_types"},
           default=default_options["diagnostics_show_template"] or default_options["jln-diagnostics-show-template"] or "default",
           after_check=function(option) check_option("jln-diagnostics-show-template", "diagnostics_show_template") end,
         })
  option("jln-exceptions", {
           showmenu=true,
           category=category,
           description="Enable C++ exceptions.",
           values={"default", "off", "on"},
           default=default_options["exceptions"] or default_options["jln-exceptions"] or "default",
           after_check=function(option) check_option("jln-exceptions", "exceptions") end,
         })
  option("jln-linker", {
           showmenu=true,
           category=category,
           description="Configure linker.",
           values={"default", "bfd", "gold", "lld", "mold", "native"},
           default=default_options["linker"] or default_options["jln-linker"] or "default",
           after_check=function(option) check_option("jln-linker", "linker") end,
         })
  option("jln-lto", {
           showmenu=true,
           category=category,
           description="Enable Link Time Optimization. Also known as interprocedural optimization (IPO).\\n - on: Activates ThinLTO when available (Clang), otherwise FullLTO.\\n - full: Activates FullLTO.\\n - thin_or_nothing: Activates ThinLTO. Disable lto when not supported.\\n - whole_program: Assume that the current compilation unit represents the whole program being compiled. This option should not be used to compile a library. When not supported by the compiler, ThinLTO or FullLTO are used.\\n - whole_program_and_full_lto: Same as whole_program, but use FullLTO when not supported.",
           values={"default", "off", "on", "full", "thin_or_nothing", "whole_program", "whole_program_and_full_lto"},
           default=default_options["lto"] or default_options["jln-lto"] or "default",
           after_check=function(option) check_option("jln-lto", "lto") end,
         })
  option("jln-msvc-crt-secure-no-warnings", {
           showmenu=true,
           category=category,
           description="Disable CRT warnings with MSVC.",
           values={"default", "off", "on"},
           default=default_options["msvc_crt_secure_no_warnings"] or default_options["jln-msvc-crt-secure-no-warnings"] or "on",
           after_check=function(option) check_option("jln-msvc-crt-secure-no-warnings", "msvc_crt_secure_no_warnings") end,
         })
  option("jln-msvc-diagnostics-format", {
           showmenu=true,
           category=category,
           description="Controls the display of error and warning information (https://learn.microsoft.com/en-us/cpp/build/reference/diagnostics-compiler-diagnostic-options?view=msvc-170).\\n - classic: Which reports only the line number where the issue was found.\\n - column: Includes the column where the issue was found. This can help you identify the specific language construct or character that is causing the issue.\\n - caret: Includes the column where the issue was found and places a caret (^) under the location in the line of code where the issue was detected.",
           values={"default", "classic", "column", "caret"},
           default=default_options["msvc_diagnostics_format"] or default_options["jln-msvc-diagnostics-format"] or "caret",
           after_check=function(option) check_option("jln-msvc-diagnostics-format", "msvc_diagnostics_format") end,
         })
  option("jln-msvc-isystem", {
           showmenu=true,
           category=category,
           description="Warnings concerning external header (https://devblogs.microsoft.com/cppblog/broken-warnings-theory).",
           values={"default", "anglebrackets", "include_and_caexcludepath", "assumed"},
           default=default_options["msvc_isystem"] or default_options["jln-msvc-isystem"] or "default",
           after_check=function(option) check_option("jln-msvc-isystem", "msvc_isystem") end,
         })
  option("jln-msvc-isystem-with-template-instantiations-treated-as-non-external", {
           showmenu=true,
           category=category,
           description="Allows warnings from external headers when they occur in a template that\'s instantiated in your code. (requires msvc_isystem).",
           values={"default", "off", "on"},
           default=default_options["msvc_isystem_with_template_instantiations_treated_as_non_external"] or default_options["jln-msvc-isystem-with-template-instantiations-treated-as-non-external"] or "default",
           after_check=function(option) check_option("jln-msvc-isystem-with-template-instantiations-treated-as-non-external", "msvc_isystem_with_template_instantiations_treated_as_non_external") end,
         })
  option("jln-ndebug", {
           showmenu=true,
           category=category,
           description="Enable NDEBUG macro (disable assert macro).",
           values={"default", "off", "on", "with_optimization_1_or_above"},
           default=default_options["ndebug"] or default_options["jln-ndebug"] or "with_optimization_1_or_above",
           after_check=function(option) check_option("jln-ndebug", "ndebug") end,
         })
  option("jln-noexcept-warnings", {
           showmenu=true,
           category=category,
           description="Warn when a noexcept-expression evaluates to false because of a call to a function that does not have a non-throwing exception specification (i.e. \"throw()\" or \"noexcept\") but is known by the compiler to never throw an exception. Only with GCC.",
           values={"default", "off", "on"},
           default=default_options["noexcept_warnings"] or default_options["jln-noexcept-warnings"] or "default",
           after_check=function(option) check_option("jln-noexcept-warnings", "noexcept_warnings") end,
         })
  option("jln-optimization", {
           showmenu=true,
           category=category,
           description="Optimization level.\\n - 0: Not optimize.\\n - g: Enable debugging experience.\\n - 1: Optimize.\\n - 2: Optimize even more.\\n - 3: Optimize yet more.\\n - fast: Enables all optimization=3 and disregard strict standards compliance.\\n - size: Optimize for size.\\n - z: Optimize for size aggressively (/!\\ possible slow compilation with emcc).",
           values={"default", "0", "g", "1", "2", "3", "fast", "size", "z"},
           default=default_options["optimization"] or default_options["jln-optimization"] or "default",
           after_check=function(option) check_option("jln-optimization", "optimization") end,
         })
  option("jln-optimization-warnings", {
           showmenu=true,
           category=category,
           description="Activate warnings about optimization.",
           values={"default", "off", "on"},
           default=default_options["optimization_warnings"] or default_options["jln-optimization-warnings"] or "default",
           after_check=function(option) check_option("jln-optimization-warnings", "optimization_warnings") end,
         })
  option("jln-pedantic", {
           showmenu=true,
           category=category,
           description="Issue all the warnings demanded by strict ISO C and ISO C++.",
           values={"default", "off", "on", "as_error"},
           default=default_options["pedantic"] or default_options["jln-pedantic"] or "on",
           after_check=function(option) check_option("jln-pedantic", "pedantic") end,
         })
  option("jln-pie", {
           showmenu=true,
           category=category,
           description="Controls position-independent code generation.",
           values={"default", "off", "on", "static", "fpic", "fPIC", "fpie", "fPIE"},
           default=default_options["pie"] or default_options["jln-pie"] or "default",
           after_check=function(option) check_option("jln-pie", "pie") end,
         })
  option("jln-relro", {
           showmenu=true,
           category=category,
           description="Specifies a memory segment that should be made read-only after relocation, if supported.",
           values={"default", "off", "on", "full"},
           default=default_options["relro"] or default_options["jln-relro"] or "default",
           after_check=function(option) check_option("jln-relro", "relro") end,
         })
  option("jln-reproducible-build-warnings", {
           showmenu=true,
           category=category,
           description="Warn when macros \"__TIME__\", \"__DATE__\" or \"__TIMESTAMP__\" are encountered as they might prevent bit-wise-identical reproducible compilations.",
           values={"default", "off", "on"},
           default=default_options["reproducible_build_warnings"] or default_options["jln-reproducible-build-warnings"] or "default",
           after_check=function(option) check_option("jln-reproducible-build-warnings", "reproducible_build_warnings") end,
         })
  option("jln-rtti", {
           showmenu=true,
           category=category,
           description="Disable generation of information about every class with virtual functions for use by the C++ run-time type identification features (\"dynamic_cast\" and \"typeid\").",
           values={"default", "off", "on"},
           default=default_options["rtti"] or default_options["jln-rtti"] or "default",
           after_check=function(option) check_option("jln-rtti", "rtti") end,
         })
  option("jln-sanitizers", {
           showmenu=true,
           category=category,
           description="Enable sanitizers (asan, ubsan, etc) when available.\\n - on: Enable address sanitizer and other compatible sanitizers\\n - extra: Enable address sanitizer and other compatible sanitizers, even those who require a config via environment variable.\\n - address: Enable address sanitizer only.\\n - kernel: Enable kernel-address sanitizers and other compatible sanitizers\\n - kernel_extra: Enable kernel-address sanitizers and other compatible sanitizers, even those who require a config via environment variable.\\n - kernel_address: Enable kernel address sanitizer only.\\n - thread: Enable thread sanitizer.\\n - undefined: Enable undefined sanitizer.\\n - undefined_minimal_runtime: Enable undefined sanitizer with minimal UBSan runtime when available (Clang>=6).\\n - scudo_hardened_allocator: Enable Scudo Hardened Allocator with Clang. See https://llvm.org/docs/ScudoHardenedAllocator.html",
           values={"default", "off", "on", "extra", "address", "kernel", "kernel_extra", "kernel_extra", "kernel_address", "thread", "undefined", "undefined_minimal_runtime", "scudo_hardened_allocator"},
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
           description="Emit extra code to check for buffer overflows, such as stack smashing attacks.",
           values={"default", "off", "on", "strong", "all"},
           default=default_options["stack_protector"] or default_options["jln-stack-protector"] or "default",
           after_check=function(option) check_option("jln-stack-protector", "stack_protector") end,
         })
  option("jln-stl-fix", {
           showmenu=true,
           category=category,
           description="Enable /DNOMINMAX with msvc.",
           values={"default", "off", "on"},
           default=default_options["stl_fix"] or default_options["jln-stl-fix"] or "on",
           after_check=function(option) check_option("jln-stl-fix", "stl_fix") end,
         })
  option("jln-stl-hardening", {
           showmenu=true,
           category=category,
           description="Hardening allows turning some instances of undefined behavior in the standard library into a contract violation.\\n - fast: A set of security-critical checks that can be done with relatively little overhead in constant time and are intended to be used in production. No impact on the ABI.\\n - extensive: All the checks from fast mode and some additional checks for undefined behavior that incur relatively little overhead but aren’t security-critical. No impact on the ABI.\\n - debug: Enables all the available checks, including heuristic checks that might have significant performance overhead as well as internal library assertions. No impact on the ABI.\\n - debug_with_broken_abi: Debug mode with ABI incompatibility for more check.",
           values={"default", "off", "fast", "extensive", "debug", "debug_with_broken_abi"},
           default=default_options["stl_hardening"] or default_options["jln-stl-hardening"] or "default",
           after_check=function(option) check_option("jln-stl-hardening", "stl_hardening") end,
         })
  option("jln-suggest-attributes", {
           showmenu=true,
           category=category,
           description="Warn for cases where adding an attribute may be beneficial. With GCC, this  analysis requires option -fipa-pure-const, which is enabled by default at -O1 and higher.\\n - on: Suggests noreturn attribute with Clang and GCC.\\n - common: Suggests noreturn and format attributes with GCC ; noreturn with Clang.\\n - analysis: Suggests noreturn, format attributes, malloc and returns_nonnull attributes with GCC ; noreturn with Clang.\\n - unity: Suggests noreturn, format attributes and final on types and methods ; noreturn with Clang.\\n - all: Active all suggestions for attributes.",
           values={"default", "off", "on", "common", "analysis", "unity", "all"},
           default=default_options["suggest_attributes"] or default_options["jln-suggest-attributes"] or "on",
           after_check=function(option) check_option("jln-suggest-attributes", "suggest_attributes") end,
         })
  option("jln-switch-warnings", {
           showmenu=true,
           category=category,
           description="Warnings concerning the switch keyword.",
           values={"default", "on", "off", "exhaustive_enum", "mandatory_default", "exhaustive_enum_and_mandatory_default"},
           default=default_options["switch_warnings"] or default_options["jln-switch-warnings"] or "on",
           after_check=function(option) check_option("jln-switch-warnings", "switch_warnings") end,
         })
  option("jln-symbols", {
           showmenu=true,
           category=category,
           description="Produce debugging information in the operating system\'s.\\n - hidden: Use -fvisibility=hidden with Clang, GCC and other compilers that support this flag.\\n - strip_all: Strip all symbols.\\n - gc_sections: Enable garbage collection of unused sections.\\n - nodebug: Request no debugging information.\\n - debug: Request debugging information. How much information can be controlled with options \'minimal_debug\', and \'full_debug\'. If the level is not supported by a compiler, this is equivalent to the \'debug\' option.\\n - minimal_debug: If possible, produces information for tracebacks only. This includes descriptions of functions and external variables, and line number tables, but no information about local variables.\\n - full_debug: If possible, includes extra information, such as all the macro definitions present in the program.\\n - btf: GCC only. Request BTF debug information. BTF is the default debugging format for the eBPF  target.\\n - codeview: GCC only. Code View debug format (used by Microsoft Visual C++ on Windows).\\n - ctf: GCC only. Produce a CTF debug information. The default level is 2.\\n - ctf1: Level 1 produces CTF information for tracebacks only. This includes callsite information, but does not include type information.\\n - ctf2: Level 2 produces type information for entities (functions, data objects etc.)  at file-scope or global-scope only.\\n - vms: GCC only. Alpha/VMS debug format (used by DEBUG on Alpha/VMS systems).The default level is 2.\\n - vms1: Same as 1, but for Alpha/VMS.\\n - vms2: Same as 2, but for Alpha/VMS.\\n - vms3: Same as 3, but for Alpha/VMS.\\n - dbx: Clang only.\\n - lldb: Clang only.\\n - sce: Clang only.\\n - dwarf: Clang-cl only",
           values={"default", "hidden", "strip_all", "gc_sections", "nodebug", "debug", "minimal_debug", "full_debug", "btf", "codeview", "ctf", "ctf1", "ctf2", "vms", "vms1", "vms2", "vms3", "dbx", "lldb", "sce", "dwarf"},
           default=default_options["symbols"] or default_options["jln-symbols"] or "default",
           after_check=function(option) check_option("jln-symbols", "symbols") end,
         })
  option("jln-unsafe-buffer-usage-warnings", {
           showmenu=true,
           category=category,
           description="Enable -Wunsafe-buffer-usage with clang (https://clang.llvm.org/docs/SafeBuffers.html).",
           values={"default", "on", "off"},
           default=default_options["unsafe_buffer_usage_warnings"] or default_options["jln-unsafe-buffer-usage-warnings"] or "default",
           after_check=function(option) check_option("jln-unsafe-buffer-usage-warnings", "unsafe_buffer_usage_warnings") end,
         })
  option("jln-var-init", {
           showmenu=true,
           category=category,
           description="Initialize all stack variables implicitly, including padding.\\n - uninitialized: Doesn\'t initialize any automatic variables (default behavior of Clang and GCC).\\n - pattern: Initialize automatic variables with byte-repeatable pattern (0xFE for GCC, 0xAA for Clang).\\n - zero: zero Initialize automatic variables with zeroes.",
           values={"default", "uninitialized", "pattern", "zero"},
           default=default_options["var_init"] or default_options["jln-var-init"] or "default",
           after_check=function(option) check_option("jln-var-init", "var_init") end,
         })
  option("jln-warnings", {
           showmenu=true,
           category=category,
           description="Warning level.\\n - on: Activates essential warnings and extras.\\n - essential: Activates essential warnings, typically -Wall -Wextra or /W4).\\n - extensive: Activates essential warnings, extras and some that may raise false positives",
           values={"default", "off", "on", "essential", "extensive"},
           default=default_options["warnings"] or default_options["jln-warnings"] or "on",
           after_check=function(option) check_option("jln-warnings", "warnings") end,
         })
  option("jln-warnings-as-error", {
           showmenu=true,
           category=category,
           description="Make all or some warnings into errors.",
           values={"default", "off", "on", "basic"},
           default=default_options["warnings_as_error"] or default_options["jln-warnings-as-error"] or "default",
           after_check=function(option) check_option("jln-warnings-as-error", "warnings_as_error") end,
         })
  option("jln-windows-abi-compatibility-warnings", {
           showmenu=true,
           category=category,
           description="In code that is intended to be portable to Windows-based compilers the warning helps prevent unresolved references due to the difference in the mangling of symbols declared with different class-keys.",
           values={"default", "off", "on"},
           default=default_options["windows_abi_compatibility_warnings"] or default_options["jln-windows-abi-compatibility-warnings"] or "off",
           after_check=function(option) check_option("jln-windows-abi-compatibility-warnings", "windows_abi_compatibility_warnings") end,
         })
  option("jln-windows-bigobj", {
           showmenu=true,
           category=category,
           description="Increases that addressable sections capacity.",
           values={"default", "on"},
           default=default_options["windows_bigobj"] or default_options["jln-windows-bigobj"] or "on",
           after_check=function(option) check_option("jln-windows-bigobj", "windows_bigobj") end,
         })
  option("jln-cxx", {showmenu=true, description="Path or name of the compiler for jln functions", default=""})
  option("jln-cxx-version", {showmenu=true, description="Force the compiler version for jln functions", default=""})
  option("jln-ld", {showmenu=true, description="Path or name of the linker for jln functions", default=""})
end

jln_cxx_default_options_by_modes = {
  debug={
    control_flow='on',
    sanitizers='on',
    stl_hardening='debug',
    symbols='debug',
  },
  releasedbg={
    optimization='g',
    symbols='debug',
  },
  minsizerel={
    lto='on',
    optimization='size',
  },
  release={
    lto='on',
    optimization='3',
  },
}

local cached_flags = {}
local current_path = os.scriptdir()

local function _jln_cxx_rule_fn(target, module_name, rulename, options, extra_options, import)
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
end

local function _jln_table_clone(extra_options, options)
  if extra_options.clone_options then
    local cloned = {}
    for k, v in pairs(options) do
      cloned[k] = v
    end
    return cloned
  end
  return options
end

-- Set options for a specific mode (see also jln_cxx_rule()).
-- If options_by_modes is nil, a default configuration is used.
-- `options_by_modes` = {
--   [modename]: {
--     function() ... end, -- optional callback
--     stl_hardening='debug_with_broken_abi', ... -- options (see create_options())
--   }
-- }
-- `extra_options` = {
--   rulename :string = name for current mode (default value is '__jln_cxx_flags__')
--   other options are sent to jln_cxx_rule()
-- }
function jln_cxx_init_modes(options_by_modes, extra_options)
  extra_options = extra_options or {}
  local rulename = extra_options.rulename or '__jln_cxx_flags__'
  local module_name = extra_options.module_name or _module_name

  local options = {}

  for mode,opts in pairs(options_by_modes or jln_cxx_default_options_by_modes) do
    if is_mode(mode) then
      options = opts
      break
    end
  end

  local callback = options[1]
  options = _jln_table_clone(extra_options, options)

  rule(rulename)
    on_config(function(target)
      if callback then
        options[1] = nil
      end

      _jln_cxx_rule_fn(target, module_name, rulename, options, extra_options, import)

      if callback then
        options[1] = callback
        callback()
      end
    end)
  rule_end()
  add_rules(rulename)
end

-- Create a new rule. Options are added to the current configuration (see create_options())
-- `options`: same as create_options()
-- `extra_options` = {
--   module_name :string = module name used by on_config() in jln_cxx_rule()
--   clone_options :boolean = make an internal copy of options
--                            which prevents changing it after the call to jln_cxx_rule().
--                            (default: false)
--   other options are sent to get_flags()
-- }
function jln_cxx_rule(rulename, options, extra_options)
  extra_options = extra_options or {}
  local module_name = extra_options.module_name or _module_name

  options = _jln_table_clone(extra_options, options)

  rule(rulename)
    on_config(function(target)
      _jln_cxx_rule_fn(target, module_name, rulename, options, extra_options, import)
    end)
  rule_end()
end

