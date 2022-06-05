local todefault = function(x)
  return x == 'default' and '' or x
end

local platform_table = {
  macos='macosx',
}
local toplatform = function(plat)
  return platform_table[plat] or plat
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
    local cxflags = _.is_C and "cflags" or "cxxflags"
    local imported_filename = _.is_C and "c.flags" or "cpp.flags"
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

    _:print('-- File generated with https://github.com/jonathanpoelen/cpp-compiler-options\n')
    _:print('\nfunction ' .. funcprefix .. 'init_options(defaults, category --[[string|boolean=false]])')
    _:print(common_code)
    _:print([[
  if defaults then
    for k,v in pairs(defaults) do
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
    defaults = {}
  end

  local check_option = function(opt, optname)
    local value = get_config(opt)
    if not _flag_names[optname][value] then
      os.raise(vformat("${color.error}Unknown value '%s' for '%s'", value, opt))
    end
  end

  category = category == true and "]] .. funcprefix:sub(1, -2) .. [["
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
      _:print('           default=defaults["' .. optname .. '"] '
              .. (opt ~= optname and 'or defaults["' .. opt .. '"] ' or '')
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
-- `options_by_modes`: {
--    [modename]: {
--      function() ... end, -- optional callback
--      stl_debug='on', ... -- options (see tovalues())
--    }
--  }
-- `func_options`: {
--    rulename = name for current mode (default value is '__]] .. funcprefix .. [[_flags__')
--    disable_other_options = see ]] .. funcprefix .. [[rule
--    imported = see ]] .. funcprefix .. [[rule
-- }
function ]] .. funcprefix .. [[init_modes(options_by_modes, func_options)
  for mode,options in pairs(options_by_modes) do
    if is_mode(mode) then
      func_options = func_options or {}
      local rulename = func_options.rulename or '__]] .. funcprefix .. [[_flags__'
      local callback = options[1]
      if callback then
        options[1] = nil
      end
      ]] .. funcprefix .. [[rule(rulename, options, func_options.disable_other_options, func_options.imported)
      if callback then
        options[1] = callback
      end
      callback()
      add_rules(rulename)
      return
    end
  end
end


local cached_flags = {}

-- Create a new rule. Options are added to the current configuration (see tovalues())
function ]] .. funcprefix .. [[rule(rulename, options, disable_other_options, imported)
  imported = imported or ']] .. imported_filename .. [['

  rule(rulename)
    on_load(function(target)
      local cached = cached_flags[rulename]
      if not cached then
        import(imported)
        cached = flags.getoptions(options, disable_other_options)
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

-- Returns the merge of the default values and new value table
-- tovalues(table, disable_other_options = false)
-- `values`: table. ex: {warnings='on'}
-- `values` can have 3 additional fields:
--  - `cxx`: compiler name (otherwise deducted from --cxx and --toolchain)
--  - `cxx_version`: compiler version (otherwise deducted from cxx). ex: '7', '7.2'
--  - `ld`: linker name
function tovalues(values, disable_other_options)
  if values then
    _check_flags(values)
    return {]])
    for option in _:getoptions() do
      local optname = option.name
      local opt = _:tostroption(optname)
      local isnotsamename = (opt ~= optname)
      _:print('      ["' .. optname .. '"] = values["' .. optname .. '"] '
              .. (isnotsamename and 'or values["' .. opt .. '"] ' or '')
              .. 'or (disable_other_options and "" or _flag_names["' .. optname
              .. '"][get_config("' .. opt .. '")]),')
    end
    for i,extra in ipairs(extraopts) do
      local optname = extra[1]
      local opt = _:tostroption(optname)
      _:print('      ["' .. optname .. '"] = values["' .. optname .. '"] '
              .. (isnotsamename and 'or values["' .. opt .. '"] ' or '')
              .. 'or (not disable_other_options and _get_extra("' .. opt .. '")) or nil,')
    end
    _:print([[}
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
    _:print([[}
  end
end

-- same as getoptions() and apply the options on a target
function setoptions(target, values, disable_other_options, print_compiler)
  local options = getoptions(values, disable_other_options, print_compiler)
  table.insert(options.cxxflags, {force=true})
  table.insert(options.ldflags, {force=true})
  target:add(']] .. cxflags .. [[', table.unpack(options.]] .. cxflags .. [[))
  target:add('ldflags', table.unpack(options.ldflags))
  table.remove(options.cxxflags)
  table.remove(options.ldflags)
  return options
end

local _compiler_by_toolname = {
  vs='msvc',
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
local _ld_cache = {}

-- getoptions(values = {}, disable_other_options = false, print_compiler = false)
-- `values`: same as tovalues()
-- `disable_other_options`: boolean
-- `print_compiler`: boolean
-- return {]] .. cxflags .. [[=table, ldflags=table}
function getoptions(values, disable_other_options, print_compiler)
  values = tovalues(values, disable_other_options)

  local compiler = values.]] .. compprefix .. [[
  local version = values.]] .. compprefix .. [[_version
  local linker = values.ld

  do
    local original_linker = linker or ''
    linker = _ld_cache[original_linker]

    if not linker then
      if disable_other_options then
        linker = ''
        _ld_cache[original_linker] = linker
      else
        local program, toolname = platform.tool('ld')
        linker = toolname or detect.find_toolname(program) or ''
        _ld_cache[original_linker] = linker
      end
    end
  end

  local original_compiler = compiler or ''
  local compcache = _comp_cache[original_compiler]
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
    _comp_cache[original_compiler] = {}

    local toolname
    if not compiler then
      compiler, toolname = platform.tool(']] .. (_.is_C and "cc" or "cxx") .. [[')
      if not compiler then
        -- wprint("Unknown compiler")
        compcache[original_compiler] = {}
        return {]] .. cxflags .. [[={}, ldflags={}}
      end
    end

    local compinfos = detect.find_tool(toolname or compiler, {version=true, program=compiler})
    if compinfos then
      compiler = compinfos.name
      version = compinfos.version
    else
      -- extract basename
      compiler = compiler:match('/([^/]+)$') or compiler
      version = compiler:match('%d+%.?%d*%.?%d*$') or ''
      local has_sep = compiler:byte(#compiler-1) == 45 -- '-'
      -- remove version suffix
      compiler = compiler:sub(1, #compiler - #version - (has_sep and 2 or 1))
    end

    compiler = _compiler_by_toolname[compiler]
            or (compiler:find('^vs') and 'msvc')
            or compiler

    compversion = {}
    for i in version:gmatch("%d+") do
      compversion[#compversion+1] = tonumber(i)
    end
    if not compversion[1] then
      cprint("${color.red}Wrong version format: %s", version)
      compcache[original_compiler] = {}
      return {]] .. cxflags .. [[={}, ldflags={}}
    end

    compversion = compversion[1] * 100 + (compversion[2] or 0)
    _comp_cache[original_compiler] = {compiler, version, compversion}
  end

  if print_compiler then
    cprint("getoptions: compiler: ${cyan}%s${reset}, version: ${cyan}%s", compiler, version)
  end

  local insert = table.insert
  local jln_cxflags, jln_ldflags = {}, {}
]])
  end,

  _vcond_lvl=function(_, lvl, optname) return 'values["' .. optname .. '"] == "' .. todefault(lvl) .. '"' end,
  _vcond_verless=function(_, major, minor) return 'compversion < ' .. tostring(major * 100 + minor) end,
  _vcond_compiler=function(_, compiler) return 'compiler == "' .. compiler .. '"' end,
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
