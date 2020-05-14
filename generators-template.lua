-- all functions are optional
return {
  ignore={
  },

  indent = '',

  -- is_C = true | false -- set by caller

  startoptcond=function(_, name)
  end,

  stopopt=function(_)
  end,

  cond=function(_, v)
  end,

  -- x =
  -- _and = {left, right} |
  -- _or = {left, right} |
  -- _not = expr |
  -- compiler = name |
  -- hasopt = name |
  -- lvl = name |
  -- version = {major, minor}
  -- NOTE: major can be negative
  startcond=function(_, x, optname)
  end,

  elsecond=function(_, optname)
  end,

  -- close startcond and startoptcond
  stopcond=function(_, optname)
  end,

  cxx=function(_, x)
  end,

  link=function(_, x)
  end,

  stop=function(_) return table.concat(_.strs) end,

  strs={},
  print=function(_, s) _:write(s) ; _:write('\n') end,
  write=function(_, s) _.strs[#_.strs+1] = s end,

  start=function(_)
    -- default keywords
    local keywords = {
      _or = '||',
      _and = '&&',
      _not = '!',
      _if = 'if',
      _else = 'else',
      open = '(',
      close = ')',
      openbloc = '{',
      closebloc = '}',
    }
    -- optional keywords
    keywords.ifopen = keywords.open
    keywords.ifclose = keywords.close
    -- _vcond_* functions initialize
    -- Override startoptcond, stopopt, startcond, elsecond, markelseif, stopcond, cxx, link
    _:_vcond_init(keywords)
  end,

  -- only if \a _vcond_init
  -- BEGIN
  _vcond_lvl=function(_, lvl, optname) return lvl .. 'in option[' .. optname .. ']' end,
  _vcond_verless=function(_, major, minor) return 'version < ' .. major .. '.' minor end,
  _vcond_compiler=function(_, compiler) return 'compiler == ' .. compiler end,
  _vcond_linker=function(_, linker) return 'linker == ' .. linker end,
  _vcond_toflags=function(_, cxxflags, ldflags) return cxxflags .. ' ' .. ldflags end,
  -- optional:
  _vcond=function(_, v, optname) return '' end,
  _vcond_hasopt=function(_, optname) return '' end,
  _vcond_printflags=function(_) --[[ used _vcond_toflags(_._vcond_flags_cxx, _._vcond_flags_link) ]] end,
  -- END
}
