local knwon_opts = {}
local errors = {}

local table_insert = table.insert

local without_space_or_error = function(self, s)
  if s:find(' ') then
    table_insert(errors, '"' .. s .. '" contains a space')
  end
end

local is_available = function(self, optname)
  return self._koptions[optname].unavailable ~= self.lang
end

return {
  start=function(self, ...)
    local show_profile, color, categorized, verbose
    local help = function()
      print(self.generator_name .. ' [-h] [-v] [--categorized] [--profile] [--color]')
      return false
    end
    local cli = {
      ['--categorized']=function() categorized=true end,
      ['--profile']=function() show_profile=true end,
      ['--color']=function() color=true end,
      ['-v']=function() verbose=true end,
      ['-h']=help,
      ['--help']=help,
    }
    for _,v in ipairs({...}) do
      local opt = cli[v]
      if not opt then
        return help()
      end
      if opt() == false then
        return false
      end
    end

    local push_opt_for_print, opt_for_print_end
    if categorized then
      local categorized_opts = {}
      for k,infos in ipairs(self._opts_by_category) do
        local i = #categorized_opts + 1
        categorized_opts[i] = {infos[1], {}}
        for k,optname in ipairs(infos[2]) do
          categorized_opts[optname] = i
        end
      end
      local other_cat = #categorized_opts + 1
      categorized_opts[other_cat] = {'Other', {}}

      push_opt_for_print = function(option, str, desc)
        local strings = categorized_opts[categorized_opts[option.name] or other_cat][2]
        table_insert(strings, str)
        if verbose and desc then
          table_insert(strings, '  ' .. desc)
        end
      end

      opt_for_print_end = function()
        local strings = {}
        local first = true
        for k,infos in ipairs(categorized_opts) do
          if #infos[2] ~= 0 then
            if not first then
              table_insert(strings, '')
            end
            table_insert(strings, color and ('\027[1m# ' .. infos[1] .. '\027[0m:\n')
                                         or ('# ' .. infos[1] .. ':\n'))
            first = false
            for k,str in ipairs(infos[2]) do
              table_insert(strings, str)
            end
          end
        end
        print(table.concat(strings, '\n'))
      end
    else
      push_opt_for_print = function(option, str, desc)
        print(str)
        if verbose and desc then
          print('  ' .. desc)
        end
      end
      opt_for_print_end = function() end
    end

    local add_opt = function(option)
      knwon_opts[option.name] = {option.kvalues}
    end

    if color then
      local color_map = {
        on='\027[32m',
        off='\027[31m',
        default='\027[37m',
      }
      color_map[0] = '\027[34m'
      color_map[1] = '\027[35m'
      local color_size = 2
      for option in self:getoptions() do
        local str, ic = option.name .. ' \027[37m=', 0
        for i,x in ipairs(option.ordered_values) do
          local c = color_map[x]
          if not c then
            c = color_map[ic % color_size]
            ic = ic + 1
          end
          str = str .. ' ' .. (i == 1
            and (c:sub(0,-2) .. ';7m' .. x .. '\027[0m')
            or (c .. x))
        end
        push_opt_for_print(option, str .. '\027[0m',
                           option.description and ('\027[37m' .. option.description .. '\027[0m'))
        add_opt(option)
      end
    else
      for option in self:getoptions() do
        push_opt_for_print(option, option.name .. ' = '
                           .. table.concat(option.ordered_values, ' '),
                           option.description)
        add_opt(option)
      end
    end

    opt_for_print_end()

    if show_profile then
      print('\n\nProfiles:')
      table.sort(self._opts_build_type)
      for name, opts in self:getbuildtype() do
        print('\n' .. name)
        for i,xs in ipairs(opts) do
          print(' - ' .. xs[1] .. ' = ' .. xs[2])
        end
      end
    end
  end,

  resetopt=function(self, optname)
    local known = knwon_opts[optname]
    if not known then
      if is_available(self, optname) then
        table_insert(errors, '_koptions[' .. optname .. ']: unknown key')
      end
    end
  end,

  startoptcond=function(self, optname)
    local known = knwon_opts[optname]
    if not known then
      if is_available(self, optname) then
        table_insert(errors, '_koptions[' .. optname .. ']: unknown key')
      end
    else
      known[2] = true
    end
  end,

  startcond=function(self, x, optname)
    if x.lvl then
      local known = knwon_opts[optname]
      if not known then
        if is_available(self, optname) then
          table_insert(errors, '_koptions[' .. optname .. ']: unknown key')
        end
      elseif not known[1][x.lvl] then
        table_insert(errors, '_koptions[' .. optname .. ']: unknown value: ' .. x.lvl)
      else
        known[2] = true
      end
    elseif x._not then
      self:startcond(x._not, optname)
    else
      local sub = x._and or x._or
      if sub then
        for k,y in ipairs(sub) do
          self:startcond(y, optname)
        end
      end
    end
  end,

  stop=function(self)
    for k,opts in pairs(knwon_opts) do
      if not opts[2] then
        table_insert(errors, '_koptions[' .. k .. ']: not used in the tree')
      end
    end
    if #errors ~= 0 then
      error(table.concat(errors, '\n'))
    end
  end,

  cxx=without_space_or_error,
  link=without_space_or_error,
  act=function() return true end,
}
