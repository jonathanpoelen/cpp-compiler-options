return {
  --ignore={
  --  optimization=true,
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
      _else='else()',
      endif='endif()',
    })

    _:print('# File generated with https://github.com/jonathanpoelen/cpp-compiler-options\n')

    local print_check_value = function(prefix, localname, expositionname, values)
      _:print(prefix .. 'if(NOT(("' .. table.concat(values, '" STREQUAL ' .. localname .. ') OR ("') .. '" STREQUAL ' .. localname .. ')))')
      _:print(prefix .. '  message(FATAL_ERROR "Unknow value \\\"${' .. localname .. '}\\\" for ' .. expositionname .. ', expected: ' .. table.concat(values, ', ') .. '")')
      _:print(prefix .. 'endif()')
    end

    for optname,args in _:getoptions() do
      local opt = _:tocmakeoption(optname)
      _:print('set(' .. opt .. ' "${' .. opt .. '}" CACHE STRING "")')
      _:print('if(NOT("${' .. opt .. '}" STREQUAL ""))')
      _:print('  string(TOLOWER "${' .. opt .. '}" ' .. opt .. ')')
      print_check_value('  ', opt, opt, args)
      _:print('endif()')
    end

    local extraopts = {'verbose', 'auto_profile'}

    for _k, optname in ipairs(extraopts) do
      local opt = _:tocmakeoption(optname)
      _:print('set(' .. opt .. ' ${' .. opt .. '} CACHE STRING "")')
    end

    local prefixfunc = _.is_C and 'jln_c' or 'jln'
    local cvar = _.is_C and 'C_VAR' or 'CXX_VAR'
    _.cvar = cvar

    _:print('\n# init default values')
    _:print('# '.. prefixfunc .. '_init_flags([<'.. prefixfunc .. '-option> <default_value>]... [AUTO_PROFILE on] [VERBOSE on])')
    _:print('# AUTO_PROFILE: enables options based on CMAKE_BUILD_TYPE (assumes "Debug" if CMAKE_BUILD_TYPE is empty)')
    _:print('function('.. prefixfunc .. '_init_flags)')
    _:write('  cmake_parse_arguments(JLN_DEFAULT_FLAG "" "VERBOSE')
    local names = {}
    for optname in _:getoptions() do
      local name = optname:upper()
      names[#names+1] = name
      _:write(';' .. name)
    end
    if _._opts['auto_profile'] then
      error('profile option is reserved')
    end
    _:write(';AUTO_PROFILE')
    _:print('" "" ${ARGN})\n')

    for _k, optname in ipairs(extraopts) do
      local opt = _:tocmakeoption(optname)
      local localname = optname:upper()
      local cmake_opt = 'JLN_DEFAULT_FLAG_' .. localname;
      _:print('  if(DEFINED ' .. cmake_opt .. ')')
      _:print('    set(' .. opt .. '_D ${' .. cmake_opt .. '})')
      _:print('  elseif("${' .. opt .. '}" STREQUAL "")')
      _:print('    set(' .. opt .. '_D "")')
      _:print('  else()')
      _:print('    set(' .. opt .. '_D "${' .. opt .. '}")')
      _:print('  endif()')
      _:print('  string(TOLOWER "${' .. opt .. '}" ' .. opt .. ')\n')
    end

    _:print('  if("${JLN_AUTO_PROFILE_D}" STREQUAL "on")')
    _:print('    if("${CMAKE_BUILD_TYPE}" STREQUAL "")')
    _:print('      set(JLN_BUILD_TYPE "Debug")')
    _:print('    else()')
    _:print('      set(JLN_BUILD_TYPE ${CMAKE_BUILD_TYPE})')
    _:print('    endif()')
    local buildtypes = {
      debug='Debug',
      release='Release',
      debug_optimized='RelWithDebInfo',
      minimum_size_release='MinSizeRel',
    }
    for buildtypename, opts in _:getbuildtype() do
      local cmake_buildtype = buildtypes[buildtypename]
      if cmake_buildtype then
        _:print('\n    if("' .. cmake_buildtype .. '" STREQUAL "${JLN_BUILD_TYPE}")')
        for i,xs in pairs(opts) do
          local cmake_opt = 'JLN_DEFAULT_FLAG_' .. xs[1]:upper()
          _:print('      if(NOT(DEFINED ' .. cmake_opt .. '))')
          _:print('        set(' .. cmake_opt .. ' "' .. xs[2] .. '")')
          _:print('      endif()')
        end
        _:print('    endif()')
      end
    end
    _:print('  endif()\n')

    for optname,args,default_value in _:getoptions() do
      local localname = optname:upper()
      local cmake_opt = 'JLN_DEFAULT_FLAG_' .. localname;
      local opt = _:tocmakeoption(optname)
      _:print('  if(DEFINED ' .. cmake_opt .. ')')
      _:print('    string(TOLOWER "${' .. cmake_opt .. '}" ' .. cmake_opt .. ')')
      print_check_value('    ', cmake_opt, localname, args)
      _:print('    set(' .. opt .. '_D ${' .. cmake_opt .. '} CACHE STRING "private" FORCE)')
      _:print('  elseif("${' .. opt .. '}" STREQUAL "")')
      _:print('    set(' .. opt .. '_D "' .. default_value .. '" CACHE STRING "private" FORCE)')
      _:print('  else()')
      _:print('    set(' .. opt .. '_D "${' .. opt .. '}" CACHE STRING "private" FORCE)')
      _:print('  endif()\n')
    end

    _:print('  if("${JLN_VERBOSE_D}" STREQUAL "on" OR "${JLN_VERBOSE_D}" STREQUAL "1")')
    _:print('    message(STATUS "' .. _:tocmakeoption('auto_profile') .. ' = ${JLN_AUTO_PROFILE_D}\t[off, on]")')
    for optname,args in _:getoptions() do
      local opt = _:tocmakeoption(optname)
      _:print('    message(STATUS "' .. opt .. ' = ${' .. opt .. '_D}\t[' .. table.concat(args, ', ') .. ']")')
    end
    _:print('  endif()\n')
    _:print('endfunction()\n')

    _:print('# '.. prefixfunc .. '_target_interface(<libname> {INTERFACE|PUBLIC|PRIVATE} [<'.. prefixfunc .. '-option> <value>]... [DISABLE_OTHERS on|off])')
    _:print('function('.. prefixfunc .. '_target_interface name type)')
    _:print('  '.. prefixfunc .. '_flags(' .. cvar .. ' cxx LINK_VAR link ${ARGV})')
    _:print('  add_library(${name} ${type})')
    _:print('  target_link_libraries(${name} ${type} ${link})')
    _:print('  target_compile_options(${name} ${type} ${cxx})')
    _:print('endfunction()\n')

    _:print('# '.. prefixfunc .. '_flags(' .. cvar .. ' <out-variable> LINK_VAR <out-variable> [<'.. prefixfunc .. '-option> <value>]... [DISABLE_OTHERS on|off])')
    _:print('function('.. prefixfunc .. '_flags)')
    _:print('  set(CXX_FLAGS "")')
    _:print('  set(LINK_LINK "")')
    _:write('  cmake_parse_arguments(JLN_FLAGS "DISABLE_OTHERS" "' .. cvar .. ';LINK_VAR')
    for optname in _:getoptions() do
       _:write(';' .. optname:upper())
    end
    _:print('" "" ${ARGN})\n')

    for optname,args,default_value in _:getoptions() do
      local opt = _:tocmakeoption(optname)
      local localname = optname:upper()
      local cmake_opt = 'JLN_FLAGS_' .. localname;
      _:print('  if(DEFINED ' .. cmake_opt .. ')')
      _:print('    string(TOLOWER "${' .. cmake_opt .. '}" ' .. cmake_opt .. ')')
      print_check_value('    ', cmake_opt, localname, args)
      _:print('  else()')
      _:print('    if(${JLN_FLAGS_DISABLE_OTHERS})')
      _:print('      set(' .. cmake_opt .. ' "' .. default_value .. '")')
      _:print('    else()')
      _:print('      set(' .. cmake_opt .. ' "${' .. opt .. '_D}")')
      _:print('    endif()')
      _:print('  endif()\n')
    end
  end,

  _vcond_lvl=function(_, lvl, optname) return 'JLN_FLAGS_' .. optname:upper() .. ' STREQUAL "' .. lvl .. '"' end,
  _vcond_verless=function(_, major, minor) return 'CMAKE_CXX_COMPILER_VERSION VERSION_LESS "' .. major .. '.' .. minor .. '"' end,

  _comp_id = {
    gcc='"GNU"',
    clang='"Clang"',
    ['clang-cl']='"Clang" AND DEFINED MSVC',
    msvc='"MSVC"',
  },
  _vcond_compiler=function(_, compiler)
    local str_comp = _._comp_id[compiler]
    if not str_comp then
      error('Unknown ' .. compiler .. ' compiler')
    end
    return 'CMAKE_CXX_COMPILER_ID MATCHES ' .. str_comp
  end,

  cxx=function(_, x) return ' "' .. x .. '"' end,
  link=function(_, x) return ' "' .. x .. '"' end,

  _vcond_toflags=function(_, cxx, links)
    return (#cxx ~= 0 and _.indent .. '  list(APPEND CXX_FLAGS ' .. cxx .. ')\n' or '')
        .. (#links ~= 0 and _.indent .. '  list(APPEND LINK_FLAGS ' .. links .. ')\n' or '')
  end,

  stop=function(_)
    return _:get_output() .. [[
set(${JLN_FLAGS_]] .. _.cvar .. [[} ${CXX_FLAGS} PARENT_SCOPE)
set(${JLN_FLAGS_LINK_VAR} ${LINK_FLAGS} PARENT_SCOPE)
endfunction()
]]
  end
}
