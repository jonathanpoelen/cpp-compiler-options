color_map = {
  on='\x1b[32m',
  off='\x1b[31m',
  default='\x1b[37m',
}
color_map[0] = '\x1b[34m'
color_map[1] = '\x1b[35m'
color_size = 2

return {
  output_lines = {},
  known_opts = {},

  start=function(_, color)
    _.enable_color = color
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

    if _.enable_color then
      local str, ic = optname .. ' \x1b[37m=', 0
      for i,x in ipairs(_._opts[optname]) do
        local c = color_map[x]
        if not c then
          c = color_map[ic % color_size]
          ic = ic + 1
        end
        str = str .. ' ' .. c .. x
      end
      _.output_lines[#_.output_lines+1] = str .. '\x1b[0m'
    else
      _.output_lines[#_.output_lines+1] = optname .. ' = ' .. table.concat(_._opts[optname], ' ')
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
        kerr[#kerr] = k
      end
    end
    if #kerr ~= 0 then
      error('_.opts: no match for "' .. table.concat(kerr, ', ') .. '"')
    end

    table.sort(_.output_lines)
    return table.concat(_.output_lines, '\n') .. '\n'
  end,
}
