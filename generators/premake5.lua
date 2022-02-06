return {
  ignore={
  --  optimization=true,
    msvc_isystem={external_as_include_system_flag=true},
  },

  tostroption=function(_, optname)
    return _.optprefix .. optname:gsub('_', '-')
  end,

  start=function(_, optprefix)
    _.optprefix = optprefix or ''
    _:_vcond_init({
      _not='not',
      _and='and',
      _or='or',
      openblock='',
      closeblock='',
      ifopen='',
      ifclose='then',
      endif='end',
    })

    _:print('-- File generated with https://github.com/jonathanpoelen/cpp-compiler-options\n')

    local compprefix = (_.is_C and 'cc' or 'cxx')
    local prefixfunc = _.is_C and 'jln_c' or 'jln'
    local comp_gcc = _.is_C and "'gcc'" or "'g++'"
    local comp_clang = _.is_C and "'clang'" or "'clang++'"

    local extraopts = {
      {compprefix, 'Path or name of the compiler for jln functions'},
      {compprefix..'_version', 'Force the compiler version for jln functions'},
      {'ld', 'Path or name of the linker for jln functions'},
    }

    _:print('local _' .. prefixfunc .. '_extraopt_flag_names = {')
    for i,extra in ipairs(extraopts) do
      local optname = extra[1]
      local opt = _:tostroption(optname)
      _:print('  ["' .. opt .. '"] = true,')
      _:print('  ["' .. optname .. '"] = true,')
    end
    _:print('}\n')

    _:print('local _' .. prefixfunc .. '_flag_names = {')
    for option in _:getoptions() do
      local optname = option.name
      local opt = _:tostroption(optname)
      _:print('  ["' .. opt .. '"] = true,')
      if opt ~= optname then
        _:print('  ["' .. optname .. '"] = true,')
      end
    end
    _:print('}\n')

    _:print([[
local _]] .. prefixfunc .. [[_check_flag_names = function(t)
  for k in pairs(t) do
    if not _]] .. prefixfunc .. [[_flag_names[k]
    and not _]] .. prefixfunc .. [[_extraopt_flag_names[k] then
      error("unknown '" .. k .. "' jln flag name")
    end
  end
end]])

    _:print('\nfunction ' .. prefixfunc .. '_newoptions(defaults)')
    _:print('  if defaults then')
    _:print('    _' .. prefixfunc .. '_check_flag_names(defaults)')
    _:print('  else')
    _:print('    defaults = {}')
    _:print('  end')
    for option in _:getoptions() do
      local optname = option.name
      local opt = _:tostroption(optname)
      local values = {}
      for i,v in ipairs(option.values) do
        local desc = option.value_descriptions[i]
        if desc then
          values[#values+1] = "{'" .. v .. "', '".. quotable(desc) .. "'}"
        else
          values[#values+1] = "{'" .. v .. "'}"
        end
      end
      _:print('\n  newoption{trigger="' .. opt .. '", allowed={' ..  table.concat(values, ', ') .. '}, description="' .. quotable(option.description) .. '"}')
      _:print('  if not _OPTIONS["' .. opt .. '"] then _OPTIONS["' .. opt .. '"] = (defaults["' .. optname .. '"] ' .. (opt ~= optname and 'or defaults["' .. opt .. '"]' or '') .. ' or "' .. option.default .. '") end')
    end
    for i,extra in ipairs(extraopts) do
      local optname = extra[1]
      local desc = extra[2]
      local opt = _:tostroption(optname)
      _:print('  newoption{trigger="' .. opt .. '", description="' .. desc .. '"}')
    end
    _:print('end\n')

    _:print([[
-- same as ]] .. prefixfunc .. [[_getoptions
function ]] .. prefixfunc .. [[_setoptions(compiler, version, values, disable_others, print_compiler)
  local options = ]] .. prefixfunc .. [[_getoptions(compiler, version, values, disable_others, print_compiler)
  buildoptions(options.buildoptions)
  linkoptions(options.linkoptions)
  return options
end

local _]] .. prefixfunc .. [[_compiler_by_os = {
  windows='msvc',
  linux=]] .. comp_gcc .. [[,
  cygwin=]] .. comp_gcc .. [[,
  mingw=]] .. comp_gcc .. [[,
  bsd=]] .. comp_gcc .. [[,
  macosx=]] .. comp_clang .. [[,
}

local _]] .. prefixfunc .. [[_default_compiler = ]] .. comp_gcc .. [[

local _]] .. prefixfunc .. [[_comp_cache = {}

local _get_extra = function(opt)
  local x = _OPTIONS[opt]
  return x ~= '' and x or nil
end

-- Returns the merge of the default values and new value table
-- ]] .. prefixfunc .. [[_tovalues(table, disable_others = false)
-- `values`: table. ex: {warnings='on'}
-- `values` can have 3 additional fields:
--  - `cxx`: compiler name (otherwise deducted from --cxx and --toolchain)
--  - `cxx_version`: compiler version (otherwise deducted from cxx). ex: '7', '7.2'
--  - `ld`: linker name
function ]] .. prefixfunc .. [[_tovalues(values, disable_others)
  if values then
    _]] .. prefixfunc .. [[_check_flag_names(values)
    return {]])
    for option in _:getoptions() do
      local optname = option.name
      local opt = _:tostroption(optname)
      local isnotsamename = (opt ~= optname)
      _:print('      ["' .. optname .. '"] = values["' .. optname .. '"] '
              .. (isnotsamename and 'or values["' .. opt .. '"] ' or '')
              .. 'or (disable_others and "default" or _OPTIONS["' .. opt .. '"]),')
    end
    for i,extra in ipairs(extraopts) do
      local optname = extra[1]
      local opt = _:tostroption(optname)
      _:print('      ["' .. optname .. '"] = values["' .. optname .. '"] '
              .. (isnotsamename and 'or values["' .. opt .. '"] ' or '')
              .. 'or (not disable_others and _get_extra("' .. opt .. '")) or nil,')
    end
    _:print([[}
  else
    return {]])
    for option in _:getoptions() do
      local optname = option.name
      local opt = _:tostroption(optname)
      _:print('      ["' .. optname .. '"] = _OPTIONS["' .. opt .. '"],')
    end
    for i,extra in ipairs(extraopts) do
      local optname = extra[1]
      local opt = _:tostroption(optname)
      _:print('      ["' .. optname .. '"] = _get_extra("' .. opt .. '"),')
    end
    _:print([[}
  end
end

-- ]] .. prefixfunc .. [[_getoptions(values = {}, disable_others = false, print_compiler = false)
-- `values`: same as ]] .. prefixfunc .. [[_tovalue()
-- `disable_others`: boolean
-- `print_compiler`: boolean
-- return {buildoptions={}, linkoptions={}}
function ]] .. prefixfunc .. [[_getoptions(values, disable_others, print_compiler)
  local compversion

  values = ]] .. prefixfunc .. [[_tovalues(values, disable_others)
  local compiler = values.]] .. compprefix .. [[
  local version = values.]] .. compprefix .. [[_version
  local linker = values.ld or (not disable_others and _OPTIONS['ld']) or nil

  local cache = _]] .. prefixfunc .. [[_comp_cache
  local original_compiler = compiler or ''
  local compcache = cache[original_compiler]

  if compcache then
    compiler = compcache[1]
    version = compcache[2]
    compversion = compcache[3]
    if not compiler then
      -- printf("WARNING: unknown compiler")
      return {buildoptions={}, linkoptions={}}
    end
  else
    cache[original_compiler] = {}

    if not compiler then
      compiler = _OPTIONS[']] .. _:tostroption'compiler' .. [[']
              or _OPTIONS['cc']
              or _]] .. prefixfunc .. [[_compiler_by_os[os.target()]
              or _]] .. prefixfunc .. [[_default_compiler
      version = _OPTIONS[']] .. _:tostroption'compiler-version' .. [['] or nil
    end

    local compiler_path = compiler
    if compiler then
      compiler = (compiler:find('clang-cl', 1, true) and 'clang-cl') or
                 (compiler:find('clang', 1, true) and 'clang') or
                 ((compiler:find('msvc', 1, true) or
                   compiler:find('MSVC', 1, true) or
                   compiler:find('^vs%d') or
                   compiler:find('^VS%d')
                  ) and 'msvc') or
                 ((compiler:find('g++', 1, true) or
                   compiler:find('gcc', 1, true) or
                   compiler:find('GCC', 1, true) or
                   compiler:find('MinGW', 1, true) or
                   compiler:find('mingw', 1, true)
                  ) and 'gcc') or
                 nil
    end

    if not compiler then
      -- printf("WARNING: unknown compiler")
      return {buildoptions={}, linkoptions={}}
    end

    if not version then
      local output = os.outputof(compiler_path .. " --version")
      if output then
        output = output:sub(0, output:find('\n') or #output)
        version = output:match("%d+%.%d+%.%d+")
      else
        printf("WARNING: `%s --version` failed", compiler)
        output = original_compiler:match("%d+%.?%d*%.?%d*$")
        if output then
          version = output
          printf("Extract version %s of the compiler name", version)
        end
      end

      if not version then
        version = tostring(tonumber(os.date("%y")) - (compiler:sub(0, 5) == 'clang' and 14 or 12))
      end
    end

    compversion = {}
    for i in version:gmatch("%d+") do
      compversion[#compversion+1] = tonumber(i)
    end
    if not compversion[1] then
      printf("WARNING: wrong version format")
      return {buildoptions={}, linkoptions={}}
    end
    compversion = compversion[1] * 100 + (compversion[2] or 0)

    cache[original_compiler] = {compiler, version, compversion}
  end

  if print_compiler then
    printf("]] .. prefixfunc .. [[_getoptions: compiler: %s, version: %s", compiler, version)
  end

  local jln_buildoptions, jln_linkoptions = {}, {}
]])
  end,

  _vcond_lvl=function(_, lvl, optname) return 'values["' .. optname .. '"] == "' .. lvl .. '"' end,
  _vcond_verless=function(_, major, minor) return 'compversion < ' .. tostring(major * 100 + minor) end,
  _vcond_compiler=function(_, compiler) return 'compiler == "' .. compiler .. '"' end,
  _vcond_platform=function(_, platform) return 'os.target() == "' .. platform .. '"' end,
  _vcond_linker=function(_, linker) return 'linker == "' .. linker .. '"' end,

  cxx=function(_, x) return _.indent .. 'jln_buildoptions[#jln_buildoptions+1] = "' .. x .. '"\n' end,
  link=function(_, x) return _.indent .. 'jln_linkoptions[#jln_linkoptions+1] = "' .. x .. '"\n' end,

  act=function(_, name, datas, optname)
    _:print(_.indent .. '-- unimplementable')
    return true
  end,

  stop=function(_)
    _:print('  return {buildoptions=jln_buildoptions, linkoptions=jln_linkoptions}\nend\n')
    return _:get_output()
  end,
}
