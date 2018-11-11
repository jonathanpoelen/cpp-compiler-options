return {
  d = {comp={}, test={true}, opts={
    stl_debug='allow_broken_abi',
    debug='on',
    pedantic='on',
    sanitizers='on',
    suggests='on',
    warnings='on',
  }},

  ignore={
  },

  indent = '',

  start=function(_, compiler, ...)
    -- list compilers
    if not compiler then
      return {
        t = {},
        comp = nil,

        startcond=function(_, x)
          if x.compiler then
            _.comp = x.compiler
          end
          if x.version then
            _.t[#_.t+1] = _.comp .. '-' .. (x.version[1] < 0 and -x.version[1] or x.version[1]) .. '.' .. x.version[2]
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
          local t = {}
          for k,v in ipairs(_.t) do
            t[v] = v
          end

          _.t = {}
          for k,v in pairs(t) do
            _.t[#_.t+1] = v
          end

          table.sort(_.t)
          return table.concat(_.t, '\n') .. '\n'
        end,
      }
    end

    -- help
    local is_help = function(s)
      return s == 'h' or s =='-h' or s == 'help' or s == '--help'
    end
    local has_help = is_help(compiler)
    if not has_help then
      for k,v in pairs(arg) do
        has_help = is_help(v)
        if has_help then
          break
        end
      end
    end
    if has_help then
      print(arg[0] .. ' [-h] | [ {compiler|compiler-version} [[{+|-}]{option}[={level}] ...]] ]')
      print('\nsample:\n  ' .. arg[0] .. ' ' .. arg[1] .. ' gcc warnings=strict')
      print('\nBy default:')
      local lines={}
      for k,v in pairs(_.d.opts) do
        lines[#lines+1] = '  ' .. k .. '=' .. v
      end
      table.sort(lines)
      print(table.concat(lines, '\n'))
      lines={}
      print('\nOptions:')
      for k,v in pairs(_._opts) do
        lines[#lines+1] = '  ' .. k .. ' = ' .. table.concat(v[2], ', ')
      end
      table.sort(lines)
      print(table.concat(lines, '\n'))
      return 0
    end

    -- list options 
    local t = _.d.comp
    compiler:gsub('^g++','gcc'):gsub('^clang++', 'clang'):gsub('%w+', function(x) t[#t+1]=x end)
    t[2] = t[2] and tonumber(t[2]) or 999
    t[3] = t[3] and tonumber(t[3]) or 999
    t[4] = t[4] and tonumber(t[4]) or 999
    local opts = {...}
    if #opts ~= 0 then
      t = {}
      local concat_opts = false
      for k,v in ipairs(opts) do
        v:gsub('([%-+]?)([%w%-_]+)=?(.*)', function(f, name, lvl)
              if name == 'warn' or name == 'warning' then name = 'warnings'
          elseif name == 'san' or name == 'sanitizer' then name = 'sanitizers'
          elseif name == 'error' then name = 'warnings_as_error'
          else name = name:gsub('-', '_')
          end
          if not _._opts[name] then
            error('Unknown `' .. name .. '` option')
          end
          if f == '+' then
            _.d.opts[name] = (lvl or true)
            concat_opts = true
          elseif f == '-' then
            _.d.opts[name] = false
            concat_opts = true
          else
            t[name] = (lvl or true)
          end
        end)
      end
      if concat_opts then
        for k,v in pairs(t) do
          _.d.opts[k] = v
        end
      elseif t then
        _.d.opts = t
      end
    end
  end,

  stop=function(_)
    -- remove duplications
    if #_._strs ~= 0 then
      local t = {}
      for k,v in ipairs(_._strs) do
        t[v] = true
      end
      local l = {}
      for k,v in pairs(t) do
        l[#l+1] = k
      end      
      table.sort(l)
      return table.concat(l, '\n') .. '\n'
    end
    return ''
  end,

  startopt=function(_, name)
    _.d.opt = name
    return _.d.opts[name] and true or false
  end,

  stopopt=function(_)
  end,

  cond=function(_, v)
    local r = true
        if v._or  then r = _:cond(v._or[1]) or _:cond(v._or[2])
    elseif v._and then r = _:cond(v._and[1]) and _:cond(v._and[2])
    elseif v._not then r = not _:cond(v._not)
    elseif v.lvl  then
      if _.d.opts then
        r = v.lvl == _.d.opts[_.d.opt]
      else
        r = v.lvl == 'GLIBCXX_ALLOW_BROKEN_ABI'
      end
    elseif v.version  then
      -- _.d.condtype.version = v.version
      if v.version[1] < 0 then
        r = _.d.comp[2] < -v.version[1] or _.d.comp[3] < v.version[2]
      else
        r = _.d.comp[2] > v.version[1] or (_.d.comp[2] == v.version[1] and _.d.comp[3] >= v.version[2])
      end
    elseif v.compiler then r = _.d.comp[1] == v.compiler
    elseif v.hasopt   then r = not _.d.opts or (_.d.opts[v.hasopt] and true or false)
    else
      local ks = ''
      for k,_ in pairs(v) do
        ks = ks .. k .. ', '
      end
      error('Unknown cond ' .. ks)
    end
    return r
  end,

  startcond=function(_, x)
    _.d.condtype = {}
    local r = _:cond(x)
    -- if r and _.d.condtype.version then
    --   _:print('#  ' .. _.d.comp[1] .. '-' .. _.d.condtype.version[1] .. '.' .. _.d.condtype.version[2] .. '.' .. _.d.condtype.version[3])
    -- end
    _.d.test[#_.d.test+1] = r
    return r
  end,

  elsecond=function(_)
    _.d.test[#_.d.test] = not _.d.test[#_.d.test]
  end,

  stopcond=function(_)
    _.d.test[#_.d.test] = nil
  end,

  cxx=function(_, x)
    if _.d.test[#_.d.test] then
      _:write(x)
    end
  end,
  link=function(_, x) _:cxx(x) end,
  define=function(_, x) _:cxx('-D'..x) end,
}
