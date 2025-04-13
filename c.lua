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
--  Supported options are listed below by category.
--  The same option can be found in several categories.
--
--  The first value corresponds to the one used by default,
--  and the value `default` has no associated behavior.
--
--  Options with a default value other than `default` are listed below.
--
--  <!-- ./compiler-options.lua generators/list_options.lua --color --categorized -->
--  ```ini
--  # Warning:
--
--  warnings = on default off essential extensive
--  warnings_as_error = default off on basic
--  conversion_warnings = on default off sign float conversion all
--  covered_switch_default_warnings = on default off
--  fix_compiler_error = on default off
--  msvc_crt_secure_no_warnings = on default off
--  noexcept_warnings = default off on
--  reproducible_build_warnings = default off on
--  shadow_warnings = off default on local compatible_local all
--  suggestions = default off on
--  switch_warnings = on default off exhaustive_enum mandatory_default exhaustive_enum_and_mandatory_default
--  unsafe_buffer_usage_warnings = default on off
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
--  debug = default off on gdb lldb vms codeview dbx sce
--  debug_level = default 0 1 2 3 line_tables_only line_directives_only
--  stl_hardening = default off fast extensive debug debug_with_broken_abi
--  control_flow = default off on branch return allow_bugs
--  sanitizers = default off on
--  float_sanitizers = default off on
--  integer_sanitizers = default off on
--  other_sanitizers = default off thread pointer memory
--  var_init = default uninitialized pattern zero
--  ndebug = with_optimization_1_or_above default off on
--  optimization = default 0 g 1 2 3 fast size z
--
--  # Optimization:
--
--  cpu = default generic native
--  linker = default bfd gold lld mold native
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
--  stl_hardening = default off fast extensive debug debug_with_broken_abi
--
--  # Analyzer:
--
--  analyzer = default off on
--  analyzer_too_complex_warning = default off on
--  analyzer_verbosity = default 0 1 2 3
--
--  # Other:
--
--  color = default auto never always
--  coverage = default off on
--  diagnostics_format = default fixits patch print_source_range_info
--  diagnostics_show_template_tree = default off on
--  elide_type = default off on
--  msvc_diagnostics_format = caret default classic column
--  msvc_isystem = default anglebrackets include_and_caexcludepath external_as_include_system_flag assumed
--  msvc_isystem_with_template_from_non_external = default off on
--  pie = default off on static fpic fPIC fpie fPIE
--  windows_bigobj = on default
--  ```
--  <!-- ./compiler-options.lua -->
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
--  ### To know
--
--  - `control_flow=allow_bugs`
--    - clang: Can crash programs with "illegal hardware instruction" on totally unlikely lines. It can also cause link errors and force `-fvisibility=hidden` and `-flto`.
--  - `msvc_isystem=external_as_include_system_flag` is only available with `cmake`.
--  - `stl_hardening=debug`
--    - msvc: unlike `stl_hardening=debug_with_broken_abi`, STL debugging is not enabled by this option, as it breaks the ABI (only hardening mode is enabled on recent versions). However, as the `_DEBUG` macro can be defined in many different ways, STL debugging can be activated and the ABI broken.
--
--
--  ## Recommended options
--
--  category | options
--  ---------|---------
--  debug | `control_flow=on`<br>`debug=on`<br>`sanitizers=on`<br>`stl_hardening=debug_with_broken_abi` or `debug`<br>`optimization=g` or `optimization=0` + `debug_level=3`
--  release | `cpu=native`<br>`lto=on` or `thin`<br>`optimization=3`<br>`rtti=off`<br>`whole_program=strip_all`
--  security | `control_flow=on`<br>`relro=full`<br>`stack_protector=strong`<br>`pie=fPIE`<br>`stl_hardening=fast` or `extensive`
--  really strict warnings | `pedantic=as_error`<br>`shadow_warnings=local`<br>`suggestions=on`<br>`warnings=extensive`
--
--  

-- File generated with https://github.com/jonathanpoelen/cpp-compiler-options

local _jln_c_extraopt_flag_names = {
  ["jln-cc"] = true,
  ["cc"] = true,
  ["jln-cc-version"] = true,
  ["cc_version"] = true,
  ["jln-ld"] = true,
  ["ld"] = true,
}

local _jln_c_flag_names = {
  ["jln-analyzer"] = true,
  ["analyzer"] = true,
  ["jln-analyzer-too-complex-warning"] = true,
  ["analyzer_too_complex_warning"] = true,
  ["jln-analyzer-verbosity"] = true,
  ["analyzer_verbosity"] = true,
  ["jln-color"] = true,
  ["color"] = true,
  ["jln-control-flow"] = true,
  ["control_flow"] = true,
  ["jln-conversion-warnings"] = true,
  ["conversion_warnings"] = true,
  ["jln-coverage"] = true,
  ["coverage"] = true,
  ["jln-covered-switch-default-warnings"] = true,
  ["covered_switch_default_warnings"] = true,
  ["jln-cpu"] = true,
  ["cpu"] = true,
  ["jln-debug"] = true,
  ["debug"] = true,
  ["jln-debug-level"] = true,
  ["debug_level"] = true,
  ["jln-diagnostics-format"] = true,
  ["diagnostics_format"] = true,
  ["jln-exceptions"] = true,
  ["exceptions"] = true,
  ["jln-fix-compiler-error"] = true,
  ["fix_compiler_error"] = true,
  ["jln-float-sanitizers"] = true,
  ["float_sanitizers"] = true,
  ["jln-integer-sanitizers"] = true,
  ["integer_sanitizers"] = true,
  ["jln-linker"] = true,
  ["linker"] = true,
  ["jln-lto"] = true,
  ["lto"] = true,
  ["jln-msvc-conformance"] = true,
  ["msvc_conformance"] = true,
  ["jln-msvc-crt-secure-no-warnings"] = true,
  ["msvc_crt_secure_no_warnings"] = true,
  ["jln-msvc-diagnostics-format"] = true,
  ["msvc_diagnostics_format"] = true,
  ["jln-msvc-isystem"] = true,
  ["msvc_isystem"] = true,
  ["jln-ndebug"] = true,
  ["ndebug"] = true,
  ["jln-optimization"] = true,
  ["optimization"] = true,
  ["jln-other-sanitizers"] = true,
  ["other_sanitizers"] = true,
  ["jln-pedantic"] = true,
  ["pedantic"] = true,
  ["jln-pie"] = true,
  ["pie"] = true,
  ["jln-relro"] = true,
  ["relro"] = true,
  ["jln-reproducible-build-warnings"] = true,
  ["reproducible_build_warnings"] = true,
  ["jln-sanitizers"] = true,
  ["sanitizers"] = true,
  ["jln-shadow-warnings"] = true,
  ["shadow_warnings"] = true,
  ["jln-stack-protector"] = true,
  ["stack_protector"] = true,
  ["jln-stl-fix"] = true,
  ["stl_fix"] = true,
  ["jln-suggestions"] = true,
  ["suggestions"] = true,
  ["jln-switch-warnings"] = true,
  ["switch_warnings"] = true,
  ["jln-unsafe-buffer-usage-warnings"] = true,
  ["unsafe_buffer_usage_warnings"] = true,
  ["jln-var-init"] = true,
  ["var_init"] = true,
  ["jln-warnings"] = true,
  ["warnings"] = true,
  ["jln-warnings-as-error"] = true,
  ["warnings_as_error"] = true,
  ["jln-whole-program"] = true,
  ["whole_program"] = true,
  ["jln-windows-bigobj"] = true,
  ["windows_bigobj"] = true,
}

local _jln_c_check_flag_names = function(t)
  for k in pairs(t) do
    if not _jln_c_flag_names[k]
    and not _jln_c_extraopt_flag_names[k] then
      error("unknown '" .. k .. "' jln flag name")
    end
  end
end

