return {
  knwon_opts = {},
  errors = {},

  start=function(_, show_profile, color)
    show_profile, color = not (show_profile == '--noprofile' or color == '--noprofile'), (show_profile == '--color' or color == '--color')

    local knwon_opts = _.knwon_opts
    local add_opt = function(optname, args)
      local t = {}
      for k,v in pairs(args) do
        t[v] = true
      end
      _.knwon_opts[optname] = {t}
    end

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
          str = str .. ' ' .. (i == 1
            and (c:sub(0,-2) .. ';7m' .. x .. '\x1b[0m')
            or (c .. x))
        end
        print(str .. '\x1b[0m')
        add_opt(optname, args)
      end
    else
      for optname, args, default_value, ordered_args in _:getoptions() do
        print(optname .. ' = ' .. table.concat(ordered_args, ' '))
        add_opt(optname, args)
      end
    end

    if show_profile then
      print('\n\nProfiles:')
      table.sort(_._opts_build_type)
      for name, opts in _:getbuildtype() do
        print('\n' .. name)
        for i,xs in ipairs(opts) do
          print(' - ' .. xs[1] .. ' = ' .. xs[2])
        end
      end
    end
  end,

  startopt=function(_, optname)
    local known = _.knwon_opts[optname]
    if not known then
      _.errors[#_.errors+1] = '_opts[' .. optname .. ']: unknown key'
    else
      known[2] = true
    end
  end,

  startcond=function(_, x, optname)
    if x.lvl then
      local known = _.knwon_opts[optname]
      if not known then
        _.errors[#_.errors+1] = '_opts[' .. optname .. ']: unknown key'
      elseif not known[1][x.lvl] then
        _.errors[#_.errors+1] = '_opts[' .. optname .. ']: unknown value: ' .. x.lvl
      else
        known[2] = true
      end
    elseif x._not then
      _:startcond(x._not, optname)
    else
      local sub = x._and or x._or
      if sub then
        _:startcond(sub[1], optname)
        _:startcond(sub[2], optname)
      end
    end
  end,

  stop=function(_)
    for k,opts in pairs(_.knwon_opts) do
      if not opts[2] then
        _.errors[#_.errors+1] = '_opts[' .. k .. ']: not used in the tree'
      end
    end
    if #_.errors ~= 0 then
      error(table.concat(_.errors, '\n'))
    end
  end,
}
