local normnum=function(x)
  x = '00' .. tostring(x)
  return x:sub(-2)
end

local jamlvl=function(lvl)
  return lvl:gsub('_', '-')
end

return {
  ignore={
  -- warnings_as_error=true,
  -- optimization=true,
  -- debug=true,
  },

  tobjamoption=function(_, optname)
    local norm = optname:gsub('_', '-')
    local opt = _.optprefix .. norm
    local iopt = not _._incidental[optname] and _.optprefix .. norm .. '-incidental'
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
    return '$(version) < "' .. normnum(major) .. '.' .. normnum(minor) .. '"'
  end,
  _vcond_compiler=function(_, compiler) return '$(toolset) = "' .. compiler .. '"' end,
  _vcond_linker=function(_, linker) return '$(linker) = "' .. linker .. '"' end,

  cxx=function(_, x) return _.indent .. '  <' .. _.prefixflag .. 'flags>"' .. x .. '"\n' end,
  link=function(_, x) return _.indent .. '  <linkflags>"' .. x .. '"\n' end,

  _vcond_toflags=function(_, cxx, links)
    return _.indent .. '  flags +=\n' .. cxx .. links .. _.indent .. '  ;\n'
  end,

  start=function(_, optprefix, optenvprefix)
    _.prefixflag = _.is_C and 'c' or 'cxx'
    _.optprefix = (optprefix or ''):gsub('_', '-')
    _.optenvprefix = (optenvprefix or _.optprefix):gsub('-', '_')

    _:_vcond_init({ifopen='', ifclose='', open='( ', close=' )'})

    _:print([[# File generated with https://github.com/jonathanpoelen/cpp-compiler-options

# jam reference: https://boostorg.github.io/build/manual/develop/index.html

import feature : feature ;
import modules ;

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

    for optname,args,default_value,ordered_args in _:getoptions() do
      local opt, iopt, env = _:tobjamoption(optname)
      local defaultjoined = jamlvl(table.concat(ordered_args, ' '))

      _:print('feature <' .. opt .. '> : _ ' .. defaultjoined .. (iopt and ' : incidental ;' or ' : propagated ;'))

      defaults = defaults .. 'feature <' .. opt .. '-default> : ' .. defaultjoined .. ' : incidental ;\n'
      constants = constants .. 'constant '.. prefixfunc .. '_env_' .. optname .. ' : [ '.. prefixfunc .. '-get-env ' .. env .. ' : ' .. defaultjoined .. ' ] ;\n'
      if iopt then
        relevants = relevants .. '\n      <relevant>' .. opt
        incidentals = incidentals .. 'feature <' .. iopt .. '> : _ ' .. defaultjoined .. ' : incidental ;\n'
        for i,opt in pairs({opt, iopt}) do
          toolsetflags = toolsetflags .. '  toolset.flags ' .. opt .. ' ' .. opt:gsub('-', '_'):upper() .. ' : <' .. opt .. '> ;\n'
        end
        locals = locals .. '  local x_' .. optname .. ' = [ '.. prefixfunc .. '-get-value2 $(ps) : '
                 .. opt .. ' : ' .. iopt .. ' : $('.. prefixfunc .. '_env_' .. optname .. ') ] ;\n'
      else
        locals = locals .. '  local x_' .. optname .. ' = [ '.. prefixfunc .. '-get-value $(ps) : '
                 .. opt .. ' : $('.. prefixfunc .. '_env_' .. optname .. ') ] ;\n'
      end
    end

    _:print()
    _:print(incidentals)
    _:print(defaults)
    _:print([[

import os ;

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
import property-set ;
import string ;

local ORIGINAL_TOOLSET = 0 ;
local COMP_VERSION = 00.00 ;

rule ]] .. prefixfunc .. [[-get-normalized-compiler-version ( toolset : version )
{
  # TODO `version` is not the real version. For toolset=gcc-5, version is 5 ; for clang-scan, version is ''
  # define PP_CAT_I(a,b) a##b
  # define PP_CAT(a,b) PP_CAT_I(a,b)
  # g++ -x c++ -E - <<<'PP_CAT(__GNUC__, PP_CAT(__GNUC_MINOR__, __GNUC_PATCHLEVEL__))'
  # clang++ -x c++ -E - <<<'PP_CAT(__clang_major__, PP_CAT(__clang_minor__, __clang_patchlevel__))'
  if $(ORIGINAL_TOOLSET) != $(toolset)
  {
    local version = [ MATCH "^[^0-9]*(.*)$" : $(version) ] ;
    if ! $(version) {
      # if $(toolset) = gcc {
      #   version = [ SHELL "$(toolset) -dumpfullversion" ] ;
      # }
      # else {
        version = [ MATCH ".*(\\d+\\.\\d+\\.\\d+).*" : [ SHELL "$(toolset) --version" ] ] ;
      # }
    }
    local match = [ MATCH "^([0-9]+)(\\.([0-9]+))?" : $(version) ] ;
    local major = [ MATCH "(..)$" : [ string.join 00 $(match[1]) ] ] ;
    local minor = [ MATCH "(..)$" : [ string.join 00 $(match[3]) ] ] ;
    COMP_VERSION = $(major).$(minor) ;
    ORIGINAL_TOOLSET = $(toolset) ;
  }
  return $(COMP_VERSION) ;
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
  local version = [ ]] .. prefixfunc .. [[-get-normalized-compiler-version $(toolset)
                  : [ $(ps).get <toolset-$(toolset):version> ] ] ;
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
