local table_insert = table.insert

return {
  ignore={
  --  optimization=true,
    msvc_isystem={external_as_include_system_flag=true},
  },

  tostroption=function(self, optname)
    return self.optprefix .. optname:gsub('_', '-')
  end,

  start=function(self, optprefix)
    self.optprefix = optprefix or ''
    self:_vcond_init({
      _not='not',
      _and='and',
      _or='or',
      openblock='',
      closeblock='',
      ifopen='',
      ifclose='then',
      endif='end',
      platform='os.target()',
      options='values',
      not_eq=' ~= ',
    })

    self:print_header('--')

    local compprefix = (self.is_C and 'cc' or 'cxx')
    local prefixfunc = self.is_C and 'jln_c' or 'jln'
    local comp_gcc = self.is_C and "'gcc'" or "'g++'"
    local comp_clang = self.is_C and "'clang'" or "'clang++'"
    -- local comp_icc = self.is_C and "'icc'" or "'icp'"
    -- local comp_icx = self.is_C and "'icx'" or "'icpx'"

    local extraopts = {
      {compprefix, 'Path or name of the compiler for jln functions'},
      {compprefix..'_version', 'Force the compiler version for jln functions'},
      {'ld', 'Path or name of the linker for jln functions'},
    }

    self:print('local _' .. prefixfunc .. '_extraopt_flag_names = {')
    for _,extra in ipairs(extraopts) do
      local optname = extra[1]
      local opt = self:tostroption(optname)
      self:print('  ["' .. opt .. '"] = true,')
      self:print('  ["' .. optname .. '"] = true,')
    end
    self:print('}\n')

    self:print('local _' .. prefixfunc .. '_flag_names = {')
    for option in self:getoptions() do
      local optname = option.name
      local opt = self:tostroption(optname)
      self:print('  ["' .. opt .. '"] = true,')
      if opt ~= optname then
        self:print('  ["' .. optname .. '"] = true,')
      end
    end
    self:print('}\n')

    self:print([[
local _]] .. prefixfunc .. [[_check_flag_names = function(t)
  for k in pairs(t) do
    if not _]] .. prefixfunc .. [[_flag_names[k]
    and not _]] .. prefixfunc .. [[_extraopt_flag_names[k] then
      error("unknown '" .. k .. "' jln flag name")
    end
  end
end]])

    self:print('\nfunction ' .. prefixfunc .. '_newoptions(defaults)')
    self:print('  if defaults then')
    self:print('    _' .. prefixfunc .. '_check_flag_names(defaults)')
    self:print('  else')
    self:print('    defaults = {}')
    self:print('  end')
    for option in self:getoptions() do
      local optname = option.name
      local opt = self:tostroption(optname)
      local values = {}
      for i,v in ipairs(option.values) do
        local desc = option.value_descriptions[i]
        if desc then
          table_insert(values, "{'" .. v .. "', '".. quotable(desc) .. "'}")
        else
          table_insert(values, "{'" .. v .. "'}")
        end
      end
      self:print('\n  newoption{trigger="' .. opt .. '", allowed={' ..  table.concat(values, ', ') .. '}, description="' .. quotable(option.description) .. '"}')
      self:print('  if not _OPTIONS["' .. opt .. '"] then _OPTIONS["' .. opt .. '"] = (defaults["' .. optname .. '"] ' .. (opt ~= optname and 'or defaults["' .. opt .. '"]' or '') .. ' or "' .. option.default .. '") end')
    end
    for _,extra in ipairs(extraopts) do
      local optname = extra[1]
      local desc = extra[2]
      local opt = self:tostroption(optname)
      self:print('  newoption{trigger="' .. opt .. '", description="' .. desc .. '"}')
    end
    self:print('end\n')

    self:print([[
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
    for option in self:getoptions() do
      local optname = option.name
      local opt = self:tostroption(optname)
      local isnotsamename = (opt ~= optname)
      self:print('      ["' .. optname .. '"] = values["' .. optname .. '"] '
              .. (isnotsamename and 'or values["' .. opt .. '"] ' or '')
              .. 'or (disable_others and "default" or _OPTIONS["' .. opt .. '"]),')
    end
    for _,extra in ipairs(extraopts) do
      local optname = extra[1]
      local opt = self:tostroption(optname)
      self:print('      ["' .. optname .. '"] = values["' .. optname .. '"] '
              .. (isnotsamename and 'or values["' .. opt .. '"] ' or '')
              .. 'or (not disable_others and _get_extra("' .. opt .. '")) or nil,')
    end
    self:print([[}
  else
    return {]])
    for option in self:getoptions() do
      local optname = option.name
      local opt = self:tostroption(optname)
      self:print('      ["' .. optname .. '"] = _OPTIONS["' .. opt .. '"],')
    end
    for _,extra in ipairs(extraopts) do
      local optname = extra[1]
      local opt = self:tostroption(optname)
      self:print('      ["' .. optname .. '"] = _get_extra("' .. opt .. '"),')
    end
    self:print([[}
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

  local table_insert = table.insert

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
      compiler = _OPTIONS[']] .. self:tostroption'compiler' .. [[']
              or _OPTIONS['cc']
              or _]] .. prefixfunc .. [[_compiler_by_os[os.target()]
              or _]] .. prefixfunc .. [[_default_compiler
      version = _OPTIONS[']] .. self:tostroption'compiler-version' .. [['] or nil
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
                 (compiler:find('icp?c', 1, true) and 'icc') or
                 (compiler:find('icl', 1, true) and 'icl') or
                 ((compiler:find('ico?x', 1, true) or
                   compiler:find('dpcpp', 1, true)
                  ) and 'icx') or
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
      table_insert(compversion, tonumber(i))
    end
    if not compversion[1] then
      printf("WARNING: wrong version format")
      return {buildoptions={}, linkoptions={}}
    end
    compversion = compversion[1] * 100000 + (compversion[2] or 0)

    cache[original_compiler] = {compiler, version, compversion}
  end

  if print_compiler then
    printf("]] .. prefixfunc .. [[_getoptions: compiler: %s, version: %s", compiler, version)
  end

  local jln_buildoptions, jln_linkoptions = {}, {}
]])
  end,

  _vcond_to_version=function(self, major, minor) return tostring(major * 100000 + minor) end,

  cxx=function(self, x) return self.indent .. 'table_insert(jln_buildoptions, "' .. x .. '")\n' end,
  link=function(self, x) return self.indent .. 'table_insert(jln_linkoptions, "' .. x .. '")\n' end,

  act=function(self, name, datas, optname)
    self:print(self.indent .. '-- unimplementable')
    return true
  end,

  stop=function(self)
    self:print('  return {buildoptions=jln_buildoptions, linkoptions=jln_linkoptions}\nend\n')
    return self:get_output()
  end,
}
