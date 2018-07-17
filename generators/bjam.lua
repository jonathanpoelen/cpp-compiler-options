local normnum=function(x)
  x = '00' .. tostring(x)
  return x:sub(-2)
end

function tobjamoption(optname)
  return optname:gsub('_', '-')
end


return {
  ignore={
    warnings_as_error=true,
    optimize=true,
    debug=true,
  },

  _vcond_lvl=function(_, lvl, optname) return '<' .. _.optprefix .. tobjamoption(optname) .. '>' .. lvl .. ' in $(properties)' end,
  _vcond_verless=function(_, major, minor) return '$(version) < ' .. normnum(major) .. '.' .. normnum(minor) end,
  _vcond_comp=function(_, compiler) return '$(toolset) = ' .. compiler end,

  cxx=function(_, x) return _.indent .. '  <cxxflags>' .. x .. '\n' end,
  link=function(_, x) return _.indent .. '  <linkflags>' .. x .. '\n' end,
  define=function(_, x) return _.indent .. '  <define>' .. x .. '\n' end,

  _vcond_toflags=function(_, cxx, links, defines) return _.indent .. '  flags +=\n' .. cxx .. links .. defines .. _.indent .. '  ;' end,

  start=function(_, optprefix)
    _.optprefix = optprefix or ''
    _:_vcond_init({ifopen='', ifclose='', open='( ', close=' )'})

    -- http://www.boost.org/build/doc/html/index.html
    -- http://www.boost.org/build/doc/html/bbv2/reference/definitions.html#bbv2.reference.features.attributes

    _:print('import property-set ;')
    _:print('import feature ;')
    _:print('import toolset ;\n')

    for optname,v in pairs(_._opts) do
      if optname ~= 'warnings_as_error' then
        local opt = _.optprefix .. tobjamoption(optname)
        _:print('feature.feature <' .. opt .. '> : ' .. v[2] .. (_._incidental[optname] and ' : incidental ;' or ' : propagated ;'))
        _:print('toolset.flags ' .. opt .. ' ' .. optname:upper() .. ' : <' .. opt .. '> ;\n')
      end
    end
    _:print([[import property-set ;
import string ;

local ORIGINAL_TOOLSET = 0 ;
local COMP_VERSION = 00.00 ;
local FLAGS = ;

rule flags ( properties * )
{
  local ps = [ property-set.create $(properties) ] ;
  local toolset = [ $(ps).get <toolset> ] ;

  if $(ORIGINAL_TOOLSET) = $(toolset)
  {
    return $(FLAGS) ;
  }
  else
  {
    # TODO `version` is not the real version. For toolset=gcc-5, version is 5 ; for clang-scan, version is ''
    # define PP_CAT_I(a,b) a##b
    # define PP_CAT(a,b) PP_CAT_I(a,b)
    # g++ -x c++ -E - <<<'PP_CAT(__GNUC__, PP_CAT(__GNUC_MINOR__, __GNUC_PATCHLEVEL__))'
    # clang++ -x c++ -E - <<<'PP_CAT(__clang_major__, PP_CAT(__clang_minor__, __clang_patchlevel__))'
    local version = [ $(ps).get <toolset-$(toolset):version> ] ;
    version = [ MATCH "^[^0-9]*(.*)$" : $(version) ] ;
    if ! $(version) {
      # if $(toolset) = gcc {
      #   version = [ SHELL "$(toolset) -dumpfullversion" ] ;
      # }
      # else {
        version = [ MATCH "^[^ ]+ [^ ]+ ([^ ]+)" : [ SHELL "$(toolset) --version" ] ] ;
      # }
    }
    local match = [ MATCH "^([0-9]+)(\\.([0-9]+))?" : $(version) ] ;
    local major = [ MATCH (..)$ : [ string.join 00 $(match[1]) ] ] ;
    local minor = [ MATCH (..)$ : [ string.join 00 $(match[3]) ] ] ;
    version = $(major).$(minor) ;
    ORIGINAL_TOOLSET = $(toolset) ;

    local flags ;

]])
    _.indent = '    '
  end,

  stop=function(_)
    return _:get_output() .. '    FLAGS = $(flags) ; return $(flags) ;\n  }\n}'
  end,
}
