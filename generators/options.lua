return {
  s = '',
  
  startopt=function(_)
    _.t = {}
  end,

  stopopt=function(_, optname)
    -- check _._opts with the options inside the tree
    local m = {}
    for k,v in ipairs(_.t) do
      m[v] = true
    end
    if m[_._opts[optname][1]] then
      error('G[' .. optname .. ']: disable value ' .. _._opts[optname][1] .. ' is used')
    end
    m.on  = true
    m.off = true

    local t = {}
    _._opts[optname][2]:gsub('(%w+)', function(x) t[x] = true end)
    if not t[_._opts[optname][1]] then
      error('_opts[' .. optname .. '][1]: disable value ' .. _._opts[optname][1] .. ' is not used')
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
    
    _.s = _.s .. optname .. ' = ' .. _._opts[optname][2] .. '\n'
    _._opts[optname] = nil    
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
    for k,x in pairs(_._opts) do
      error('_.opts: no match for ' .. k)
    end
    return _.s
  end,
}
