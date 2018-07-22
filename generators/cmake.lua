return {
  --ignore={
  --  optimize=true,
  --  debug=true,
  --},

  tocmakeoption=function(_, optname)
    return _.optprefix .. optname:upper()
  end,

  start=function(_, optprefix)
    optprefix = optprefix:upper():gsub('-', '_') or ''
    _.optprefix = optprefix
    _:_vcond_init({
      _not='NOT',
      _and='AND',
      _or='OR',
      openblock='',
      openblock='',
      closeblock='',
      else_of_else_if='else',
      _else='else()',
      endif='endif()',
    })

    for optname,args in _:getoptions() do
      local opt = _:tocmakeoption(optname)
      _:print('set(' .. opt .. ' "' .. args[1] .. '" CACHE STRING "")')
      _:print('if(NOT(("' .. table.concat(args, '" STREQUAL ' .. opt .. ') OR ("') .. '" STREQUAL ' .. opt .. ')))')
      _:print('  message(FATAL_ERROR "Unknow value \\\"${' .. opt .. '}\\\" for ' .. opt .. ', expected: ' .. table.concat(args, ', ') .. '")')
      _:print('endif()\n')
    end

    _:print('if("${JLN_VERBOSE}" STREQUAL "on" OR "${JLN_VERBOSE}" STREQUAL "1")')
    for optname,args in _:getoptions() do
      local opt = _:tocmakeoption(optname)
      _:print('  message(STATUS "' .. opt .. '=${' .. opt .. '}\t[' .. table.concat(args, ', ') .. ']")')
    end
    _:print('endif()')

    _:print('set(JLN_CXX_FLAGS "")\nset(JLN_LINK_FLAGS "")\n')
  end,

  _vcond_lvl=function(_, lvl, optname) return _:tocmakeoption(optname) .. ' STREQUAL "' .. lvl .. '"' end,
  _vcond_verless=function(_, major, minor) return 'CMAKE_CXX_COMPILER_VERSION VERSION_LESS "' .. major .. '.' .. minor .. '"' end,
  _vcond_comp=function(_, compiler) return 'CMAKE_CXX_COMPILER_ID MATCHES ' .. (compiler == 'gcc' and '"GNU"' or '"Clang"') end,

  cxx=function(_, x) return ' ' .. x end,
  link=function(_, x) return ' ' .. x end,
  define=function(_, x) return ' -D' .. x end,

  _vcond_toflags=function(_, cxx, links, defines)
    return ((#cxx ~= 0 or #defines ~= 0) and _.indent .. '  string(CONCAT JLN_CXX_FLAGS ${JLN_CXX_FLAGS} "' .. cxx .. defines .. '")\n' or '')
        .. (#links ~= 0 and _.indent .. '  string(CONCAT JLN_LINK_FLAGS ${JLN_LINK_FLAGS} "' .. links .. '")' or '')
  end,

  stop=function(_)
    return _:get_output() .. 'string(STRIP "${JLN_CXX_FLAGS}" JLN_CXX_FLAGS)\nstring(STRIP "${JLN_LINK_FLAGS}" JLN_LINK_FLAGS)'
  end
}
