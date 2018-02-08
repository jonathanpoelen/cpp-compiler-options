function tocmakeoption(optname)
  return 'JLN_CXX_FLAGS_' .. optname:upper()
end

return {
  ignore={
    optimize=true,
    debug=true,
  },

  start=function(_, optprefix)
    optprefix = optprefix or ''
    _:_vcond_init({_not='NOT'})
    for optname,v in pairs(_._opts) do
      local opt = tocmakeoption(optname)
      _:print('option(' .. opt .. ' "' .. optprefix .. string.gsub(v[3] or optname, '_', '-') ..  '" "' .. v[1] .. '")')
      _:print('string(TOLOWER ${' .. opt .. '} ' .. opt .. ')')
      _:print('if not ( "' .. v[2]:gsub(' ', '" STREQUAL ${' .. opt .. '} OR "') .. ' STREQUAL ${' .. opt .. '} )')
      _:print('  error("Unknow value for ' .. opt .. ', expected ' .. v[2]:gsub(' ', ' or ') .. '")')
      _:print('endif()\n')
    end
  end,
  
  _vcond_lvl=function(_, lvl, optname) return tocmakeoption(optname) .. ' STREQUAL "' .. lvl ..'"' end,
  _vcond_verless=function(_, major, minor) return 'CMAKE_CXX_COMPILER_VERSION VERSION_LESS "' .. major .. '.' .. minor .. '"' end,
  _vcond_comp=function(_, compiler) return 'CMAKE_CXX_COMPILER_ID MATCHES ' .. (compiler == 'gcc' and '"GNU"' or '"Clang"') end,

  cxx=function(_, x) return _.indent .. '  ' .. x .. '\n' end,
  link=function(_, x) return _.indent .. '  ' .. x .. '\n' end,
  define=function(_, x) return _.indent .. '  -D' .. x .. '\n' end,
  
  _vcond_toflags=function(_, cxx, links, defines)
    return ((#cxx ~= 0 or #defines ~= 0) and _.indent .. '  add_definitions(\n' .. cxx .. defines .. _.indent .. '  )' or '')
        .. ((#cxx ~= 0 or #defines ~= 0) and #links ~= 0 and '\n' or '')
        .. (#links ~= 0                  and _.indent .. '  link_libraries(\n' .. links           .. _.indent .. '  )' or '')
  end
}
