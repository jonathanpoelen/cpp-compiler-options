local table_insert = table.insert

local meson_compilers = {
  icc='intel',
  icl='intel-cl',
  ['clang-emcc']='emscripten',
}

return {
  ignore={
  --  optimization=true,
  --  debug=true, -- reserved
    msvc_isystem={external_as_include_system_flag=true},
  },

  tobuildoption=function(_, optname)
    return _.optprefix .. optname
  end,

  _option_strs = {},

  start=function(_, optprefix)
    _.optprefix = optprefix and optprefix:gsub('-', '_') or ''
    _:_vcond_init({
      _not='not',
      _and='and',
      _or='or',
      openblock='',
      closeblock='',
      _else='else',
      endif='endif',
    })

    _:print_header('#')

    local prefixfunc = _.is_C and 'jln_c' or 'jln'
    _.prefixfunc = prefixfunc

    local option_strs = _._option_strs
    _:write([[
___]] .. prefixfunc .. [[_default_flags = get_variable(']] .. prefixfunc .. [[_default_flags', {}) + get_variable(']] .. prefixfunc .. [[_buildtype_flags', {}).get(get_option('buildtype'), {})
if get_option('warning_level') == '0'
  ___]] .. prefixfunc .. [[_warnings = 'off'
else
  ___]] .. prefixfunc .. [[_warnings = ___]] .. prefixfunc .. [[_default_flags.get('warnings', get_option(']] .. _:tobuildoption('warnings') .. [['))
endif
___]] .. prefixfunc .. [[_flags = {
]])
    for option in _:getoptions() do
      local name = _:tobuildoption(option.name)
      table_insert(option_strs, "option('" .. name .. "', type : 'combo', choices : ['"
        .. table.concat(option.values, "', '") .. "'], value : '" .. option.default
        .. "', description : '" .. quotable_desc(option) .. "')")
      if option.name == 'warnings' then
        _:write("  '" .. option.name .. "': ___" .. prefixfunc .. "_warnings,\n")
      else
        _:write("  '" .. option.name .. "': ___" .. prefixfunc .. "_default_flags.get('" .. option.name .. "', get_option('" .. name .. "')),\n")
      end
    end

    local lang = _.lang

    _.platforms = {
      mingw="(host_machine.system() == 'windows' and ___"
            .. _.prefixfunc .. "_compiler_id == 'gcc')",
      windows="host_machine.system() == 'windows'",
      linux="host_machine.system() == 'linux'",
      macos="host_machine.system() == 'macos'",
    }

    _:print([[}

]] .. prefixfunc .. [[_custom_]] .. lang .. [[_flags = []
]] .. prefixfunc .. [[_custom_link_flags = []

___]] .. prefixfunc .. [[_compiler = meson.get_compiler(']] .. lang .. [[')
___]] .. prefixfunc .. [[_compiler_id = ___]] .. prefixfunc .. [[_compiler.get_id()
if ___]] .. prefixfunc .. [[_compiler_id == 'emscripten'
  ___]] .. prefixfunc .. [[_compiler_version = ___]] .. prefixfunc .. [[_compiler.get_define('__clang_major__.__clang_minor__').replace(' ', '')
else
  ___]] .. prefixfunc .. [[_compiler_version = ___]] .. prefixfunc .. [[_compiler.version()
endif
___]] .. prefixfunc .. [[_linker_id = ___]] .. prefixfunc .. [[_compiler.get_linker_id()

___]] .. prefixfunc .. [[_custom_flags = get_variable(']] .. prefixfunc .. [[_custom_flags', []) + [___]] .. prefixfunc .. [[_flags]

foreach ___]] .. prefixfunc .. [[_flags : ___]] .. prefixfunc .. [[_custom_flags
  ]] .. prefixfunc .. [[_]] .. lang .. [[_flags = []
  ]] .. prefixfunc .. [[_link_flags = []

]])
  end,

  _vcond_lvl=function(_, lvl, optname) return  "(___" .. _.prefixfunc .. "_flags.get('" .. optname .. "', 'default') == '" .. lvl .. "')" end,
  _vcond_verless=function(_, major, minor) return "___" .. _.prefixfunc .. "_compiler_version.version_compare('<" .. major .. '.' .. minor .. "')" end,
  _vcond_compiler=function(_, compiler) return "(___" .. _.prefixfunc .. "_compiler_id == '" .. (meson_compilers[compiler] or compiler) .. "')" end,
  _vcond_platform=function(_, platform) return _.platforms[platform] end,
  _vcond_linker=function(_, linker) return "(___" .. _.prefixfunc .. "_linker_id == '" .. linker .. "')" end,

  cxx=function(_, x) return "'" .. x .. "', " end,
  link=function(_, x) return "'" .. x .. "', " end,

  act=function(_, name, datas, optname)
    _:print(_.indent .. '# unimplementable')
    return true
  end,

  _vcond_toflags=function(_, cxx, links)
    return (#cxx ~= 0 and _.indent .. _.prefixfunc .. '_' .. _.lang .. '_flags += [' .. cxx .. ']\n' or '')
        .. (#links ~= 0 and _.indent .. _.prefixfunc .. '_link_flags += [' .. links .. ']\n' or '')
  end,

  stop=function(_, filebase)
    local meson_options = table.concat(_._option_strs, '\n') .. '\n'
    local meson_build = _:get_output() .. [[

  ]] .. _.prefixfunc .. [[_custom_]] .. _.lang .. [[_flags += []] .. _.prefixfunc .. [[_]] .. _.lang .. [[_flags]
  ]] .. _.prefixfunc .. [[_custom_link_flags += []] .. _.prefixfunc .. [[_link_flags]
endforeach
]]

    return filebase and {
      {filebase .. '_options.txt', meson_options},
      {filebase, meson_build}
    } or '# meson_options.txt\n' .. meson_options ..
     '\n\n# meson.build\n' .. meson_build
  end
}
