return {
  known_opts = {},

  start=function(_, color)
    if color then
      local color_map = {
        on='\x1b[32m',
        off='\x1b[31m',
        default='\x1b[37m',
      }
      color_map[0] = '\x1b[34m'
      color_map[1] = '\x1b[35m'
      local color_size = 2
      for optname, args, default_value, ordered_args in _:getoptions() do
        local str, ic = optname .. ' \x1b[37m=', 0
        for i,x in ipairs(ordered_args) do
          local c = color_map[x]
          if not c then
            c = color_map[ic % color_size]
            ic = ic + 1
          end
          str = str .. ' ' .. c .. x
        end
        print(str .. '\x1b[0m')
      end
    else
      for optname, args, default_value, ordered_args in _:getoptions() do
        print(optname .. ' = ' .. table.concat(ordered_args, ' '))
      end
    end
  end,

  startopt=function(_, optname)
    _.t = {}
  end,

  stopopt=function(_, optname)
    if _.known_opts[optname] then
      return
    end

    -- check _._opts with the options inside the tree
    local m = {}
    for k,v in ipairs(_.t) do
      m[v] = true
    end
    if m['default'] then
      error('_opts[' .. optname .. ']: "default" value is used')
    end

    for k,x in pairs(_.t) do
      if not m[x] then
        error('_opts[' .. optname .. ']: unknown ' .. x)
      end
      m[x] = nil
    end

    if #m ~= 0 then
      error('_opts[' .. optname .. ']: unspecified ' .. table.concat(m, ', '))
    end

    _.known_opts[optname] = true
  end,

  startcond=function(_, x)
    if x.lvl then
      _.t[#_.t+1] = x.lvl
    elseif x._not then
      _:startcond(x._not)
    else
      local sub = x._and or x._or
      if sub then
        _:startcond(sub[1])
        _:startcond(sub[2])
      end
    end
  end,

  stop=function(_)
    local kerr = {}
    for k in pairs(_._opts) do
      if not _.known_opts[k] then
        kerr[#kerr + 1] = k
      end
    end
    if #kerr ~= 0 then
      error(table.concat(kerr, ', ') .. ': not used in the tree')
    end
  end,
}
