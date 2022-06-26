```lua
-- launch example: premake5 --jln-sanitizers=on

include "cpp.lua"

-- Registers new command-line options and set default values
jln_newoptions({warnings='very_strict'})

    -- getoptions(values = {}, disable_others = false, print_compiler = false)
    -- `values`: table. ex: {warnings='on'}
    -- `values` can have 3 additional fields:
    --  - `cxx`: compiler name (otherwise deducted from --cxx and --toolchain)
    --  - `cxx_version` (otherwise deducted from cxx)
    --  - `ld`: linker name
    -- `disable_others`: boolean
    -- `print_compiler`: boolean
    -- return {cxxflags=table, ldflags=table}
    -- Note: with C language, cxxflags, cxx and cxx_version become cflags, cc and cc_version
    local options = flags.getoptions({elide_type='on'})
    for _,opt in ipairs(options.cxxflags) do target:add('cxxflags', opt, {force=true}) end
    for _,opt in ipairs(options.ldflags) do target:add('ldflags', opt, {force=true}) end

    -- or equivalent (return also options)
    flags.setoptions(target, {elide_type='on'})

    -- return the merge of the default values and new value table
    local values = flags.tovalues({elide_type='on'}, --[[disable_others:bool]])
    print(values)

-- jln_getoptions(values = {}, disable_others = false, print_compiler = false)
-- `values`: table. ex: {warnings='on'}
-- `values` can have 3 additional fields:
--  - `cxx`: compiler name
--  - `cxx_version` (otherwise deducted from cxx)
--  - `ld`: linker name
-- `disable_others`: boolean
-- `print_compiler`: boolean
-- return {buildoptions=table, linkoptions=table}
-- Note: with C language, cxx and cxx_version become cc and cc_version
local mylib_options = jln_getoptions({elide_type='on'})
buildoptions(mylib_options.buildoptions)
linkoptions(mylib_options.linkoptions)

-- or equivalent
jln_setoptions({elide_type='on'})

-- returns the merge of the default values and new value table
local values = jln_tovalues({elide_type='on'}, --[[disable_others:bool]])
print(values)

-- NOTE: for C, jln_ prefix function becomes jln_c_
```


# Options

Supported options are (alphabetically in a category):

<!-- ./compiler-options.lua generators/list_options.lua --color -->
```ini
# Warning:

analyzer = default off on taint
analyzer_too_complex_warning = default off on
analyzer_verbosity = default 0 1 2 3
conversion_warnings = on default off sign conversion
covered_switch_default_warnings = on default off
fix_compiler_error = on default off
msvc_crt_secure_no_warnings = on default off
noexcept_warnings = default off on
reproducible_build_warnings = default off on
shadow_warnings = off default on local compatible_local all
suggestions = default off on
switch_warnings = on default off exhaustive_enum mandatory_default exhaustive_enum_and_mandatory_default
warnings = on default off strict very_strict
warnings_as_error = default off on basic
windows_abi_compatibility_warnings = off default on

# Pedantic:

msvc_conformance = all default all_without_throwing_new
pedantic = on default off as_error
stl_fix = on default off

# Debug:

debug = default off on line_tables_only gdb lldb sce
float_sanitizers = default off on
integer_sanitizers = default off on
ndebug = with_optimization_1_or_above default off on
other_sanitizers = default off thread pointer memory
sanitizers = default off on
stl_debug = default off on allow_broken_abi allow_broken_abi_and_bugs assert_as_exception
var_init = default pattern

# Optimization:

cpu = default generic native
linker = default bfd gold lld native
lto = default off on fat thin
optimization = default 0 g 1 2 3 fast size z
whole_program = default off on strip_all

# C++:

exceptions = default off on
rtti = default off on

# Hardening:

control_flow = default off on branch return allow_bugs
relro = default off on full
stack_protector = default off on strong all

# Other:

color = default auto never always
coverage = default off on
diagnostics_format = default fixits patch print_source_range_info
diagnostics_show_template_tree = default off on
elide_type = default off on
msvc_isystem = default anglebrackets include_and_caexcludepath external_as_include_system_flag
msvc_isystem_with_template_from_non_external = default off on
pie = default off on static fpic fPIC fpie fPIE
windows_bigobj = on default
```
<!-- ./compiler-options.lua -->

The value `default` does nothing.

If not specified, `conversion_warnings`, `covered_switch_default_warnings`, `fix_compiler_error`, `msvc_crt_secure_no_warnings`, `pedantic`, `stl_fix`, `switch_warnings`, `warnings` and `windows_bigobj` are `on` ; `msvc_conformance` is `all` ; `ndebug` is `with_optimization_1_or_above` ; `shadow_warnings` and `windows_abi_compatibility_warnings` is `off`.

- `control_flow=allow_bugs`
  - clang: Can crash programs with "illegal hardware instruction" on totally unlikely lines. It can also cause link errors and force `-fvisibility=hidden` and `-flto`.
- `stl_debug=allow_broken_abi_and_bugs`
  - clang: libc++ can crash on dynamic memory releases in the standard classes. This bug is fixed with the library associated with version 8.
- `msvc_isystem=external_as_include_system_flag` is only available with `cmake`.


## Recommended options

category | options
---------|---------
debug | `control_flow=on`<br>`debug=on`<br>`sanitizers=on`<br>`stl_debug=allow_broken_abi` or `on`<br>
release | `cpu=native`<br>`linker=gold`, `lld` or `native`<br>`lto=on` or `thin`<br>`optimization=3`<br>`rtti=off`<br>`whole_program=strip_all`
security | `control_flow=on`<br>`relro=full`<br>`stack_protector=strong`<br>`pie=PIE`
really strict warnings | `pedantic=as_error`<br>`shadow_warnings=local`<br>`suggestions=on`<br>`warnings=very_strict`

