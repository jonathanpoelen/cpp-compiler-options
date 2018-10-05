#!/usr/bin/env lua
local cond_mt = {
  __call = function(_, x)
    if _._t then error('`t` is not nil') end
    _._t = x
    return _
  end,
  __div = function(_, x)
    local t = _._else
    if t then t[#t+1] = x
    else _._else = {x} end
    return _
  end,
  __mul = function(_, x)
    local t = _._c or _._t
    t[#t+1] = x
    _._c = x._t
    return _
  end,
  __unm = function(_)
    return setmetatable({ _not=_, _t=_._t }, cond_mt)
  end,
}

local comp_mt = {
  __call = function(_, x_or_major, minor)
    if type(x_or_major) == 'number' then
      return setmetatable({ _and = { { compiler=_.compiler }, { version={x_or_major, minor or 0} } } }, cond_mt)
    else
      return setmetatable({ compiler=_.compiler, _t=x_or_major }, cond_mt)
    end
  end,
  __div = function(_, x)
    return _({}) / x
  end,
  __mul = function(_, x)
    return _({}) * x
  end,
}

function compiler(name) return setmetatable({ compiler=name }, comp_mt) end

local gcc = compiler('gcc')
local clang = compiler('clang')
function vers(major, minor) return setmetatable({ version={major, minor or 0} }, cond_mt) end
function def(x) return { def=x } end
function cxx(x) return { cxx=x } end
function link(x) return { link=(x:sub(1,1) == '-' and x or '-l'..x) } end
function fl(x) return { cxx=x, link=x } end
function lvl(x) return setmetatable({ lvl=x }, cond_mt) end
function opt(x) return setmetatable({ opt=x }, cond_mt) end
function hasopt(x) return setmetatable({ hasopt=x }, cond_mt) end
function Or(...) return setmetatable({ _or={...} }, cond_mt) end

-- gcc and clang
-- g++ -Q --help=optimizers,warnings,target,params,common,undocumented,joined,separate,language__ -O3
G = Or(gcc, clang) {
  opt'lto' {
    fl'-flto', -- clang -flto=thin
    gcc(5) {
      fl'-flto-odr-type-merging', -- increases size of LTO object files, but enables diagnostics about ODR violations
      lvl'fat' {
        cxx'-ffat-lto-objects',
      },
    },
  },

  opt'coverage' {
    cxx'--coverage', -- -fprofile-arcs -ftest-coverage
    link'--coverage', -- -lgcov
    clang {
      link'-lprofile_rt',
      -- fl'-fprofile-instr-generate',
      -- fl'-fcoverage-mapping',
    },
  },

  opt'debug' { cxx'-g' },

  opt'fast_math' { cxx'-ffast-math', },

  opt'optimize' {
    lvl'on'    { cxx'-O2' } /
    lvl'off'   { cxx'-O0' } /
    lvl'size'  { cxx'-Os' } /
    lvl'speed' { cxx'-O3' } /
    lvl'full'  { cxx'-O3', cxx'-march=native' },
  },

  opt'pedantic' {
    cxx'-pedantic',
    lvl'as_error' {
      cxx'-pedantic-errors',
    },
  },

  opt'stack_protector' {
    def'_FORTIFY_SOURCE=2',
    cxx'-Wstack-protector',
    fl'-fstack-protector',
    lvl'strong' {
      -gcc(-4,9) {
        fl'-fstack-protector-strong',
      },
    } /
    lvl'all' {
      fl'-fstack-protector-all',
    },
  },

  opt'relro' {
    lvl'off' { link'-Wl,-z,norelro', } /
    lvl'on'  { link'-Wl,-z,relro', } /
    lvl'full'{ link'-Wl,-z,relro,-z,now', },
  },

  opt'suggests' {
    gcc {
      cxx'-Wsuggest-attribute=pure',
      cxx'-Wsuggest-attribute=const',
    }*
    vers(5) {
      cxx'-Wsuggest-final-types',
      cxx'-Wsuggest-final-methods',
   -- cxx'-Wsuggest-attribute=format',
    }*
    vers(5,1) {
      cxx'-Wnoexcept',
    },
  },

  opt'stl_debug' {
    def'_LIBCPP_DEBUG=1',
    lvl'assert_as_exception' {
      def'_LIBCPP_DEBUG_USE_EXCEPTIONS'
    },
    lvl'allow_broken_abi' {
      def'_GLIBCXX_DEBUG',
    } / {
      def'_GLIBCXX_ASSERTIONS',
    },
    hasopt'pedantic' {
      def'_GLIBCXX_DEBUG_PEDANTIC'
    },
  },

  opt'warnings' {
    gcc {
      cxx'-Wall',
      cxx'-Wextra',
      cxx'-Wcast-align',
      cxx'-Wcast-qual',
      cxx'-Wdisabled-optimization',
      cxx'-Wfloat-equal',
      cxx'-Wformat-security',
      cxx'-Wformat-signedness',
      cxx'-Wformat=2',
      cxx'-Wmissing-declarations',
      cxx'-Wmissing-include-dirs',
      cxx'-Wnon-virtual-dtor',
      cxx'-Wold-style-cast',
      cxx'-Woverloaded-virtual',
   -- cxx'-Weffc++',
      cxx'-Wpacked',
      cxx'-Wredundant-decls',
      cxx'-Wundef',
      cxx'-Wuninitialized',
      cxx'-Wunused-macros',
      cxx'-Wvla',
   -- cxx'-Winline',
   -- cxx'-Wswitch-default',
   -- cxx'-Wswitch-enum',
    }*

    vers(4,7) {
      cxx'-Wsuggest-attribute=noreturn',
      cxx'-Wzero-as-null-pointer-constant',
      cxx'-Wlogical-op',
   -- cxx'-Wno-aggressive-loop-optimizations',
   -- cxx'-Wnormalized=nfc',
      cxx'-Wvector-operation-performance',
      cxx'-Wdouble-promotion',
      cxx'-Wtrampolines', -- C only with a nested function ?
    }*

    vers(4,8) {
      cxx'-Wuseless-cast',
    }*

    vers(4,9) {
      cxx'-Wconditionally-supported',
      cxx'-Wfloat-conversion',
      cxx'-Wopenmp-simd',
    }*

    vers(5,1) {
      cxx'-fsized-deallocation',
      cxx'-Warray-bounds=2', -- This option is only active when -ftree-vrp is active (default for -O2 and above). level=1 enabled by -Wall.
      cxx'-Wconditionally-supported',
   -- cxx'-Wctor-dtor-privacy',
      cxx'-Wsized-deallocation',
      cxx'-Wstrict-null-sentinel',
      cxx'-Wsuggest-override',
    }*

    vers(6,1) {
      cxx'-Wduplicated-cond',
      cxx'-Wnull-dereference', -- This option is only active when -fdelete-null-pointer-checks is active, which is enabled by optimizations in most targets.
    }*

    vers(7) {
      cxx'-Waligned-new',
    }*

    vers(7,1) {
      cxx'-Walloc-zero',
      cxx'-Walloca',
      cxx'-Wformat-overflow', -- =level
   -- cxx'-Wformat-truncation=1', -- enabled by -Wformat. Works best with -O2 and higher. =2 = calls to bounded functions whose return value is used
   -- cxx'-Wformat-y2k', -- strftime formats that may yield only a two-digit year.
      cxx'-Wshadow=compatible-local', -- global (default), local, compatible-local
    }*

    vers(8) {
      cxx'-Wclass-memaccess',
    },

    clang {
      cxx'-Weverything',
   -- cxx'-Wno-documentation-unknown-command',
   -- cxx'-Wno-range-loop-analysis',
   -- cxx'-Wno-disabled-macro-expansion',
      cxx'-Wno-c++98-compat',
      cxx'-Wno-c++98-compat-pedantic',
      cxx'-Wno-mismatched-tags',
      cxx'-Wno-padded',
      cxx'-Wno-shadow',
      cxx'-Wno-global-constructors',
      cxx'-Wno-weak-vtables',
      cxx'-Wno-exit-time-destructors',
      cxx'-Wno-covered-switch-default',
   -- cxx'-Qunused-arguments',
      cxx'-Wno-switch-default',
      cxx'-Wno-switch-enum',
      cxx'-Wno-inconsistent-missing-destructor-override',
    },

    lvl'strict' {
      cxx'-Wconversion',
      gcc(8) { cxx'-Wcast-align=strict', }
    } /
    clang {
      cxx'-Wno-conversion',
      cxx'-Wno-sign-conversion',
    },
  },

  opt'sanitizers' {
    clang {
      vers(3,1) {
        fl'-fsanitize=undefined',
        fl'-fsanitize=address', -- memory, thread are mutually exclusive
        cxx'-fsanitize-address-use-after-scope',
        cxx'-fno-omit-frame-pointer',
        cxx'-fno-optimize-sibling-calls',
      }*
      vers(3,4) {
        fl'-fsanitize=leak', -- requires the address sanitizer
      }*
      vers(6) {
        fl'-fsanitize=bounds',
      },
    } /
    -- gcc
    {
      vers(4,8) {
        fl'-fsanitize=address', -- memory, thread are mutually exclusive
        cxx'-fno-omit-frame-pointer',
        cxx'-fno-optimize-sibling-calls',
      }*
      vers(4,9) {
        fl'-fsanitize=undefined',
        fl'-fsanitize=leak', -- requires the address sanitizer
      }*
      vers(6) {
        cxx'-fsanitize=bounds',
        cxx'-fsanitize=bounds-strict',
      }
    },
  },

  opt'sanitizers_extra' {
    lvl'thread' { cxx'-fsanitize=thread', } /
    lvl'pointer' {
      gcc(8) {
        -- By default the check is disabled at run time.
        -- To enable it, add "detect_invalid_pointer_pairs=2" to the environment variable ASAN_OPTIONS.
        -- Using "detect_invalid_pointer_pairs=1" detects invalid operation only when both pointers are non-null.
        -- These options cannot be combined with -fsanitize=thread and/or -fcheck-pointer-bounds
        -- ASAN_OPTIONS=detect_invalid_pointer_pairs=2
        -- ASAN_OPTIONS=detect_invalid_pointer_pairs=1
        cxx'-fsanitize=pointer-compare',
        cxx'-fsanitize=pointer-subtract',
      }
    }
  },

  opt'report_template' {
    gcc(8) {
      cxx'-fno-elide-type',
      cxx'-fdiagnostics-show-template-tree',
    },
    clang(3,4) {
      cxx'-fno-elide-type',
    },
  },

  opt'color' {
    Or(gcc(4,9), clang) {
      lvl'auto' { cxx'-fdiagnostics-color=auto' } /
      lvl'never' { cxx'-fdiagnostics-color=never' } /
      lvl'always' { cxx'-fdiagnostics-color=always' },
    },
  },

  opt'warnings_as_error' { cxx'-Werror', },
}

function noop() end

function fopt(t)
  local u = { }
  for _, v in ipairs(t[2]) do u[v] = true end
  if not u[t[1]] then
    error('_opts integrity error: disable value ' .. t[1] .. ' is not used')
  end
  t[3] = u
  return t
end

function fopts(t)
  local r = {}
  for k,v in pairs(t) do
    r[k] = fopt(v)
  end
  return r
end

Vbase = {
  _incidental={
    color=true,
    pedantic=true,
    suggests=true,
    warnings=true,
    warnings_as_error=true,
    report_template=true,
  },

  _opts=fopts{
    stack_protector={'off', {'off', 'on', 'strong', 'all'}},
    relro={'default', {'default', 'off', 'on', 'full'}},
    lto={'off', {'off', 'on', 'fat'}},
    fast_math={'off', {'off', 'on'}},
    optimize={'default', {'default', 'off', 'on', 'size', 'speed', 'full'}},
    coverage={'off', {'off', 'on'}},
    pedantic={'off', {'on', 'off', 'as_error'}},
    debug={'off', {'off', 'on'}},
    stl_debug={'off', {'off', 'on', 'allow_broken_abi', 'assert_as_exception'}},
    sanitizers={'off', {'off', 'on'}},
    sanitizers_extra={'off', {'off', 'thread', 'pointer'}},
    suggests={'off', {'off', 'on'}},
    warnings={'off', {'on', 'off', 'strict'}},
    report_template={'off', {'off', 'on'}},
    warnings_as_error={'off', {'off', 'on'}},
    color={'default', {'default', 'auto', 'never', 'always'}},
  },

  indent = '',
  if_prefix = '',
  ignore={},

  start=noop, -- function(_) end,
  stop=function(_) return _:get_output() end,

  _strs={},
  print=function(_, s) _:write(s) ; _:write('\n') end,
  write=function(_, s) _._strs[#_._strs+1] = s end,
  get_output=function(_) return table.concat(_._strs) end,

  startopt=noop, -- function(_, name) end,
  stopopt=noop, -- function(_) end,

  startcond=noop, -- function(_, x, optname) end,
  elsecond=noop, -- function(_, optname) end,
  markelseif=noop, -- function() end,
  stopcond=noop, -- function(_, optname) end,

  cxx=noop,
  link=noop,
  define=noop,

  _vcond_init=function(_, keywords)
    _._vcondkeyword = keywords or {}
    for k,v in pairs({
     _or = '||',
     _and = '&&',
     _not = '!',
     _if = 'if',
     _else = 'else',
     open = '(',
     close = ')',
     openblock = '{',
     closeblock = '}',
    }) do
      if not _._vcondkeyword[k] then
        _._vcondkeyword[k] = v
      end
    end
    _._vcondkeyword.ifopen = _._vcondkeyword.ifopen or _._vcondkeyword.open
    _._vcondkeyword.ifclose = _._vcondkeyword.ifclose or _._vcondkeyword.close
    _._vcondkeyword.else_of_else_if = _._vcondkeyword.else_of_else_if or (_._vcondkeyword._else .. ' ')
    _._vcondkeyword.endif = _._vcondkeyword.endif or _._vcondkeyword.closeblock
    if #_._vcondkeyword.ifopen ~= 0 then _._vcondkeyword.ifopen = ' ' .. _._vcondkeyword.ifopen .. ' ' end
    if #_._vcondkeyword.ifclose ~= 0 then _._vcondkeyword.ifclose = ' ' .. _._vcondkeyword.ifclose end

    _._vcond=function(_, v, optname)
          if v._or      then _:write(' '.._._vcondkeyword.open) ; _:_vcond(v._or[1]) ; _:write(' '.._._vcondkeyword._or) _:_vcond(v._or[2]) ; _:write(' '.._._vcondkeyword.close)
      elseif v._and     then _:write(' '.._._vcondkeyword.open) ; _:_vcond(v._and[1]); _:write(' '.._._vcondkeyword._and) _:_vcond(v._and[2]); _:write(' '.._._vcondkeyword.close)
      elseif v._not     then _:write(' '.._._vcondkeyword._not) ; _:_vcond(v._not);
      elseif v.lvl      then _:write(' '.._:_vcond_lvl(v.lvl, optname))
      elseif v.version  then
        if v.version[1] < 0 then _:write(' '.._:_vcond_verless(-v.version[1], v.version[2]))
        else                     _:write(' '.._._vcondkeyword._not..' '.._._vcondkeyword.open..' '.._:_vcond_verless(v.version[1], v.version[2])..' '.._._vcondkeyword.close) end
      elseif v.compiler then _:write(' '.._:_vcond_comp(v.compiler))
      elseif v.hasopt   then _:write(' '.._:_vcond_hasopt(v.hasopt))
      else error('Unknown cond ', ipairs(v))
      end
    end

    _._vcond_hasopt=function(_, optname) return _._vcondkeyword._not..' '.._._vcondkeyword.open..' '.._:_vcond_lvl(_._opts[optname][1], optname).._._vcondkeyword.close end

    _.startopt=function(_, optname)
      _:_vcond_printflags()
      _:print(_.indent .. _._vcondkeyword._if .. _._vcondkeyword.ifopen .. ' ' .. _:_vcond_hasopt(optname) .. _._vcondkeyword.ifclose)
      if _._vcondkeyword.openblock then
        _:print(_.indent .. _._vcondkeyword.openblock)
      end
    end

    _.stopopt=function(_)
      _:_vcond_printflags()
      if _._vcondkeyword.endif then
        _:print(_.indent .. _._vcondkeyword.endif)
      end
    end

    _.startcond=function(_, x, optname)
      _.indent = _.indent:sub(1, #_.indent-2)
      _:_vcond_printflags()
      _.indent = _.indent .. '  '
      _:write(_.indent .. _.if_prefix .. _._vcondkeyword._if .. _._vcondkeyword.ifopen)
      _.if_prefix = ''
      _:_vcond(x, optname)
      _:print(_._vcondkeyword.ifclose)
      if #_._vcondkeyword.openblock then
        _:print(_.indent .. _._vcondkeyword.openblock)
      end
    end

    _.elsecond=function(_)
      _:_vcond_printflags()
      if #_._vcondkeyword.closeblock then
        _:print(_.indent .. _._vcondkeyword.closeblock)
      end
      _:print(_.indent .. _._vcondkeyword._else)
      if #_._vcondkeyword.openblock then
        _:print(_.indent .. _._vcondkeyword.openblock)
      end
    end

    _.markelseif=function(_)
      _:_vcond_printflags()
      if #_._vcondkeyword.closeblock then
        _:print(_.indent .. _._vcondkeyword.closeblock)
      end
      _.if_prefix = _._vcondkeyword.else_of_else_if
    end

    _.stopcond=function(_)
      _:_vcond_printflags()
      if #_._vcondkeyword.endif then
        _:print(_.indent .. _._vcondkeyword.endif)
      end
    end

    _._vcond_flags_cxx = ''
    _._vcond_flags_link = ''
    _._vcond_flags_define = ''
    _._vcond_printflags=function(_)
      if #_._vcond_flags_cxx ~= 0 or #_._vcond_flags_link ~= 0 or #_._vcond_flags_define ~= 0 then
        local s = _:_vcond_toflags(_._vcond_flags_cxx, _._vcond_flags_link, _._vcond_flags_define)
        if s and #s ~= 0 then _:print(s) end
      end
      _._vcond_flags_cxx = ''
      _._vcond_flags_link = ''
      _._vcond_flags_define = ''
    end

    local accu=function(k, f)
      return function(_, x)
        _[k] = _[k] .. f(_, x)
      end
    end

    _.cxx = accu('_vcond_flags_cxx', _.cxx)
    _.link = accu('_vcond_flags_link', _.link)
    _.define = accu('_vcond_flags_define', _.define)
  end,

  -- iterator: optname,args,disable_value
  getoptions=function(_)
    local ordered_keys = {}

    for k in pairs(_._opts) do
      table.insert(ordered_keys, k)
    end

    table.sort(ordered_keys)
    local i = 0

    return function()
      if i == #ordered_keys then
        return nil
      end
      i = i + 1
      local k = ordered_keys[i]
      local v = _._opts[k]
      return k, v[2], v[1]
    end
  end,
}

function is_cond(t)
  return t.lvl or t._or or t._and or t._not or t.hasopt or t.compiler or t.version
end

function evalflags(t, v, curropt, no_stopcond)
  if is_cond(t) then
    if t.lvl and not v._opts[curropt][3][t.lvl] then
       error('Unknown lvl "' .. t.lvl .. '" in ' .. curropt)
    end
    local r = v:startcond(t, curropt)
    if r ~= false and t._t then
      v.indent = v.indent .. '  '
      evalflags(t._t, v, curropt)
      v.indent = v.indent:sub(1, #v.indent-2)
    end
    if r ~= true and t._else then
      local n = #t._else
      for k,x in ipairs(t._else) do
        mark_elseif = (k ~= n or is_cond(x))
        if mark_elseif then
          v:markelseif()
          evalflags(x, v, curropt, mark_elseif)
        else
          v:elsecond(curropt)
          v.indent = v.indent .. '  '
          evalflags(x, v, curropt, mark_elseif)
          v.indent = v.indent:sub(1, #v.indent-2)
        end
      end
    end
    if not no_stopcond then
      v:stopcond(curropt)
    end
  elseif t.opt then
    if not v._opts[t.opt] then
      error('Unknown "' .. t.opt .. '" option')
    end
    if not v.ignore[t.opt] and v:startopt(t.opt) ~= false then
      v.indent = v.indent .. '  '
      evalflags(t._t, v, t.opt)
      v.indent = v.indent:sub(1, #v.indent-2)
      v:stopopt(t.opt)
    end
  elseif t.cxx or t.link or t.def then
    if t.cxx  then v:cxx(t.cxx, curropt) end
    if t.link then v:link(t.link, curropt) end
    if t.def  then v:define(t.def, curropt) end
  else
    for k,x in ipairs(t) do
      evalflags(x, v, curropt)
    end
  end
end

function insert_missing_function(V)
  for k,mem in pairs(Vbase) do
    if not V[k] then
      V[k] = mem
    end
  end
end

function run(generaton_name, ...)
  if not generaton_name or generaton_name == '-h' or generaton_name == '--help' then
    local out = generaton_name and io.stdout or io.stderr
    out:write(arg[0] .. ' {generator.lua} [-h|{options}...]\n')
    if not generaton_name then
      out:write('Missing generator file\n')  
      os.exit(1)
    end
    return
  end
  local V = require(generaton_name:gsub('.lua$', ''))
  insert_missing_function(V)

  local r = V:start(...)
  if r == false then
    os.exit(1)
  elseif type(r) == 'number' then
    os.exit(r)
  elseif r ~= nil and r ~= V then
    V = r
    insert_missing_function(V)
  end

  for k,mem in pairs(V.ignore) do
    if not Vbase._opts[k] then
      error('Unknown ' .. k .. ' in ignore table')
    end
  end

  evalflags(G, V)

  local out = V:stop()
  if out then io.write(out) end
end

run(...)
