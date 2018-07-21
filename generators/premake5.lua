return {
  -- inogre = { optimize=true, }

  tostroption=function(_, optname)
    return _.optprefix .. string.gsub(optname, '_', '-')
  end,

  start=function(_, optprefix)
    _.optprefix = optprefix or ''
    _:_vcond_init({
      _not='not',
      _and='and',
      _or='or',
      else_of_else_if='else',
      openblock='',
      closeblock='',
      ifopen='',
      ifclose='then',
      endif='end',
    })

    _:print('function jln_newoptions(defaults)')
    _:print('  defaults = defaults or {}')
    for optname,v in pairs(_._opts) do
      local opt = _:tostroption(optname)
      _:print('  newoption{trigger="' .. opt .. '", allowed={{"' ..  v[2]:gsub(' ', '"}, {"') .. '"}}, description="' .. optname .. '"}')
      _:print('  if not _OPTIONS["' .. opt .. '"] then _OPTIONS["' .. opt .. '"] = (defaults["' .. optname .. '"] or "' .. v[1] .. '") end')
    end
    _:print('end')

    _:print([[
function jln_setoptions(compiler, version)
  local options = jln_getoptions()
  buildoptions(options.buildoptions)
  linkoptions(options.linkoptions)
  return options
end

function jln_getoptions(compiler, version)
  if not compiler then compiler = _OPTIONS['cc'] or 'gcc'
  elseif compiler == 'g++' then compiler = 'gcc'
  elseif compiler == 'clang++' then compiler = 'clang'
  end

  local compversion = {}
  local output = version
  if not output then
     output = os.outputof(compiler .. " --version")
     if not output then
       return {buildoptions='', linkoptions=''}
     end
     version = output:gsub("^[^ ]+ [^ ]+ ([^ ]+).*", "%1")
  end
  for i in version:gmatch("%d+") do
    compversion[#compversion+1] = tonumber(i)
  end
  if not compversion[1] then
    return
  end
  compversion = compversion[1] * 100 + (compversion[2] or 0)

  local jln_buildoptions, jln_linkoptions = '', ''
]])
  end,

  _vcond_lvl=function(_, lvl, optname) return '_OPTIONS["' .. _:tostroption(optname) .. '"] == "' .. lvl .. '"' end,
  _vcond_verless=function(_, major, minor) return 'compversion < ' .. tostring(major * 100 + minor) end,
  _vcond_comp=function(_, compiler) return 'compiler == "' .. compiler .. '"' end,

  cxx=function(_, x) return ' ' .. x end,
  link=function(_, x) return ' ' .. x end,
  define=function(_, x) return ' -D' .. x end,

  _vcond_toflags=function(_, cxx, links, defines)
    return ((#cxx ~= 0 or #defines ~= 0) and _.indent .. '  jln_buildoptions = jln_buildoptions .. "' .. cxx .. defines .. '"' or '')
        .. ((#cxx ~= 0 or #defines ~= 0) and #links ~= 0 and '\n' or '')
        .. (#links ~= 0                  and _.indent .. '  jln_linkoptions = jln_linkoptions .. "' .. links .. '"' or '')
  end,

  stop=function(_)
    return _:get_output() .. '  return {buildoptions=jln_buildoptions, linkoptions=jln_linkoptions}\nend\nreturn m'
  end,
}
