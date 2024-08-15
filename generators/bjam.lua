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

  tobjamoption=function(self, option)
    local optname = option.name
    local norm = optname:gsub('_', '-')
    local opt = self.optprefix .. norm
    local iopt = not option.incidental and self.optprefix .. norm .. '-incidental'
    local env = self.optenvprefix .. optname
    return opt, iopt, env
  end,

  _vcond_resetopt=function(self, optname)
    return 'x_' .. optname .. ' = "default" ;'
  end,

  _vcond_lvl=function(self, lvl, optname, not_)
    return '$(x_' .. optname .. ')' .. self:eq_op(not_) .. '"' .. jamlvl(lvl) .. '"'
  end,

  _vcond_version=function(self, op, major, minor)
    local version = tostring(major * 100000 + minor)
    local var = '$(JLN_NORMALIZED_' .. self.prefixcomp .. '_COMP_VERSION)'
    if op == '>=' then
      return '! [ numbers.less ' .. var .. ' ' .. version .. ' ]'
    elseif op == '<=' then
      return '! [ numbers.less ' .. version .. ' ' .. var .. ' ]'
    elseif op == '<' then
      return '[ numbers.less ' .. var .. ' ' .. version .. ' ]'
    elseif op == '>' then
      return '[ numbers.less ' .. version .. ' ' .. var .. ' ]'
    elseif op == '=' then
      return var .. ' = ' .. version
    elseif op == '!=' then
      return var .. ' != ' .. version
    end
    assert('Unknown operator '.. op)
  end,

  _vcond_to_compiler=function(self, compiler)
    return '"' .. (jamcompilers[compiler] or compiler) .. '"'
  end,

  _vcond_to_platform=function(self, platform)
    return jamplatforms[platform]
  end,

  cxx=function(self, x) return self.indent .. '  <' .. self.prefixflag .. 'flags>"' .. x .. '"\n' end,
  link=function(self, x) return self.indent .. '  <linkflags>"' .. x .. '"\n' end,

  act=function(self, name, datas, optname)
    self:print(self.indent .. '# unimplementable')
    return true
  end,

  _vcond_toflags=function(self, cxx, links)
    return self.indent .. 'flags +=\n' .. cxx .. links .. self.indent .. ';\n'
  end,

  start=function(self, optprefix, optenvprefix)
    self.prefixflag = self.is_C and 'c' or 'cxx'
    self.optprefix = (optprefix or ''):gsub('_', '-')
    self.optenvprefix = (optenvprefix or self.optprefix):gsub('-', '_')

    self.prefixcomp = self.is_C and 'C' or 'CXX'

    self._vcond_to_compiler_like_map = {
      ['clang-like'] = '$(JLN_NORMALIZED_' .. self.prefixcomp .. '_IS_CLANG_LIKE)',
    }

    self:_vcond_init({
      ifopen='', ifclose='', eq=' = ', no_eq=' != ',
      compiler='$(JLN_NORMALIZED_' .. self.prefixcomp .. '_COMP)',
      linker='$(linker)',
      platform='[ os.name ]',
    })

    self:print_header('#')
    self:print([[
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
    --   local opt = self:tobjamoption(optname)
    --   self:print('feature <' .. opt .. '> : : free ;')
    -- end

    local relevants = ''
    local incidentals = ''
    local toolsetflags = ''
    local constants = ''
    local locals = ''
    local defaults = ''
    local prefixfunc = self.is_C and 'jln_c' or 'jln'

    for option in self:getoptions() do
      local opt, iopt, env = self:tobjamoption(option)
      local defaultjoined = jamlvl(table.concat(option.ordered_values, ' '))

      if option.description then
        self:print('# ' .. quotable_desc(option, '\n# ', ''))
      end
      self:print('feature <' .. opt .. '> : _ ' .. defaultjoined
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
        for _,opt in pairs({opt, iopt}) do
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

    self:print()
    self:print(incidentals)
    self:print(defaults)
    self:print([[

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
    self:print(constants)
    self:print('if $(JLN_BJAM_YEAR_VERSION) < 2016.00\n{')
    self:print('  import toolset ;')
    self:print(toolsetflags)
    self:print('}')
    self:print([[

JLN_ORIGINAL_]] .. self.prefixcomp .. [[_TOOLSET = "" ;
JLN_NORMALIZED_]] .. self.prefixcomp .. [[_COMP = "" ;
JLN_NORMALIZED_]] .. self.prefixcomp .. [[_COMP_VERSION = 100000 ;
JLN_NORMALIZED_]] .. self.prefixcomp .. [[_IS_CLANG_LIKE = 0 ;

rule ]] .. prefixfunc .. [[-update-normalized-compiler ( toolset : version )
{
  if $(JLN_ORIGINAL_]] .. self.prefixcomp .. [[_TOOLSET) != $(toolset)
  {
    JLN_ORIGINAL_]] .. self.prefixcomp .. [[_TOOLSET = $(toolset) ;

    local is_emcc = 0 ;
    local is_intel = 0 ;
    local is_clang = 0 ;
    switch $(toolset)  {
      case emscripten* : is_emcc = 1 ;
      case emcc* : is_emcc = 1 ;
      case intel : is_intel = 1 ;
      case icx* : is_intel = 1 ;
      case icpx* : is_intel = 1 ;
      case dpcpp* : is_intel = 1 ;
      case clang* : is_clang = 1 ;
    }

    if $(is_emcc) = 1 {
      JLN_NORMALIZED_]] .. self.prefixcomp .. [[_COMP = clang-emcc ;
      JLN_NORMALIZED_]] .. self.prefixcomp .. [[_IS_CLANG_LIKE = 1 ;
      # get clang version. Assume emcc exists
      version = [ MATCH "clang version ([0-9]+\\.[0-9]+\\.[0-9]+)" : [ SHELL "emcc -v 2>&1" ] ] ;
    }
    # icx / icpx
    else if $(is_intel) = 1 {
      JLN_NORMALIZED_]] .. self.prefixcomp .. [[_COMP = clang ;
      JLN_NORMALIZED_]] .. self.prefixcomp .. [[_IS_CLANG_LIKE = 1 ;
      switch $(version)  {
        case 2021* : JLN_NORMALIZED_]] .. self.prefixcomp .. [[_COMP_VERSION = 1200000 ;
        case 2022* : JLN_NORMALIZED_]] .. self.prefixcomp .. [[_COMP_VERSION = 1400000 ;
        case 2023* : JLN_NORMALIZED_]] .. self.prefixcomp .. [[_COMP_VERSION = 1600000 ;
        case 2024* : JLN_NORMALIZED_]] .. self.prefixcomp .. [[_COMP_VERSION = 1800000 ;
        case 2025* : JLN_NORMALIZED_]] .. self.prefixcomp .. [[_COMP_VERSION = 2000000 ;
        case 2026* : JLN_NORMALIZED_]] .. self.prefixcomp .. [[_COMP_VERSION = 2200000 ;
        case 2027* : JLN_NORMALIZED_]] .. self.prefixcomp .. [[_COMP_VERSION = 2400000 ;
        case 2028* : JLN_NORMALIZED_]] .. self.prefixcomp .. [[_COMP_VERSION = 2600000 ;
        case 2029* : JLN_NORMALIZED_]] .. self.prefixcomp .. [[_COMP_VERSION = 2800000 ;
        case 2030* : JLN_NORMALIZED_]] .. self.prefixcomp .. [[_COMP_VERSION = 3000000 ;
      }
    }
    else {
      JLN_NORMALIZED_]] .. self.prefixcomp .. [[_IS_CLANG_LIKE = $(is_clang) ;
      # TODO `version` is not the real version.
      # For toolset=gcc-5, version is 5 ; for clang-scan, version is ''
      JLN_NORMALIZED_]] .. self.prefixcomp .. [[_COMP = $(toolset) ;
      version = [ MATCH "^[^0-9]*(.*)$" : $(version) ] ;
      if ! $(version) {
        version = [ MATCH "([0-9]+\\.[0-9]+\\.[0-9]+)" : [ SHELL "$(toolset) --version" ] ] ;
      }
    }

    if $(is_intel) = 0 {
      local match = [ MATCH "^([0-9]+)(\\.([0-9]+))?" : $(version) ] ;
      local major = $(match[1]) ;
      local minor = [ MATCH "(.....)$" : [ string.join 00000 $(match[3]) ] ] ;
      JLN_NORMALIZED_]] .. self.prefixcomp .. [[_COMP_VERSION = $(major)$(minor) ;
    }
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
    self:print(locals)

    self.indent = '  '
  end,

  stop=function(self)
    return self:get_output() .. '  return $(flags) ;\n}\n'
  end,
}