function jln_c_newoptions(defaults)
  if defaults then
    _jln_c_check_flag_names(defaults)
  else
    defaults = {}
  end

  newoption{trigger="jln-analyzer", allowed={{'default'}, {'off'}, {'on'}}, description="Enables an static analysis. It can have false positives and false negatives. It is a bug-finding tool, rather than a tool for proving program correctness. Available only with GCC and MSVC."}
  if not _OPTIONS["jln-analyzer"] then _OPTIONS["jln-analyzer"] = (defaults["analyzer"] or defaults["jln-analyzer"] or "default") end

  newoption{trigger="jln-analyzer-too-complex-warning", allowed={{'default'}, {'off'}, {'on'}}, description="By default, the analysis silently stops if the code is too complicated for the analyzer to fully explore and it reaches an internal limit. This option warns if this occurs. Available only with GCC."}
  if not _OPTIONS["jln-analyzer-too-complex-warning"] then _OPTIONS["jln-analyzer-too-complex-warning"] = (defaults["analyzer_too_complex_warning"] or defaults["jln-analyzer-too-complex-warning"] or "default") end

  newoption{trigger="jln-analyzer-verbosity", allowed={{'default'}, {'0', 'At this level, interprocedural call and return events are displayed, along with the most pertinent state-change events relating to a diagnostic. For example, for a double-free diagnostic, both calls to free will be shown.'}, {'1', 'As per the previous level, but also show events for the entry to each function.'}, {'2', 'As per the previous level, but also show events relating to control flow that are significant to triggering the issue (e.g. “true path taken” at a conditional). This level is the default.'}, {'3', 'As per the previous level, but show all control flow events, not just significant ones.'}}, description="Controls the complexity of the control flow paths that are emitted for analyzer diagnostics. Available only with GCC."}
  if not _OPTIONS["jln-analyzer-verbosity"] then _OPTIONS["jln-analyzer-verbosity"] = (defaults["analyzer_verbosity"] or defaults["jln-analyzer-verbosity"] or "default") end

  newoption{trigger="jln-color", allowed={{'default'}, {'auto'}, {'never'}, {'always'}}, description=""}
  if not _OPTIONS["jln-color"] then _OPTIONS["jln-color"] = (defaults["color"] or defaults["jln-color"] or "default") end

  newoption{trigger="jln-control-flow", allowed={{'default'}, {'off'}, {'on'}, {'branch'}, {'return'}, {'allow_bugs'}}, description="Insert extra runtime security checks to detect attempts to compromise your code."}
  if not _OPTIONS["jln-control-flow"] then _OPTIONS["jln-control-flow"] = (defaults["control_flow"] or defaults["jln-control-flow"] or "default") end

  newoption{trigger="jln-conversion-warnings", allowed={{'default'}, {'off'}, {'on', 'Combine conversion and sign value'}, {'sign', 'Warn for implicit conversions that may change the sign (lke `unsigned_integer = signed_integer`) or a comparison between signed and unsigned values could produce an incorrect result when the signed value is converted to unsigned.'}, {'float', 'Warn for implicit conversions that reduce the precision of a real value.'}, {'conversion', 'Warn for implicit conversions that may alter a value.'}, {'all', 'Like conversion and also warn about implicit conversions from arithmetic operations even when conversion of the operands to the same type cannot change their values.'}}, description="Warn for implicit conversions that may alter a value."}
  if not _OPTIONS["jln-conversion-warnings"] then _OPTIONS["jln-conversion-warnings"] = (defaults["conversion_warnings"] or defaults["jln-conversion-warnings"] or "on") end

  newoption{trigger="jln-coverage", allowed={{'default'}, {'off'}, {'on'}}, description=""}
  if not _OPTIONS["jln-coverage"] then _OPTIONS["jln-coverage"] = (defaults["coverage"] or defaults["jln-coverage"] or "default") end

  newoption{trigger="jln-covered-switch-default-warnings", allowed={{'default'}, {'on'}, {'off'}}, description="Warning for default label in switch which covers all enumeration values."}
  if not _OPTIONS["jln-covered-switch-default-warnings"] then _OPTIONS["jln-covered-switch-default-warnings"] = (defaults["covered_switch_default_warnings"] or defaults["jln-covered-switch-default-warnings"] or "on") end

  newoption{trigger="jln-cpu", allowed={{'default'}, {'generic'}, {'native'}}, description=""}
  if not _OPTIONS["jln-cpu"] then _OPTIONS["jln-cpu"] = (defaults["cpu"] or defaults["jln-cpu"] or "default") end

  newoption{trigger="jln-debug", allowed={{'default'}, {'off'}, {'on'}, {'gdb'}, {'lldb'}, {'vms', 'Alpha/VMS debug format (used by DEBUG on Alpha/VMS systems).'}, {'codeview', 'CodeView debug format (used by Microsoft Visual C++ on Windows).'}, {'dbx'}, {'sce'}}, description="Produce debugging information in the operating system\'s."}
  if not _OPTIONS["jln-debug"] then _OPTIONS["jln-debug"] = (defaults["debug"] or defaults["jln-debug"] or "default") end

  newoption{trigger="jln-debug-level", allowed={{'default'}, {'0'}, {'1'}, {'2'}, {'3'}, {'line_tables_only', 'Emit debug line number tables only.'}, {'line_directives_only', 'Emit debug line info directives only.'}}, description="Specify debugging level"}
  if not _OPTIONS["jln-debug-level"] then _OPTIONS["jln-debug-level"] = (defaults["debug_level"] or defaults["jln-debug-level"] or "default") end

  newoption{trigger="jln-diagnostics-format", allowed={{'default'}, {'fixits'}, {'patch'}, {'print_source_range_info'}}, description="Emit fix-it hints in a machine-parseable format."}
  if not _OPTIONS["jln-diagnostics-format"] then _OPTIONS["jln-diagnostics-format"] = (defaults["diagnostics_format"] or defaults["jln-diagnostics-format"] or "default") end

  newoption{trigger="jln-exceptions", allowed={{'default'}, {'off'}, {'on'}}, description="Enable C++ exceptions."}
  if not _OPTIONS["jln-exceptions"] then _OPTIONS["jln-exceptions"] = (defaults["exceptions"] or defaults["jln-exceptions"] or "default") end

  newoption{trigger="jln-fix-compiler-error", allowed={{'default'}, {'off'}, {'on'}}, description="Transforms some warnings into errors to comply with the standard."}
  if not _OPTIONS["jln-fix-compiler-error"] then _OPTIONS["jln-fix-compiler-error"] = (defaults["fix_compiler_error"] or defaults["jln-fix-compiler-error"] or "on") end

  newoption{trigger="jln-float-sanitizers", allowed={{'default'}, {'off'}, {'on'}}, description=""}
  if not _OPTIONS["jln-float-sanitizers"] then _OPTIONS["jln-float-sanitizers"] = (defaults["float_sanitizers"] or defaults["jln-float-sanitizers"] or "default") end

  newoption{trigger="jln-integer-sanitizers", allowed={{'default'}, {'off'}, {'on'}}, description=""}
  if not _OPTIONS["jln-integer-sanitizers"] then _OPTIONS["jln-integer-sanitizers"] = (defaults["integer_sanitizers"] or defaults["jln-integer-sanitizers"] or "default") end

  newoption{trigger="jln-linker", allowed={{'default'}, {'bfd'}, {'gold'}, {'lld'}, {'mold'}, {'native'}}, description="Configure linker."}
  if not _OPTIONS["jln-linker"] then _OPTIONS["jln-linker"] = (defaults["linker"] or defaults["jln-linker"] or "default") end

  newoption{trigger="jln-lto", allowed={{'default'}, {'off'}, {'on'}, {'normal'}, {'fat'}, {'thin'}}, description="Enable Link Time Optimization."}
  if not _OPTIONS["jln-lto"] then _OPTIONS["jln-lto"] = (defaults["lto"] or defaults["jln-lto"] or "default") end

  newoption{trigger="jln-msvc-conformance", allowed={{'default'}, {'all'}, {'all_without_throwing_new'}}, description="Standard conformance options."}
  if not _OPTIONS["jln-msvc-conformance"] then _OPTIONS["jln-msvc-conformance"] = (defaults["msvc_conformance"] or defaults["jln-msvc-conformance"] or "all") end

  newoption{trigger="jln-msvc-crt-secure-no-warnings", allowed={{'default'}, {'off'}, {'on'}}, description="Disable CRT warnings with MSVC."}
  if not _OPTIONS["jln-msvc-crt-secure-no-warnings"] then _OPTIONS["jln-msvc-crt-secure-no-warnings"] = (defaults["msvc_crt_secure_no_warnings"] or defaults["jln-msvc-crt-secure-no-warnings"] or "on") end

  newoption{trigger="jln-msvc-diagnostics-format", allowed={{'default'}, {'classic', 'Which reports only the line number where the issue was found.'}, {'column', 'Includes the column where the issue was found. This can help you identify the specific language construct or character that is causing the issue.'}, {'caret', 'Includes the column where the issue was found and places a caret (^) under the location in the line of code where the issue was detected.'}}, description="Controls the display of error and warning information (https://learn.microsoft.com/en-us/cpp/build/reference/diagnostics-compiler-diagnostic-options?view=msvc-170)."}
  if not _OPTIONS["jln-msvc-diagnostics-format"] then _OPTIONS["jln-msvc-diagnostics-format"] = (defaults["msvc_diagnostics_format"] or defaults["jln-msvc-diagnostics-format"] or "caret") end

  newoption{trigger="jln-msvc-isystem", allowed={{'default'}, {'anglebrackets'}, {'include_and_caexcludepath'}, {'assumed'}}, description="Warnings concerning external header (https://devblogs.microsoft.com/cppblog/broken-warnings-theory)."}
  if not _OPTIONS["jln-msvc-isystem"] then _OPTIONS["jln-msvc-isystem"] = (defaults["msvc_isystem"] or defaults["jln-msvc-isystem"] or "default") end

  newoption{trigger="jln-ndebug", allowed={{'default'}, {'off'}, {'on'}, {'with_optimization_1_or_above'}}, description="Enable NDEBUG macro (disable assert macro)."}
  if not _OPTIONS["jln-ndebug"] then _OPTIONS["jln-ndebug"] = (defaults["ndebug"] or defaults["jln-ndebug"] or "with_optimization_1_or_above") end

  newoption{trigger="jln-optimization", allowed={{'default'}, {'0', 'Not optimize.'}, {'g', 'Enable debugging experience.'}, {'1', 'Optimize.'}, {'2', 'Optimize even more.'}, {'3', 'Optimize yet more.'}, {'fast', 'Enables all optimization=3 and disregard strict standards compliance.'}, {'size', 'Optimize for size.'}, {'z', 'Optimize for size aggressively (/!\\ possible slow compilation with emcc).'}}, description="Optimization level."}
  if not _OPTIONS["jln-optimization"] then _OPTIONS["jln-optimization"] = (defaults["optimization"] or defaults["jln-optimization"] or "default") end

  newoption{trigger="jln-other-sanitizers", allowed={{'default'}, {'off'}, {'thread'}, {'pointer'}, {'memory'}}, description="Enable other sanitizers."}
  if not _OPTIONS["jln-other-sanitizers"] then _OPTIONS["jln-other-sanitizers"] = (defaults["other_sanitizers"] or defaults["jln-other-sanitizers"] or "default") end

  newoption{trigger="jln-pedantic", allowed={{'default'}, {'off'}, {'on'}, {'as_error'}}, description="Issue all the warnings demanded by strict ISO C and ISO C++."}
  if not _OPTIONS["jln-pedantic"] then _OPTIONS["jln-pedantic"] = (defaults["pedantic"] or defaults["jln-pedantic"] or "on") end

  newoption{trigger="jln-pie", allowed={{'default'}, {'off'}, {'on'}, {'static'}, {'fpic'}, {'fPIC'}, {'fpie'}, {'fPIE'}}, description="Controls position-independent code generation."}
  if not _OPTIONS["jln-pie"] then _OPTIONS["jln-pie"] = (defaults["pie"] or defaults["jln-pie"] or "default") end

  newoption{trigger="jln-relro", allowed={{'default'}, {'off'}, {'on'}, {'full'}}, description="Specifies a memory segment that should be made read-only after relocation, if supported."}
  if not _OPTIONS["jln-relro"] then _OPTIONS["jln-relro"] = (defaults["relro"] or defaults["jln-relro"] or "default") end

  newoption{trigger="jln-reproducible-build-warnings", allowed={{'default'}, {'off'}, {'on'}}, description="Warn when macros \"__TIME__\", \"__DATE__\" or \"__TIMESTAMP__\" are encountered as they might prevent bit-wise-identical reproducible compilations."}
  if not _OPTIONS["jln-reproducible-build-warnings"] then _OPTIONS["jln-reproducible-build-warnings"] = (defaults["reproducible_build_warnings"] or defaults["jln-reproducible-build-warnings"] or "default") end

  newoption{trigger="jln-sanitizers", allowed={{'default'}, {'off'}, {'on'}}, description="Enable sanitizers (asan, ubsan, etc)."}
  if not _OPTIONS["jln-sanitizers"] then _OPTIONS["jln-sanitizers"] = (defaults["sanitizers"] or defaults["jln-sanitizers"] or "default") end

  newoption{trigger="jln-shadow-warnings", allowed={{'default'}, {'off'}, {'on'}, {'local'}, {'compatible_local'}, {'all'}}, description=""}
  if not _OPTIONS["jln-shadow-warnings"] then _OPTIONS["jln-shadow-warnings"] = (defaults["shadow_warnings"] or defaults["jln-shadow-warnings"] or "off") end

  newoption{trigger="jln-stack-protector", allowed={{'default'}, {'off'}, {'on'}, {'strong'}, {'all'}}, description="Emit extra code to check for buffer overflows, such as stack smashing attacks."}
  if not _OPTIONS["jln-stack-protector"] then _OPTIONS["jln-stack-protector"] = (defaults["stack_protector"] or defaults["jln-stack-protector"] or "default") end

  newoption{trigger="jln-stl-fix", allowed={{'default'}, {'off'}, {'on'}}, description="Enable /DNOMINMAX with msvc."}
  if not _OPTIONS["jln-stl-fix"] then _OPTIONS["jln-stl-fix"] = (defaults["stl_fix"] or defaults["jln-stl-fix"] or "on") end

  newoption{trigger="jln-suggestions", allowed={{'default'}, {'off'}, {'on'}}, description="Warn for cases where adding an attribute may be beneficial."}
  if not _OPTIONS["jln-suggestions"] then _OPTIONS["jln-suggestions"] = (defaults["suggestions"] or defaults["jln-suggestions"] or "default") end

  newoption{trigger="jln-switch-warnings", allowed={{'default'}, {'on'}, {'off'}, {'exhaustive_enum'}, {'mandatory_default'}, {'exhaustive_enum_and_mandatory_default'}}, description="Warnings concerning the switch keyword."}
  if not _OPTIONS["jln-switch-warnings"] then _OPTIONS["jln-switch-warnings"] = (defaults["switch_warnings"] or defaults["jln-switch-warnings"] or "on") end

  newoption{trigger="jln-unsafe-buffer-usage-warnings", allowed={{'default'}, {'on'}, {'off'}}, description="Enable -Wunsafe-buffer-usage with clang (https://clang.llvm.org/docs/SafeBuffers.html)."}
  if not _OPTIONS["jln-unsafe-buffer-usage-warnings"] then _OPTIONS["jln-unsafe-buffer-usage-warnings"] = (defaults["unsafe_buffer_usage_warnings"] or defaults["jln-unsafe-buffer-usage-warnings"] or "default") end

  newoption{trigger="jln-var-init", allowed={{'default'}, {'uninitialized', 'Doesn\'t initialize any automatic variables (default behavior of Gcc and Clang).'}, {'pattern', 'Initialize automatic variables with byte-repeatable pattern (0xFE for Gcc, 0xAA for Clang).'}, {'zero', 'zero Initialize automatic variables with zeroes.'}}, description="Initialize all stack variables implicitly, including padding."}
  if not _OPTIONS["jln-var-init"] then _OPTIONS["jln-var-init"] = (defaults["var_init"] or defaults["jln-var-init"] or "default") end

  newoption{trigger="jln-warnings", allowed={{'default'}, {'off'}, {'on', 'Activates essential warnings and extras.'}, {'essential', 'Activates essential warnings, typically -Wall -Wextra or /W4).'}, {'extensive', 'Activates essential warnings, extras and some that may raise false positives'}}, description="Warning level."}
  if not _OPTIONS["jln-warnings"] then _OPTIONS["jln-warnings"] = (defaults["warnings"] or defaults["jln-warnings"] or "on") end

  newoption{trigger="jln-warnings-as-error", allowed={{'default'}, {'off'}, {'on'}, {'basic'}}, description="Make all or some warnings into errors."}
  if not _OPTIONS["jln-warnings-as-error"] then _OPTIONS["jln-warnings-as-error"] = (defaults["warnings_as_error"] or defaults["jln-warnings-as-error"] or "default") end

  newoption{trigger="jln-whole-program", allowed={{'default'}, {'off'}, {'on'}, {'strip_all'}}, description="Assume that the current compilation unit represents the whole program being compiled. This option should not be used in combination with lto."}
  if not _OPTIONS["jln-whole-program"] then _OPTIONS["jln-whole-program"] = (defaults["whole_program"] or defaults["jln-whole-program"] or "default") end

  newoption{trigger="jln-windows-bigobj", allowed={{'default'}, {'on'}}, description="Increases that addressable sections capacity."}
  if not _OPTIONS["jln-windows-bigobj"] then _OPTIONS["jln-windows-bigobj"] = (defaults["windows_bigobj"] or defaults["jln-windows-bigobj"] or "on") end
  newoption{trigger="jln-cc", description="Path or name of the compiler for jln functions"}
  newoption{trigger="jln-cc-version", description="Force the compiler version for jln functions"}
  newoption{trigger="jln-ld", description="Path or name of the linker for jln functions"}
end

-- same as jln_c_getoptions
function jln_c_setoptions(compiler, version, values, disable_others, print_compiler)
  local options = jln_c_getoptions(compiler, version, values, disable_others, print_compiler)
  buildoptions(options.buildoptions)
  linkoptions(options.linkoptions)
  return options
end

local _jln_c_compiler_by_os = {
  windows='msvc',
  linux='gcc',
  cygwin='gcc',
  mingw='gcc',
  bsd='gcc',
  macosx='clang',
}

local _jln_c_default_compiler = 'gcc'
local _jln_c_comp_cache = {}

local _get_extra = function(opt)
  local x = _OPTIONS[opt]
  return x ~= '' and x or nil
end

