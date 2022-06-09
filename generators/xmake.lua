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
local tocomp = function(comp)
  return compiler_table[comp] or comp
end

return {
  ignore = {
    -- msvc_isystem=true,
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

    local funcprefix = (_.is_C and 'jln_c_' or 'jln_cxx_')
    local compprefix = (_.is_C and 'cc' or 'cxx')
    local cxflags = _.is_C and 'cflags' or 'cxxflags'
    local import_base = _.is_C and 'c' or 'cpp'
    _.cxflags_name = cxflags

    local extraopts = {
      {compprefix, 'Path or name of the compiler for jln functions'},
      {compprefix..'_version', 'Force the compiler version for jln functions'},
      {'ld', 'Path or name of the linker for jln functions'},
    }

    _:print('local _extraopt_flag_names = {')
    for i,extra in ipairs(extraopts) do
      local optname = extra[1]
      local opt = _:tostroption(optname)
      _:print('  ["' .. opt .. '"] = true,')
      _:print('  ["' .. optname .. '"] = true,')
    end
    _:print('}\n')

    _:print('local _flag_names = {')
    for option in _:getoptions() do
      local opt = _:tostroption(option.name)
      local list = {}
      for _,arg in ipairs(option.values) do
        list[#list+1] = '["' .. arg .. '"]="' .. todefault(arg) .. '", '
      end
      local allowed = table.concat(list)
      _:print('  ["' .. opt .. '"] = {' .. allowed .. '[""]=""},')
      if opt ~= option.name then
        _:print('  ["' .. option.name .. '"] = {' .. allowed .. '[""]=""},')
      end
    end
    _:print('}\n')

    local common_code = _:get_output()
    _._strs = {}

    _:print_header('--')
    _:print([[
local _import_base = ']] .. import_base .. [['

-- Registers new command-line options and set default values
-- `default_options` (see create_options())
-- `extra_options` = {
--   category :string|boolean = false -- add a category for option()
--   import_base: string = ']] .. import_base .. [[' -- default value for ]] .. funcprefix .. [[rule()
-- }
]])
    _:print('\nfunction ' .. funcprefix .. 'init_options(default_options, extra_options)')
    _:print(common_code)
    _:print([[
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
  _import_base = extra_options.import_base or _import_base

  local category = extra_options.category
  category = category == true and ']] .. funcprefix .. [[flags'
          or category
          or nil
    ]])
    for option in _:getoptions() do
      local optname = option.name
      local opt = _:tostroption(optname)
      _:print('  option("' .. opt .. '", {')
      _:print('           showmenu=true,')
      _:print('           category=category,')
      _:print('           description="' .. quotable_desc(option) .. '",')
      _:print('           values={"' .. table.concat(option.values, '", "') .. '"},')
      _:print('           default=default_options["' .. optname .. '"] '
              .. (opt ~= optname and 'or default_options["' .. opt .. '"] ' or '')
              .. 'or "' .. option.default .. '",')
      _:print('           after_check=function(option) check_option("'
              .. opt .. '", "' .. optname .. '") end,')
      _:print('         })')
    end
    for i,extra in ipairs(extraopts) do
      local optname = extra[1]
      local desc = extra[2]
      local opt = _:tostroption(optname)
      _:print('  option("' .. opt .. '", {showmenu=true, description="' .. desc .. '", default=""})')
    end
    _:print('end\n')

    _:print([[
-- Set options for a specific mode (see also ]] .. funcprefix .. [[rule())
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

  for mode,options in pairs(options_by_modes) do
    if is_mode(mode) then
      local callback = options[1]
      if callback then
        options[1] = nil
      end
      ]] .. funcprefix .. [[rule(rulename, options, extra_options)
      if callback then
        options[1] = callback
        callback()
      end
      add_rules(rulename)
      return
    end
  end

  ]] .. funcprefix .. [[rule(rulename, {}, extra_options)
  add_rules(rulename)
end


local cached_flags = {}

-- Create a new rule. Options are added to the current configuration (see create_options())
-- `options`: same as create_options()
-- `extra_options` = {
--   import_base :string = import directory containing flags.lua (default: ']] .. import_base .. [[')
--   clone_options :boolean = make an internal copy of options
--                            which prevents changing it after the call to ]] .. funcprefix .. [[rule().
--                            (default: false)
--   other options are sent to get_flags()
-- }
function ]] .. funcprefix .. [[rule(rulename, options, extra_options)
  extra_options = extra_options or {}
  local import_base = extra_options.import_base or ']] .. import_base .. [['

  if extra_options.clone_options then
    local cloned = {}
    for k, v in pairs(options) do
      cloned[k] = v
    end
    options = cloned
  end

  rule(rulename)
    on_load(function(target)
      local cached = cached_flags[rulename]
      if not cached then
        import(import_base .. '.flags')
        cached = flags.get_flags(options, extra_options)
        table.insert(cached.cxxflags, {force=true})
        table.insert(cached.ldflags, {force=true})
        cached_flags[rulename] = cached
      end
      target:add('cxxflags', table.unpack(cached.cxxflags))
      target:add('ldflags', table.unpack(cached.ldflags))
    end)
  rule_end()
end
]])

    _._options_str = _:get_output()
    _._strs = {}
    _:print('-- File generated with https://github.com/jonathanpoelen/cpp-compiler-options\n')
    _:print(common_code)

    _:print([[
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
        os.raise(vformat("${color.error}Unknown key: '%s'", k))
      end
    elseif not ref[v] then
      os.raise(vformat("${color.error}Unknown value '%s' for '%s'", v, k))
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
    for option in _:getoptions() do
      local optname = option.name
      local opt = _:tostroption(optname)
      local isnotsamename = (opt ~= optname)
      _:print('      ' .. optname .. ' = options.' .. optname .. ' '
              .. (isnotsamename and 'or options["' .. opt .. '"] ' or '')
              .. 'or (disable_other_options and "" or _flag_names.' .. optname
              .. '[get_config("' .. opt .. '")]),')
    end
    for i,extra in ipairs(extraopts) do
      local optname = extra[1]
      local opt = _:tostroption(optname)
      _:print('      ' .. optname .. ' = options.' .. optname .. ' '
              .. (isnotsamename and 'or options["' .. opt .. '"] ' or '')
              .. 'or (not disable_other_options and _get_extra("' .. opt .. '")) or nil,')
    end
    _:print([[    }
  else
    return {]])
    for option in _:getoptions() do
      local optname = option.name
      local opt = _:tostroption(optname)
      _:print('      ["' .. optname .. '"] = _flag_names["' .. optname
              .. '"][get_config("' .. opt .. '")],')
    end
    for i,extra in ipairs(extraopts) do
      local optname = extra[1]
      local opt = _:tostroption(optname)
      _:print('      ["' .. optname .. '"] = _get_extra("' .. opt .. '"),')
    end
    _:print([[    }
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
  dpcpp='icx',
}

local _comp_cache = {}
local _ld_cache

local extract_progname_and_version_from_path = function(compiler)
  compiler = compiler:match('/([^/]+)$') or compiler
  local version = compiler:match('%d+%.?%d*%.?%d*$') or ''
  -- remove version suffix
  local has_sep = compiler:byte(#compiler - #version) == 45 -- '-'
  compiler = compiler:sub(1, #compiler - #version - (has_sep and 1 or 0))
  return compiler, version
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
    if compiler then
      local restored_version = version
      compiler, version = extract_progname_and_version_from_path(compiler)
      version = restored_version or version
    else
      local toolname
      if not compiler then
        compiler, toolname = platform.tool(']] .. (_.is_C and "cc" or "cxx") .. [[')
        if not compiler then
          -- wprint("Unknown compiler")
          local tmp = _comp_cache[original_compiler] or {}
          tmp[original_version] = {}
          _comp_cache[original_compiler] = tmp
          return {]] .. cxflags .. [[={}, ldflags={}}
        end
      end

      local compinfos = detect.find_tool(toolname or compiler, {version=true, program=compiler})
      if compinfos then
        compiler = compinfos.name
        version = compinfos.version
      else
        compiler, version = extract_progname_and_version_from_path(compiler)
      end
    end

    compiler = _compiler_by_toolname[compiler] or compiler

    compversion = {}
    for i in version:gmatch("%d+") do
      compversion[#compversion+1] = tonumber(i)
    end

    if not compversion[1] then
      wprint("Wrong version format: %s", version)
      compversion = 0
    else
      compversion = compversion[1] * 100000 + (compversion[2] or 0)
    end

    local tmp = _comp_cache[original_compiler] or {}
    tmp[original_version] = {compiler, version, compversion}
    _comp_cache[original_compiler] = tmp
  end

  if extra_options and extra_options.print_compiler then
    cprint("get_flags: compiler: ${cyan}%s${reset}, version: ${cyan}%s", compiler, version)
  end

  local insert = table.insert
  local jln_cxflags, jln_ldflags = {}, {}
]])
  end,

  _vcond_lvl=function(_, lvl, optname) return 'options.' .. optname .. ' == "' .. todefault(lvl) .. '"' end,
  _vcond_verless=function(_, major, minor) return 'compversion < ' .. tostring(major * 100000 + minor) end,
  _vcond_compiler=function(_, compiler) return 'compiler == "' .. tocomp(compiler) .. '"' end,
  _vcond_platform=function(_, platform) return 'is_plat("' .. toplatform(platform) .. '")' end,
  _vcond_linker=function(_, linker) return 'linker == "' .. linker .. '"' end,

  cxx=function(_, x) return _.indent .. 'insert(jln_cxflags, "' .. x .. '")\n' end,
  link=function(_, x) return _.indent .. 'insert(jln_ldflags, "' .. x .. '")\n' end,

  act=function(_, name, datas, optname)
    _:print(_.indent .. '-- unimplementable')
    return true
  end,

  stop=function(_, filebase)
    _:print('  return {' .. _.cxflags_name .. '=jln_cxflags, ldflags=jln_ldflags}\nend\n')
    return filebase and {
      {filebase .. '_options.lua', _._options_str},
      {filebase, _:get_output()}
    } or _:get_output()
  end,
}
