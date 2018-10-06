return {
  --ignore={
  --  optimize=true,
  --  debug=true,
  --},

  tobuildoption=function(_, optname)
    return _.optprefix .. optname
  end,

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

    _:print('# meson_options.txt')
    for optname,args in _:getoptions() do
      _:print("option('" .. _:tobuildoption(optname) .. "', type : 'combo', choices : ['" .. table.concat(args, "', '") .. "'])")
    end

    _:print([[
# meson.build

jln_cxx_flags = []
jln_link_flags = []

jln_cpp_compiler = meson.get_compiler('cpp')
]])
  end,

  _vcond_lvl=function(_, lvl, optname) return  "get_option('" .. _:tobuildoption(optname) .. "') == '" .. lvl .. "'" end,
  _vcond_verless=function(_, major, minor) return 'false' end,
  _vcond_comp=function(_, compiler) return "jln_cpp_compiler.get_id() == '" .. compiler .. "'" end,

  cxx=function(_, x) return "'" .. x .. "', " end,
  link=function(_, x) return "'" .. x .. "', " end,
  define=function(_, x) return "'-D" .. x .. "', " end,

  _vcond_toflags=function(_, cxx, links, defines)
    return ((#cxx ~= 0 or #defines ~= 0) and _.indent .. '  jln_cxx_flags += [' .. cxx .. defines .. ']\n' or '')
        .. (#links ~= 0 and _.indent .. '  jln_link_flags += [' .. links .. ']\n' or '')
  end,

  stop=function(_)
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
    return table.concat(t, '\n') .. [[

jln_cxx_flags = jln_cpp_compiler.get_supported_arguments(jln_cxx_flags)
jln_link_flags = jln_cpp_compiler.get_supported_arguments(jln_link_flags)
]]
  end
}
