return {
  d = {comp={}, test={true}, opts={}},

  ignore={
  },

  indent = '',

  start=function(_, compiler, ...)
    -- list compilers
    if not compiler then
      local currcomps = {}
      local stackcomp = {}
      local versions_by_compiler = {}

      return {
        _startcond=function(_, x, compilers, versions)
          if x.compiler then
            compilers[#compilers+1] = x.compiler
          elseif x.version then
            versions[#versions+1] = (x.version[1] < 0 and -x.version[1] or x.version[1])
                                 .. '.' .. x.version[2]
          elseif x._not then
            _:_startcond(x._not, compilers, versions)
          else
            local sub = x._and or x._or
            if sub then
              for k,y in pairs(sub) do
                _:_startcond(y, compilers, versions)
              end
            end
          end
        end,

        stopcond=function(_)
          currcomps = stackcomp[#stackcomp]
        end,

        startcond=function(_, x)
          local compilers, versions = {}, {}
          _:_startcond(x, compilers, versions)

          if #compilers == 0 then
            compilers = currcomps
          end

          currcomps = compilers
          stackcomp[#stackcomp+1] = compilers
          for k,comp in ipairs(compilers) do
            local kversions = versions_by_compiler[comp]
            if not kversions then
              kversions = {}
              versions_by_compiler[comp] = kversions
            end

            for k,vers in ipairs(versions) do
              kversions[#kversions+1] = vers
            end
          end
        end,

        stop=function(_)
          local kcomps = {}
          for comp,versions in pairs(versions_by_compiler) do
            if #versions == 0 then
              kcomps[comp] = true
            else
              for k,version in ipairs(versions) do
                kcomps[comp .. '-' .. version] = true
              end
            end
          end

          local comps = {}
          for k in pairs(kcomps) do
            comps[#comps+1] = k
          end

          table.sort(comps)
          return table.concat(comps, '\n') .. '\n'
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

  startopt=function(_, name)
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
