return {
  ignore={
  --  optimization=true,
  --  debug=true, -- reserved
    msvc_isystem={external_as_include_system_flag=true},
  },

  _option_strs = {},

  start=function(_, optprefix)
    _:_vcond_init({
      _not='not',
      _and='and',
      _or='or',
      openblock='',
      closeblock='',
      ifopen='',
      ifclose=':',
      _else='else:',
      endif='',
    })

    _:print('# File generated with https://github.com/jonathanpoelen/cpp-compiler-options\n')

    local optprefix = optprefix and optprefix:gsub('-', '_') or ''
    local prefixenv = _.is_C and 'CC' or 'CXX'

    local enums, flags, var2opts, opt2vars, xvalues = {}, {}, {}, {}, {}
    for option in _:getoptions() do
      local optname = option.name
      local name = optprefix .. optname
      flags[#flags+1] = "  '" .. optname .. "': '" .. option.default .. "',\n"
      var2opts[#var2opts+1] = "  '" .. name .. "': '" .. optname .. "',\n"
      opt2vars[#opt2vars+1] = "  '" .. optname .. "': '" .. name .. "',\n"
      xvalues[#xvalues+1] = "  x_" .. optname .. " = options.get('" .. optname
                            .. "', _default_flags['" .. optname .. "'])"
      enums[#enums+1] = "    EnumVariable('" .. name .. "', '"
        .. quotable_desc(option) .. "', default_values.get('"
        .. optname .. "', _default_flags['" .. optname
        .. "']),\n                 allowed_values=('"
        .. table.concat(option.values, "', '") .. "'))"
    end

    _:write([[
from SCons.Environment import Environment
from SCons.Variables.EnumVariable import EnumVariable
import os
import re

_default_flags = {
]] .. table.concat(flags) .. [[
}

_var2opts = {
]] .. table.concat(var2opts) .. [[
}

_opt2vars = {
]] .. table.concat(opt2vars) .. [[
}

def set_global_flags(default_values):
  _default_flags.update(default_values)

def add_variables(vars, default_values={}):
  vars.AddVariables(
]] .. table.concat(enums, ',\n') .. [[
  )

def varname_to_optname(options):
  return ]] .. (optprefix
    and '{_var2opts.get(k, k):v for k,v in options.items()}'
    or 'options'
  ) .. [[

def optname_to_varname(options):
  return ]] .. (
    optprefix
    and '{_opt2vars.get(k, k):v for k,v in options.items()}'
    or 'options'
  ) .. [[

def variables_to_options(vars):
  args = vars.args
  return {]] .. (optprefix and '_var2opts[v.key]' or 'v.key')
    .. [[:args.get(v.key, v.default) for v in vars.options}

_default_env = Environment()
_map_compiler = {
  "g++": "gcc",
  "clang++": "clang",
  "icpc": "icc",
}
_compiler_name_extractor = re.compile('([\w+]+(?:-[\w+]+)*)')
_compiler_version_cache = {}

def get_flags(options, env=None):
  env = env or _default_env
  compiler = env[']] .. prefixenv .. [[']
  version = env.get(']] .. prefixenv .. [[VERSION')
  linker = env.get('LD')

  _compiler = os.path.basename(compiler)
  _compiler = _compiler_name_extractor.match(_compiler).group(1)
  _compiler = _map_compiler.get(_compiler, _compiler)
  platform = None

  if version:
    version = version.split(".")
    version[0] = int(version[0])
    version[1] = int(version[1]) if len(version) == 1 else 0

  if _compiler == 'mingw':
    compiler = 'gcc'
    platform = 'mingw'
  elif _compiler in ('icx', 'icpx', 'dpcpp'):
    # is icx version, replace with clang version
    if not version or version[0] > 2000:
      version = _compiler_version_cache.get(compiler)
      if not version:
        from subprocess import check_output
        out = check_output([compiler, '-x', 'c', '-', '-dM', '-E'], input=b'').decode()
        m = re.search(
            '__clang_major__ (\d+)\n'
            '#define __clang_minor__ (\d+)\n'
            '#define __clang_patchlevel__ (\d+)',
            out
        )
        version = (int(m.group(1)), int(m.group(2)))
        _compiler_version_cache[compiler] = version
    compiler = 'clang'
  else:
    compiler = _compiler

  version = version or (0,0)

  options = options if type(options) == dict else variables_to_options(options)

  def verless(major, minor):
    return version[0] < major or (version[0] == major and version[1] < minor)

  flags=[]
  linkflags=[]
]])
    _:write(table.concat(xvalues, '\n'))
    _:write('\n\n')
  end,

  _vcond_lvl=function(_, lvl, optname) return  "x_" .. optname .. " == '" .. lvl .. "'" end,
  _vcond_verless=function(_, major, minor) return "verless(" .. major .. ', ' .. minor .. ")" end,
  _vcond_compiler=function(_, compiler) return "compiler == '" .. compiler .. "'" end,
  _vcond_platform=function(_, platform) return "platform == '" .. platform .. "'" end,
  _vcond_linker=function(_, linker) return "linker == '" .. linker .. "'" end,

  cxx=function(_, x) return "'" .. x .. "', " end,
  link=function(_, x) return "'" .. x .. "', " end,

  act=function(_, name, datas, optname)
    _:print(_.indent .. '# unimplementable')
    _:print(_.indent .. 'pass')
    return true
  end,

  _vcond_toflags=function(_, cxx, links)
    return (#cxx ~= 0 and _.indent .. 'flags += (' .. cxx .. ')\n' or '')
        .. (#links ~= 0 and _.indent .. 'linkflags += (' .. links .. ')\n' or '')
  end,

  stop=function(_, filebase)
    _:write('  return {"flags": flags, "linkflags": linkflags}\n')
    return _:get_output()
  end
}
