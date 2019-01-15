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
      openblock='',
      closeblock='',
      else_of_else_if='el',
      _else='else',
      endif='endif',
    })

    local option_strs = _._option_strs
    for optname,args,default_value,ordered_args in _:getoptions() do
      option_strs[#option_strs+1] = "option('" .. _:tobuildoption(optname) .. "', type : 'combo', choices : ['" .. table.concat(ordered_args, "', '") .. "'])"
    end

    _:print([[
jln_cpp_flags = []
jln_link_flags = []

jln_cpp_compiler = meson.get_compiler('cpp')
]])
  end,

  _vcond_lvl=function(_, lvl, optname) return  "(get_option('" .. _:tobuildoption(optname) .. "') == '" .. lvl .. "')" end,
  _vcond_verless=function(_, major, minor) return 'false' end,
  _vcond_comp=function(_, compiler) return "(jln_cpp_compiler.get_id() == '" .. compiler .. "')" end,

  cxx=function(_, x) return "'" .. x .. "', " end,
  link=function(_, x) return "'" .. x .. "', " end,
  define=function(_, x) return "'-D" .. x .. "', " end,

  _vcond_toflags=function(_, cxx, links, defines)
    return ((#cxx ~= 0 or #defines ~= 0) and _.indent .. '  jln_cpp_flags += [' .. cxx .. defines .. ']\n' or '')
        .. (#links ~= 0 and _.indent .. '  jln_link_flags += [' .. links .. ']\n' or '')
  end,

  stop=function(_, filebase)
    -- filter empty line and constant condition ; indent
    local t={}
    local depth={}
    local rm={}
    local indent=''
    local flags={}
    local append=function(s)
      if flags[1] then table.insert(t, flags[1]) end
      if flags[2] then table.insert(t, flags[2]) end
      flags={}
      table.insert(t, s)
    end
    local l_byte = string.byte('l', 1)
    for match in _:get_output():gmatch("(.-)\n") do
      match = match:gsub('^ +', ''):gsub(' and not %( false %)', ''):gsub(' and false', '')
      if match == '' then
      elseif match:find('^if %(  not %( false %) %)') then
        table.insert(rm, #depth)
        table.insert(depth, #depth)
      elseif match:find('^endif') then
        table.remove(depth)
        if rm[#rm] == #depth then
          table.remove(rm)
        else
          indent = indent:sub(1, #indent-2)
          append(indent..match)
        end
      elseif match:find('^el') then
        append(indent:sub(1, #indent-2)..match)
      elseif match:find('^if') then
        table.insert(depth, #depth)
        append(indent..match)
        indent = indent..'  '
      elseif match:find('^jln_cxx') or match:find('^jln_link') then
        local i = match:byte(5) == l_byte and 2 or 1
        if flags[i] then
          flags[i] = flags[i]:sub(1, #flags[i]-1) .. match:sub(18+i)
        else
          flags[i] = indent..match
        end
      else
        append(indent..match)
      end
    end

    local meson_options = table.concat(_._option_strs, '\n')
    local meson_build = table.concat(t, '\n') .. [[

jln_cpp_flags = jln_cpp_compiler.get_supported_arguments(jln_cpp_flags)
jln_link_flags = jln_cpp_compiler.get_supported_arguments(jln_link_flags)
]]

    return filebase and {
      {filebase .. '_options.txt', meson_options},
      {filebase, meson_build}
    } or '# meson_options.txt\n' .. meson_options ..
     '\n\n# meson.build\n' .. meson_build
  end
}
