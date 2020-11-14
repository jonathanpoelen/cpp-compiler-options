local todefault = function(x)
  return x == 'default' and '' or x
end

return {
  -- ignore = { optimization=true, }

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
    local comp_gcc = _.is_C and "'gcc'" or "'g++'"
    local comp_clang = _.is_C and "'clang'" or "'clang++'"
    local cxflags = _.is_C and "cflags" or "cxxflags"
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
    for optname,args in _:getoptions() do
      local opt = _:tostroption(optname)
      local list = {}
      for _,arg in ipairs(args) do
        list[#list+1] = '["' .. arg .. '"]="' .. todefault(arg) .. '", '
      end
      local allowed = table.concat(list)
      _:print('  ["' .. opt .. '"] = {' .. allowed .. '[""]=""},')
      if opt ~= optname then
        _:print('  ["' .. optname .. '"] = {' .. allowed .. '[""]=""},')
      end
    end
    _:print('}\n')

    local common_code = _:get_output()
    _._strs = {}

    _:print('-- File generated with https://github.com/jonathanpoelen/cpp-compiler-options\n')
    _:print('\nfunction ' .. funcprefix .. 'init_options(defaults, add_category)')
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

  add_category = add_category == true and "]] .. funcprefix:sub(1, -2) .. [["
              or add_category
              or nil
    ]])
    for optname,args,default in _:getoptions() do
      local opt = _:tostroption(optname)
      _:print('  option("' .. opt .. '", {')
      _:print('           showmenu=true,')
      _:print('           category=add_category,')
      _:print('           description="' .. optname .. '",')
      _:print('           values={"' .. table.concat(args, '", "') .. '"},')
      _:print('           default=defaults["' .. optname .. '"] '
              .. (opt ~= optname and 'or defaults["' .. opt .. '"] ' or '')
              .. 'or "' .. default .. '",')
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

    _._options_str = _:get_output()
    _._strs = {}
    _:print('-- File generated with https://github.com/jonathanpoelen/cpp-compiler-options\n')
    _:print(common_code)

    _:print([[
import'core.platform.platform'
import"lib.detect"

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
-- tovalues(table, disable_others = false)
-- `values`: table. ex: {warnings='on'}
-- `values` can have 3 additional fields:
--  - `cxx`: compiler name (otherwise deducted from --cxx and --toolchain)
--  - `cxx_version`: compiler version (otherwise deducted from cxx). ex: '7', '7.2'
--  - `ld`: linker name
function tovalues(values, disable_others)
  if values then
    _check_flags(values)
    return {]])
    for optname,args,default in _:getoptions() do
      local opt = _:tostroption(optname)
      local isnotsamename = (opt ~= optname)
      _:print('      ["' .. optname .. '"] = values["' .. optname .. '"] '
              .. (isnotsamename and 'or values["' .. opt .. '"] ' or '')
              .. 'or (disable_others and "" or _flag_names["' .. optname
              .. '"][get_config("' .. opt .. '")]),')
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
    for optname,args,default in _:getoptions() do
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

-- same as getoptions but with target as first parameter
function setoptions(target, values, disable_others, print_compiler)
  local options = getoptions(values, disable_others, print_compiler)
  for _,opt in ipairs(options.]] .. cxflags .. [[) do target:add(']] .. cxflags .. [[', opt, {force=true}) end
  for _,opt in ipairs(options.ldflags) do target:add('ldflags', opt, {force=true}) end
  return options
end

local _compiler_by_toolname = {
  vs='msvc',
  gcc='gcc',
  gxx='gcc',
  clang='clang',
  clangxx='clang',
}

local _comp_cache = {}
local _ld_cache = {}

-- getoptions(values = {}, disable_others = false, print_compiler = false)
-- `values`: same as tovalue()
-- `disable_others`: boolean
-- `print_compiler`: boolean
-- return {]] .. cxflags .. [[=table, ldflags=table}
function getoptions(values, disable_others, print_compiler)
  local compversion

  values = tovalues(values, disable_others)
  local compiler = values.]] .. compprefix .. [[
  local version = values.]] .. compprefix .. [[_version
  local linker = values.ld

  do
    local original_linker = linker or ''
    linker = _ld_cache[original_linker]

    if not linker then
      if disable_others then
        linker = ''
        _ld_cache[original_linker] = linker
      else
        local program, toolname = platform.tool('ld')
        linker = toolname or detect.find_toolname(program) or nil
        _ld_cache[original_linker] = linker or ''
      end
    end
  end

  local cache = _comp_cache
  local original_compiler = compiler or ''
  local compcache = cache[original_compiler]

  if compcache then
    compiler = compcache[1]
    version = compcache[2]
    compversion = compcache[3]
    if not compiler then
      -- wrintf("Unknown compiler")
      return {buildoptions={}, linkoptions={}}
    end
  else
    cache[original_compiler] = {}

    local toolname
    if not compiler then
      compiler, toolname = platform.tool(']] .. (_.is_C and "cc" or "cxx") .. [[')
    end

    if not compiler then
      -- wprint("Unknown compiler")
      return {]] .. cxflags .. [[={}, ldflags={}}
    end

    local realcompiler = compiler

    compiler = detect.find_toolname(compiler)
    if not compiler then
      compiler = detect.find_toolname(toolname) or toolname
      if compiler then
        if not version then
          version = toolname:match("%d+%.?%d*%.?%d*$")
        end
      else
        compiler = realcompiler
      end
    end
    compiler = _compiler_by_toolname[compiler]
            or (compiler:find('^vs') and 'msvc')
            or compiler

    if not version then
      version = detect.find_programver(realcompiler)

      if not version then
        version = tostring(tonumber(os.date("%y")) - (compiler:sub(0, 5) == 'clang' and 14 or 12))
      end
    end

    compversion = {}
    for i in version:gmatch("%d+") do
      compversion[#compversion+1] = tonumber(i)
    end
    if not compversion[1] then
      cprint("${color.red}Wrong version format: %s", version)
      return {]] .. cxflags .. [[={}, ldflags={}}
    end
    compversion = compversion[1] * 100 + (compversion[2] or 0)

    cache[original_compiler] = {compiler, version, compversion}
  end

  if print_compiler then
    cprint("getoptions: compiler: ${cyan}%s${reset}, version: ${cyan}%s", compiler, version)
  end

  local jln_cxflags, jln_ldflags = {}, {}
]])
  end,

  _vcond_lvl=function(_, lvl, optname) return 'values["' .. optname .. '"] == "' .. todefault(lvl) .. '"' end,
  _vcond_verless=function(_, major, minor) return 'compversion < ' .. tostring(major * 100 + minor) end,
  _vcond_compiler=function(_, compiler) return 'compiler == "' .. compiler .. '"' end,
  _vcond_linker=function(_, linker) return 'linker == "' .. linker .. '"' end,

  cxx=function(_, x) return _.indent .. 'jln_cxflags[#jln_cxflags+1] = "' .. x .. '"\n' end,
  link=function(_, x) return _.indent .. 'jln_ldflags[#jln_ldflags+1] = "' .. x .. '"\n' end,

  stop=function(_, filebase)
    _:print('  return {' .. _.cxflags_name .. '=jln_cxflags, ldflags=jln_ldflags}\nend\n')
    return filebase and {
      {filebase .. '_options.lua', _._options_str},
      {filebase, _:get_output()}
    } or _:get_output()
  end,
}
