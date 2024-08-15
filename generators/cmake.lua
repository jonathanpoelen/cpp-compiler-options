local table_insert = table.insert

local version_ops = {
  ['=']='VERSION_EQUAL',
  ['<']='VERSION_LESS',
  ['>']='VERSION_GREATER',
  ['<=']='VERSION_LESS_EQUAL',
  ['>=']='VERSION_GREATER_EQUAL',
}

return {
  --ignore={
  --  optimization=true,
  --  debug=true,
  --},

  tocmakeoption=function(self, optname)
    return self.optprefix .. optname:upper()
  end,

  start=function(self, optprefix)
    optprefix = optprefix and optprefix:upper():gsub('-', '_') or ''
    self.optprefix = optprefix
    self:_vcond_init({
      _not='NOT',
      _and='AND',
      _or='OR',
      openblock='',
      closeblock='',
      _else='else()',
      endif='endif()',
    })

    self:print_header('#')

    for option in self:getoptions() do
      self:print('set(_JLN_' .. option.name:upper() .. '_VALUES '.. table.concat(option.values, ' ') .. ')')
    end
    self:print[[
set(_JLN_VERBOSE_VALUES on off)
set(_JLN_AUTO_PROFILE_VALUES on off)
set(_JLN_DISABLE_OTHERS_VALUES on off)

]]

    for option in self:getoptions() do
      local opt = self:tocmakeoption(option.name)
      self:print('set(' .. opt .. ' "${' .. opt .. '}" CACHE STRING "'
              .. quotable_desc(option, '\\n', '"') .. '")')
      self:print('set_property(CACHE ' .. opt .. ' PROPERTY STRINGS "'
              .. table.concat(option.values, '" "') .. '")')
      self:print('if(NOT("${' .. opt .. '}" STREQUAL ""))')
      self:print('  string(TOLOWER "${' .. opt .. '}" ' .. opt .. ')')
      self:print('  if(NOT(("' .. table.concat(option.values, '" STREQUAL ' .. opt .. ') OR ("')
              .. '" STREQUAL ' .. opt .. ')))')
      self:print('    message(FATAL_ERROR "Unknow value \\\"${' .. opt .. '}\\\" for '
              .. opt .. ', expected: ' .. table.concat(option.values, ', ') .. '")')
      self:print('  endif()')
      self:print('endif()')
    end

    local extraopts = {'verbose', 'auto_profile'}

    for _, optname in ipairs(extraopts) do
      local opt = self:tocmakeoption(optname)
      self:print('set(' .. opt .. ' ${' .. opt .. '} CACHE STRING "")')
    end

    local compiler_type = self.is_C and 'C' or 'CXX'
    local prefixfunc = self.is_C and 'jln_c' or 'jln'
    local cvar = self.is_C and 'C_VAR' or 'CXX_VAR'
    self.cvar = cvar
    self.compiler_type = compiler_type

    self:print[[
if("${CMAKE_BUILD_TYPE}" STREQUAL "")
  set(_JLN_BUILD_TYPE "Debug")
  set(_JLN_BUILD_TYPE_PARSER "Debug")
else()
  set(_JLN_BUILD_TYPE ${CMAKE_BUILD_TYPE})
  string(TOLOWER ${CMAKE_BUILD_TYPE} _JLN_BUILD_TYPE_PARSER)
endif()
]]
    self:print('function('.. prefixfunc .. '_parse_arguments prefix one_value_keywords)')
    self:print([[
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
    self:print('set(JLN_' .. compiler_type .. '_IS_INITIALIZED 0 CACHE BOOL "private" FORCE)\n\n')
    self:print('# init default values')
    self:print('# '.. prefixfunc .. '_init_flags(')
    self:print('#     ['.. prefixfunc .. '-option> <default_value>]...')
    self:print('#     [AUTO_PROFILE on]')
    self:print('#     [VERBOSE on]')
    self:print('#     [BUILD_TYPE type ['.. prefixfunc .. '-option> <default_value>]...]...')
    self:print('# )')
    self:print('# AUTO_PROFILE: enables options based on CMAKE_BUILD_TYPE (assumes "Debug" if CMAKE_BUILD_TYPE is empty)')
    self:print('# BUILD_TYPE: enables following options only if ${CMAKE_BUILD_TYPE} has the same value (CMAKE_BUILD_TYPE assumed to Debug if empty)')
    self:print('# Example:')
    self:print('#   '.. prefixfunc .. '_init_flags(')
    self:print('#       SUGGESTIONS on')
    self:print('#')
    self:print('#       BUILD_TYPE debug SANITIZERS on')
    self:print('#       BUILD_TYPE release LTO on')
    self:print('#   )')
    self:print('function('.. prefixfunc .. '_init_flags)')
    self:write('  '.. prefixfunc .. '_parse_arguments(JLN_DEFAULT_FLAG "VERBOSE')
    local names = {}
    for option in self:getoptions() do
      local name = option.name:upper()
      table_insert(names, name)
      self:write(';' .. name)
    end
    if self._koptions.auto_profile then
      error('"auto_profile" option is reserved')
    end
    self:write(';AUTO_PROFILE')
    self:print('" ${ARGN})\n')

    for _, optname in ipairs(extraopts) do
      local opt = self:tocmakeoption(optname)
      local localname = optname:upper()
      local cmake_opt = 'JLN_DEFAULT_FLAG_' .. localname;
      self:print('  if(DEFINED ' .. cmake_opt .. ')')
      self:print('    set(' .. opt .. '_D ${' .. cmake_opt .. '})')
      self:print('  elseif("${' .. opt .. '}" STREQUAL "")')
      self:print('    set(' .. opt .. '_D "")')
      self:print('  else()')
      self:print('    string(TOLOWER "${' .. opt .. '}" ' .. opt .. '_D)')
      self:print('  endif()\n')
    end

    self:print('  if("${JLN_AUTO_PROFILE_D}" STREQUAL "on")')
    local buildtypes = {
      debug='Debug',
      release='Release',
      debug_optimized='RelWithDebInfo',
      minimum_size_release='MinSizeRel',
    }
    for buildtypename, opts in self:getbuildtype() do
      buildtypename = buildtypes[buildtypename] or error('Unknown build type: ' .. buildtypename)
      self:print('\n    if("' .. buildtypename .. '" STREQUAL "${_JLN_BUILD_TYPE}")')
      for _,xs in pairs(opts) do
        local cmake_opt = 'JLN_DEFAULT_FLAG_' .. xs[1]:upper()
        self:print('      if(NOT DEFINED ' .. cmake_opt .. ')')
        self:print('        set(' .. cmake_opt .. ' "' .. xs[2] .. '")')
        self:print('      endif()')
      end
      self:print('    endif()')
    end
    self:print('  endif()\n')

    for option in self:getoptions() do
      local localname = option.name:upper()
      local cmake_opt = 'JLN_DEFAULT_FLAG_' .. localname;
      local opt = self:tocmakeoption(option.name)
      self:print('  if(DEFINED ' .. cmake_opt .. ')')
      self:print('    set(' .. opt .. '_D ${' .. cmake_opt .. '} CACHE STRING "private" FORCE)')
      self:print('  elseif("${' .. opt .. '}" STREQUAL "")')
      self:print('    set(' .. opt .. '_D "' .. option.default .. '" CACHE STRING "private" FORCE)')
      self:print('  else()')
      self:print('    set(' .. opt .. '_D "${' .. opt .. '}" CACHE STRING "private" FORCE)')
      self:print('  endif()\n')
    end

    self:print('  if("${JLN_VERBOSE_D}" STREQUAL "on" OR "${JLN_VERBOSE_D}" STREQUAL "1")')
    self:print('    message(STATUS "' .. self:tocmakeoption('auto_profile') .. ' = ${JLN_AUTO_PROFILE_D}\t[off, on]")')
    for option in self:getoptions() do
      local opt = self:tocmakeoption(option.name)
      self:print('    message(STATUS "' .. opt .. ' = ${' .. opt .. '_D}\t[' .. table.concat(option.values, ', ') .. ']")')
    end
    self:print('  endif()\n')
    self:print('  set(JLN_' .. compiler_type .. '_IS_INITIALIZED 1 CACHE BOOL "private" FORCE)\n')
    self:print('endfunction()\n')

    self:print([[
set(JLN_]].. compiler_type .. [[_COMPILER_VERSION ${CMAKE_]].. compiler_type .. [[_COMPILER_VERSION})

if(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
  set(JLN_GCC_]].. compiler_type .. [[_COMPILER 1)
elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  set(JLN_CLANG_LIKE_COMPILER 1)
  if (CMAKE_CXX_COMPILER MATCHES ]] .. (self.is_C and '/emcc' or '/em\\\\+\\\\+') .. [[)
    set(JLN_CLANG_EMCC_]].. compiler_type .. [[_COMPILER 1)
  elseif(MSVC)
    set(JLN_CLANG_CL_]].. compiler_type .. [[_COMPILER 1)
  else()
    set(JLN_CLANG_]].. compiler_type .. [[_COMPILER 1)
  endif()
# icx / icpx, dpcpp
elseif(CMAKE_CXX_COMPILER_ID MATCHES "IntelLLVM")
  set(JLN_CLANG_LIKE_COMPILER 1)
  set(JLN_ICX_]].. compiler_type .. [[_COMPILER 1)
  set(JLN_CLANG_]].. compiler_type .. [[_COMPILER 1)
  # extract clang version (dpcpp requires a valid c++ file)
  file(WRITE "${CMAKE_BINARY_DIR}/jln_null.cpp"
             "int vers = __clang_major__ - __clang_minor__;")
  execute_process(
    COMMAND ${CMAKE_CXX_COMPILER} "${CMAKE_BINARY_DIR}/jln_null.cpp" -E
    OUTPUT_VARIABLE JLN_ICX_MACROS_OUTPUT
  )
  file(REMOVE "${CMAKE_BINARY_DIR}/jln_null.cpp")
  string(REGEX MATCH "\nint vers = ([0-9]+) - ([0-9]+)"
         JLN_ICX_MACROS_OUTPUT "${JLN_ICX_MACROS_OUTPUT}")
  set(JLN_]].. compiler_type .. [[_COMPILER_VERSION "${CMAKE_MATCH_1}.${CMAKE_MATCH_2}.${CMAKE_MATCH_3}")
# icc / icl
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
      ['clang-like']='JLN_CLANG_LIKE_COMPILER',
      ['clang-cl']='JLN_CLANG_CL_'.. compiler_type .. '_COMPILER',
      ['clang-emcc']='JLN_CLANG_EMCC_'.. compiler_type .. '_COMPILER',
      icl='JLN_ICL_'.. compiler_type .. '_COMPILER',
      icc='JLN_ICC_'.. compiler_type .. '_COMPILER',
      -- linker
      ld64='JLN_LD64_'.. compiler_type .. '_LINKER',
      ['lld-link']='JLN_LLD_LINK_'.. compiler_type .. '_LINKER',
      -- platform
      mingw='MINGW',
      windows='CMAKE_HOST_WIN32',
      linux='CMAKE_HOST_UNIX',
      macos='CMAKE_HOST_APPLE',
    }
    local vcond_tool = function(self, toolname, not_)
      local expr = tool_ids[toolname] or error('Unknown ' .. toolname .. ' tool')
      return self:propagate_not(expr, not_)
    end

    self._vcond_compiler_like = vcond_tool
    self._vcond_compiler = vcond_tool
    self._vcond_platform = vcond_tool
    self._vcond_linker = vcond_tool

    self:print('# '.. prefixfunc .. '_target_interface(')
    self:print('#     <libname> {INTERFACE|PUBLIC|PRIVATE}')
    self:print('#     [<'.. prefixfunc .. '-option> <value>]...')
    self:print('#     [DISABLE_OTHERS {on|off}]')
    self:print('#     [BUILD_TYPE type ['.. prefixfunc .. '-option> <value>]...]...')
    self:print('# )')
    self:print('# BUILD_TYPE: enables following options only if ${CMAKE_BUILD_TYPE} has the same value (CMAKE_BUILD_TYPE assumed to Debug if empty)')
    self:print('function('.. prefixfunc .. '_target_interface name type)')
    self:print('  '.. prefixfunc .. '_flags(' .. cvar .. ' cxx LINK_VAR link ${ARGN})')
    self:print('  add_library(${name} ${type})')
    self:print('  target_link_options(${name} ${type} ${link})')
    self:print('  target_compile_options(${name} ${type} ${cxx})')
    self:print('endfunction()\n')

    self:print('# '.. prefixfunc .. '_flags(')
    self:print('#     ' .. cvar .. ' <out-variable>')
    self:print('#     LINK_VAR <out-variable>')
    self:print('#     [<'.. prefixfunc .. '-option> <value>]...')
    self:print('#     [DISABLE_OTHERS {on|off}]')
    self:print('#     [BUILD_TYPE type ['.. prefixfunc .. '-option> <value>]...]...')
    self:print('# )')
    self:print('# BUILD_TYPE: enables following options only if ${CMAKE_BUILD_TYPE} has the same value (CMAKE_BUILD_TYPE assumed to Debug if empty)')
    self:print('function('.. prefixfunc .. '_flags)')
    self:print('  if(NOT JLN_' .. compiler_type .. '_IS_INITIALIZED)')
    self:print('    '.. prefixfunc .. '_init_flags()')
    self:print('  endif()')
    self:print('  set(CXX_FLAGS "")')
    self:print('  set(LINK_LINK "")')
    self:write('  '.. prefixfunc .. '_parse_arguments(JLN_FLAGS "DISABLE_OTHERS;' .. cvar .. ';LINK_VAR')
    for option in self:getoptions() do
       self:write(';' .. option.name:upper())
    end
    self:print('" ${ARGN})\n')

    for option in self:getoptions() do
      local opt = self:tocmakeoption(option.name)
      local localname = option.name:upper()
      local cmake_opt = 'JLN_FLAGS_' .. localname
      self:print('  if(NOT DEFINED ' .. cmake_opt .. ')')
      self:print('    if(JLN_FLAGS_DISABLE_OTHERS)')
      self:print('      set(' .. cmake_opt .. ' "' .. option.default .. '")')
      self:print('    else()')
      self:print('      set(' .. cmake_opt .. ' "${' .. opt .. '_D}")')
      self:print('    endif()')
      self:print('  endif()\n')
    end
  end,

  _vcond_resetopt=function(self, optname)
    return 'set(JLN_FLAGS_' .. optname:upper() .. ' "default")'
  end,

  _vcond_lvl=function(self, lvl, optname, not_)
    local expr = 'JLN_FLAGS_' .. optname:upper() .. ' STREQUAL "' .. lvl .. '"'
    return self:propagate_not(expr, not_)
  end,
  _vcond_version=function(self, op, major, minor)
    op = version_ops[op]
    local expr = 'JLN_' .. self.compiler_type .. '_COMPILER_VERSION '
              .. (op or 'VERSION_EQUAL') .. ' "' .. major .. '.' .. minor .. '"'
    return self:propagate_not(expr, not op)
  end,

  cxx=function(self, x) return ' "' .. x .. '"' end,
  link=function(self, x) return ' "' .. x .. '"' end,

  act=function(self, datas, optname)
    local cxx_flags, isystem_flag

    local cat = self.is_C and 'C' or 'CXX'
    for k,d in pairs(datas) do
      if k == 'cxx' then
        cxx_flags = self.indent .. 'set(CMAKE_' .. cat .. '_FLAGS "${CMAKE_' .. cat .. '_FLAGS} '
                 .. d .. ' " CACHE INTERNAL "")'
      elseif k == 'system_flag' then
        isystem_flag = self.indent .. 'set(CMAKE_INCLUDE_SYSTEM_FLAG_' .. cat
                    .. ' "' .. d .. ' " CACHE INTERNAL "")'
      else
        return 'Unknow ' .. k
      end
    end

    if not cxx_flags and not isystem_flag then
      return 'Missing key: system_flag or cxx'
    end

    if cxx_flags then self:print(cxx_flags) end
    if isystem_flag then self:print(isystem_flag) end

    return true
  end,

  _vcond_toflags=function(self, cxx, links)
    return (#cxx ~= 0 and self.indent .. 'list(APPEND CXX_FLAGS ' .. cxx .. ')\n' or '')
        .. (#links ~= 0 and self.indent .. 'list(APPEND LINK_FLAGS ' .. links .. ')\n' or '')
  end,

  stop=function(self)
    return self:get_output() .. [[
  if(JLN_FLAGS_]] .. self.cvar .. [[)
    set(${JLN_FLAGS_]] .. self.cvar .. [[} ${CXX_FLAGS} PARENT_SCOPE)
  endif()
  if(JLN_FLAGS_LINK_VAR)
    set(${JLN_FLAGS_LINK_VAR} ${LINK_FLAGS} PARENT_SCOPE)
  endif()
endfunction()
]]
  end
}
