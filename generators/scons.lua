local table_insert = table.insert

return {
  ignore={
  --  optimization=true,
  --  debug=true, -- reserved
    msvc_isystem={external_as_include_system_flag=true},
  },

  _option_strs = {},

  start=function(self, optprefix)
    self:_vcond_init({
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

    self:print_header('#')

    optprefix = optprefix and optprefix:gsub('-', '_') or ''
    local prefixenv = self.is_C and 'CC' or 'CXX'

    local enums, flags, var2opts, opt2vars, xvalues = {}, {}, {}, {}, {}
    for option in self:getoptions() do
      local optname = option.name
      local name = optprefix .. optname
      table_insert(flags, "  '" .. optname .. "': '" .. option.default .. "',\n")
      table_insert(var2opts, "  '" .. name .. "': '" .. optname .. "',\n")
      table_insert(opt2vars, "  '" .. optname .. "': '" .. name .. "',\n")
      table_insert(xvalues, "  x_" .. optname .. " = options.get('" .. optname
                         .. "', _default_flags['" .. optname .. "'])")
      table_insert(enums, "    EnumVariable('" .. name .. "', '"
        .. quotable_desc(option) .. "', default_values.get('"
        .. optname .. "', _default_flags['" .. optname
        .. "']),\n                 allowed_values=('"
        .. table.concat(option.values, "', '") .. "'))")
    end

    self:write([[
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
    is_clang_like = true
    compiler = 'clang'
  elif _compiler == 'emcc':
    is_clang_like = true
    compiler = 'clang-emcc'
  else:
    is_clang_like = compiler.startswith('clang') and not compiler.startswith('clang-cl')
    compiler = _compiler

  version = version or (0,0)
  compversion = version[0] * 100000 + version[1]

  options = options if type(options) == dict else variables_to_options(options)

  flags=[]
  linkflags=[]
]])
    self:write(table.concat(xvalues, '\n'))
    self:write('\n\n')
  end,

  _vcond_to_version=function(self, major, minor) return tostring(major * 100000 + minor) end,
  _vcond_to_opt=function(self, optname) return  "x_" .. optname end,

  _vcond_to_compiler_like_map={
    ['clang-like'] = 'is_clang_like',
  },

  cxx=function(self, x) return "'" .. x .. "', " end,
  link=function(self, x) return "'" .. x .. "', " end,

  act=function(self, datas, optname)
    self:print(self.indent .. '# unimplementable')
    self:print(self.indent .. 'pass')
    return true
  end,

  _vcond_toflags=function(self, cxx, links)
    return (#cxx ~= 0 and self.indent .. 'flags += (' .. cxx .. ')\n' or '')
        .. (#links ~= 0 and self.indent .. 'linkflags += (' .. links .. ')\n' or '')
  end,

  stop=function(self, filebase)
    self:write('  return {"flags": flags, "linkflags": linkflags}\n')
    return self:get_output()
  end
}
