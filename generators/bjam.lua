local function normnum(x)
  x = '00' .. tostring(x)
  return x:sub(-2)
end

local function jamlvl(lvl)
  return lvl:gsub('_', '-')
end

local jamplatforms = {
  mingw='MINGW',
  windows='NT',
  linux='LINUX',
  macos='MACOSX',
}

local jamcompilers = {
  icc="intel' && $(original_version) = 'linux",
  icl="intel' && $(original_version) = 'windows",
  icx='intel',
  dpcpp='intel',
}

return {
  ignore={
  -- warnings_as_error=true,
  -- optimization=true,
  -- debug=true,
    msvc_isystem={external_as_include_system_flag=true},
  },

  tobjamoption=function(_, option)
    local optname = option.name
    local norm = optname:gsub('_', '-')
    local opt = _.optprefix .. norm
    local iopt = not option.incidental and _.optprefix .. norm .. '-incidental'
    local env = _.optenvprefix .. optname
    return opt, iopt, env
  end,

  _vcond_lvl=function(_, lvl, optname)
    return '( $(x_' .. optname .. ') = "' .. jamlvl(lvl) .. '" )'
  end,
  _vcond_hasopt=function(_, optname)
    return '( $(x_' .. optname .. ') != "default" )'
  end,

  _vcond_verless=function(_, major, minor)
    return '[ numbers.less $(NORMALIZED_' .. _.prefixcomp .. '_COMP_VERSION) ' .. tostring(major * 100000 + minor) .. ' ]'
  end,
  _vcond_compiler=function(_, compiler) return '$(NORMALIZED_' .. _.prefixcomp .. '_COMP) = "' .. (jamcompilers[compiler] or compiler) .. '"' end,
  _vcond_platform=function(_, platform) return '[ os.name ] = ' .. jamplatforms[platform] end,
  _vcond_linker=function(_, linker) return '$(linker) = "' .. linker .. '"' end,

  cxx=function(_, x) return _.indent .. '  <' .. _.prefixflag .. 'flags>"' .. x .. '"\n' end,
  link=function(_, x) return _.indent .. '  <linkflags>"' .. x .. '"\n' end,

  act=function(_, name, datas, optname)
    _:print(_.indent .. '# unimplementable')
    return true
  end,

  _vcond_toflags=function(_, cxx, links)
    return _.indent .. 'flags +=\n' .. cxx .. links .. _.indent .. ';\n'
  end,

  start=function(_, optprefix, optenvprefix)
    _.prefixflag = _.is_C and 'c' or 'cxx'
    _.optprefix = (optprefix or ''):gsub('_', '-')
    _.optenvprefix = (optenvprefix or _.optprefix):gsub('-', '_')

    _:_vcond_init({ifopen='', ifclose='', open='( ', close=' )'})

    _:print_header('#')
    _:print([[
# jam reference: https://www.boost.org/build/doc/html/index.html

import feature : feature ;
import modules ;
import numbers ;
import os ;
import property-set ;
import string ;

JLN_BJAM_YEAR_VERSION = [ modules.peek : JAMVERSION ] ;
]])

    -- for optname,k in pairs({'compiler', 'compiler-version'}) do
    --   local opt = _:tobjamoption(optname)
    --   _:print('feature <' .. opt .. '> : : free ;')
    -- end

    local relevants = ''
    local incidentals = ''
    local toolsetflags = ''
    local constants = ''
    local locals = ''
    local defaults = ''
    local prefixfunc = _.is_C and 'jln_c' or 'jln'

    _.prefixcomp = _.is_C and 'C' or 'CXX'

    for option in _:getoptions() do
      local opt, iopt, env = _:tobjamoption(option)
      local defaultjoined = jamlvl(table.concat(option.ordered_values, ' '))

      if option.description then
        _:print('# ' .. quotable_desc(option, '\n# ', ''))
      end
      _:print('feature <' .. opt .. '> : _ ' .. defaultjoined
              .. (iopt and ' : incidental ;' or ' : propagated ;'))

      defaults = defaults .. 'feature <' .. opt .. '-default> : '
                 .. defaultjoined .. ' : incidental ;\n'
      constants = constants .. 'constant '.. prefixfunc .. '_env_'
                  .. option.name .. ' : [ '.. prefixfunc .. '-get-env ' .. env
                  .. ' : ' .. defaultjoined .. ' ] ;\n'
      if iopt then
        relevants = relevants .. '\n      <relevant>' .. opt
        incidentals = incidentals .. 'feature <' .. iopt .. '> : _ '
                      .. defaultjoined .. ' : incidental ;\n'
        for i,opt in pairs({opt, iopt}) do
          toolsetflags = toolsetflags .. '  toolset.flags ' .. opt .. ' '
                         .. opt:gsub('-', '_'):upper() .. ' : <' .. opt .. '> ;\n'
        end
        locals = locals .. '  local x_' .. option.name .. ' = [ '.. prefixfunc .. '-get-value2 $(ps) : '
                 .. opt .. ' : ' .. iopt .. ' : $('.. prefixfunc .. '_env_' .. option.name .. ') ] ;\n'
      else
        locals = locals .. '  local x_' .. option.name .. ' = [ '.. prefixfunc .. '-get-value $(ps) : '
                 .. opt .. ' : $('.. prefixfunc .. '_env_' .. option.name .. ') ] ;\n'
      end
    end

    _:print()
    _:print(incidentals)
    _:print(defaults)
    _:print([[

rule ]] .. prefixfunc .. [[-get-env ( env : values * )
{
  local x = [ os.environ $(env) ] ;
  if $(x)
  {
    if $(x) in $(values)
    {
      return $(x) ;
    }
    else
    {
      EXIT "Unknown '$(x)' for $(env)" : 7 ;
    }
  }
  else
  {
    return "" ;
  }
}
]])
    _:print(constants)
    _:print('if $(JLN_BJAM_YEAR_VERSION) < 2016.00\n{')
    _:print('  import toolset ;')
    _:print(toolsetflags)
    _:print('}')
    _:print([[

local ORIGINAL_TOOLSET = 0 ;
local NORMALIZED_]] .. _.prefixcomp .. [[_COMP = "" ;
local NORMALIZED_]] .. _.prefixcomp .. [[_COMP_VERSION = 100000 ;

rule ]] .. prefixfunc .. [[-update-normalized-compiler ( toolset : version )
{
  if $(ORIGINAL_TOOLSET) != $(toolset)
  {
    ORIGINAL_TOOLSET = $(toolset) ;

    local is_emcc = 0 ;
    switch $(toolset)  {
      case emscripten* : is_emcc = 1 ;
      case emcc* : is_emcc = 1 ;
    }

    if $(is_emcc) = 1 {
      NORMALIZED_]] .. _.prefixcomp .. [[_COMP = clang-emcc ;
      # get clang version. Assume emcc exists
      version = [ MATCH "clang version ([0-9]+\\.[0-9]+\\.[0-9]+)" : [ SHELL "emcc -v 2>&1" ] ] ;
    }
    else {
      # TODO `version` is not the real version.
      # For toolset=gcc-5, version is 5 ; for clang-scan, version is ''
      NORMALIZED_]] .. _.prefixcomp .. [[_COMP = $(toolset) ;
      version = [ MATCH "^[^0-9]*(.*)$" : $(version) ] ;
      if ! $(version) {
        if $(toolset) != intel {
          version = [ MATCH "([0-9]+\\.[0-9]+\\.[0-9]+)" : [ SHELL "$(toolset) --version" ] ] ;
        }
      }
    }

    local match = [ MATCH "^([0-9]+)(\\.([0-9]+))?" : $(version) ] ;
    local major = $(match[1]) ;
    local minor = [ MATCH "(.....)$" : [ string.join 00000 $(match[3]) ] ] ;
    NORMALIZED_]] .. _.prefixcomp .. [[_COMP_VERSION = $(major)$(minor) ;
  }
}

rule ]] .. prefixfunc .. [[-get-value ( ps : opt : env )
{
  local x = [ $(ps).get <$(opt)> ] ;
  if $(x) = "_"
  {
    x = $(env) ;
    if $(x) = ""
    {
      x = [ $(ps).get <$(opt)-default> ] ;
    }
  }
  return $(x) ;
}

rule ]] .. prefixfunc .. [[-get-value2 ( ps : opt : iopt : env )
{
  local x = [ $(ps).get <$(opt)> ] ;
  if $(x) = "_"
  {
    x = [ $(ps).get <$(iopt)> ] ;
    if $(x) = "_"
    {
      x = $(env) ;
      if $(x) = ""
      {
        x = [ $(ps).get <$(opt)-default> ] ;
      }
    }
  }
  return $(x) ;
}

rule ]] .. prefixfunc .. [[_flags ( properties * )
{
  local ps = [ property-set.create $(properties) ] ;
  local toolset = [ $(ps).get <toolset> ] ;
  local original_version = [ $(ps).get <toolset-$(toolset):version> ] ;
  ]] .. prefixfunc .. [[-update-normalized-compiler $(toolset) : $(original_version) ;
  local linker = [ $(ps).get <linker> ] ;

  local flags = ;
  if $(JLN_BJAM_YEAR_VERSION) >= 2016.00
  {
    flags += ]] .. relevants .. [[

    ;
  }
]])
    _:print(locals)

    _.indent = '  '
  end,

  stop=function(_)
    return _:get_output() .. '  return $(flags) ;\n}\n'
  end,
}
