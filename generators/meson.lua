return {
  ignore={
  --  optimization=true,
  --  debug=true, -- reserved
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
      else_of_else_if='el',
      _else='else',
      endif='endif',
    })

    _:print('# Generated file with https://github.com/jonathanpoelen/cpp-compiler-options\n')

    local prefixfunc = _.is_C and 'jln_c' or 'jln'
    _.prefixfunc = prefixfunc

    local option_strs = _._option_strs
    _:write([[___]] .. prefixfunc .. [[_default_flags = get_variable(']] .. prefixfunc .. [[_default_flags', {})
if get_option('warning_level') == '0'
  ___]] .. prefixfunc .. [[_warnings = 'off'
else
  ___]] .. prefixfunc .. [[_warnings = ___]] .. prefixfunc .. [[_default_flags.get('warnings', get_option(']] .. _:tobuildoption('warnings') .. [['))
endif
___]] .. prefixfunc .. [[_flags = {
]])
    for optname,args,default_value,ordered_args in _:getoptions() do
      local name = _:tobuildoption(optname)
      option_strs[#option_strs+1] = "option('" .. name .. "', type : 'combo', choices : ['" .. table.concat(args, "', '") .. "'], value : '" .. default_value .. "')"
      if optname == 'warnings' then
        _:write("  '" .. optname .. "': ___" .. prefixfunc .. "_warnings,\n")
      else
        _:write("  '" .. optname .. "': ___" .. prefixfunc .. "_default_flags.get('" .. optname .. "', get_option('" .. name .. "')),\n")
      end
    end

    local clang = _.is_C and 'c' or 'cpp'
    _.clang = clang

    _:print([[}

]] .. prefixfunc .. [[_custom_]] .. clang .. [[_flags = []
]] .. prefixfunc .. [[_custom_link_flags = []

___]] .. prefixfunc .. [[_compiler = meson.get_compiler(']] .. clang .. [[')
___]] .. prefixfunc .. [[_compiler_id = ___]] .. prefixfunc .. [[_compiler.get_id()
___]] .. prefixfunc .. [[_compiler_version = ___]] .. prefixfunc .. [[_compiler.version()

___]] .. prefixfunc .. [[_custom_flags = get_variable(']] .. prefixfunc .. [[_custom_flags', []) + [___]] .. prefixfunc .. [[_flags]

foreach ___]] .. prefixfunc .. [[_flags : ___]] .. prefixfunc .. [[_custom_flags
  ]] .. prefixfunc .. [[_]] .. clang .. [[_flags = []
  ]] .. prefixfunc .. [[_link_flags = []

]])
  end,

  _vcond_lvl=function(_, lvl, optname) return  "(___" .. _.prefixfunc .. "_flags.get('" .. optname .. "', 'default') == '" .. lvl .. "')" end,
  _vcond_verless=function(_, major, minor) return "___" .. _.prefixfunc .. "_compiler_version.version_compare('<" .. major .. '.' .. minor .. "')" end,
  _vcond_comp=function(_, compiler) return "(___" .. _.prefixfunc .. "_compiler_id == '" .. compiler .. "')" end,

  cxx=function(_, x) return "'" .. x .. "', " end,
  link=function(_, x) return "'" .. x .. "', " end,

  _vcond_toflags=function(_, cxx, links)
    return (#cxx ~= 0 and _.indent .. '  ' .. _.prefixfunc .. '_' .. _.clang .. '_flags += [' .. cxx .. ']\n' or '')
        .. (#links ~= 0 and _.indent .. '  ' .. _.prefixfunc .. '_link_flags += [' .. links .. ']\n' or '')
  end,

  stop=function(_, filebase)
    local meson_options = table.concat(_._option_strs, '\n') .. '\n'
    local meson_build = _:get_output() .. [[

  ]] .. _.prefixfunc .. [[_custom_]] .. _.clang .. [[_flags += []] .. _.prefixfunc .. [[_]] .. _.clang .. [[_flags]
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
