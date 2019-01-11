local normnum=function(x)
  x = '00' .. tostring(x)
  return x:sub(-2)
end

return {
  ignore={
    warnings_as_error=true,
  -- optimize=true,
  -- debug=true,
  },

  tobjamoption=function(_, optname)
    local norm = optname:gsub('_', '-')
    local opt = _.optprefix .. norm
    if _._incidental[optname] then
      return opt
    end
    return opt, _.ioptprefix .. norm
  end,

  _vcond_lvl=function(_, lvl, optname)
    local opt, iopt = _:tobjamoption(optname)
    return iopt and
      '( <' .. opt .. '>' .. lvl .. ' in $(properties) || <'
            .. iopt .. '>' .. lvl .. ' in $(properties) )'
     or '<' .. opt .. '>' .. lvl .. ' in $(properties)'
  end,
  _vcond_verless=function(_, major, minor) return '$(version) < ' .. normnum(major) .. '.' .. normnum(minor) end,
  _vcond_comp=function(_, compiler) return '$(toolset) = ' .. compiler end,

  cxx=function(_, x) return _.indent .. '  <cxxflags>' .. x .. '\n' end,
  link=function(_, x) return _.indent .. '  <linkflags>' .. x .. '\n' end,
  define=function(_, x) return _.indent .. '  <define>' .. x .. '\n' end,

  _vcond_toflags=function(_, cxx, links, defines) return _.indent .. '  flags +=\n' .. cxx .. links .. defines .. _.indent .. '  ;' end,

  start=function(_, optprefix)
    _.optprefix = optprefix or ''
    local optprefix_suffix = _.optprefix:sub(#_.optprefix)
    _.ioptprefix = _.optprefix .. (optprefix_suffix ~= '_' and optprefix_suffix ~= '-' and '-' or '') .. 'incidental-'

    _:_vcond_init({ifopen='', ifclose='', open='( ', close=' )'})

    _:print([[# https://boostorg.github.io/build/manual/develop/index.html

import feature : feature ;
import modules ;

CXX_BJAM_YEAR_VERSION = [ modules.peek : JAMVERSION ] ;
]])

    -- for optname,k in pairs({'compiler', 'compiler-version'}) do
    --   local opt = _:tobjamoption(optname)
    --   _:print('feature <' .. opt .. '> : : free ;')
    -- end

    local relevants = ""

    for optname,args,default_value,ordered_args in _:getoptions() do
      local opt, iopt = _:tobjamoption(optname)
      if not _._incidental[optname] then
        relevants = relevants .. "\n      <relevant>" .. opt
      end
      local joined = table.concat(ordered_args, ' ')
      _:print('feature <' .. opt .. '> : ' .. joined .. (_._incidental[optname] and ' : incidental ;' or ' : propagated ;'))
      if iopt then
        _:print('feature <' .. iopt .. '> : ' .. joined .. ' : incidental ;')
      end
    end
    relevants = relevants .. '\n'

    _:print('\nif $(CXX_BJAM_YEAR_VERSION) < 2016.00 {')
    _:print('  import toolset ;')
    for optname in _:getoptions() do
      if not _._incidental[optname] then
        for i,opt in pairs({_:tobjamoption(optname)}) do
          _:print('  toolset.flags ' .. opt .. ' ' .. opt:gsub('-', '_'):upper() .. ' : <' .. opt .. '> ;')
        end
      end
    end
    _:print([[}

import property-set ;
import string ;

local ORIGINAL_TOOLSET = 0 ;
local COMP_VERSION = 00.00 ;

rule jln-get-normalized-compiler-version ( toolset : version )
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

rule jln_flags ( properties * )
{
  local ps = [ property-set.create $(properties) ] ;
  local toolset = [ $(ps).get <toolset> ] ;
  local version = [ jln-get-normalized-compiler-version $(toolset)
                  : [ $(ps).get <toolset-$(toolset):version> ] ] ;

  local flags = ;
  if $(CXX_BJAM_YEAR_VERSION) >= 2016.00
  {
    flags += ]] .. relevants .. [[
    ;
  }

]])
    _.indent = '  '
  end,

  stop=function(_)
    return _:get_output() .. '  return $(flags) ;\n}\n'
  end,
}
