return {
  d = {comp={}, test={true}, opts={}},

  ignore={
  },

  indent = '',

  start=function(_, compiler, ...)
    -- list compilers
    if not compiler then
      -- compilers for current depth
      local stackcomp = {{}}
      -- compiler used in current if
      local stackifcomp = {{}}
      local versions_by_compiler = {}

      return {
        -- currcomp = {kcompilers, has_comp:bool}
        _startcond=function(_, x, currcomp)
          if x.compiler then
            versions_by_compiler[x.compiler] = versions_by_compiler[x.compiler] or {}
            currcomp[1][x.compiler] = true
            currcomp[2] = true
            return {[x.compiler]=true}
          elseif x.version then
            local vers = '-' .. x.version[1] .. '.' .. x.version[2]
            for comp in pairs(currcomp[2] and currcomp[1] or stackcomp[#stackcomp]) do
              local intversion = x.version[1] * 1000000 + x.version[2]
              versions_by_compiler[comp][intversion] = {x.version[1], x.version[2], comp..vers}
            end
          elseif x._not then
            return _:_startcond(x._not, currcomp)
          else
            local sub = x._and or x._or
            if sub then
              local compilers = {}
              local has_value

              currcomp = {{}, false}
              for k,y in ipairs(sub) do
                for comp in pairs(_:_startcond(y, currcomp) or {}) do
                  compilers[comp] = true
                  has_value = true
                end
              end

              return has_value and compilers
            end
          end
        end,

        stopcond=function(_)
          stackcomp[#stackcomp] = nil
          stackifcomp[#stackifcomp] = nil
        end,

        startoptcond=function(_)
          stackcomp[#stackcomp+1] = stackcomp[#stackcomp]
          stackifcomp[#stackifcomp+1] = false
        end,

        startcond=function(_, x)
          local r = _:_startcond(x, {{}, false})
          stackifcomp[#stackifcomp+1] = r or false
          stackcomp[#stackcomp+1] = r or stackcomp[#stackcomp]
        end,

        elsecond=function(_)
          -- exclude `if` compilers from the parent's active compilers
          if stackifcomp[#stackifcomp] then
            local old = stackifcomp[#stackifcomp]
            local new = {}
            for comp in pairs(stackcomp[#stackcomp-1]) do
              if not old[comp] then
                new[comp] = true
              end
            end
            stackcomp[#stackcomp] = new
          end
        end,

        stop=function(_)
          local comps = {}
          for comp, t in pairs(versions_by_compiler) do
            local versions = {}
            if comp == 'clang-cl' then
              -- assume than minimal version is 8.0
              for vers, d in pairs(t) do
                if d[1] >= 8 then
                  versions[#versions+1] = d
                end
              end
              if #versions <= 1 then
                comp = 'clang-cl'
                versions = {}
              end
            else
              for vers, d in pairs(t) do
                versions[#versions+1] = d
              end
            end
            comps[#comps+1] = {comp, versions}
          end

          -- sort by name
          table.sort(comps, function(a,b) return a[1] < b[1] end)

          local names = {}
          for k,comp_vers in ipairs(comps) do
            if #comp_vers[2] ~= 0 then
              -- sort by version
              table.sort(comp_vers[2], function(a,b)
                return a[1] < b[1]
                    or a[1] == b[1] and a[2] < b[2]
              end)
              for k,d in ipairs(comp_vers[2]) do
                names[#names+1] = d[3]
              end
            else
              names[#names+1] = comp_vers[1]
            end
          end

          return table.concat(names, '\n') .. '\n'
        end,
      }
    end

    for k,args,default_value in _:getoptions() do
      if default_value ~= 'default' then
        _.d.opts[k] = default_value
      end
    end

    -- help
    local is_help = function(s)
      return s == 'h' or s =='-h' or s == 'help' or s == '--help'
    end
    local has_help = is_help(compiler)
    if not has_help then
      for k,v in pairs({...}) do
        has_help = is_help(v)
        if has_help then
          break
        end
      end
    end
    if has_help then
      print(_.generator_name .. ' [-h] | [ {compiler|compiler-version} [[{+|-}]{option}[={level}] ...]] ]')
      print('\nsample:\n  ' .. _.generator_name .. ' gcc warnings=strict')
      print('\nBy default:')
      local lines={}
      for k,v in pairs(_.d.opts) do
        lines[#lines+1] = '  ' .. k .. '=' .. v
      end
      table.sort(lines)
      print(table.concat(lines, '\n'))
      lines={}
      print('\nOptions:')
      for k,args in _:getoptions() do
        lines[#lines+1] = '  ' .. k .. ' = ' .. table.concat(args, ', ')
      end
      print(table.concat(lines, '\n'))
      return 0
    end

    -- list options
    local t = _.d.comp
    local version
    compiler, version = compiler:match('([^%d]+)(.*)')
    t[1] = compiler:gsub('^g%+%+','gcc'):gsub('^clang%+%+', 'clang'):gsub('-$','')
    version:gsub('[%w_]+', function(x) t[#t+1]=x end)
    t[2] = t[2] and tonumber(t[2]) or 999
    t[3] = t[3] and tonumber(t[3]) or 999
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

          local opt_args = _._opts_krev[name]
          if not opt_args then
            error('Unknown `' .. name .. '` option')
          end

          if #lvl == 0 then
            lvl = 'on'
          end

          if not opt_args[lvl] or lvl == 'default' then
            error('Unknown value `' .. lvl .. '` in ' .. name)
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

  startoptcond=function(_, name)
    _.d.opt = name
    return _.d.opts[name] and true or false
  end,

  _cond=function(_, v, r)
    for k,x in ipairs(v) do
      if _:cond(x) == r then
        return r
      end
    end
    return not r
  end,

  cond=function(_, v)
    -- for k,x in pairs(v) do
    --   if k == 'version' then
    --     print(k, x[1],x[2])
    --   else
    --     print(k, x)
    --   end
    -- end

    local r = true
        if v._or  then r = _:_cond(v._or, true)
    elseif v._and then r = _:_cond(v._and, false)
    elseif v._not then r = not _:cond(v._not)
    elseif v.lvl  then
      if _.d.opts then
        r = v.lvl == _.d.opts[_.d.opt]
      end
    elseif v.version then
      -- print(table.concat(_.d.comp,'.'), table.concat(v.version,'.'))
      r = _.d.comp[2] > v.version[1] or (_.d.comp[2] == v.version[1] and _.d.comp[3] >= v.version[2])
    elseif v.compiler then r = _.d.comp[1] == v.compiler
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
    -- print('>')
    local r = _:cond(x)
    -- print('---',r)
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
      -- print(x)
    end
  end,
  link=function(_, x) _:cxx(x) end,
}
