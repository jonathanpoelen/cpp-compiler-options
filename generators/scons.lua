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
    local prefixfunc = _.is_C and 'jln_c' or 'jln'
    local prefixenv = _.is_C and 'CC' or 'CXX'

    local enums, flags, var2opts, opt2vars, xvalues = {}, {}, {}, {}, {}
    for option in _:getoptions() do
      local optname = option.name
      local name = optprefix .. optname
      flags[#flags+1] = "  '" .. optname .. "': '" .. option.default .. "',\n"
      var2opts[#var2opts+1] = "  '" .. name .. "': '" .. optname .. "',\n"
      opt2vars[#opt2vars+1] = "  '" .. optname .. "': '" .. name .. "',\n"
      xvalues[#xvalues+1] = "  x_" .. optname .. " = options.get('" .. optname
                            .. "', _" .. prefixfunc
                            .. "_default_flags['" .. optname .. "'])"
      enums[#enums+1] = "    EnumVariable('" .. name .. "', '"
        .. quotable_desc(option) .. "', default_values.get('"
        .. optname .. "', _jln_default_flags['" .. optname
        .. "']),\n                 allowed_values=('"
        .. table.concat(option.values, "', '") .. "'))"
    end

    _:write([[
from SCons.Environment import Environment
from SCons.Variables.EnumVariable import EnumVariable

_]] .. prefixfunc .. [[_default_flags = {
]] .. table.concat(flags) .. [[
}

_]] .. prefixfunc .. [[_var2opts = {
]] .. table.concat(var2opts) .. [[
}

_]] .. prefixfunc .. [[_opt2vars = {
]] .. table.concat(opt2vars) .. [[
}

def ]] .. prefixfunc .. [[_set_global_flags(default_values):
  _]] .. prefixfunc .. [[_default_flags.update(default_values)

def ]] .. prefixfunc .. [[_add_variables(vars, default_values={}):
  vars.AddVariables(
]] .. table.concat(enums, ',\n') .. [[
  )

def ]] .. prefixfunc .. [[_varname_to_optname(options):
  return ]] .. (optprefix
    and '{_' .. prefixfunc .. '_var2opts.get(k, k):v for k,v in options.items()}'
    or 'options'
  ) .. [[

def ]] .. prefixfunc .. [[_optname_to_varname(options):
  return ]] .. (
    optprefix
    and '{_' .. prefixfunc .. '_opt2vars.get(k, k):v for k,v in options.items()}'
    or 'options'
  ) .. [[

def ]] .. prefixfunc .. [[_variables_to_options(vars):
  args = vars.args
  return {]] .. (optprefix and '_' .. prefixfunc .. '_var2opts[v.key]' or 'v.key')
    .. [[:args.get(v.key, v.default) for v in vars.options}

_]] .. prefixfunc .. [[_default_env = Environment()
_]] .. prefixfunc .. [[_map_compiler = {"g++": "gcc", "mingw": "gcc", "clang++": "clang"}
def ]] .. prefixfunc .. [[_flags(options, compiler=None, version=None, linker=None):
  compiler = compiler or _]] .. prefixfunc .. [[_default_env[']] .. prefixenv .. [[']

  _compiler = None
  for comp in ('clang', 'g++', 'gcc', 'msvc'):
    if compiler.find(comp) != -1:
      _compiler = comp
      break

  if not _compiler:
    return {}

  compiler = _]] .. prefixfunc .. [[_map_compiler.get(_compiler, _compiler)
  version = version or _]] .. prefixfunc .. [[_default_env[']] .. prefixenv .. [[VERSION']
  version = version.split(".")
  version[0] = int(version[0])
  version[1] = int(version[1]) if len(version) == 1 else 0

  options = options if type(options) == dict else ]] .. prefixfunc .. [[_variables_to_options(options)

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
