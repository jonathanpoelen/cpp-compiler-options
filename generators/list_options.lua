local known_opts = {}
local errors = {}

local _color_map = {
  '\027[34m',
  '\027[35m',
  -- specific color for certain values
  on='\027[32m',
  off='\027[31m',
  default='\027[37m',
}
local color_size = 2
local _color_reset = '\027[0m'
local _color_reverse = ';7m'
local _color_sep = '\027[37m'
local _color_desc = '\027[37m'
local _color_cat = '\027[1m'

local table_insert = table.insert

local function add_opt(option)
  known_opts[option.name] = {option.kvalues}
end

local without_space_otherwise_error = function(self, s)
  if s:find(' ') then
    table_insert(errors, '"' .. s .. '" contains a space')
  end
end

local is_available = function(self, optname)
  return self._koptions[optname].unavailable ~= self.lang
end

return {
  start=function(self, ...)
    -- cli options
    local show_profile, colorize, categorized, verbose

    -- cli and parse
    -- @{
    local cli = {
      ['--categorized']=function() categorized=true end,
      ['--profile']=function() show_profile=true end,
      ['--color']=function() colorize=true end,
      ['--verbose']=function() verbose=true end,
      ['-v']=function() verbose=true end,
    }

    for _,v in ipairs({...}) do
      local opt = cli[v]
      if not opt then
        local f = (v == '-h' or v == '--help') and io.stdout or io.stderr
        f:write(self.generator_name .. ' [{-h | --help] [{-v | --verbose}] [--categorized] [--profile] [--color]\n')
        f:flush()
        return false
      end
      opt()
    end
    -- @}

    -- reset table, populated with add_opt()
    known_opts = {}

    local color_map = colorize and _color_map or ''
    local color_reset = colorize and _color_reset or ''
    local color_reverse = colorize and _color_reverse or ''
    local color_sep = colorize and _color_sep or ''
    local color_desc = colorize and _color_desc or ''

    local string_parts = {}
    -- {opt_name: string = [string, used: bool]}
    local stringify_options = {}

    -- init option

    local icolor, desc
    local color = ''
    for option in self:getoptions() do
      add_opt(option)

      -- option name

      table_insert(string_parts, option.name)
      if not verbose then
        table_insert(string_parts, ' ')
        table_insert(string_parts, color_sep)
        table_insert(string_parts, '=')
      else
        table_insert(string_parts, '\n')
      end

      -- option description

      if verbose and option.description then
        table_insert(string_parts, '  ')
        table_insert(string_parts, color_desc)
        table_insert(string_parts, option.description)
        table_insert(string_parts, color_reset)
        table_insert(string_parts, '\n')
      end

      -- option values

      icolor = 0
      for i,opt_value in ipairs(option.ordered_values) do
        if colorize then
          color = color_map[x]
          if not color then
            color = color_map[icolor % color_size + 1]
            icolor = icolor + 1
          end
        end

        -- value seperator

        if verbose then
          desc = option.value_descriptions[i]
          table_insert(string_parts, color_desc)
          table_insert(string_parts, '  - ')
        else
          table_insert(string_parts, ' ')
        end

        -- value name

        if i == 1 then
          table_insert(string_parts, color:sub(0,-2))
          table_insert(string_parts, color_reverse)
          table_insert(string_parts, opt_value)
          table_insert(string_parts, color_reset)
        else
          table_insert(string_parts, color)
          table_insert(string_parts, opt_value)
        end

        -- value description

        if desc then
          table_insert(string_parts, ': ')
          table_insert(string_parts, color_desc)
          table_insert(string_parts, desc)
        end
        if verbose then
          table_insert(string_parts, '\n')
        end
      end

      -- option seperation

      if not verbose then
        table_insert(string_parts, '\n')
      end
      table_insert(string_parts, color_reset)

      if categorized then
        stringify_options[option.name] = {table.concat(string_parts)}
        string_parts = {}
      end
    end

    -- init categories

    if categorized then
      local color_cat = colorize and _color_cat or ''
      local opt

      local push_title = function(name)
        table_insert(string_parts, color_cat)
        table_insert(string_parts, '# ')
        table_insert(string_parts, name)
        table_insert(string_parts, color_reset)
        table_insert(string_parts, ':\n\n')
      end

      -- populate categories

      string_parts = {}
      for _,infos in ipairs(self._opts_by_category) do
        push_title(infos[1])
        table.sort(infos[2])
        for _,optname in ipairs(infos[2]) do
          opt = stringify_options[optname]
          opt[2] = true
          table_insert(string_parts, opt[1])
        end
        table_insert(string_parts, '\n')
      end

      -- populate "Other" category

      push_title('Other')
      for option in self:getoptions() do -- getoptions() is always sorted
        opt = stringify_options[option.name]
        if not opt[2] then
          table_insert(string_parts, opt[1])
        end
      end
    end

    -- populate profile

    if show_profile then
      table_insert(string_parts, '\n\nProfiles:\n')
      for name, opts in self:getbuildtype() do
        table_insert(string_parts, '\n' .. name)
        for _,xs in ipairs(opts) do
          table_insert(string_parts, '\n - ' .. xs[1] .. ' = ' .. xs[2])
        end
      end
      table_insert(string_parts, '\n')
    end

    -- print

    if show_profile then
      io.stdout:write('Options:\n\n')
    end

    io.stdout:write(table.concat(string_parts))
    io.stdout:flush()
  end,

  resetopt=function(self, optname)
    local known = known_opts[optname]
    if not known then
      if is_available(self, optname) then
        table_insert(errors, '_koptions[' .. optname .. ']: unknown key')
      end
    end
  end,

  startoptcond=function(self, optname)
    local known = known_opts[optname]
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
      local known = known_opts[optname]
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
        for _,y in ipairs(sub) do
          self:startcond(y, optname)
        end
      end
    end
  end,

  stop=function()
    for k,opts in pairs(known_opts) do
      if not opts[2] then
        table_insert(errors, '_koptions[' .. k .. ']: not used in the tree')
      end
    end
    if #errors ~= 0 then
      error(table.concat(errors, '\n'))
    end
  end,

  cxx=without_space_otherwise_error,
  link=without_space_otherwise_error,
  act=function() return true end,
}
