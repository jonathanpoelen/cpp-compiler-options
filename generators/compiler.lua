return {
  -- ignore={ },

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
              versions_by_compiler[comp][intversion] = {x.version[1], x.version[2], comp..vers, comp}
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

              -- add a lower version to those tested
              -- vers(2) { ... } / { ... } -> version 2 and 1.99
              local minimal_comp = comp_vers[2][1]
              if minimal_comp[2] == 0 then
                names[#names+1] = minimal_comp[4] .. '-'
                              .. (minimal_comp[1] - 1) .. '.0'
              else
                names[#names+1] = minimal_comp[4] .. '-'
                              .. minimal_comp[1] .. '.'
                              .. (minimal_comp[2] - 1)
              end

              for k,d in ipairs(comp_vers[2]) do
                names[#names+1] = d[3]
              end
            else
              names[#names+1] = comp_vers[1]
            end
          end

          return table.concat(names, '\n') .. '\n'
        end,

        act=function() return true end
      }
    end

    local opts = {}

    for k,args,default_value in _:getoptions() do
      if default_value ~= 'default' then
        opts[k] = default_value
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
      for k,v in pairs(opts) do
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
    local major, minor
    do
      local t, version = {}
      compiler, version = compiler:match('([^%d]+)(.*)')
      compiler = compiler:gsub('^g%+%+','gcc'):gsub('^clang%+%+', 'clang'):gsub('-$','')
      version:gsub('[%w_]+', function(x) t[#t+1]=x end)
      major = t[1] and tonumber(t[1]) or 999
      minor = t[2] and tonumber(t[2]) or 999
    end

    local cli_opts = {...}
    if #cli_opts ~= 0 then
      t = {}
      local concat_opts = false
      for k,v in ipairs(cli_opts) do
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
            opts[name] = (lvl or true)
            concat_opts = true
          elseif f == '-' then
            opts[name] = false
            concat_opts = true
          else
            t[name] = (lvl or true)
          end
        end)
      end

      if concat_opts then
        for k,v in pairs(t) do
          opts[k] = v
        end
      elseif t then
        opts = t
      end
    end

    local current_optname
    local flags = {}
    return {
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

            if v._or  then return _:_cond(v._or, true)
        elseif v._and then return _:_cond(v._and, false)
        elseif v._not then return not _:cond(v._not)
        elseif v.lvl  then return v.lvl == opts[current_optname]
        elseif v.version then return major > v.version[1]
                                  or (major == v.version[1] and minor >= v.version[2])
        elseif v.compiler then return compiler == v.compiler
        elseif v.linker or v.linker_version then return false
        end

        local ks = ''
        for k,_ in pairs(v) do
          ks = ks .. k .. ', '
        end
        error('Unknown cond ' .. ks)
      end,

      startcond=function(_, x, optname)
        current_optname = optname
        return _:cond(x)
      end,

      startoptcond=function(_, optname)
        return opts[optname] and true or false
      end,

      stop=function(_)
        local l = {}
        for k,v in pairs(flags) do
          l[#l+1] = k
        end

        if #l ~= 0 then
          table.sort(l)
          return table.concat(l, '\n') .. '\n'
        end

        return ''
      end,

      cxx=function(_, x) flags[x] = true end,
      link=function(_, x) flags[x] = true end,

      act=function(_, name, datas)
        for _,k in ipairs({'cxx','link'}) do
          for _,x in ipairs(datas[k] or {}) do
            flags[x] = true
          end
        end
        return true
      end,
    }
  end,
}