-- Returns the merge of the default values and new value table
-- jln_c_tovalues(table, disable_others = false)
-- `values`: table. ex: {warnings='on'}
-- `values` can have 3 additional fields:
--  - `cxx`: compiler name (otherwise deducted from --cxx and --toolchain)
--  - `cxx_version`: compiler version (otherwise deducted from cxx). ex: '7', '7.2'
--  - `ld`: linker name
function jln_c_tovalues(values, disable_others)
  if values then
    _jln_c_check_flag_names(values)
    return {
      ["analyzer"] = values["analyzer"] or values["jln-analyzer"] or (disable_others and "default" or _OPTIONS["jln-analyzer"]),
      ["analyzer_too_complex_warning"] = values["analyzer_too_complex_warning"] or values["jln-analyzer-too-complex-warning"] or (disable_others and "default" or _OPTIONS["jln-analyzer-too-complex-warning"]),
      ["analyzer_verbosity"] = values["analyzer_verbosity"] or values["jln-analyzer-verbosity"] or (disable_others and "default" or _OPTIONS["jln-analyzer-verbosity"]),
      ["color"] = values["color"] or values["jln-color"] or (disable_others and "default" or _OPTIONS["jln-color"]),
      ["control_flow"] = values["control_flow"] or values["jln-control-flow"] or (disable_others and "default" or _OPTIONS["jln-control-flow"]),
      ["conversion_warnings"] = values["conversion_warnings"] or values["jln-conversion-warnings"] or (disable_others and "default" or _OPTIONS["jln-conversion-warnings"]),
      ["coverage"] = values["coverage"] or values["jln-coverage"] or (disable_others and "default" or _OPTIONS["jln-coverage"]),
      ["covered_switch_default_warnings"] = values["covered_switch_default_warnings"] or values["jln-covered-switch-default-warnings"] or (disable_others and "default" or _OPTIONS["jln-covered-switch-default-warnings"]),
      ["cpu"] = values["cpu"] or values["jln-cpu"] or (disable_others and "default" or _OPTIONS["jln-cpu"]),
      ["debug"] = values["debug"] or values["jln-debug"] or (disable_others and "default" or _OPTIONS["jln-debug"]),
      ["debug_level"] = values["debug_level"] or values["jln-debug-level"] or (disable_others and "default" or _OPTIONS["jln-debug-level"]),
      ["diagnostics_format"] = values["diagnostics_format"] or values["jln-diagnostics-format"] or (disable_others and "default" or _OPTIONS["jln-diagnostics-format"]),
      ["exceptions"] = values["exceptions"] or values["jln-exceptions"] or (disable_others and "default" or _OPTIONS["jln-exceptions"]),
      ["fix_compiler_error"] = values["fix_compiler_error"] or values["jln-fix-compiler-error"] or (disable_others and "default" or _OPTIONS["jln-fix-compiler-error"]),
      ["float_sanitizers"] = values["float_sanitizers"] or values["jln-float-sanitizers"] or (disable_others and "default" or _OPTIONS["jln-float-sanitizers"]),
      ["integer_sanitizers"] = values["integer_sanitizers"] or values["jln-integer-sanitizers"] or (disable_others and "default" or _OPTIONS["jln-integer-sanitizers"]),
      ["linker"] = values["linker"] or values["jln-linker"] or (disable_others and "default" or _OPTIONS["jln-linker"]),
      ["lto"] = values["lto"] or values["jln-lto"] or (disable_others and "default" or _OPTIONS["jln-lto"]),
      ["msvc_conformance"] = values["msvc_conformance"] or values["jln-msvc-conformance"] or (disable_others and "default" or _OPTIONS["jln-msvc-conformance"]),
      ["msvc_crt_secure_no_warnings"] = values["msvc_crt_secure_no_warnings"] or values["jln-msvc-crt-secure-no-warnings"] or (disable_others and "default" or _OPTIONS["jln-msvc-crt-secure-no-warnings"]),
      ["msvc_diagnostics_format"] = values["msvc_diagnostics_format"] or values["jln-msvc-diagnostics-format"] or (disable_others and "default" or _OPTIONS["jln-msvc-diagnostics-format"]),
      ["msvc_isystem"] = values["msvc_isystem"] or values["jln-msvc-isystem"] or (disable_others and "default" or _OPTIONS["jln-msvc-isystem"]),
      ["ndebug"] = values["ndebug"] or values["jln-ndebug"] or (disable_others and "default" or _OPTIONS["jln-ndebug"]),
      ["optimization"] = values["optimization"] or values["jln-optimization"] or (disable_others and "default" or _OPTIONS["jln-optimization"]),
      ["other_sanitizers"] = values["other_sanitizers"] or values["jln-other-sanitizers"] or (disable_others and "default" or _OPTIONS["jln-other-sanitizers"]),
      ["pedantic"] = values["pedantic"] or values["jln-pedantic"] or (disable_others and "default" or _OPTIONS["jln-pedantic"]),
      ["pie"] = values["pie"] or values["jln-pie"] or (disable_others and "default" or _OPTIONS["jln-pie"]),
      ["relro"] = values["relro"] or values["jln-relro"] or (disable_others and "default" or _OPTIONS["jln-relro"]),
      ["reproducible_build_warnings"] = values["reproducible_build_warnings"] or values["jln-reproducible-build-warnings"] or (disable_others and "default" or _OPTIONS["jln-reproducible-build-warnings"]),
      ["sanitizers"] = values["sanitizers"] or values["jln-sanitizers"] or (disable_others and "default" or _OPTIONS["jln-sanitizers"]),
      ["shadow_warnings"] = values["shadow_warnings"] or values["jln-shadow-warnings"] or (disable_others and "default" or _OPTIONS["jln-shadow-warnings"]),
      ["stack_protector"] = values["stack_protector"] or values["jln-stack-protector"] or (disable_others and "default" or _OPTIONS["jln-stack-protector"]),
      ["stl_fix"] = values["stl_fix"] or values["jln-stl-fix"] or (disable_others and "default" or _OPTIONS["jln-stl-fix"]),
      ["suggestions"] = values["suggestions"] or values["jln-suggestions"] or (disable_others and "default" or _OPTIONS["jln-suggestions"]),
      ["switch_warnings"] = values["switch_warnings"] or values["jln-switch-warnings"] or (disable_others and "default" or _OPTIONS["jln-switch-warnings"]),
      ["unsafe_buffer_usage_warnings"] = values["unsafe_buffer_usage_warnings"] or values["jln-unsafe-buffer-usage-warnings"] or (disable_others and "default" or _OPTIONS["jln-unsafe-buffer-usage-warnings"]),
      ["var_init"] = values["var_init"] or values["jln-var-init"] or (disable_others and "default" or _OPTIONS["jln-var-init"]),
      ["warnings"] = values["warnings"] or values["jln-warnings"] or (disable_others and "default" or _OPTIONS["jln-warnings"]),
      ["warnings_as_error"] = values["warnings_as_error"] or values["jln-warnings-as-error"] or (disable_others and "default" or _OPTIONS["jln-warnings-as-error"]),
      ["whole_program"] = values["whole_program"] or values["jln-whole-program"] or (disable_others and "default" or _OPTIONS["jln-whole-program"]),
      ["windows_bigobj"] = values["windows_bigobj"] or values["jln-windows-bigobj"] or (disable_others and "default" or _OPTIONS["jln-windows-bigobj"]),
      ["cc"] = values["cc"] or values["jln-cc"] or (not disable_others and _get_extra("jln-cc")) or nil,
      ["cc_version"] = values["cc_version"] or values["jln-cc-version"] or (not disable_others and _get_extra("jln-cc-version")) or nil,
      ["ld"] = values["ld"] or values["jln-ld"] or (not disable_others and _get_extra("jln-ld")) or nil,
}
  else
    return {
      ["analyzer"] = _OPTIONS["jln-analyzer"],
      ["analyzer_too_complex_warning"] = _OPTIONS["jln-analyzer-too-complex-warning"],
      ["analyzer_verbosity"] = _OPTIONS["jln-analyzer-verbosity"],
      ["color"] = _OPTIONS["jln-color"],
      ["control_flow"] = _OPTIONS["jln-control-flow"],
      ["conversion_warnings"] = _OPTIONS["jln-conversion-warnings"],
      ["coverage"] = _OPTIONS["jln-coverage"],
      ["covered_switch_default_warnings"] = _OPTIONS["jln-covered-switch-default-warnings"],
      ["cpu"] = _OPTIONS["jln-cpu"],
      ["debug"] = _OPTIONS["jln-debug"],
      ["debug_level"] = _OPTIONS["jln-debug-level"],
      ["diagnostics_format"] = _OPTIONS["jln-diagnostics-format"],
      ["exceptions"] = _OPTIONS["jln-exceptions"],
      ["fix_compiler_error"] = _OPTIONS["jln-fix-compiler-error"],
      ["float_sanitizers"] = _OPTIONS["jln-float-sanitizers"],
      ["integer_sanitizers"] = _OPTIONS["jln-integer-sanitizers"],
      ["linker"] = _OPTIONS["jln-linker"],
      ["lto"] = _OPTIONS["jln-lto"],
      ["msvc_conformance"] = _OPTIONS["jln-msvc-conformance"],
      ["msvc_crt_secure_no_warnings"] = _OPTIONS["jln-msvc-crt-secure-no-warnings"],
      ["msvc_diagnostics_format"] = _OPTIONS["jln-msvc-diagnostics-format"],
      ["msvc_isystem"] = _OPTIONS["jln-msvc-isystem"],
      ["ndebug"] = _OPTIONS["jln-ndebug"],
      ["optimization"] = _OPTIONS["jln-optimization"],
      ["other_sanitizers"] = _OPTIONS["jln-other-sanitizers"],
      ["pedantic"] = _OPTIONS["jln-pedantic"],
      ["pie"] = _OPTIONS["jln-pie"],
      ["relro"] = _OPTIONS["jln-relro"],
      ["reproducible_build_warnings"] = _OPTIONS["jln-reproducible-build-warnings"],
      ["sanitizers"] = _OPTIONS["jln-sanitizers"],
      ["shadow_warnings"] = _OPTIONS["jln-shadow-warnings"],
      ["stack_protector"] = _OPTIONS["jln-stack-protector"],
      ["stl_fix"] = _OPTIONS["jln-stl-fix"],
      ["suggestions"] = _OPTIONS["jln-suggestions"],
      ["switch_warnings"] = _OPTIONS["jln-switch-warnings"],
      ["unsafe_buffer_usage_warnings"] = _OPTIONS["jln-unsafe-buffer-usage-warnings"],
      ["var_init"] = _OPTIONS["jln-var-init"],
      ["warnings"] = _OPTIONS["jln-warnings"],
      ["warnings_as_error"] = _OPTIONS["jln-warnings-as-error"],
      ["whole_program"] = _OPTIONS["jln-whole-program"],
      ["windows_bigobj"] = _OPTIONS["jln-windows-bigobj"],
      ["cc"] = _get_extra("jln-cc"),
      ["cc_version"] = _get_extra("jln-cc-version"),
      ["ld"] = _get_extra("jln-ld"),
}
  end
end

