```lua
-- launch example: xmake f --jln-sanitizers=on

includes'cpp'

-- Registers new command-line options and set default values
jln_cxx_init_options({warnings='very_strict'})

target("hello")
  set_kind("binary")
  on_load(function(target)
    import'cpp.flags'
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
  end)

  add_files("src/*.cpp")

-- NOTE: for C, jln_ and jln_cxx_ prefix function become jln_c_
```


# Options

Supported options are (in alphabetical order):

<!-- ./compiler-options.lua generators/list_options.lua --color -->
```ini
color = default auto never always
control_flow = default off on branch return allow_bugs
coverage = default off on
cpu = default generic native
debug = default off on line_tables_only gdb lldb sce
diagnostics_format = default fixits patch print_source_range_info
diagnostics_show_template_tree = default off on
elide_type = default off on
exceptions = default off on
fix_compiler_error = on default off
linker = default bfd gold lld native
lto = default off on fat thin
microsoft_abi_compatibility_warning = off default on
msvc_isystem = default anglebrackets include_and_caexcludepath
msvc_isystem_with_template_from_non_external = default off on
optimization = default 0 g 1 2 3 fast size
pedantic = on default off as_error
pie = default off on pic
relro = default off on full
reproducible_build_warnings = default off on
rtti = default off on
sanitizers = default off on
sanitizers_extra = default off thread pointer
shadow_warnings = off default on local compatible_local all
stack_protector = default off on strong all
stl_debug = default off on allow_broken_abi allow_broken_abi_and_bugs assert_as_exception
stl_fix = on default off
suggestions = default off on
warnings = on default off strict very_strict
warnings_as_error = default off on basic
whole_program = default off on strip_all
```
<!-- ./compiler-options.lua -->

The value `default` does nothing.

If not specified, `fix_compiler_error`, `pedantic`, `stl_fix` and `warnings` are `on` ; `microsoft_abi_compatibility_warning` and `shadow_warnings` are `off`.

- `control_flow=allow_bugs`
  - clang: Can crash programs with "illegal hardware instruction" on totally unlikely lines. It can also cause link errors and force `-fvisibility=hidden` and `-flto`.
- `stl_debug=allow_broken_abi_and_bugs`
  - clang: libc++ can crash on dynamic memory releases in the standard classes. This bug is fixed with the library associated with version 8.


## Recommended options

category | options
---------|---------
debug | `control_flow=on`<br>`debug=on`<br>`sanitizers=on`<br>`stl_debug=allow_broken_abi` or `on`<br>
release | `cpu=native`<br>`linker=gold`, `lld` or `native`<br>`lto=on` or `thin`<br>`optimization=3`<br>`rtti=off`<br>`whole_program=strip_all`
security | `control_flow=on`<br>`relro=full`<br>`stack_protector=strong`
really strict warnings | `pedantic=as_error`<br>`shadow_warnings=local`<br>`suggestions=on`<br>`warnings=very_strict`

