return {
  --ignore={
  --  optimize=true,
  --  debug=true,
  --},

  tocmakeoption=function(_, optname)
    return _.optprefix .. optname:upper()
  end,

  start=function(_, optprefix)
    optprefix = optprefix and optprefix:upper():gsub('-', '_') or ''
    _.optprefix = optprefix
    _:_vcond_init({
      _not='NOT',
      _and='AND',
      _or='OR',
      openblock='',
      closeblock='',
      else_of_else_if='else',
      _else='else()',
      endif='endif()',
    })

    _:print('# jln_init_flags([<jln-option> <value>]... [VERBOSE on|1])')
    _:print('function(jln_init_flags)')
    _:write('  cmake_parse_arguments(JLN_DEFAULT_FLAG "" "VERBOSE')
    for optname in _:getoptions() do
       _:write(';' .. optname:upper())
    end
    _:print('" "" ${ARGN})\n')

    _:print('  if(DEFINED JLN_DEFAULT_FLAG_VERBOSE)')
    _:print('    set(JLN_VERBOSE ${JLN_DEFAULT_FLAG_VERBOSE})')
    _:print('  endif()\n')

    for optname,args,default_value in _:getoptions() do
      local cmake_opt = 'JLN_DEFAULT_FLAG_' .. optname:upper();
      local opt = _:tocmakeoption(optname)
      _:print('  if(DEFINED ' .. cmake_opt .. ')')
      _:print('    set(' .. opt .. ' ${' .. cmake_opt .. '} CACHE STING "")')
      _:print('  else()')
      _:print('    set(' .. opt .. ' "' .. default_value .. '" CACHE STRING "")')
      _:print('  endif()\n')

      _:print('  if(NOT(("' .. table.concat(args, '" STREQUAL ' .. opt .. ') OR ("') .. '" STREQUAL ' .. opt .. ')))')
      _:print('    message(FATAL_ERROR "Unknow value \\\"${' .. opt .. '}\\\" for ' .. opt .. ', expected: ' .. table.concat(args, ', ') .. '")')
      _:print('  endif()\n')
    end

    _:print('  if("${JLN_VERBOSE}" STREQUAL "on" OR "${JLN_VERBOSE}" STREQUAL "1")')
    for optname,args in _:getoptions() do
      local opt = _:tocmakeoption(optname)
      _:print('    message(STATUS "' .. opt .. '=${' .. opt .. '}\t[' .. table.concat(args, ', ') .. ']")')
    end
    _:print('  endif()\n')
    _:print('endfunction()\n')

    _:print('# jln_target_interface(<libname> [<jln-option> <value>]... [DISABLE_OTHERS on|off])')
    _:print('function(jln_target_interface name type)')
    _:print('  jln_flags(CXX_VAR cxx LINK_VAR link ${ARGV})')
    _:print('  target_link_libraries(${name} INTERFACE ${link})')
    _:print('  target_compile_options(${name} INTERFACE ${cxx})')
    _:print('endfunction()\n')

    _:print('# jln_flags(CXX_VAR <out-variable> LINK_VAR <out-variable> [<jln-option> <value>]... [DISABLE_OTHERS on|off])')
    _:print('function(jln_flags)')
    _:print('  set(CXX_FLAGS "")')
    _:print('  set(LINK_LINK "")')
    _:write('  cmake_parse_arguments(JLN_FLAGS "DISABLE_OTHERS" "CXX_VAR;LINK_VAR')
    for optname in _:getoptions() do
       _:write(';' .. optname:upper())
    end
    _:print('" "" ${ARGN})\n')
    for optname,args,default_value in _:getoptions() do
      local cmake_opt = 'JLN_FLAGS_' .. optname:upper();
      _:print('  if(NOT DEFINED ' .. cmake_opt .. ')')
      _:print('    if(${JLN_FLAGS_DISABLE_OTHERS})')
      _:print('      set(' .. cmake_opt .. ' "' .. default_value .. '")')
      _:print('    else()')
      _:print('      set(' .. cmake_opt .. ' "${' .. _:tocmakeoption(optname) .. '}")')
      _:print('    endif()')
      _:print('  endif()\n')
    end
  end,

  _vcond_lvl=function(_, lvl, optname) return 'JLN_FLAGS_' .. optname:upper() .. ' STREQUAL "' .. lvl .. '"' end,
  _vcond_verless=function(_, major, minor) return 'CMAKE_CXX_COMPILER_VERSION VERSION_LESS "' .. major .. '.' .. minor .. '"' end,

  _comp_id = {
    gcc='"GNU"',
    clang='"Clang"',
    msvc='"MSVC"',
  },
  _vcond_comp=function(_, compiler)
    local str_comp = _._comp_id[compiler]
    if not str_comp then
      error('Unknown ' .. compiler .. ' compiler')
    end
    return 'CMAKE_CXX_COMPILER_ID MATCHES ' .. str_comp
  end,

  cxx=function(_, x) return ' "' .. x .. '"' end,
  link=function(_, x) return ' "' .. x .. '"' end,

  _vcond_toflags=function(_, cxx, links)
    return (#cxx ~= 0 and _.indent .. '  set(CXX_FLAGS ${CXX_FLAGS} ' .. cxx .. ')\n' or '')
        .. (#links ~= 0 and _.indent .. '  set(LINK_FLAGS ${LINK_FLAGS} ' .. links .. ')\n' or '')
  end,

  stop=function(_)
    return _:get_output() .. [[
set(${JLN_FLAGS_CXX_VAR} ${CXX_FLAGS} PARENT_SCOPE)
set(${JLN_FLAGS_LINK_VAR} ${LINK_FLAGS} PARENT_SCOPE)
endfunction()
]]
  end
}
