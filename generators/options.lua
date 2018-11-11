return {
  output_lines = {},
  known_opts = {},

  startopt=function(_)
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
    if m[_._opts[optname][1]] then
      error('_opts[' .. optname .. ']: disable value ' .. _._opts[optname][1] .. ' is used')
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
    _.output_lines[#_.output_lines+1] = optname .. ' = ' .. table.concat(_._opts[optname][2], ' ')
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
    for k,x in pairs(_._opts) do
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
