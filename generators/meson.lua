return {
  ignore={
  --  optimize=true,
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

    local option_strs = _._option_strs
    _:print("___jln_default_flags = get_variable('jln_default_flags', {})\n___jln_flags = {\n")
    for optname,args,default_value,ordered_args in _:getoptions() do
      local name = _:tobuildoption(optname)
      option_strs[#option_strs+1] = "option('" .. name .. "', type : 'combo', choices : ['" .. table.concat(args, "', '") .. "'], value : '" .. default_value .. "')"
      _:print("  '" .. name .. "': ___jln_default_flags.get('" .. name .. "', get_option('" .. name .. "')),\n")
    end

    _:print[[}

jln_custom_cpp_flags = []
jln_custom_link_flags = []

___jln_cpp_compiler = meson.get_compiler('cpp')
___jln_compiler_id = ___jln_cpp_compiler.get_id()
___jln_compiler_version = ___jln_cpp_compiler.version()

___jln_custom_flags = get_variable('jln_custom_flags', []) + [___jln_flags]

foreach ___jln_flags : ___jln_custom_flags
jln_cpp_flags = []
jln_link_flags = []

]]
  end,

  _vcond_lvl=function(_, lvl, optname) return  "(___jln_flags.get('" .. _:tobuildoption(optname) .. "', 'default') == '" .. lvl .. "')" end,
  _vcond_verless=function(_, major, minor) return "___jln_compiler_version.version_compare('<" .. major .. '.' .. minor .. "')" end,
  _vcond_comp=function(_, compiler) return "(___jln_compiler_id == '" .. compiler .. "')" end,

  cxx=function(_, x) return "'" .. x .. "', " end,
  link=function(_, x) return "'" .. x .. "', " end,

  _vcond_toflags=function(_, cxx, links)
    return (#cxx ~= 0 and _.indent .. '  jln_cpp_flags += [' .. cxx .. ']\n' or '')
        .. (#links ~= 0 and _.indent .. '  jln_link_flags += [' .. links .. ']\n' or '')
  end,

  stop=function(_, filebase)
    local meson_options = table.concat(_._option_strs, '\n')
    local meson_build = _:get_output() .. [[

  jln_custom_cpp_flags += [jln_cpp_flags]
  jln_custom_link_flags += [jln_link_flags]
endforeach
]]

    return filebase and {
      {filebase .. '_options.txt', meson_options},
      {filebase, meson_build}
    } or '# meson_options.txt\n' .. meson_options ..
     '\n\n# meson.build\n' .. meson_build
  end
}