-- jln_c_getoptions(values = {}, disable_others = false, print_compiler = false)
-- `values`: same as jln_c_tovalue()
-- `disable_others`: boolean
-- `print_compiler`: boolean
-- return {buildoptions={}, linkoptions={}}
function jln_c_getoptions(values, disable_others, print_compiler)
  values = jln_c_tovalues(values, disable_others)
  local compiler = values.cc  local version = values.cc_version
  local linker = values.ld or (not disable_others and _OPTIONS['ld']) or nil

  local cache = _jln_c_comp_cache
  local original_compiler = compiler or ''
  local compcache = cache[original_compiler]

  local table_insert = table.insert

  if compcache then
    compiler = compcache[1]
    version = compcache[2]
    if not compiler then
      -- printf("WARNING: unknown compiler")
      return {buildoptions={}, linkoptions={}}
    end
  else
    cache[original_compiler] = {}

    if not compiler then
      compiler = _OPTIONS['jln-compiler']
              or _OPTIONS['cc']
              or _jln_c_compiler_by_os[os.target()]
              or _jln_c_default_compiler
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
                 (compiler:find('icp?c', 1, true) and 'icc') or
                 (compiler:find('icl', 1, true) and 'icl') or
                 ((compiler:find('ico?x', 1, true) or
                   compiler:find('dpcpp', 1, true)
                  ) and 'icx') or
                 (compiler:find('emcc', 1, true) and 'clang-emcc') or
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

    local versparts = {}
    for i in version:gmatch("%d+") do
      table_insert(versparts, tonumber(i))
    end

    if versparts[1] then
      version = versparts[1] * 100000 + (versparts[2] or 0)
    else
      wprint("Wrong version format: %s", version)
      version = 0
    end

    cache[original_compiler] = {compiler, version}
  end

  if print_compiler then
    printf("jln_c_getoptions: compiler: %s, version: %s", compiler, version)
  end

  local is_clang_like = compiler:find('^clang')

  local jln_buildoptions, jln_linkoptions = {}, {}

  if values['ndebug'] ~= 'default' then
    if ( compiler == 'msvc' or compiler == 'icl' ) then
      if values['ndebug'] == 'off' then
        table_insert(jln_buildoptions, "/UNDEBUG")
      else
        if values['ndebug'] == 'on' then
          table_insert(jln_buildoptions, "/DNDEBUG")
        else
          if values['optimization'] ~= 'default' and not ( values['optimization'] == '0' or values['optimization'] == 'g' ) then
            table_insert(jln_buildoptions, "/DNDEBUG")
          end
        end
      end
    else
      if values['ndebug'] == 'off' then
        table_insert(jln_buildoptions, "-UNDEBUG")
      else
        if values['ndebug'] == 'on' then
          table_insert(jln_buildoptions, "-DNDEBUG")
        else
          if values['optimization'] ~= 'default' and not ( values['optimization'] == '0' or values['optimization'] == 'g' ) then
            table_insert(jln_buildoptions, "-DNDEBUG")
          end
        end
      end
    end
  end
  if ( compiler == 'gcc' or is_clang_like ) then
    if values['warnings'] ~= 'default' then
      if values['warnings'] == 'off' then
        table_insert(jln_buildoptions, "-w")
      else
        if values['warnings'] == 'essential' then
          table_insert(jln_buildoptions, "-Wall")
          table_insert(jln_buildoptions, "-Wextra")
          table_insert(jln_buildoptions, "-Wwrite-strings")
        else
          if compiler == 'gcc' then
            table_insert(jln_buildoptions, "-Wall")
            table_insert(jln_buildoptions, "-Wextra")
            if version < 800000 then
              table_insert(jln_buildoptions, "-Wcast-align")
            end
            table_insert(jln_buildoptions, "-Wcast-qual")
            table_insert(jln_buildoptions, "-Wdisabled-optimization")
            table_insert(jln_buildoptions, "-Wfloat-equal")
            table_insert(jln_buildoptions, "-Wformat-security")
            table_insert(jln_buildoptions, "-Wformat=2")
            table_insert(jln_buildoptions, "-Winvalid-pch")
            table_insert(jln_buildoptions, "-Wmissing-declarations")
            table_insert(jln_buildoptions, "-Wmissing-include-dirs")
            table_insert(jln_buildoptions, "-Wpacked")
            table_insert(jln_buildoptions, "-Wredundant-decls")
            table_insert(jln_buildoptions, "-Wundef")
            table_insert(jln_buildoptions, "-Wunused-macros")
            table_insert(jln_buildoptions, "-Wpointer-arith")
            table_insert(jln_buildoptions, "-Wbad-function-cast")
            table_insert(jln_buildoptions, "-Winit-self")
            table_insert(jln_buildoptions, "-Wjump-misses-init")
            table_insert(jln_buildoptions, "-Wnested-externs")
            table_insert(jln_buildoptions, "-Wold-style-definition")
            table_insert(jln_buildoptions, "-Wstrict-prototypes")
            table_insert(jln_buildoptions, "-Wwrite-strings")
            if version >= 400007 then
              table_insert(jln_buildoptions, "-Wsuggest-attribute=noreturn")
              table_insert(jln_buildoptions, "-Wlogical-op")
              table_insert(jln_buildoptions, "-Wvector-operation-performance")
              table_insert(jln_buildoptions, "-Wdouble-promotion")
              table_insert(jln_buildoptions, "-Wtrampolines")
              if version >= 400008 then
                if version >= 400009 then
                  if version >= 500001 then
                    table_insert(jln_buildoptions, "-Wformat-signedness")
                    table_insert(jln_buildoptions, "-Warray-bounds=2")
                    if version >= 600001 then
                      table_insert(jln_buildoptions, "-Wduplicated-cond")
                      table_insert(jln_buildoptions, "-Wnull-dereference")
                      if version >= 700000 then
                        if version >= 700001 then
                          table_insert(jln_buildoptions, "-Walloc-zero")
                          table_insert(jln_buildoptions, "-Walloca")
                          table_insert(jln_buildoptions, "-Wformat-overflow=2")
                          table_insert(jln_buildoptions, "-Wduplicated-branches")
                          if version >= 800000 then
                            table_insert(jln_buildoptions, "-Wcast-align=strict")
                            table_insert(jln_buildoptions, "-Wformat-truncation=2")
                            table_insert(jln_buildoptions, "-Wshift-overflow=2")
                            if version >= 1400000 then
                              table_insert(jln_buildoptions, "-Walloc-size")
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
            if values['warnings'] == 'extensive' then
              if version >= 800000 then
                table_insert(jln_buildoptions, "-Wstringop-overflow=4")
                if version >= 1200000 then
                  table_insert(jln_buildoptions, "-Wuse-after-free=3")
                end
              end
            end
          else
            table_insert(jln_buildoptions, "-Weverything")
            table_insert(jln_buildoptions, "-Wno-documentation")
            table_insert(jln_buildoptions, "-Wno-documentation-unknown-command")
            table_insert(jln_buildoptions, "-Wno-newline-eof")
            table_insert(jln_buildoptions, "-Wno-padded")
            table_insert(jln_buildoptions, "-Wno-global-constructors")
            if  not ( ( values['switch_warnings'] == 'off' or values['switch_warnings'] == 'exhaustive_enum' or values['switch_warnings'] == 'exhaustive_enum_and_mandatory_default' ) ) then
              table_insert(jln_buildoptions, "-Wno-switch-enum")
            end
            if values['covered_switch_default_warnings'] == 'default' then
              table_insert(jln_buildoptions, "-Wno-covered-switch-default")
            end
            if values['conversion_warnings'] ~= 'default' then
              if values['conversion_warnings'] == 'conversion' then
                table_insert(jln_buildoptions, "-Wno-sign-compare")
                table_insert(jln_buildoptions, "-Wno-sign-conversion")
              else
                if ( values['conversion_warnings'] == 'float' or values['conversion_warnings'] == 'sign' ) then
                  table_insert(jln_buildoptions, "-Wno-conversion")
                end
              end
            end
            if version >= 300009 then
              if version >= 500000 then
                if version >= 900000 then
                  if version >= 1000000 then
                    if version >= 1100000 then
                      if version >= 1600000 then
                        if values['unsafe_buffer_usage_warnings'] == 'default' then
                          table_insert(jln_buildoptions, "-Wno-unsafe-buffer-usage")
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
    if compiler == 'gcc' then
      if values['switch_warnings'] ~= 'default' then
        if values['switch_warnings'] == 'on' then
          table_insert(jln_buildoptions, "-Wswitch")
        else
          if values['switch_warnings'] == 'exhaustive_enum' then
            table_insert(jln_buildoptions, "-Wswitch-enum")
          else
            if values['switch_warnings'] == 'mandatory_default' then
              table_insert(jln_buildoptions, "-Wswitch-default")
            else
              if values['switch_warnings'] == 'exhaustive_enum_and_mandatory_default' then
                table_insert(jln_buildoptions, "-Wswitch-default")
                table_insert(jln_buildoptions, "-Wswitch-enum")
              else
                table_insert(jln_buildoptions, "-Wno-switch")
                table_insert(jln_buildoptions, "-Wno-switch-enum")
                table_insert(jln_buildoptions, "-Wno-switch-default")
              end
            end
          end
        end
      end
    else
      if values['switch_warnings'] ~= 'default' then
        if values['switch_warnings'] == 'on' then
          table_insert(jln_buildoptions, "-Wswitch")
          table_insert(jln_buildoptions, "-Wno-switch-default")
        else
          if values['switch_warnings'] == 'mandatory_default' then
            table_insert(jln_buildoptions, "-Wswitch")
            table_insert(jln_buildoptions, "-Wswitch-default")
          else
            if values['switch_warnings'] == 'exhaustive_enum' then
              table_insert(jln_buildoptions, "-Wswitch")
              table_insert(jln_buildoptions, "-Wswitch-enum")
              table_insert(jln_buildoptions, "-Wno-switch-default")
            else
              if values['switch_warnings'] == 'exhaustive_enum_and_mandatory_default' then
                table_insert(jln_buildoptions, "-Wswitch")
                table_insert(jln_buildoptions, "-Wswitch-enum")
                table_insert(jln_buildoptions, "-Wswitch-default")
              else
                table_insert(jln_buildoptions, "-Wno-switch")
                table_insert(jln_buildoptions, "-Wno-switch-enum")
                table_insert(jln_buildoptions, "-Wno-switch-default")
              end
            end
          end
        end
      end
      if values['covered_switch_default_warnings'] ~= 'default' then
        if values['covered_switch_default_warnings'] == 'off' then
          table_insert(jln_buildoptions, "-Wno-covered-switch-default")
        else
          table_insert(jln_buildoptions, "-Wcovered-switch-default")
        end
      end
    end
    if values['unsafe_buffer_usage_warnings'] ~= 'default' then
      if ( is_clang_like and version >= 1600000 ) then
        if values['unsafe_buffer_usage_warnings'] == 'off' then
          table_insert(jln_buildoptions, "-Wno-unsafe-buffer-usage")
        end
      end
    end
    if values['exceptions'] ~= 'default' then
      if values['exceptions'] == 'on' then
        table_insert(jln_buildoptions, "-fexceptions")
        if compiler == 'clang-emcc' then
          table_insert(jln_buildoptions, "-sDISABLE_EXCEPTION_CATCHING=0")
        end
      else
        table_insert(jln_buildoptions, "-fno-exceptions")
      end
    end
    if values['var_init'] ~= 'default' then
      if ( ( compiler == 'gcc' and version >= 1200000 ) or ( is_clang_like and version >= 800000 ) ) then
        if ( is_clang_like and version <= 1500000 ) then
          if values['var_init'] == 'zero' then
            table_insert(jln_buildoptions, "-enable-trivial-auto-var-init-zero-knowing-it-will-be-removed-from-clang")
          end
        end
        if values['var_init'] == 'pattern' then
          table_insert(jln_buildoptions, "-ftrivial-auto-var-init=pattern")
          if compiler == 'gcc' then
            table_insert(jln_buildoptions, "-Wtrivial-auto-var-init")
          end
        else
          if values['var_init'] == 'zero' then
            table_insert(jln_buildoptions, "-ftrivial-auto-var-init=zero")
            if compiler == 'gcc' then
              table_insert(jln_buildoptions, "-Wtrivial-auto-var-init")
            end
          else
            table_insert(jln_buildoptions, "-ftrivial-auto-var-init=uninitialized")
          end
        end
      end
    end
    if values['warnings_as_error'] ~= 'default' then
      if values['warnings_as_error'] == 'on' then
        table_insert(jln_buildoptions, "-Werror")
      else
        if values['warnings_as_error'] == 'basic' then
          table_insert(jln_buildoptions, "-Werror=return-type")
          table_insert(jln_buildoptions, "-Werror=init-self")
          if compiler == 'gcc' then
            table_insert(jln_buildoptions, "-Werror=div-by-zero")
            if version >= 500001 then
              table_insert(jln_buildoptions, "-Werror=array-bounds")
              table_insert(jln_buildoptions, "-Werror=logical-op")
              table_insert(jln_buildoptions, "-Werror=logical-not-parentheses")
            end
          else
            table_insert(jln_buildoptions, "-Werror=array-bounds")
            table_insert(jln_buildoptions, "-Werror=division-by-zero")
            if version >= 300004 then
              table_insert(jln_buildoptions, "-Werror=logical-not-parentheses")
            end
          end
        else
          table_insert(jln_buildoptions, "-Wno-error")
        end
      end
    end
    if values['suggestions'] ~= 'default' then
      if values['suggestions'] ~= 'off' then
        if compiler == 'gcc' then
          table_insert(jln_buildoptions, "-Wsuggest-attribute=pure")
          table_insert(jln_buildoptions, "-Wsuggest-attribute=const")
        end
      end
    end
    if values['sanitizers'] ~= 'default' then
      if values['sanitizers'] == 'off' then
        table_insert(jln_buildoptions, "-fno-sanitize=all")
        table_insert(jln_linkoptions, "-fno-sanitize=all")
      else
        if compiler == 'clang-cl' then
          table_insert(jln_buildoptions, "-fsanitize=undefined")
          table_insert(jln_buildoptions, "-fsanitize=address")
          table_insert(jln_buildoptions, "-fsanitize-address-use-after-scope")
        else
          if ( compiler == 'clang' or compiler == 'clang-emcc' ) then
            if version >= 300001 then
              table_insert(jln_buildoptions, "-fsanitize=undefined")
              table_insert(jln_buildoptions, "-fsanitize=address")
              table_insert(jln_buildoptions, "-fsanitize-address-use-after-scope")
              table_insert(jln_buildoptions, "-fno-omit-frame-pointer")
              table_insert(jln_buildoptions, "-fno-optimize-sibling-calls")
              table_insert(jln_linkoptions, "-fsanitize=undefined")
              table_insert(jln_linkoptions, "-fsanitize=address")
              if compiler == 'clang' then
                if version >= 300004 then
                  table_insert(jln_buildoptions, "-fsanitize=leak")
                  table_insert(jln_linkoptions, "-fsanitize=leak")
                end
                if version >= 600000 then
                  if values['stack_protector'] ~= 'default' then
                    if values['stack_protector'] ~= 'off' then
                      table_insert(jln_buildoptions, "-fsanitize-minimal-runtime")
                    end
                  end
                end
              end
            end
          else
            if version >= 400008 then
              table_insert(jln_buildoptions, "-fsanitize=address")
              table_insert(jln_buildoptions, "-fno-omit-frame-pointer")
              table_insert(jln_buildoptions, "-fno-optimize-sibling-calls")
              table_insert(jln_linkoptions, "-fsanitize=address")
              if version >= 400009 then
                table_insert(jln_buildoptions, "-fsanitize=undefined")
                table_insert(jln_buildoptions, "-fsanitize=leak")
                table_insert(jln_linkoptions, "-fsanitize=undefined")
                table_insert(jln_linkoptions, "-fsanitize=leak")
                if version >= 1200000 then
                  table_insert(jln_buildoptions, "-fsanitize=bounds-strict")
                  table_insert(jln_linkoptions, "-fsanitize=bounds-strict")
                end
              end
            end
          end
        end
      end
    end
    if values['control_flow'] ~= 'default' then
      if compiler == 'clang-emcc' then
        if values['control_flow'] == 'off' then
          table_insert(jln_linkoptions, "-sASSERTIONS=0")
          table_insert(jln_linkoptions, "-sSAFE_HEAP=0")
        else
          table_insert(jln_linkoptions, "-sASSERTIONS=1")
          table_insert(jln_linkoptions, "-sDEMANGLE_SUPPORT=1")
          if  not ( ( values['sanitizers'] == 'on' ) ) then
            table_insert(jln_linkoptions, "-sSAFE_HEAP=1")
          end
        end
      else
        if values['control_flow'] == 'off' then
          if ( compiler == 'gcc' and version >= 800000 ) then
            table_insert(jln_buildoptions, "-fcf-protection=none")
          else
            table_insert(jln_buildoptions, "-fno-sanitize=cfi")
            table_insert(jln_buildoptions, "-fcf-protection=none")
            table_insert(jln_buildoptions, "-fno-sanitize-cfi-cross-dso")
            table_insert(jln_linkoptions, "-fno-sanitize=cfi")
          end
        else
          if ( ( compiler == 'gcc' and version >= 800000 ) or compiler ~= 'gcc' ) then
            if values['control_flow'] == 'branch' then
              table_insert(jln_buildoptions, "-fcf-protection=branch")
            else
              if values['control_flow'] == 'return' then
                table_insert(jln_buildoptions, "-fcf-protection=return")
              else
                table_insert(jln_buildoptions, "-fcf-protection=full")
              end
            end
            if ( values['control_flow'] == 'allow_bugs' and compiler == 'clang' ) then
              table_insert(jln_buildoptions, "-fsanitize=cfi")
              table_insert(jln_buildoptions, "-fvisibility=hidden")
              table_insert(jln_buildoptions, "-flto")
              table_insert(jln_linkoptions, "-fsanitize=cfi")
              table_insert(jln_linkoptions, "-flto")
            end
          end
        end
      end
    end
    if values['color'] ~= 'default' then
      if ( version >= 400009 or compiler ~= 'gcc' ) then
        if values['color'] == 'auto' then
          table_insert(jln_buildoptions, "-fdiagnostics-color=auto")
        else
          if values['color'] == 'never' then
            table_insert(jln_buildoptions, "-fdiagnostics-color=never")
          else
            table_insert(jln_buildoptions, "-fdiagnostics-color=always")
          end
        end
      end
    end
    if values['reproducible_build_warnings'] ~= 'default' then
      if ( compiler == 'gcc' and version >= 400009 ) then
        if values['reproducible_build_warnings'] == 'on' then
          table_insert(jln_buildoptions, "-Wdate-time")
        else
          table_insert(jln_buildoptions, "-Wno-date-time")
        end
      end
    end
    if values['diagnostics_format'] ~= 'default' then
      if values['diagnostics_format'] == 'fixits' then
        if ( ( compiler == 'gcc' and version >= 700000 ) or ( compiler ~= 'gcc' and version >= 500000 ) ) then
          table_insert(jln_buildoptions, "-fdiagnostics-parseable-fixits")
        end
      else
        if values['diagnostics_format'] == 'patch' then
          if ( compiler == 'gcc' and version >= 700000 ) then
            table_insert(jln_buildoptions, "-fdiagnostics-generate-patch")
          end
        else
          if is_clang_like then
            table_insert(jln_buildoptions, "-fdiagnostics-print-source-range-info")
          end
        end
      end
    end
    if values['fix_compiler_error'] ~= 'default' then
      if values['fix_compiler_error'] == 'on' then
        table_insert(jln_buildoptions, "-Werror=write-strings")
      else
        if compiler ~= 'gcc' then
          table_insert(jln_buildoptions, "-Wno-error=c++11-narrowing")
          table_insert(jln_buildoptions, "-Wno-reserved-user-defined-literal")
        end
      end
    end
    if values['lto'] ~= 'default' then
      if values['lto'] == 'off' then
        table_insert(jln_buildoptions, "-fno-lto")
        table_insert(jln_linkoptions, "-fno-lto")
      else
        if compiler == 'gcc' then
          table_insert(jln_buildoptions, "-flto")
          table_insert(jln_linkoptions, "-flto")
          if version >= 500000 then
            if values['warnings'] ~= 'default' then
              if values['warnings'] ~= 'off' then
                table_insert(jln_buildoptions, "-flto-odr-type-merging")
                table_insert(jln_linkoptions, "-flto-odr-type-merging")
              end
            end
            if values['lto'] == 'fat' then
              table_insert(jln_buildoptions, "-ffat-lto-objects")
            else
              if values['lto'] == 'thin' then
                table_insert(jln_linkoptions, "-fuse-linker-plugin")
              end
            end
          end
        else
          if compiler == 'clang-cl' then
            table_insert(jln_linkoptions, "-fuse-ld=lld")
          end
          if ( ( values['lto'] == 'thin' or values['lto'] == 'on' ) and version >= 600000 ) then
            table_insert(jln_buildoptions, "-flto=thin")
            table_insert(jln_linkoptions, "-flto=thin")
          else
            table_insert(jln_buildoptions, "-flto")
            table_insert(jln_linkoptions, "-flto")
          end
        end
      end
    end
    if values['shadow_warnings'] ~= 'default' then
      if values['shadow_warnings'] == 'off' then
        table_insert(jln_buildoptions, "-Wno-shadow")
        if ( is_clang_like and version >= 800000 ) then
          table_insert(jln_buildoptions, "-Wno-shadow-field")
        end
      else
        if values['shadow_warnings'] == 'on' then
          table_insert(jln_buildoptions, "-Wshadow")
        else
          if values['shadow_warnings'] == 'all' then
            if compiler == 'gcc' then
              table_insert(jln_buildoptions, "-Wshadow")
            else
              table_insert(jln_buildoptions, "-Wshadow-all")
            end
          else
            if ( compiler == 'gcc' and version >= 700001 ) then
              if values['shadow_warnings'] == 'local' then
                table_insert(jln_buildoptions, "-Wshadow=local")
              else
                table_insert(jln_buildoptions, "-Wshadow=compatible-local")
              end
            end
          end
        end
      end
    end
    if values['float_sanitizers'] ~= 'default' then
      if ( ( compiler == 'gcc' and version >= 500000 ) or ( is_clang_like and version >= 500000 ) ) then
        if values['float_sanitizers'] == 'on' then
          table_insert(jln_buildoptions, "-fsanitize=float-divide-by-zero")
          table_insert(jln_buildoptions, "-fsanitize=float-cast-overflow")
        else
          table_insert(jln_buildoptions, "-fno-sanitize=float-divide-by-zero")
          table_insert(jln_buildoptions, "-fno-sanitize=float-cast-overflow")
        end
      end
    end
    if values['integer_sanitizers'] ~= 'default' then
      if ( is_clang_like and version >= 500000 ) then
        if values['integer_sanitizers'] == 'on' then
          table_insert(jln_buildoptions, "-fsanitize=integer")
        else
          table_insert(jln_buildoptions, "-fno-sanitize=integer")
        end
      else
        if ( compiler == 'gcc' and version >= 400009 ) then
          if values['integer_sanitizers'] == 'on' then
            table_insert(jln_buildoptions, "-ftrapv")
            table_insert(jln_buildoptions, "-fsanitize=undefined")
          end
        end
      end
    end
  end
  if values['conversion_warnings'] ~= 'default' then
    if ( compiler == 'gcc' or is_clang_like or compiler == 'icc' ) then
      if values['conversion_warnings'] == 'on' then
        table_insert(jln_buildoptions, "-Wconversion")
        table_insert(jln_buildoptions, "-Wsign-compare")
        table_insert(jln_buildoptions, "-Wsign-conversion")
      else
        if values['conversion_warnings'] == 'conversion' then
          table_insert(jln_buildoptions, "-Wconversion")
        else
          if values['conversion_warnings'] == 'float' then
            if compiler == 'gcc' then
              if version >= 400009 then
                table_insert(jln_buildoptions, "-Wfloat-conversion")
              end
            else
              table_insert(jln_buildoptions, "-Wfloat-conversion")
            end
          else
            if values['conversion_warnings'] == 'sign' then
              table_insert(jln_buildoptions, "-Wsign-compare")
              table_insert(jln_buildoptions, "-Wsign-conversion")
            else
              if values['conversion_warnings'] == 'all' then
                table_insert(jln_buildoptions, "-Wconversion")
                if compiler == 'gcc' then
                  table_insert(jln_buildoptions, "-Warith-conversion")
                end
              else
                table_insert(jln_buildoptions, "-Wno-conversion")
                table_insert(jln_buildoptions, "-Wno-sign-compare")
                table_insert(jln_buildoptions, "-Wno-sign-conversion")
              end
            end
          end
        end
      end
    end
  end
  if ( compiler == 'gcc' or compiler == 'clang' or compiler == 'clang-emcc' ) then
    if values['pedantic'] ~= 'default' then
      if values['pedantic'] ~= 'off' then
        table_insert(jln_buildoptions, "-pedantic")
        if values['pedantic'] == 'as_error' then
          table_insert(jln_buildoptions, "-pedantic-errors")
        end
      end
    end
    if compiler == 'clang-emcc' then
      if values['optimization'] ~= 'default' then
        if values['optimization'] == '0' then
          table_insert(jln_buildoptions, "-O0")
          table_insert(jln_linkoptions, "-O0")
        else
          if values['optimization'] == 'g' then
            table_insert(jln_buildoptions, "-Og")
            table_insert(jln_linkoptions, "-Og")
          else
            if values['optimization'] == '1' then
              table_insert(jln_buildoptions, "-O1")
              table_insert(jln_linkoptions, "-O1")
            else
              if values['optimization'] == '2' then
                table_insert(jln_buildoptions, "-O2")
                table_insert(jln_linkoptions, "-O2")
              else
                if values['optimization'] == '3' then
                  table_insert(jln_buildoptions, "-O3")
                  table_insert(jln_linkoptions, "-O3")
                else
                  if values['optimization'] == 'fast' then
                    table_insert(jln_buildoptions, "-O3")
                    table_insert(jln_buildoptions, "-mnontrapping-fptoint")
                    table_insert(jln_linkoptions, "-O3")
                    table_insert(jln_linkoptions, "-mnontrapping-fptoint")
                  else
                    if values['optimization'] == 'size' then
                      table_insert(jln_buildoptions, "-Os")
                      table_insert(jln_linkoptions, "-Os")
                    else
                      table_insert(jln_buildoptions, "-Oz")
                      table_insert(jln_linkoptions, "-Oz")
                    end
                  end
                end
              end
            end
          end
        end
      end
      if values['debug_level'] ~= 'default' then
        if values['debug_level'] == '0' then
          table_insert(jln_buildoptions, "-g0")
        else
          if values['debug_level'] == '1' then
            table_insert(jln_buildoptions, "-g1")
          else
            if values['debug_level'] == '2' then
              table_insert(jln_buildoptions, "-g2")
            else
              if values['debug_level'] == '3' then
                table_insert(jln_buildoptions, "-g3")
              end
            end
          end
        end
      end
      if values['debug'] ~= 'default' then
        if values['debug'] == 'off' then
          table_insert(jln_buildoptions, "-g0")
        else
          if values['debug_level'] == 'default' then
            table_insert(jln_buildoptions, "-g")
          end
        end
      end
    else
      if values['coverage'] ~= 'default' then
        if values['coverage'] == 'on' then
          table_insert(jln_buildoptions, "--coverage")
          table_insert(jln_linkoptions, "--coverage")
          if compiler == 'clang' then
            table_insert(jln_linkoptions, "-lprofile_rt")
          end
        end
      end
      if values['debug_level'] ~= 'default' then
        if values['debug_level'] == '0' then
          table_insert(jln_buildoptions, "-g0")
        else
          if values['debug_level'] == '1' then
            if ( values['debug'] == 'gdb' ) then
              table_insert(jln_buildoptions, "-ggdb1")
            else
              table_insert(jln_buildoptions, "-g1")
            end
          else
            if values['debug_level'] == '2' then
              if ( values['debug'] == 'gdb' ) then
                table_insert(jln_buildoptions, "-ggdb2")
              else
                table_insert(jln_buildoptions, "-g2")
              end
            else
              if values['debug_level'] == '3' then
                if ( values['debug'] == 'gdb' ) then
                  table_insert(jln_buildoptions, "-ggdb3")
                else
                  table_insert(jln_buildoptions, "-g3")
                end
              else
                if values['debug_level'] == 'line_tables_only' then
                  if compiler == 'clang' then
                    table_insert(jln_buildoptions, "-gline-tables-only")
                  else
                    table_insert(jln_buildoptions, "-g")
                  end
                else
                  if values['debug_level'] == 'line_directives_only' then
                    if compiler == 'clang' then
                      table_insert(jln_buildoptions, "-gline-directives-only")
                    else
                      table_insert(jln_buildoptions, "-g")
                    end
                  end
                end
              end
            end
          end
        end
      end
      if values['debug'] ~= 'default' then
        if values['debug'] == 'off' then
          table_insert(jln_buildoptions, "-g0")
        else
          if values['debug'] == 'on' then
            if values['debug_level'] == 'default' then
              table_insert(jln_buildoptions, "-g")
            end
          else
            if values['debug'] == 'gdb' then
              if values['debug_level'] == 'default' then
                table_insert(jln_buildoptions, "-ggdb")
              end
            else
              if compiler == 'clang' then
                if values['debug'] == 'lldb' then
                  table_insert(jln_buildoptions, "-glldb")
                else
                  if values['debug'] == 'sce' then
                    table_insert(jln_buildoptions, "-gsce")
                  else
                    if values['debug'] == 'dbx' then
                      table_insert(jln_buildoptions, "-gdbx")
                    else
                      table_insert(jln_buildoptions, "-g")
                    end
                  end
                end
              else
                if values['debug'] == 'vms' then
                  table_insert(jln_buildoptions, "-gvms")
                end
              end
            end
          end
        end
      end
      if values['optimization'] ~= 'default' then
        if values['optimization'] == '0' then
          table_insert(jln_buildoptions, "-O0")
        else
          if values['optimization'] == 'g' then
            table_insert(jln_buildoptions, "-Og")
          else
            table_insert(jln_linkoptions, "-Wl,-O1")
            if values['optimization'] == '1' then
              table_insert(jln_buildoptions, "-O1")
            else
              if values['optimization'] == '2' then
                table_insert(jln_buildoptions, "-O2")
              else
                if values['optimization'] == '3' then
                  table_insert(jln_buildoptions, "-O3")
                else
                  if values['optimization'] == 'size' then
                    table_insert(jln_buildoptions, "-Os")
                  else
                    if values['optimization'] == 'z' then
                      if ( compiler == 'clang' or ( compiler == 'gcc' and version >= 1200000 ) ) then
                        table_insert(jln_buildoptions, "-Oz")
                      else
                        table_insert(jln_buildoptions, "-Os")
                      end
                    else
                      if compiler == 'clang' then
                        table_insert(jln_buildoptions, "-O3")
                        table_insert(jln_buildoptions, "-ffast-math")
                      else
                        table_insert(jln_buildoptions, "-Ofast")
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
      if values['cpu'] ~= 'default' then
        if values['cpu'] == 'generic' then
          table_insert(jln_buildoptions, "-mtune=generic")
          table_insert(jln_linkoptions, "-mtune=generic")
        else
          table_insert(jln_buildoptions, "-march=native")
          table_insert(jln_buildoptions, "-mtune=native")
          table_insert(jln_linkoptions, "-march=native")
          table_insert(jln_linkoptions, "-mtune=native")
        end
      end
      if values['linker'] ~= 'default' then
        if values['linker'] == 'mold' then
          table_insert(jln_linkoptions, "-fuse-ld=mold")
        else
          if values['linker'] == 'native' then
            if compiler == 'gcc' then
              table_insert(jln_linkoptions, "-fuse-ld=gold")
            else
              table_insert(jln_linkoptions, "-fuse-ld=lld")
            end
          else
            if values['linker'] == 'bfd' then
              table_insert(jln_linkoptions, "-fuse-ld=bfd")
            else
              if ( values['linker'] == 'gold' or ( compiler == 'gcc' and version < 900000 ) ) then
                table_insert(jln_linkoptions, "-fuse-ld=gold")
              else
                if values['lto'] ~= 'default' then
                  if ( values['lto'] ~= 'off' and compiler == 'gcc' ) then
                    table_insert(jln_linkoptions, "-fuse-ld=gold")
                  else
                    table_insert(jln_linkoptions, "-fuse-ld=lld")
                  end
                else
                  table_insert(jln_linkoptions, "-fuse-ld=lld")
                end
              end
            end
          end
        end
      end
      if values['whole_program'] ~= 'default' then
        if values['whole_program'] == 'off' then
          table_insert(jln_buildoptions, "-fno-whole-program")
          if ( compiler == 'clang' and version >= 300009 ) then
            table_insert(jln_buildoptions, "-fno-whole-program-vtables")
            table_insert(jln_linkoptions, "-fno-whole-program-vtables")
          end
        else
          if linker == 'ld64' then
            table_insert(jln_linkoptions, "-Wl,-dead_strip")
            table_insert(jln_linkoptions, "-Wl,-S")
          else
            table_insert(jln_linkoptions, "-s")
            if values['whole_program'] == 'strip_all' then
              table_insert(jln_linkoptions, "-Wl,--gc-sections")
              table_insert(jln_linkoptions, "-Wl,--strip-all")
            end
          end
          if compiler == 'gcc' then
            table_insert(jln_buildoptions, "-fwhole-program")
            table_insert(jln_linkoptions, "-fwhole-program")
          else
            if compiler == 'clang' then
              if version >= 300009 then
                if values['lto'] ~= 'default' then
                  if values['lto'] ~= 'off' then
                    table_insert(jln_buildoptions, "-fwhole-program-vtables")
                    table_insert(jln_linkoptions, "-fwhole-program-vtables")
                  end
                end
                if version >= 700000 then
                  table_insert(jln_buildoptions, "-fforce-emit-vtables")
                  table_insert(jln_linkoptions, "-fforce-emit-vtables")
                end
              end
            end
          end
        end
      end
      if values['stack_protector'] ~= 'default' then
        if values['stack_protector'] == 'off' then
          table_insert(jln_buildoptions, "-Wno-stack-protector")
          table_insert(jln_buildoptions, "-U_FORTIFY_SOURCE")
          table_insert(jln_linkoptions, "-Wno-stack-protector")
        else
          table_insert(jln_buildoptions, "-Wstack-protector")
          if ( ( compiler == 'gcc' and version >= 1200000 ) or ( compiler == 'clang' and version >= 1400000 ) ) then
            table_insert(jln_buildoptions, "-D_FORTIFY_SOURCE=3")
          else
            table_insert(jln_buildoptions, "-D_FORTIFY_SOURCE=2")
          end
          if values['stack_protector'] == 'strong' then
            if compiler == 'gcc' then
              if version >= 400009 then
                table_insert(jln_buildoptions, "-fstack-protector-strong")
                table_insert(jln_linkoptions, "-fstack-protector-strong")
                if version >= 800000 then
                  table_insert(jln_buildoptions, "-fstack-clash-protection")
                  table_insert(jln_linkoptions, "-fstack-clash-protection")
                end
              end
            else
              table_insert(jln_buildoptions, "-fstack-protector-strong")
              table_insert(jln_buildoptions, "-fsanitize=safe-stack")
              table_insert(jln_linkoptions, "-fstack-protector-strong")
              table_insert(jln_linkoptions, "-fsanitize=safe-stack")
              if version >= 1100000 then
                table_insert(jln_buildoptions, "-fstack-clash-protection")
                table_insert(jln_linkoptions, "-fstack-clash-protection")
              end
            end
          else
            if values['stack_protector'] == 'all' then
              table_insert(jln_buildoptions, "-fstack-protector-all")
              table_insert(jln_linkoptions, "-fstack-protector-all")
              if ( compiler == 'gcc' and version >= 800000 ) then
                table_insert(jln_buildoptions, "-fstack-clash-protection")
                table_insert(jln_linkoptions, "-fstack-clash-protection")
              else
                table_insert(jln_buildoptions, "-fsanitize=safe-stack")
                table_insert(jln_linkoptions, "-fsanitize=safe-stack")
                if version >= 1100000 then
                  table_insert(jln_buildoptions, "-fstack-clash-protection")
                  table_insert(jln_linkoptions, "-fstack-clash-protection")
                end
              end
            else
              table_insert(jln_buildoptions, "-fstack-protector")
              table_insert(jln_linkoptions, "-fstack-protector")
            end
          end
          if compiler == 'clang' then
            table_insert(jln_buildoptions, "-fsanitize=shadow-call-stack")
            table_insert(jln_linkoptions, "-fsanitize=shadow-call-stack")
          end
        end
      end
      if values['relro'] ~= 'default' then
        if values['relro'] == 'off' then
          table_insert(jln_linkoptions, "-Wl,-z,norelro")
        else
          if values['relro'] == 'on' then
            table_insert(jln_linkoptions, "-Wl,-z,relro")
          else
            table_insert(jln_linkoptions, "-Wl,-z,relro,-z,now,-z,noexecstack")
            if values['linker'] ~= 'default' then
              if not ( ( values['linker'] == 'gold' or ( compiler == 'gcc' and version < 900000 ) or ( values['linker'] == 'native' and compiler == 'gcc' ) ) ) then
                table_insert(jln_linkoptions, "-Wl,-z,separate-code")
              end
            end
          end
        end
      end
      if values['pie'] ~= 'default' then
        if values['pie'] == 'off' then
          table_insert(jln_linkoptions, "-no-pic")
        else
          if values['pie'] == 'on' then
            table_insert(jln_linkoptions, "-pie")
          else
            if values['pie'] == 'fpie' then
              table_insert(jln_buildoptions, "-fpie")
            else
              if values['pie'] == 'fpic' then
                table_insert(jln_buildoptions, "-fpic")
              else
                if values['pie'] == 'fPIE' then
                  table_insert(jln_buildoptions, "-fPIE")
                else
                  if values['pie'] == 'fPIC' then
                    table_insert(jln_buildoptions, "-fPIC")
                  else
                    table_insert(jln_linkoptions, "-static-pie")
                  end
                end
              end
            end
          end
        end
      end
      if values['other_sanitizers'] ~= 'default' then
        if values['other_sanitizers'] == 'thread' then
          table_insert(jln_buildoptions, "-fsanitize=thread")
        else
          if values['other_sanitizers'] == 'memory' then
            if ( compiler == 'clang' and version >= 500000 ) then
              table_insert(jln_buildoptions, "-fsanitize=memory")
              table_insert(jln_buildoptions, "-fno-omit-frame-pointer")
            end
          else
            if values['other_sanitizers'] == 'pointer' then
              if ( compiler == 'gcc' and version >= 800000 ) then
                table_insert(jln_buildoptions, "-fsanitize=pointer-compare")
                table_insert(jln_buildoptions, "-fsanitize=pointer-subtract")
              end
            end
          end
        end
      end
      if values['analyzer'] ~= 'default' then
        if ( compiler == 'gcc' and version >= 1000000 ) then
          if values['analyzer'] == 'off' then
            table_insert(jln_buildoptions, "-fno-analyzer")
          else
            table_insert(jln_buildoptions, "-fanalyzer")
            if values['analyzer_too_complex_warning'] ~= 'default' then
              if values['analyzer_too_complex_warning'] == 'on' then
                table_insert(jln_buildoptions, "-Wanalyzer-too-complex")
              else
                table_insert(jln_buildoptions, "-Wno-analyzer-too-complex")
              end
            end
            if values['analyzer_verbosity'] ~= 'default' then
              if values['analyzer_verbosity'] == '0' then
                table_insert(jln_buildoptions, "-fanalyzer-verbosity=0")
              else
                if values['analyzer_verbosity'] == '1' then
                  table_insert(jln_buildoptions, "-fanalyzer-verbosity=1")
                else
                  if values['analyzer_verbosity'] == '2' then
                    table_insert(jln_buildoptions, "-fanalyzer-verbosity=2")
                  else
                    table_insert(jln_buildoptions, "-fanalyzer-verbosity=3")
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
    if values['lto'] ~= 'default' then
      if values['lto'] == 'off' then
        table_insert(jln_buildoptions, "-fno-lto")
      else
        if ( values['lto'] == 'thin' or values['lto'] == 'on' ) then
          table_insert(jln_buildoptions, "-flto=thin")
        else
          table_insert(jln_buildoptions, "-flto")
          table_insert(jln_linkoptions, "-flto")
        end
      end
    end
    if values['whole_program'] ~= 'default' then
      if values['whole_program'] == 'off' then
        table_insert(jln_buildoptions, "-fno-whole-program")
      else
        if values['lto'] ~= 'default' then
          if values['lto'] ~= 'off' then
            table_insert(jln_buildoptions, "-fwhole-program-vtables")
            table_insert(jln_linkoptions, "-fwhole-program-vtables")
          end
        end
      end
    end
  end
  if ( compiler == 'msvc' or compiler == 'clang-cl' or compiler == 'icl' ) then
    if values['exceptions'] ~= 'default' then
      if values['exceptions'] == 'on' then
        table_insert(jln_buildoptions, "/EHsc")
        table_insert(jln_buildoptions, "/D_HAS_EXCEPTIONS=1")
      else
        table_insert(jln_buildoptions, "/EHs-")
        table_insert(jln_buildoptions, "/D_HAS_EXCEPTIONS=0")
      end
    end
    if values['rtti'] ~= 'default' then
      if values['rtti'] == 'on' then
        table_insert(jln_buildoptions, "/GR")
      else
        table_insert(jln_buildoptions, "/GR-")
      end
    end
    if values['stl_hardening'] ~= 'default' then
      if values['stl_hardening'] == 'off' then
        table_insert(jln_buildoptions, "/D_SECURE_SCL=0")
      else
        if ( not ( ( values['stl_hardening'] == 'fast' or values['stl_hardening'] == 'extensive' ) ) and values['stl_hardening'] ~= 'debug' ) then
          table_insert(jln_buildoptions, "/D_DEBUG")
        end
      end
    end
    if values['stl_fix'] ~= 'default' then
      if values['stl_fix'] == 'on' then
        table_insert(jln_buildoptions, "/DNOMINMAX")
      end
    end
    if compiler ~= 'icl' then
      if values['debug_level'] ~= 'default' then
        if values['debug_level'] == 'line_tables_only' then
          if compiler == 'clang-cl' then
            table_insert(jln_buildoptions, "-gline-tables-only")
          end
          table_insert(jln_buildoptions, "/DEBUG:FASTLINK")
        end
        if values['debug_level'] == 'line_directives_only' then
          if compiler == 'clang-cl' then
            table_insert(jln_buildoptions, "-gline-directives-only")
          end
        end
      end
      if values['debug'] ~= 'default' then
        if values['debug'] == 'off' then
          table_insert(jln_linkoptions, "/DEBUG:NONE")
        else
          table_insert(jln_buildoptions, "/RTC1")
          table_insert(jln_buildoptions, "/Od")
          if values['debug'] == 'on' then
            table_insert(jln_buildoptions, "/DEBUG")
          end
          if values['optimization'] ~= 'default' then
            if values['optimization'] == 'g' then
              table_insert(jln_buildoptions, "/Zi")
            else
              if values['whole_program'] ~= 'default' then
                if values['whole_program'] == 'off' then
                  table_insert(jln_buildoptions, "/ZI")
                else
                  table_insert(jln_buildoptions, "/Zi")
                end
              else
                table_insert(jln_buildoptions, "/ZI")
              end
            end
          else
            if values['whole_program'] ~= 'default' then
              if values['whole_program'] == 'off' then
                table_insert(jln_buildoptions, "/ZI")
              else
                table_insert(jln_buildoptions, "/Zi")
              end
            else
              table_insert(jln_buildoptions, "/ZI")
            end
          end
        end
      end
      if values['optimization'] ~= 'default' then
        if values['optimization'] == '0' then
          table_insert(jln_buildoptions, "/Ob0")
          table_insert(jln_buildoptions, "/Od")
          table_insert(jln_buildoptions, "/Oi-")
          table_insert(jln_buildoptions, "/Oy-")
        else
          if values['optimization'] == 'g' then
            table_insert(jln_buildoptions, "/Ob1")
          else
            if values['optimization'] == '1' then
              table_insert(jln_buildoptions, "/O1")
            else
              if values['optimization'] == '2' then
                table_insert(jln_buildoptions, "/O2")
              else
                if values['optimization'] == '3' then
                  table_insert(jln_buildoptions, "/O2")
                else
                  if ( values['optimization'] == 'size' or values['optimization'] == 'z' ) then
                    table_insert(jln_buildoptions, "/O1")
                    table_insert(jln_buildoptions, "/GL")
                    table_insert(jln_buildoptions, "/Gw")
                  else
                    table_insert(jln_buildoptions, "/O2")
                    table_insert(jln_buildoptions, "/fp:fast")
                  end
                end
              end
            end
          end
        end
      end
      if values['linker'] ~= 'default' then
        if compiler == 'clang-cl' then
          if ( values['linker'] == 'lld' or values['linker'] == 'native' ) then
            table_insert(jln_linkoptions, "-fuse-ld=lld")
          else
            if values['linker'] == 'mold' then
              table_insert(jln_linkoptions, "-fuse-ld=mold")
            end
          end
        end
      end
      if values['control_flow'] ~= 'default' then
        if values['control_flow'] == 'off' then
          table_insert(jln_buildoptions, "/guard:cf-")
        else
          table_insert(jln_buildoptions, "/guard:cf")
        end
      end
      if values['whole_program'] ~= 'default' then
        if values['whole_program'] == 'off' then
          table_insert(jln_buildoptions, "/GL-")
        else
          table_insert(jln_buildoptions, "/GL")
          table_insert(jln_buildoptions, "/Gw")
          table_insert(jln_linkoptions, "/LTCG")
          if values['whole_program'] == 'strip_all' then
            table_insert(jln_linkoptions, "/OPT:REF")
          end
        end
      end
      if values['pedantic'] ~= 'default' then
        if values['pedantic'] ~= 'off' then
          table_insert(jln_buildoptions, "/permissive-")
          if compiler == 'msvc' then
            if values['pedantic'] == 'as_error' then
              table_insert(jln_buildoptions, "/we4608")
              if version >= 1900031 then
                if version >= 1900038 then
                  table_insert(jln_buildoptions, "/we5110")
                end
              end
            else
              table_insert(jln_buildoptions, "/w14608")
              if version >= 1900031 then
                if version >= 1900038 then
                  table_insert(jln_buildoptions, "/w15110")
                end
              end
            end
          end
        end
      end
      if values['stack_protector'] ~= 'default' then
        if values['stack_protector'] == 'off' then
          table_insert(jln_buildoptions, "/GS-")
        else
          table_insert(jln_buildoptions, "/GS")
          table_insert(jln_buildoptions, "/sdl")
          if values['stack_protector'] == 'strong' then
            table_insert(jln_buildoptions, "/RTC1")
            if ( compiler == 'msvc' and version >= 1600007 ) then
              table_insert(jln_buildoptions, "/guard:ehcont")
              table_insert(jln_linkoptions, "/CETCOMPAT")
            end
          else
            if values['stack_protector'] == 'all' then
              table_insert(jln_buildoptions, "/RTC1")
              table_insert(jln_buildoptions, "/RTCc")
            end
          end
          if values['control_flow'] ~= 'default' and not ( values['control_flow'] == 'off' ) then
            table_insert(jln_buildoptions, "/guard:cf")
          end
        end
      end
    end
  end
  if compiler == 'msvc' then
    if values['analyzer'] ~= 'default' then
      if version >= 1500000 then
        if values['analyzer'] == 'off' then
          table_insert(jln_buildoptions, "/analyze-")
        else
          table_insert(jln_buildoptions, "/analyze")
        end
      end
    end
    if values['windows_bigobj'] ~= 'default' then
      table_insert(jln_buildoptions, "/bigobj")
    end
    if values['msvc_conformance'] ~= 'default' then
      if ( values['msvc_conformance'] == 'all' or values['msvc_conformance'] == 'all_without_throwing_new' ) then
        table_insert(jln_buildoptions, "/Zc:inline")
        table_insert(jln_buildoptions, "/Zc:referenceBinding")
        if values['msvc_conformance'] == 'all' then
          table_insert(jln_buildoptions, "/Zc:throwingNew")
        end
        if version >= 1500006 then
          if version >= 1600005 then
            table_insert(jln_buildoptions, "/Zc:preprocessor")
          end
        end
      end
    end
    if values['msvc_crt_secure_no_warnings'] ~= 'default' then
      if values['msvc_crt_secure_no_warnings'] == 'on' then
        table_insert(jln_buildoptions, "/D_CRT_SECURE_NO_WARNINGS=1")
      else
        if values['msvc_crt_secure_no_warnings'] == 'off' then
          table_insert(jln_buildoptions, "/U_CRT_SECURE_NO_WARNINGS")
        end
      end
    end
    if values['msvc_diagnostics_format'] ~= 'default' then
      if version >= 1700000 then
        if values['msvc_diagnostics_format'] == 'classic' then
          table_insert(jln_buildoptions, "/diagnostics:classic")
        else
          if values['msvc_diagnostics_format'] == 'column' then
            table_insert(jln_buildoptions, "/diagnostics:column")
          else
            table_insert(jln_buildoptions, "/diagnostics:caret")
          end
        end
      end
    end
    if version < 1500016 then
      values['msvc_isystem'] = 'default'
    end
    if values['msvc_isystem'] ~= 'default' then
      if values['msvc_isystem'] == 'external_as_include_system_flag' then
        if version < 1600010 then
          -- unimplementable
        else
          -- unimplementable
        end
      else
        if values['msvc_isystem'] ~= 'assumed' then
          if version < 1600010 then
            table_insert(jln_buildoptions, "/experimental:external")
          end
          table_insert(jln_buildoptions, "/external:W0")
          if values['msvc_isystem'] == 'anglebrackets' then
            table_insert(jln_buildoptions, "/external:anglebrackets")
          else
            table_insert(jln_buildoptions, "/external:env:INCLUDE")
            table_insert(jln_buildoptions, "/external:env:CAExcludePath")
          end
        end
      end
      if values['msvc_isystem_with_template_from_non_external'] ~= 'default' then
        if values['msvc_isystem_with_template_from_non_external'] == 'off' then
          table_insert(jln_buildoptions, "/external:template")
        else
          table_insert(jln_buildoptions, "/external:template-")
        end
      end
    end
    if values['warnings'] ~= 'default' then
      if values['warnings'] == 'off' then
        table_insert(jln_buildoptions, "/W0")
      else
        if values['warnings'] == 'essential' then
          table_insert(jln_buildoptions, "/W4")
          table_insert(jln_buildoptions, "/wd4711")
        else
          if values['warnings'] == 'on' then
            table_insert(jln_buildoptions, "/W4")
            table_insert(jln_buildoptions, "/wd4711")
            table_insert(jln_buildoptions, "/w14296")
            table_insert(jln_buildoptions, "/w14444")
            table_insert(jln_buildoptions, "/w14545")
            table_insert(jln_buildoptions, "/w14546")
            table_insert(jln_buildoptions, "/w14547")
            table_insert(jln_buildoptions, "/w14548")
            table_insert(jln_buildoptions, "/w14549")
            table_insert(jln_buildoptions, "/w14555")
            table_insert(jln_buildoptions, "/w14557")
            table_insert(jln_buildoptions, "/w14905")
            table_insert(jln_buildoptions, "/w14906")
            table_insert(jln_buildoptions, "/w14917")
            if version >= 1500003 then
              if version >= 1600010 then
                table_insert(jln_buildoptions, "/w15240")
                if version >= 1700004 then
                  if values['msvc_isystem'] == 'default' then
                    table_insert(jln_buildoptions, "/w15262")
                  end
                  if version >= 1900000 then
                    table_insert(jln_buildoptions, "/w14426")
                    if values['msvc_isystem'] == 'default' then
                      table_insert(jln_buildoptions, "/w14654")
                    end
                    table_insert(jln_buildoptions, "/w15031")
                    table_insert(jln_buildoptions, "/w15032")
                    if version >= 1900015 then
                      if version >= 1900022 then
                        if version >= 1900025 then
                          if version >= 1900029 then
                            if version >= 1900030 then
                              table_insert(jln_buildoptions, "/w15249")
                              if version >= 1900032 then
                                table_insert(jln_buildoptions, "/w15258")
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
            table_insert(jln_buildoptions, "/Wall")
            table_insert(jln_buildoptions, "/wd4370")
            table_insert(jln_buildoptions, "/wd4371")
            table_insert(jln_buildoptions, "/wd4514")
            table_insert(jln_buildoptions, "/wd4571")
            table_insert(jln_buildoptions, "/wd4577")
            table_insert(jln_buildoptions, "/wd4686")
            table_insert(jln_buildoptions, "/wd4710")
            table_insert(jln_buildoptions, "/wd4711")
            table_insert(jln_buildoptions, "/wd4820")
            table_insert(jln_buildoptions, "/wd4866")
            if values['msvc_isystem'] == 'default' then
              table_insert(jln_buildoptions, "/wd4464")
              table_insert(jln_buildoptions, "/wd4548")
              table_insert(jln_buildoptions, "/wd4668")
              if version >= 1500000 then
                if version >= 1700004 then
                  table_insert(jln_buildoptions, "/wd5262")
                  if version >= 1900000 then
                    table_insert(jln_buildoptions, "/wd4774")
                  end
                end
              end
            end
            if version >= 1600000 then
              table_insert(jln_buildoptions, "/wd4800")
              if version >= 1900039 then
                table_insert(jln_buildoptions, "/wd4975")
                if version >= 1900040 then
                  table_insert(jln_buildoptions, "/wd4860")
                  table_insert(jln_buildoptions, "/wd4861")
                  table_insert(jln_buildoptions, "/wd5273")
                  table_insert(jln_buildoptions, "/wd5274")
                  if version >= 1900041 then
                    table_insert(jln_buildoptions, "/wd5306")
                    if version >= 1900043 then
                      table_insert(jln_buildoptions, "/wd5277")
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
    if values['conversion_warnings'] ~= 'default' then
      if ( values['conversion_warnings'] == 'off' or values['conversion_warnings'] == 'sign' ) then
        table_insert(jln_buildoptions, "/wd4244")
        table_insert(jln_buildoptions, "/wd4245")
        table_insert(jln_buildoptions, "/wd4365")
      else
        table_insert(jln_buildoptions, "/w14244")
        table_insert(jln_buildoptions, "/w14245")
        table_insert(jln_buildoptions, "/w14365")
      end
      if ( values['conversion_warnings'] == 'on' or values['conversion_warnings'] == 'all' or values['conversion_warnings'] == 'sign' ) then
        table_insert(jln_buildoptions, "/w14018")
        table_insert(jln_buildoptions, "/w14388")
        table_insert(jln_buildoptions, "/w14289")
      else
        table_insert(jln_buildoptions, "/wd4018")
        table_insert(jln_buildoptions, "/wd4388")
        table_insert(jln_buildoptions, "/wd4289")
      end
    end
    if values['switch_warnings'] ~= 'default' then
      if ( values['switch_warnings'] == 'on' or values['switch_warnings'] == 'mandatory_default' ) then
        table_insert(jln_buildoptions, "/wd4061")
        table_insert(jln_buildoptions, "/w14062")
      else
        if ( values['switch_warnings'] == 'exhaustive_enum' or values['switch_warnings'] == 'exhaustive_enum_and_mandatory_default' ) then
          table_insert(jln_buildoptions, "/w14061")
          table_insert(jln_buildoptions, "/w14062")
        else
          table_insert(jln_buildoptions, "/wd4061")
          table_insert(jln_buildoptions, "/wd4062")
        end
      end
    end
    if values['shadow_warnings'] ~= 'default' then
      if version >= 1900000 then
        if values['shadow_warnings'] == 'off' then
          table_insert(jln_buildoptions, "/wd4456")
          table_insert(jln_buildoptions, "/wd4459")
        else
          if ( values['shadow_warnings'] == 'on' or values['shadow_warnings'] == 'all' ) then
            table_insert(jln_buildoptions, "/w14456")
            table_insert(jln_buildoptions, "/w14459")
          else
            if values['shadow_warnings'] == 'local' then
              table_insert(jln_buildoptions, "/w4456")
              table_insert(jln_buildoptions, "/wd4459")
            end
          end
        end
      end
    end
    if values['warnings_as_error'] ~= 'default' then
      if values['warnings_as_error'] == 'on' then
        table_insert(jln_buildoptions, "/WX")
      else
        if values['warnings_as_error'] == 'off' then
          table_insert(jln_buildoptions, "/WX-")
        else
          table_insert(jln_buildoptions, "/we4716")
          table_insert(jln_buildoptions, "/we2124")
        end
      end
    end
    if values['lto'] ~= 'default' then
      if values['lto'] == 'off' then
        table_insert(jln_buildoptions, "/LTCG:OFF")
      else
        table_insert(jln_buildoptions, "/GL")
        table_insert(jln_linkoptions, "/LTCG")
      end
    end
    if values['sanitizers'] ~= 'default' then
      if version >= 1600009 then
        table_insert(jln_buildoptions, "/fsanitize=address")
        table_insert(jln_buildoptions, "/fsanitize-address-use-after-return")
      else
        if values['sanitizers'] == 'on' then
          table_insert(jln_buildoptions, "/sdl")
        else
          if values['stack_protector'] ~= 'default' then
            if values['stack_protector'] ~= 'off' then
              table_insert(jln_buildoptions, "/sdl-")
            end
          end
        end
      end
    end
  else
    if compiler == 'icl' then
      if values['warnings'] ~= 'default' then
        if values['warnings'] == 'off' then
          table_insert(jln_buildoptions, "/w")
        else
          table_insert(jln_buildoptions, "/W2")
          table_insert(jln_buildoptions, "/Qdiag-disable:1418,2259")
        end
      end
      if values['warnings_as_error'] ~= 'default' then
        if values['warnings_as_error'] == 'on' then
          table_insert(jln_buildoptions, "/WX")
        else
          if values['warnings_as_error'] == 'basic' then
            table_insert(jln_buildoptions, "/Qdiag-error:1079,39,109")
          end
        end
      end
      if values['windows_bigobj'] ~= 'default' then
        table_insert(jln_buildoptions, "/bigobj")
      end
      if values['msvc_conformance'] ~= 'default' then
        if ( values['msvc_conformance'] == 'all' or values['msvc_conformance'] == 'all_without_throwing_new' ) then
          table_insert(jln_buildoptions, "/Zc:inline")
          table_insert(jln_buildoptions, "/Zc:strictStrings")
          if values['msvc_conformance'] == 'all' then
            table_insert(jln_buildoptions, "/Zc:throwingNew")
          end
        end
      end
      if values['debug_level'] ~= 'default' then
        if ( values['debug_level'] == 'line_tables_only' or values['debug_level'] == 'line_directives_only' ) then
          table_insert(jln_buildoptions, "/debug:minimal")
        end
      end
      if values['debug'] ~= 'default' then
        if values['debug'] == 'off' then
          table_insert(jln_linkoptions, "/DEBUG:NONE")
        else
          table_insert(jln_buildoptions, "/RTC1")
          table_insert(jln_buildoptions, "/Od")
          if values['debug'] == 'on' then
            table_insert(jln_buildoptions, "/debug:full")
          end
          if ( values['optimization'] == 'g' ) then
            table_insert(jln_buildoptions, "/Zi")
          else
            if values['whole_program'] ~= 'default' then
              if values['whole_program'] == 'off' then
                table_insert(jln_buildoptions, "/ZI")
              else
                table_insert(jln_buildoptions, "/Zi")
              end
            else
              table_insert(jln_buildoptions, "/ZI")
            end
          end
        end
      end
      if values['optimization'] ~= 'default' then
        if values['optimization'] == '0' then
          table_insert(jln_buildoptions, "/Ob0")
          table_insert(jln_buildoptions, "/Od")
          table_insert(jln_buildoptions, "/Oi-")
          table_insert(jln_buildoptions, "/Oy-")
        else
          if values['optimization'] == 'g' then
            table_insert(jln_buildoptions, "/Ob1")
          else
            table_insert(jln_buildoptions, "/GF")
            if values['optimization'] == '1' then
              table_insert(jln_buildoptions, "/O1")
            else
              if values['optimization'] == '2' then
                table_insert(jln_buildoptions, "/O2")
              else
                if values['optimization'] == '3' then
                  table_insert(jln_buildoptions, "/O2")
                else
                  if values['optimization'] == 'z' then
                    table_insert(jln_buildoptions, "/O3")
                  else
                    if values['optimization'] == 'size' then
                      table_insert(jln_buildoptions, "/Os")
                    else
                      table_insert(jln_buildoptions, "/fast")
                    end
                  end
                end
              end
            end
          end
        end
      end
      if values['stack_protector'] ~= 'default' then
        if values['stack_protector'] == 'off' then
          table_insert(jln_buildoptions, "/GS-")
        else
          table_insert(jln_buildoptions, "/GS")
          if values['stack_protector'] == 'strong' then
            table_insert(jln_buildoptions, "/RTC1")
          else
            if values['stack_protector'] == 'all' then
              table_insert(jln_buildoptions, "/RTC1")
              table_insert(jln_buildoptions, "/RTCc")
            end
          end
        end
      end
      if values['sanitizers'] ~= 'default' then
        if values['sanitizers'] == 'on' then
          table_insert(jln_buildoptions, "/Qtrapuv")
        end
      end
      if values['float_sanitizers'] ~= 'default' then
        if values['float_sanitizers'] == 'on' then
          table_insert(jln_buildoptions, "/Qfp-stack-check")
          table_insert(jln_buildoptions, "/Qfp-trap:common")
        end
      end
      if values['control_flow'] ~= 'default' then
        if values['control_flow'] == 'off' then
          table_insert(jln_buildoptions, "/guard:cf-")
          table_insert(jln_buildoptions, "/mconditional-branch=keep")
        else
          table_insert(jln_buildoptions, "/guard:cf")
          if values['control_flow'] == 'branch' then
            table_insert(jln_buildoptions, "/mconditional-branch:all-fix")
            table_insert(jln_buildoptions, "/Qcf-protection:branch")
          else
            if values['control_flow'] == 'on' then
              table_insert(jln_buildoptions, "/mconditional-branch:all-fix")
              table_insert(jln_buildoptions, "/Qcf-protection:full")
            end
          end
        end
      end
      if values['cpu'] ~= 'default' then
        if values['cpu'] == 'generic' then
          table_insert(jln_buildoptions, "/Qtune:generic")
          table_insert(jln_linkoptions, "/Qtune:generic")
        else
          table_insert(jln_buildoptions, "/QxHost")
          table_insert(jln_linkoptions, "/QxHost")
        end
      end
    else
      if compiler == 'icc' then
        if values['warnings'] ~= 'default' then
          if values['warnings'] == 'off' then
            table_insert(jln_buildoptions, "-w")
          else
            if values['warnings'] == 'essential' then
              table_insert(jln_buildoptions, "-Wall")
            else
              table_insert(jln_buildoptions, "-Wall")
              table_insert(jln_buildoptions, "-Warray-bounds")
              table_insert(jln_buildoptions, "-Wcast-qual")
              table_insert(jln_buildoptions, "-Wchar-subscripts")
              table_insert(jln_buildoptions, "-Wdisabled-optimization")
              table_insert(jln_buildoptions, "-Wenum-compare")
              table_insert(jln_buildoptions, "-Wextra")
              table_insert(jln_buildoptions, "-Wfloat-equal")
              table_insert(jln_buildoptions, "-Wformat-security")
              table_insert(jln_buildoptions, "-Wformat=2")
              table_insert(jln_buildoptions, "-Winit-self")
              table_insert(jln_buildoptions, "-Winvalid-pch")
              table_insert(jln_buildoptions, "-Wmaybe-uninitialized")
              table_insert(jln_buildoptions, "-Wmissing-include-dirs")
              table_insert(jln_buildoptions, "-Wnarrowing")
              table_insert(jln_buildoptions, "-Wnonnull")
              table_insert(jln_buildoptions, "-Wpointer-sign")
              table_insert(jln_buildoptions, "-Wreorder")
              table_insert(jln_buildoptions, "-Wsequence-point")
              table_insert(jln_buildoptions, "-Wtrigraphs")
              table_insert(jln_buildoptions, "-Wundef")
              table_insert(jln_buildoptions, "-Wunused-function")
              table_insert(jln_buildoptions, "-Wunused-but-set-variable")
              table_insert(jln_buildoptions, "-Wunused-variable")
              table_insert(jln_buildoptions, "-Wpointer-arith")
              table_insert(jln_buildoptions, "-Wold-style-definition")
              table_insert(jln_buildoptions, "-Wstrict-prototypes")
              table_insert(jln_buildoptions, "-Wwrite-strings")
            end
          end
        end
        if values['switch_warnings'] ~= 'default' then
          if ( values['switch_warnings'] == 'on' or values['switch_warnings'] == 'exhaustive_enum' ) then
            table_insert(jln_buildoptions, "-Wswitch-enum")
          else
            if values['switch_warnings'] == 'mandatory_default' then
              table_insert(jln_buildoptions, "-Wswitch-default")
            else
              if values['switch_warnings'] == 'exhaustive_enum_and_mandatory_default' then
                table_insert(jln_buildoptions, "-Wswitch")
              else
                table_insert(jln_buildoptions, "-Wno-switch")
              end
            end
          end
        end
        if values['warnings_as_error'] ~= 'default' then
          if values['warnings_as_error'] == 'on' then
            table_insert(jln_buildoptions, "-Werror")
          else
            if values['warnings_as_error'] == 'basic' then
              table_insert(jln_buildoptions, "-diag-error=1079,39,109")
            end
          end
        end
        if values['pedantic'] ~= 'default' then
          if values['pedantic'] == 'off' then
            table_insert(jln_buildoptions, "-fgnu-keywords")
          else
            table_insert(jln_buildoptions, "-fno-gnu-keywords")
          end
        end
        if values['shadow_warnings'] ~= 'default' then
          if values['shadow_warnings'] == 'off' then
            table_insert(jln_buildoptions, "-Wno-shadow")
          else
            if ( values['shadow_warnings'] == 'on' or values['shadow_warnings'] == 'all' ) then
              table_insert(jln_buildoptions, "-Wshadow")
            end
          end
        end
        if values['debug'] ~= 'default' then
          if values['debug'] == 'off' then
            table_insert(jln_buildoptions, "-g0")
          else
            table_insert(jln_buildoptions, "-g")
          end
        end
        if values['optimization'] ~= 'default' then
          if values['optimization'] == '0' then
            table_insert(jln_buildoptions, "-O0")
          else
            if values['optimization'] == 'g' then
              table_insert(jln_buildoptions, "-O1")
            else
              if values['optimization'] == '1' then
                table_insert(jln_buildoptions, "-O1")
              else
                if values['optimization'] == '2' then
                  table_insert(jln_buildoptions, "-O2")
                else
                  if values['optimization'] == '3' then
                    table_insert(jln_buildoptions, "-O3")
                  else
                    if values['optimization'] == 'z' then
                      table_insert(jln_buildoptions, "-fast")
                    else
                      if values['optimization'] == 'size' then
                        table_insert(jln_buildoptions, "-Os")
                      else
                        table_insert(jln_buildoptions, "-Ofast")
                      end
                    end
                  end
                end
              end
            end
          end
        end
        if values['stack_protector'] ~= 'default' then
          if values['stack_protector'] == 'off' then
            table_insert(jln_buildoptions, "-fno-protector-strong")
            table_insert(jln_buildoptions, "-U_FORTIFY_SOURCE")
            table_insert(jln_linkoptions, "-fno-protector-strong")
          else
            table_insert(jln_buildoptions, "-D_FORTIFY_SOURCE=2")
            if values['stack_protector'] == 'strong' then
              table_insert(jln_buildoptions, "-fstack-protector-strong")
              table_insert(jln_linkoptions, "-fstack-protector-strong")
            else
              if values['stack_protector'] == 'all' then
                table_insert(jln_buildoptions, "-fstack-protector-all")
                table_insert(jln_linkoptions, "-fstack-protector-all")
              else
                table_insert(jln_buildoptions, "-fstack-protector")
                table_insert(jln_linkoptions, "-fstack-protector")
              end
            end
          end
        end
        if values['relro'] ~= 'default' then
          if values['relro'] == 'off' then
            table_insert(jln_linkoptions, "-Xlinker-znorelro")
          else
            if values['relro'] == 'on' then
              table_insert(jln_linkoptions, "-Xlinker-zrelro")
            else
              table_insert(jln_linkoptions, "-Xlinker-zrelro")
              table_insert(jln_linkoptions, "-Xlinker-znow")
              table_insert(jln_linkoptions, "-Xlinker-znoexecstack")
            end
          end
        end
        if values['pie'] ~= 'default' then
          if values['pie'] == 'off' then
            table_insert(jln_linkoptions, "-no-pic")
          else
            if values['pie'] == 'on' then
              table_insert(jln_linkoptions, "-pie")
            else
              if values['pie'] == 'fpie' then
                table_insert(jln_buildoptions, "-fpie")
              else
                if values['pie'] == 'fpic' then
                  table_insert(jln_buildoptions, "-fpic")
                else
                  if values['pie'] == 'fPIE' then
                    table_insert(jln_buildoptions, "-fPIE")
                  else
                    if values['pie'] == 'fPIC' then
                      table_insert(jln_buildoptions, "-fPIC")
                    end
                  end
                end
              end
            end
          end
        end
        if values['sanitizers'] ~= 'default' then
          if values['sanitizers'] == 'on' then
            table_insert(jln_buildoptions, "-ftrapuv")
          end
        end
        if values['integer_sanitizers'] ~= 'default' then
          if values['integer_sanitizers'] == 'on' then
            table_insert(jln_buildoptions, "-funsigned-bitfields")
          else
            table_insert(jln_buildoptions, "-fno-unsigned-bitfields")
          end
        end
        if values['float_sanitizers'] ~= 'default' then
          if values['float_sanitizers'] == 'on' then
            table_insert(jln_buildoptions, "-fp-stack-check")
            table_insert(jln_buildoptions, "-fp-trap=common")
          end
        end
        if values['linker'] ~= 'default' then
          if values['linker'] == 'bfd' then
            table_insert(jln_linkoptions, "-fuse-ld=bfd")
          else
            if values['linker'] == 'gold' then
              table_insert(jln_linkoptions, "-fuse-ld=gold")
            else
              if values['linker'] == 'mold' then
                table_insert(jln_linkoptions, "-fuse-ld=mold")
              else
                table_insert(jln_linkoptions, "-fuse-ld=lld")
              end
            end
          end
        end
        if values['lto'] ~= 'default' then
          if values['lto'] == 'off' then
            table_insert(jln_buildoptions, "-no-ipo")
            table_insert(jln_linkoptions, "-no-ipo")
          else
            table_insert(jln_buildoptions, "-ipo")
            table_insert(jln_linkoptions, "-ipo")
            if values['lto'] == 'fat' then
              if os.target() == 'linux' then
                table_insert(jln_buildoptions, "-ffat-lto-objects")
                table_insert(jln_linkoptions, "-ffat-lto-objects")
              end
            end
          end
        end
        if values['control_flow'] ~= 'default' then
          if values['control_flow'] == 'off' then
            table_insert(jln_buildoptions, "-mconditional-branch=keep")
            table_insert(jln_buildoptions, "-fcf-protection=none")
          else
            if values['control_flow'] == 'branch' then
              table_insert(jln_buildoptions, "-mconditional-branch=all-fix")
              table_insert(jln_buildoptions, "-fcf-protection=branch")
            else
              if values['control_flow'] == 'on' then
                table_insert(jln_buildoptions, "-mconditional-branch=all-fix")
                table_insert(jln_buildoptions, "-fcf-protection=full")
              end
            end
          end
        end
        if values['exceptions'] ~= 'default' then
          if values['exceptions'] == 'on' then
            table_insert(jln_buildoptions, "-fexceptions")
          else
            table_insert(jln_buildoptions, "-fno-exceptions")
          end
        end
        if values['cpu'] ~= 'default' then
          if values['cpu'] == 'generic' then
            table_insert(jln_buildoptions, "-mtune=generic")
            table_insert(jln_linkoptions, "-mtune=generic")
          else
            table_insert(jln_buildoptions, "-xHost")
            table_insert(jln_linkoptions, "-xHost")
          end
        end
      else
        if os.target() == 'mingw' then
          if values['windows_bigobj'] ~= 'default' then
            table_insert(jln_buildoptions, "-Wa,-mbig-obj")
          end
        end
      end
    end
  end
  return {buildoptions=jln_buildoptions, linkoptions=jln_linkoptions}
end

