local table_insert = table.insert

local todefault = function(x)
  return x == 'default' and '' or x
end

local platform_table = {
  macos='macosx',
}
local toplatform = function(plat)
  return platform_table[plat] or plat
end

local compiler_table = {
  msvc='cl',
}

return {
  ignore = {
    -- msvc_isystem=true,
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
      not_eq=' ~= ',
    })

    local funcprefix = (self.is_C and 'jln_c_' or 'jln_cxx_')
    local compprefix = (self.is_C and 'cc' or 'cxx')
    local cxflags = self.is_C and 'cflags' or 'cxxflags'
    self.cxflags_name = cxflags

    local extraopts = {
      {compprefix, 'Path or name of the compiler for jln functions'},
      {compprefix..'_version', 'Force the compiler version for jln functions'},
      {'ld', 'Path or name of the linker for jln functions'},
    }

    self:print('local _extraopt_flag_names = {')
    for _,extra in ipairs(extraopts) do
      local optname = extra[1]
      local opt = self:tostroption(optname)
      self:print('  ["' .. opt .. '"] = true,')
      self:print('  ["' .. optname .. '"] = true,')
    end
    self:print('}\n')

    self:print('local _flag_names = {')
    for option in self:getoptions() do
      local opt = self:tostroption(option.name)
      local list = {}
      for _,arg in ipairs(option.values) do
        table_insert(list, '["' .. arg .. '"]="' .. todefault(arg) .. '", ')
      end
      local allowed = table.concat(list)
      self:print('  ["' .. opt .. '"] = {' .. allowed .. '[""]=""},')
      if opt ~= option.name then
        self:print('  ["' .. option.name .. '"] = {' .. allowed .. '[""]=""},')
      end
    end
    self:print('}\n')

    local common_code = self:get_output()
    self._strs = {}

    self:print_header('--')
    self:print([[
local _module_name = 'flags'

-- Registers new command-line options and set default values
-- `default_options` (see create_options())
-- `extra_options` = {
--   category :string|boolean = false -- add a category for option()
--   module_name: string = 'flags' -- default value for ]] .. funcprefix .. [[rule()
-- }]])
    self:print('function ' .. funcprefix .. 'init_options(default_options, extra_options)')
    self:print(common_code)
    self:print([[
  if default_options then
    for k,v in pairs(default_options) do
      local ref = _flag_names[k]
      if not ref then
        if not _extraopt_flag_names[k] then
          local msg = "Unknown '" .. k .. "' jln flag name"
          print(msg)
          error(msg)
        end
      elseif not ref[v] then
        local msg = "Unknown value '" .. v .. "' for '" .. k .. "'"
        print(msg)
        error(msg)
      end
    end
  else
    default_options = {}
  end

  local check_option = function(opt, optname)
    local value = get_config(opt)
    if not _flag_names[optname][value] then
      os.raise(vformat("${color.error}Unknown value '%s' for '%s'", value, opt))
    end
  end

  extra_options = extra_options or {}
  _module_name = extra_options.module_name or _module_name

  local category = extra_options.category
  category = category == true and ']] .. funcprefix .. [[flags'
          or category
          or nil
    ]])
    for option in self:getoptions() do
      local optname = option.name
      local opt = self:tostroption(optname)
      self:print('  option("' .. opt .. '", {')
      self:print('           showmenu=true,')
      self:print('           category=category,')
      self:print('           description="' .. quotable_desc(option) .. '",')
      self:print('           values={"' .. table.concat(option.values, '", "') .. '"},')
      self:print('           default=default_options["' .. optname .. '"] '
              .. (opt ~= optname and 'or default_options["' .. opt .. '"] ' or '')
              .. 'or "' .. option.default .. '",')
      self:print('           after_check=function(option) check_option("'
              .. opt .. '", "' .. optname .. '") end,')
      self:print('         })')
    end
    for _,extra in ipairs(extraopts) do
      local optname = extra[1]
      local desc = extra[2]
      local opt = self:tostroption(optname)
      self:print('  option("' .. opt .. '", {showmenu=true, description="' .. desc .. '", default=""})')
    end
    self:print('end\n')

    -- create default build types for init_modes()
    -- @{
    self:write(funcprefix .. 'default_options_by_modes = {\n')
    local buildtypes = {
      debug='debug',
      release='release',
      debug_optimized='releasedbg',
      minimum_size_release='minsizerel',
    }
    for buildtypename, opts in self:getbuildtype() do
      buildtypename = buildtypes[buildtypename] or error('Unknown build type: ' .. buildtypename)
      self:write('  ' .. buildtypename .. '={\n')
      for _,opt in pairs(opts) do
        self:write('    ' .. opt[1] .. '=\'' .. opt[2] .. '\',\n')
      end
      self:write('  },\n')
    end
    self:write('}\n\n')
    -- @}

    self:print([[
local cached_flags = {}
local current_path = os.scriptdir()

local function _jln_cxx_rule_fn(target, module_name, rulename, options, extra_options, import)
  local cached = cached_flags[rulename]
  if not cached then
    import(module_name, {rootdir=current_path})
    cached = flags.get_flags(options, extra_options)
    table.insert(cached.cxxflags, {force=true})
    table.insert(cached.ldflags, {force=true})
    cached_flags[rulename] = cached
  end
  target:add('cxxflags', table.unpack(cached.cxxflags))
  target:add('ldflags', table.unpack(cached.ldflags))
end

local function _jln_table_clone(extra_options, options)
  if extra_options.clone_options then
    local cloned = {}
    for k, v in pairs(options) do
      cloned[k] = v
    end
    return cloned
  end
  return options
end

-- Set options for a specific mode (see also ]] .. funcprefix .. [[rule()).
-- If options_by_modes is nil, a default configuration is used.
-- `options_by_modes` = {
--   [modename]: {
--     function() ... end, -- optional callback
--     stl_debug='on', ... -- options (see create_options())
--   }
-- }
-- `extra_options` = {
--   rulename :string = name for current mode (default value is '__]] .. funcprefix .. [[flags__')
--   other options are sent to ]] .. funcprefix .. [[rule()
-- }
function ]] .. funcprefix .. [[init_modes(options_by_modes, extra_options)
  extra_options = extra_options or {}
  local rulename = extra_options.rulename or '__]] .. funcprefix .. [[flags__'
  local module_name = extra_options.module_name or _module_name

  local options = {}

  for mode,opts in pairs(options_by_modes or ]] .. funcprefix .. [[default_options_by_modes) do
    if is_mode(mode) then
      options = opts
      break
    end
  end

  local callback = options[1]
  options = _jln_table_clone(extra_options, options)

  rule(rulename)
    on_config(function(target)
      if callback then
        options[1] = nil
      end

      _jln_cxx_rule_fn(target, module_name, rulename, options, extra_options, import)

      if callback then
        options[1] = callback
        callback()
      end
    end)
  rule_end()
  add_rules(rulename)
end

-- Create a new rule. Options are added to the current configuration (see create_options())
-- `options`: same as create_options()
-- `extra_options` = {
--   module_name :string = module name used by on_config() in ]] .. funcprefix .. [[rule()
--   clone_options :boolean = make an internal copy of options
--                            which prevents changing it after the call to ]] .. funcprefix .. [[rule().
--                            (default: false)
--   other options are sent to get_flags()
-- }
function ]] .. funcprefix .. [[rule(rulename, options, extra_options)
  extra_options = extra_options or {}
  local module_name = extra_options.module_name or _module_name

  options = _jln_table_clone(extra_options, options)

  rule(rulename)
    on_config(function(target)
      _jln_cxx_rule_fn(target, module_name, rulename, options, extra_options, import)
    end)
  rule_end()
end
]])

    self._options_str = self:get_output()
    self._strs = {}
    self:print('-- File generated with https://github.com/jonathanpoelen/cpp-compiler-options\n')
    self:print(common_code)

    self:print([[
import'core.platform.platform'
import'lib.detect'

local _get_extra = function(opt)
  local x = get_config(opt)
  return x ~= '' and x or nil
end

local _check_flags = function(d)
  for k,v in pairs(d) do
    local ref = _flag_names[k]
    if not ref then
      if not _extraopt_flag_names[k] then
        os.raise(vformat("${color.error}cpp-compiler-options: Unknown key: '%s'", k))
      end
    elseif not ref[v] then
      os.raise(vformat("${color.error}cpp-compiler-options: Unknown value '%s' for '%s'", v, k))
    end
  end
end

-- Returns the merge of the default options and options parameter
-- `options`: table. ex: {warnings='on'}
-- `options` can have 3 additional fields:
--  - `cxx`: compiler name (otherwise deducted from --cxx and --toolchain)
--  - `cxx_version`: compiler version (otherwise deducted from cxx). ex: '7', '7.2'
--  - `ld`: linker name
-- `extra_options` = {
--   disable_other_options: bool = false
-- }
function create_options(options, extra_options)
  if options then
    _check_flags(options)
    local disable_other_options = extra_options and extra_options.disable_other_options
    return {]])
    for option in self:getoptions() do
      local optname = option.name
      local opt = self:tostroption(optname)
      local isnotsamename = (opt ~= optname)
      self:print('      ' .. optname .. ' = options.' .. optname .. ' '
              .. (isnotsamename and 'or options["' .. opt .. '"] ' or '')
              .. 'or (disable_other_options and "" or _flag_names.' .. optname
              .. '[get_config("' .. opt .. '")]),')
    end
    for _,extra in ipairs(extraopts) do
      local optname = extra[1]
      local opt = self:tostroption(optname)
      local isnotsamename = (opt ~= optname)
      self:print('      ' .. optname .. ' = options.' .. optname .. ' '
              .. (isnotsamename and 'or options["' .. opt .. '"] ' or '')
              .. 'or (not disable_other_options and _get_extra("' .. opt .. '")) or nil,')
    end
    self:print([[    }
  else
    return {]])
    for option in self:getoptions() do
      local optname = option.name
      local opt = self:tostroption(optname)
      self:print('      ["' .. optname .. '"] = _flag_names["' .. optname
              .. '"][get_config("' .. opt .. '")],')
    end
    for _,extra in ipairs(extraopts) do
      local optname = extra[1]
      local opt = self:tostroption(optname)
      self:print('      ["' .. optname .. '"] = _get_extra("' .. opt .. '"),')
    end
    self:print([[    }
  end
end

-- Same as get_flags() and apply the options on a target
function set_flags(target, options, extra_options)
  options = get_flags(options, extra_options)
  table.insert(options.cxxflags, {force=true})
  table.insert(options.ldflags, {force=true})
  target:add(']] .. cxflags .. [[', table.unpack(options.]] .. cxflags .. [[))
  target:add('ldflags', table.unpack(options.ldflags))
  table.remove(options.cxxflags)
  table.remove(options.ldflags)
  return options
end


local function string_version_to_number(version)
  local parts = {}
  for i in version:gmatch("%d+") do
    table.insert(parts, tonumber(i))
  end

  if parts[1] then
    return parts[1] * 100000 + (parts[2] or 0)
  end

  wprint("Wrong version format: %s", version)
  return 0
end


local function add_comp_cache(original_compiler, original_version, compcache)
  -- remove compiler when empty string
  if compcache[1] == '' then
    compcache[1] = nil
  end
  local tmp = _comp_cache[original_compiler] or {}
  tmp[original_version] = compcache
  _comp_cache[original_compiler] = tmp
end


local function extract_progname_and_version_from_path(compiler)
  compiler = compiler:match('/([^/]+)$') or compiler
  local version = compiler:match('%d+%.?%d*%.?%d*$') or ''
  -- remove version suffix
  local has_sep = compiler:byte(#compiler - #version) == 45 -- '-'
  compiler = compiler:sub(1, #compiler - #version - (has_sep and 1 or 0))
  return compiler, version
end


local _compiler_by_toolname = {
  vs='cl',
  cl='cl',
  gcc='gcc',
  gxx='gcc',
  clang='clang',
  clangxx='clang',
  icc='icc',
  icpc='icc',
  icl='icl',
  icx='icx',
  icpx='icx',
  ['icx-cl']='icx-cl',
  dpcpp='icx',
  ['dpcpp-cl']='icx-cl',
  ['em++']='emcc',
}


local _comp_cache = {}
local _ld_cache

local function add_comp_cache(original_compiler, original_version, data)
  local tmp = _comp_cache[original_compiler] or {}
  tmp[original_version] = data
  _comp_cache[original_compiler] = tmp
end


-- Returns an array of compile and link flags
-- `options`: same as create_options()
-- `extra_options` = {
--   disable_other_options: bool = false
--   print_compiler: bool = false -- for debug only
-- }
-- return {]] .. cxflags .. [[=table, ldflags=table}
function get_flags(options, extra_options)
  options = create_options(options, extra_options)

  local compiler = options.]] .. compprefix .. [[

  local version = options.]] .. compprefix .. [[_version
  local linker = options.ld

  if not linker then
    linker = _ld_cache
    if not linker then
      local program, toolname = platform.tool('ld')
      linker = toolname or detect.find_toolname(program) or ''
      _ld_cache = linker
    end
  end

  local original_compiler = compiler or ''
  local original_version = version or ''
  local compcache = (_comp_cache[original_compiler] or {})[original_version]
  local compversion

  if compcache then
    compiler = compcache[1]
    version = compcache[2]
    compversion = compcache[3]
    if not compiler then
      -- wrintf("Unknown compiler")
      return {]] .. cxflags .. [[={}, ldflags={}}
    end
  else
    local compiler_path = compiler

    if compiler then
      local restored_version = version
      compiler, version = extract_progname_and_version_from_path(compiler)
      version = restored_version or version
      if version == '' then
        local compinfos = detect.find_tool(compiler, {version=true, program=compiler})
        if compinfos then
          compiler = compinfos.name
          version = compinfos.version
        end
      end
    else
      local toolname
      compiler, toolname = platform.tool(']] .. (self.is_C and "cc" or "cxx") .. [[')
      if not compiler then
        -- wprint("Unknown compiler")
        add_comp_cache(original_compiler, original_version, {})
        return {]] .. cxflags .. [[={}, ldflags={}}
      end

      compiler_path = compiler
      local compinfos = detect.find_tool(toolname or compiler, {version=true, program=compiler})
      if compinfos then
        compiler = compinfos.name
        version = compinfos.version
      else
        compiler, version = extract_progname_and_version_from_path(compiler)
      end
    end

    compiler = _compiler_by_toolname[compiler] or compiler

    if compiler == 'emcc' then
      compiler = 'clang-emcc'
      local outdata, errdata = os.iorunv(compiler_path, {'-v'}, {envs = extra_options.envs})
      version = errdata:match('clang version ([^ ]+)')
    elseif compiler == 'icx' or compiler == 'icx-cl' then
      compiler = compiler == 'icx' and 'clang' or 'clang-cl'
      try {
        function()
          -- . as cpp file is an error, but stderr is good
          os.iorunv(compiler_path, {'-v', '-x', 'c++', '.', '-E'}, {envs = extra_options.envs})
        end,
        catch {
          function(proc)
            version = proc.stderr:match('/clang/([^ ]+)')
          end
        }
      }
    end

    compversion = string_version_to_number(version)

    add_comp_cache(original_compiler, original_version, {compiler, version, compversion})
  end

  if extra_options and extra_options.print_compiler then
    cprint("get_flags: compiler: ${cyan}%s${reset} (${cyan}%s${reset}), linker: ${cyan}%s", compiler, version, linker)
  end

  local insert = table.insert
  local jln_cxflags, jln_ldflags = {}, {}
]])
  end,

  _vcond_to_lvl=function(self, lvl)
    return '"' .. todefault(lvl) .. '"'
  end,
  _vcond_to_opt=function(self, optname)
    return 'options.' .. optname
  end,

  _vcond_to_version=function(self, major, minor)
    return tostring(major * 100000 + minor)
  end,
  _vcond_to_compiler=function(self, compiler)
    return "'" .. (compiler_table[compiler] or compiler) .. "'"
  end,
  _vcond_platform=function(self, platform, not_)
    return (not_ and 'not ' or '') .. 'is_plat("' .. toplatform(platform) .. '")'
  end,

  cxx=function(self, x) return self.indent .. 'insert(jln_cxflags, "' .. x .. '")\n' end,
  link=function(self, x) return self.indent .. 'insert(jln_ldflags, "' .. x .. '")\n' end,

  act=function(self, datas, optname)
    self:print(self.indent .. '-- unimplementable')
    return true
  end,

  stop=function(self, filebase)
    self:print('  return {' .. self.cxflags_name .. '=jln_cxflags, ldflags=jln_ldflags}\nend\n')
    return filebase and {
      {filebase .. '_options.lua', self._options_str},
      {filebase, self:get_output()}
    } or '-- options.lua\n' .. self._options_str ..
         '-- xmake module\n' .. self:get_output()
  end,
}
