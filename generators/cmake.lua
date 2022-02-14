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

    for option in _:getoptions() do
      _:print('set(_JLN_' .. option.name:upper() .. '_VALUES '.. table.concat(option.values, ' ') .. ')')
    end
    _:print[[
set(_JLN_VERBOSE_VALUES on off)
set(_JLN_AUTO_PROFILE_VALUES on off)
set(_JLN_DISABLE_OTHERS_VALUES on off)

]]

    for option in _:getoptions() do
      local opt = _:tocmakeoption(option.name)
      _:print('set(' .. opt .. ' "${' .. opt .. '}" CACHE STRING "'
              .. quotable_desc(option, '\\n', '"') .. '")')
      _:print('set_property(CACHE ' .. opt .. ' PROPERTY STRINGS "'
              .. table.concat(option.values, '" "') .. '")')
      _:print('if(NOT("${' .. opt .. '}" STREQUAL ""))')
      _:print('  string(TOLOWER "${' .. opt .. '}" ' .. opt .. ')')
      _:print('  if(NOT(("' .. table.concat(option.values, '" STREQUAL ' .. opt .. ') OR ("')
              .. '" STREQUAL ' .. opt .. ')))')
      _:print('    message(FATAL_ERROR "Unknow value \\\"${' .. opt .. '}\\\" for '
              .. opt .. ', expected: ' .. table.concat(option.values, ', ') .. '")')
      _:print('  endif()')
      _:print('endif()')
    end

    local extraopts = {'verbose', 'auto_profile'}

    for _k, optname in ipairs(extraopts) do
      local opt = _:tocmakeoption(optname)
      _:print('set(' .. opt .. ' ${' .. opt .. '} CACHE STRING "")')
    end

    local compiler_type = _.is_C and 'C' or 'CXX'
    local prefixfunc = _.is_C and 'jln_c' or 'jln'
    local cvar = _.is_C and 'C_VAR' or 'CXX_VAR'
    _.cvar = cvar

    _:print[[
if("${CMAKE_BUILD_TYPE}" STREQUAL "")
  set(_JLN_BUILD_TYPE "Debug")
  set(_JLN_BUILD_TYPE_PARSER "Debug")
else()
  set(_JLN_BUILD_TYPE ${CMAKE_BUILD_TYPE})
  string(TOLOWER ${CMAKE_BUILD_TYPE} _JLN_BUILD_TYPE_PARSER)
endif()
]]
    _:print('function('.. prefixfunc .. '_parse_arguments prefix one_value_keywords)')
    _:print([[
  if(${ARGC} LESS 3)
    return()
  endif()

  set(SAME_BUILD_TYPE 1)
  foreach(ival RANGE 3 ${ARGC} 2)
    math(EXPR i ${ival}-1)
    set(name ${ARGV${i}})
    if(${name} STREQUAL "BUILD_TYPE")
      string(TOLOWER "${ARGV${ival}}" type)
      if(${_JLN_BUILD_TYPE_PARSER} STREQUAL "${type}")
        set(SAME_BUILD_TYPE 1)
      else()
        set(SAME_BUILD_TYPE 0)
      endif()
    else()
      list(FIND one_value_keywords "${name}" INDEX)
      if(${INDEX} EQUAL -1)
        message(FATAL_ERROR "Unknown '${name}' parameter")
      endif()

      set(value "${ARGV${ival}}")
      string(TOLOWER "${value}" lowercase_value)
      list(FIND _JLN_${name}_VALUES "${lowercase_value}" INDEX)
      if(${INDEX} EQUAL -1)
        if(${name} STREQUAL "]] .. cvar .. [[" OR ${name} STREQUAL "LINK_VAR")
          if(SAME_BUILD_TYPE)
            set("${prefix}_${name}" ${value} PARENT_SCOPE)
          endif()
        else()
          list(JOIN _JLN_${name}_VALUES ", " values)
          message(FATAL_ERROR "Parameter '${name}': Unknown '${value}', expected: ${values}")
        endif()
      elseif(SAME_BUILD_TYPE)
        set("${prefix}_${name}" ${lowercase_value} PARENT_SCOPE)
      endif()
    endif()
  endforeach()
endfunction()
]])
    _:print('set(JLN_' .. compiler_type .. '_IS_INITIALIZED 0 CACHE BOOL "private" FORCE)\n\n')
    _:print('# init default values')
    _:print('# '.. prefixfunc .. '_init_flags(')
    _:print('#     ['.. prefixfunc .. '-option> <default_value>]...')
    _:print('#     [AUTO_PROFILE on]')
    _:print('#     [VERBOSE on]')
    _:print('#     [BUILD_TYPE type ['.. prefixfunc .. '-option> <default_value>]...]...')
    _:print('# )')
    _:print('# AUTO_PROFILE: enables options based on CMAKE_BUILD_TYPE (assumes "Debug" if CMAKE_BUILD_TYPE is empty)')
    _:print('# BUILD_TYPE: enables following options only if ${CMAKE_BUILD_TYPE} has the same value (CMAKE_BUILD_TYPE assumed to Debug if empty)')
    _:print('# Example:')
    _:print('#   '.. prefixfunc .. '_init_flags(')
    _:print('#       SUGGESTIONS on')
    _:print('#')
    _:print('#       BUILD_TYPE debug SANITIZERS on')
    _:print('#       BUILD_TYPE release LTO on')
    _:print('#   )')
    _:print('function('.. prefixfunc .. '_init_flags)')
    _:write('  '.. prefixfunc .. '_parse_arguments(JLN_DEFAULT_FLAG "VERBOSE')
    local names = {}
    for option in _:getoptions() do
      local name = option.name:upper()
      names[#names+1] = name
      _:write(';' .. name)
    end
    if _._koptions.auto_profile then
      error('"auto_profile" option is reserved')
    end
    _:write(';AUTO_PROFILE')
    _:print('" ${ARGN})\n')

    for _k, optname in ipairs(extraopts) do
      local opt = _:tocmakeoption(optname)
      local localname = optname:upper()
      local cmake_opt = 'JLN_DEFAULT_FLAG_' .. localname;
      _:print('  if(DEFINED ' .. cmake_opt .. ')')
      _:print('    set(' .. opt .. '_D ${' .. cmake_opt .. '})')
      _:print('  elseif("${' .. opt .. '}" STREQUAL "")')
      _:print('    set(' .. opt .. '_D "")')
      _:print('  else()')
      _:print('    string(TOLOWER "${' .. opt .. '}" ' .. opt .. '_D)')
      _:print('  endif()\n')
    end

    _:print('  if("${JLN_AUTO_PROFILE_D}" STREQUAL "on")')
    local buildtypes = {
      debug='Debug',
      release='Release',
      debug_optimized='RelWithDebInfo',
      minimum_size_release='MinSizeRel',
    }
    for buildtypename, opts in _:getbuildtype() do
      local cmake_buildtype = buildtypes[buildtypename]
      if cmake_buildtype then
        _:print('\n    if("' .. cmake_buildtype .. '" STREQUAL "${_JLN_BUILD_TYPE}")')
        for i,xs in pairs(opts) do
          local cmake_opt = 'JLN_DEFAULT_FLAG_' .. xs[1]:upper()
          _:print('      if(NOT DEFINED ' .. cmake_opt .. ')')
          _:print('        set(' .. cmake_opt .. ' "' .. xs[2] .. '")')
          _:print('      endif()')
        end
        _:print('    endif()')
      end
    end
    _:print('  endif()\n')

    for option in _:getoptions() do
      local localname = option.name:upper()
      local cmake_opt = 'JLN_DEFAULT_FLAG_' .. localname;
      local opt = _:tocmakeoption(option.name)
      _:print('  if(DEFINED ' .. cmake_opt .. ')')
      _:print('    set(' .. opt .. '_D ${' .. cmake_opt .. '} CACHE STRING "private" FORCE)')
      _:print('  elseif("${' .. opt .. '}" STREQUAL "")')
      _:print('    set(' .. opt .. '_D "' .. option.default .. '" CACHE STRING "private" FORCE)')
      _:print('  else()')
      _:print('    set(' .. opt .. '_D "${' .. opt .. '}" CACHE STRING "private" FORCE)')
      _:print('  endif()\n')
    end

    _:print('  if("${JLN_VERBOSE_D}" STREQUAL "on" OR "${JLN_VERBOSE_D}" STREQUAL "1")')
    _:print('    message(STATUS "' .. _:tocmakeoption('auto_profile') .. ' = ${JLN_AUTO_PROFILE_D}\t[off, on]")')
    for option in _:getoptions() do
      local opt = _:tocmakeoption(option.name)
      _:print('    message(STATUS "' .. opt .. ' = ${' .. opt .. '_D}\t[' .. table.concat(option.values, ', ') .. ']")')
    end
    _:print('  endif()\n')
    _:print('  set(JLN_' .. compiler_type .. '_IS_INITIALIZED 1 CACHE BOOL "private" FORCE)\n')
    _:print('endfunction()\n')

    _:print([[
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
  set(JLN_GCC_]].. compiler_type .. [[_COMPILER 1)
elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  if(MSVC)
    set(JLN_CLANG_CL_]].. compiler_type .. [[_COMPILER 1)
  else()
    set(JLN_CLANG_]].. compiler_type .. [[_COMPILER 1)
  endif()
elseif(CMAKE_CXX_COMPILER_ID MATCHES "IntelLLVM")
  set(JLN_ICX_]].. compiler_type .. [[_COMPILER 1)
elseif(CMAKE_CXX_COMPILER_ID MATCHES "Intel")
  if (CMAKE_HOST_WIN32)
    set(JLN_ICL_]].. compiler_type .. [[_COMPILER 1)
  else()
    set(JLN_ICC_]].. compiler_type .. [[_COMPILER 1)
  endif()
endif()

if(CMAKE_HOST_APPLE)
  set(JLN_LD64_]].. compiler_type .. [[_LINKER 1)
elseif(CMAKE_LINKER MATCHES "lld-link")
  set(JLN_LLD_LINK_]].. compiler_type .. [[_LINKER 1)
endif()
    ]])

    local tool_ids = {
      -- compiler
      gcc='JLN_GCC_'.. compiler_type .. '_COMPILER',
      msvc='JLN_MSVC_'.. compiler_type .. '_COMPILER',
      clang='JLN_CLANG_'.. compiler_type .. '_COMPILER',
      ['clang-cl']='JLN_CLANG_CL_'.. compiler_type .. '_COMPILER',
      icl='JLN_ICL_'.. compiler_type .. '_COMPILER',
      icc='JLN_ICC_'.. compiler_type .. '_COMPILER',
      icx='JLN_ICX_'.. compiler_type .. '_COMPILER',
      -- linker
      ld64='JLN_LD64_'.. compiler_type .. '_LINKER',
      ['lld-link']='JLN_LLD_LINK_'.. compiler_type .. '_LINKER',
      -- platform
      mingw='MINGW',
      windows='CMAKE_HOST_WIN32',
      linux='CMAKE_HOST_UNIX',
      macos='CMAKE_HOST_APPLE',
    }
    local vcond_tool = function(_, toolname)
      return tool_ids[toolname] or error('Unknown ' .. toolname .. ' tool')
    end

    _._vcond_compiler = vcond_tool
    _._vcond_platform = vcond_tool
    _._vcond_linker = vcond_tool

    _:print('# '.. prefixfunc .. '_target_interface(')
    _:print('#     <libname> {INTERFACE|PUBLIC|PRIVATE}')
    _:print('#     [<'.. prefixfunc .. '-option> <value>]...')
    _:print('#     [DISABLE_OTHERS {on|off}]')
    _:print('#     [BUILD_TYPE type ['.. prefixfunc .. '-option> <value>]...]...')
    _:print('# )')
    _:print('# BUILD_TYPE: enables following options only if ${CMAKE_BUILD_TYPE} has the same value (CMAKE_BUILD_TYPE assumed to Debug if empty)')
    _:print('function('.. prefixfunc .. '_target_interface name type)')
    _:print('  '.. prefixfunc .. '_flags(' .. cvar .. ' cxx LINK_VAR link ${ARGN})')
    _:print('  add_library(${name} ${type})')
    _:print('  target_link_options(${name} ${type} ${link})')
    _:print('  target_compile_options(${name} ${type} ${cxx})')
    _:print('endfunction()\n')

    _:print('# '.. prefixfunc .. '_flags(')
    _:print('#     ' .. cvar .. ' <out-variable>')
    _:print('#     LINK_VAR <out-variable>')
    _:print('#     [<'.. prefixfunc .. '-option> <value>]...')
    _:print('#     [DISABLE_OTHERS {on|off}]')
    _:print('#     [BUILD_TYPE type ['.. prefixfunc .. '-option> <value>]...]...')
    _:print('# )')
    _:print('# BUILD_TYPE: enables following options only if ${CMAKE_BUILD_TYPE} has the same value (CMAKE_BUILD_TYPE assumed to Debug if empty)')
    _:print('function('.. prefixfunc .. '_flags)')
    _:print('  if(NOT JLN_' .. compiler_type .. '_IS_INITIALIZED)')
    _:print('    '.. prefixfunc .. '_init_flags()')
    _:print('  endif()')
    _:print('  set(CXX_FLAGS "")')
    _:print('  set(LINK_LINK "")')
    _:write('  '.. prefixfunc .. '_parse_arguments(JLN_FLAGS "DISABLE_OTHERS;' .. cvar .. ';LINK_VAR')
    for option in _:getoptions() do
       _:write(';' .. option.name:upper())
    end
    _:print('" ${ARGN})\n')

    for option in _:getoptions() do
      local opt = _:tocmakeoption(option.name)
      local localname = option.name:upper()
      local cmake_opt = 'JLN_FLAGS_' .. localname;
      _:print('  if(NOT DEFINED ' .. cmake_opt .. ')')
      _:print('    if(JLN_FLAGS_DISABLE_OTHERS)')
      _:print('      set(' .. cmake_opt .. ' "' .. option.default .. '")')
      _:print('    else()')
      _:print('      set(' .. cmake_opt .. ' "${' .. opt .. '_D}")')
      _:print('    endif()')
      _:print('  endif()\n')
    end
  end,

  _vcond_lvl=function(_, lvl, optname) return 'JLN_FLAGS_' .. optname:upper() .. ' STREQUAL "' .. lvl .. '"' end,
  _vcond_verless=function(_, major, minor) return 'CMAKE_CXX_COMPILER_VERSION VERSION_LESS "' .. major .. '.' .. minor .. '"' end,

  cxx=function(_, x) return ' "' .. x .. '"' end,
  link=function(_, x) return ' "' .. x .. '"' end,

  act=function(_, name, datas, optname)
    if name == 'msvc_external' then
      local cxx_flags,isystem_flag

      local cat = _.is_C and 'C' or 'CXX'
      for k,d in pairs(datas) do
        if k == 'cxx' then
          cxx_flags = _.indent .. 'set(CMAKE_' .. cat .. '_FLAGS "${CMAKE_' .. cat .. '_FLAGS} '
                      .. table.concat(d, ' ') .. ' " CACHE INTERNAL "")'
        elseif k == 'SYSTEM_FLAG' then
          isystem_flag = _.indent .. 'set(CMAKE_INCLUDE_SYSTEM_FLAG_CXX "' .. d .. ' " CACHE INTERNAL "")'
        else
          return 'Unknow ' .. k
        end
      end

      if cxx_flags and isystem_flag then
        _:print(cxx_flags)
        _:print(isystem_flag)
      else
        return 'Missing key: ' .. (cxx_flags and 'flags' or 'cxx')
      end

      return true
    end
  end,

  _vcond_toflags=function(_, cxx, links)
    return (#cxx ~= 0 and _.indent .. 'list(APPEND CXX_FLAGS ' .. cxx .. ')\n' or '')
        .. (#links ~= 0 and _.indent .. 'list(APPEND LINK_FLAGS ' .. links .. ')\n' or '')
  end,

  stop=function(_)
    return _:get_output() .. [[
  if(JLN_FLAGS_]] .. _.cvar .. [[)
    set(${JLN_FLAGS_]] .. _.cvar .. [[} ${CXX_FLAGS} PARENT_SCOPE)
  endif()
  if(JLN_FLAGS_LINK_VAR)
    set(${JLN_FLAGS_LINK_VAR} ${LINK_FLAGS} PARENT_SCOPE)
  endif()
endfunction()
]]
  end
}
