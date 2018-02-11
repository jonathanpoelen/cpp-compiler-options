return {
  ignore={
  },

  indent = '',

  startopt=function(_, name)
  end,

  stopopt=function(_)
  end,

  cond=function(_, v)
  end,

  startcond=function(_, x, optname)
  end,

  elsecond=function(_, optname)
  end,

  stopcond=function(_, optname)
  end,

  cxx=function(_, x)
  end,

  link=function(_, x)
  end,

  define=function(_, x)
  end,

  start=function(_)
  end,

  stop=function(_) return table.concat(_.strs) end,

  strs={},
  print=function(_, s) _:write(s) ; _:write('\n') end,
  write=function(_, s) _.strs[#_.strs+1] = s end,
}
