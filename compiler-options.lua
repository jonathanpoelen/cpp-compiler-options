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
  __unm = function(_)
    return -_({})
  end,
}

function compiler(name) return setmetatable({ compiler=name }, comp_mt) end

local gcc = compiler('gcc')
local clang = compiler('clang')
local msvc = compiler('msvc')
function vers(major, minor) return setmetatable({ version={major, minor or 0} }, cond_mt) end
function lvl(x) return setmetatable({ lvl=x }, cond_mt) end
function opt(x) return setmetatable({ opt=x }, cond_mt) end
function Or(...) return setmetatable({ _or={...} }, cond_mt) end
function And(...) return setmetatable({ _and={...} }, cond_mt) end

function link(x) return { link=(x:match('^[-/]') and x or '-l'..x) } end
function flag(x) return { cxx=x } end
function fl(x) return { cxx=x, link=x } end
function noop() end

function MakeAST(is_C)

local c, cxx
if is_C then
  c = flag
  cxx = noop
else
  c = noop
  cxx = flag
end

-- opt'build' ? -pipe Avoid temporary files, speeding up builds

-- gcc and clang
-- g++ -Q --help=optimizers,warnings,target,params,common,undocumented,joined,separate,language__ -O3
-- https://clang.llvm.org/docs/DiagnosticsReference.html
-- https://github.com/llvm-mirror/clang/blob/master/include/clang/Driver/Options.td
-- https://github.com/llvm-mirror/clang/blob/master/include/clang/Basic/Diagnostic.td
return Or(gcc, clang) {
  opt'fix_compiler_error' {
    lvl'on' {
      gcc {
        vers(4,7) { cxx'-Werror=narrowing' } *
        vers(7,1) { cxx'-Werror=literal-suffix' } -- no warning name before 7.1
      },
      flag'-Werror=write-strings'
    } /
    clang {
      flag'-Wno-error=c++11-narrowing',
      flag'-Wno-reserved-user-defined-literal',
    }
  },

  opt'coverage' {
    lvl'on' {
      flag'--coverage', -- -fprofile-arcs -ftest-coverage
      link'--coverage', -- -lgcov
      clang {
        link'-lprofile_rt',
        -- fl'-fprofile-instr-generate',
        -- fl'-fcoverage-mapping',
      },
    },
  },

  opt'debug' {
    lvl'off' { flag '-g0' } /
    lvl'gdb' { flag '-ggdb' } /
    clang {
      lvl'line_tables_only' { flag'-gline-tables-only' },
      lvl'lldb' { flag '-glldb' } /
      lvl'sce' { flag '-gsce' } /
      flag'-g'
    } /
    flag'-g',
    -- flag'-fasynchronous-unwind-tables', -- Increased reliability of backtraces
  },

  opt'linker' {
    lvl'native' {
      gcc { link'-fuse-ld=gold' } /
      link'-fuse-ld=lld'
    } /
    lvl'bfd' { link'-fuse-ld=bfd' } /
    Or(lvl'gold', -gcc(9)) { link'-fuse-ld=gold' } /
    link'-fuse-ld=lld',
  },

  opt'lto' {
    lvl'off' {
      fl'-fno-lto',
    } / 
    gcc {
      fl'-flto',
      vers(5) {
        opt'warnings' {
          -lvl'off' { fl'-flto-odr-type-merging' }, -- increases size of LTO object files, but enables diagnostics about ODR violations
        },
        lvl'fat' { flag'-ffat-lto-objects', },
        lvl'linker_plugin' { link'-fuse-linker-plugin' }
      }
    } /
    And(lvl'linker_plugin', clang(6)) { fl'-flto=thin' } /
    fl'-flto',
  },

  opt'optimization' {
    lvl'0'     { fl'-O0' } /
    lvl'g' { fl'-Og' } / {
      flag'-DNDEBUG',
      lvl'size' { fl'-Os' } /
      lvl'fast' { fl'-Ofast' } /
      lvl'1' { fl'-O1' } /
      lvl'2' { fl'-O2' } /
      lvl'3' { fl'-O3' }
    }
  },

  opt'cpu' {
    lvl'generic' { fl'-mtune=generic' } /
    { fl'-march=native', fl'-mtune=native', }
  },

  opt'whole_program' {
    lvl'off' {
      flag'-fno-whole-program',
      clang(3,9) { fl'-fno-whole-program-vtables' }
    } /
    {
      link'-s',
      lvl'strip_all'{
        link'-Wl,--gc-sections',
        link'-Wl,--strip-all',
      },
      gcc {
        fl'-fwhole-program'
      } / {
        clang(3,9) {
          opt'lto'{
            -lvl'off' {
              fl'-fwhole-program-vtables'
            }
          }
        }*    
        vers(7) {
          fl'-fforce-emit-vtables',
        }
      }
    }
  },

  opt'pedantic' {
    -lvl'off' {
      flag'-pedantic',
      lvl'as_error' {
        flag'-pedantic-errors',
      },
    },
  },

  opt'stack_protector' {
    lvl'off' {
      fl'-Wno-stack-protector',
      flag'-U_FORTIFY_SOURCE'
    } /
    {
      flag'-D_FORTIFY_SOURCE=2',
      flag'-Wstack-protector',
      lvl'strong' {
        gcc(4,9) {
          fl'-fstack-protector-strong',
        } /
        clang {
          fl'-fstack-protector-strong',
          fl'-fsanitize=safe-stack',
        }
      } /
      lvl'all' {
        fl'-fstack-protector-all',
        clang {
          fl'-fsanitize=safe-stack',
        }
      } /
      fl'-fstack-protector',
    },
  },

  opt'relro' {
    lvl'off' { link'-Wl,-z,norelro', } /
    lvl'on'  { link'-Wl,-z,relro', } /
    lvl'full'{ link'-Wl,-z,relro,-z,now', },
  },

  opt'pie' {
    lvl'off'{ link'-no-pic', } /
    lvl'on' { link'-pie', } /
    lvl'pic'{ flag'-fPIC', },
  },

  opt'suggestions' {
    -lvl'off' {
      gcc {
        flag'-Wsuggest-attribute=pure',
        flag'-Wsuggest-attribute=const',
      }*
      vers(5) {
        cxx'-Wsuggest-final-types',
        cxx'-Wsuggest-final-methods',
     -- flag'-Wsuggest-attribute=format',
      }*
      vers(5,1) {
        flag'-Wnoexcept',
      },
    },
  },

  opt'stl_debug' {
    -lvl'off' {
      lvl'assert_as_exception' {
        cxx'-D_LIBCPP_DEBUG_USE_EXCEPTIONS'
      },
      Or(lvl'allow_broken_abi', lvl'allow_broken_abi_and_bugs') {
        clang {
          -- debug allocator has a bug: https://bugs.llvm.org/show_bug.cgi?id=39203
          Or(vers(8), lvl'allow_broken_abi_and_bugs') {
            cxx'-D_LIBCPP_DEBUG=1',
          },
        },
        cxx'-D_GLIBCXX_DEBUG',
      }
      / cxx'-D_GLIBCXX_ASSERTIONS',
      opt'pedantic' {
        -lvl'off' {
          cxx'-D_GLIBCXX_DEBUG_PEDANTIC'
        },
      },
    },
  },

  opt'shadow_warnings' {
    lvl'off' { flag'-Wno-shadow', clang(8) { flag'-Wno-shadow-field' } } /
    lvl'on' { flag'-Wshadow' } /
    lvl'all' {
      clang { flag'-Wshadow-all', } /
      flag'-Wshadow'
    } /
    gcc(7,1) {
      lvl'local' {
        flag'-Wshadow=local'
      } /
      lvl'compatible_local' {
        flag'-Wshadow=compatible-local'
      }
    }
  },

  opt'warnings' {
    lvl'off' {
      flag'-w'
    } / {
      gcc {
        flag'-Wall',
        flag'-Wextra',
        flag'-Wcast-align=strict',
        flag'-Wcast-qual',
        flag'-Wdisabled-optimization',
        flag'-Wfloat-equal',
        flag'-Wformat-security',
        flag'-Wformat=2',
        flag'-Wmissing-declarations',
        flag'-Wmissing-include-dirs',
     -- flag'-Weffc++',
        flag'-Wpacked',
        flag'-Wredundant-decls',
        flag'-Wundef',
        flag'-Wunused-macros',
     -- flag'-Winline',
     -- flag'-Wswitch-default',
     -- flag'-Wswitch-enum',
        flag'-Winvalid-pch',
        flag'-Wpointer-arith',
        cxx'-Wnon-virtual-dtor',
        cxx'-Wold-style-cast',
        cxx'-Woverloaded-virtual',
        c'-Wbad-function-cast',
        c'-Winit-self', -- enabled by -Wall in C++
        c'-Wjump-misses-init',
        c'-Wmissing-prototypes',
        c'-Wnested-externs',
        c'-Wold-style-definition',
        c'-Wstrict-prototypes',
        c'-Wwrite-strings',
      }*

      vers(4,7) {
        flag'-Wsuggest-attribute=noreturn',
        cxx'-Wzero-as-null-pointer-constant',
        flag'-Wlogical-op',
     -- flag'-Wno-aggressive-loop-optimizations',
     -- flag'-Wnormalized=nfc',
        flag'-Wvector-operation-performance',
        flag'-Wdouble-promotion',
        flag'-Wtrampolines', -- C only with a nested function ?
      }*

      vers(4,8) {
        cxx'-Wuseless-cast',
      }*

      vers(4,9) {
        cxx'-Wconditionally-supported',
        flag'-Wfloat-conversion',
      }*

      vers(5,1) {
        flag'-Wformat-signedness',
        flag'-Warray-bounds=2', -- This option is only active when -ftree-vrp is active (default for -O2 and above). level=1 enabled by -Wall.
        flag'-Wconditionally-supported',
     -- flag'-Wctor-dtor-privacy',
        cxx'-Wstrict-null-sentinel',
        cxx'-Wsuggest-override',
      }*

      vers(6,1) {
        flag'-Wduplicated-cond',
        flag'-Wnull-dereference', -- This option is only active when -fdelete-null-pointer-checks is active, which is enabled by optimizations in most targets.
      }*

      vers(7) {
        cxx'-Waligned-new',
      }*

      vers(7,1) {
        flag'-Walloc-zero',
        flag'-Walloca',
        flag'-Wformat-overflow=2',
     -- flag'-Wformat-truncation=1', -- enabled by -Wformat. Works best with -O2 and higher. =2 = calls to bounded functions whose return value is used
     -- flag'-Wformat-y2k', -- strftime formats that may yield only a two-digit year.
        flag'-Wduplicated-branches',
      }*

      vers(8) {
        cxx'-Wclass-memaccess',
      }

      / clang {
        flag'-Weverything',
     -- flag'-Wno-documentation-unknown-command',
     -- flag'-Wno-range-loop-analysis',
     -- flag'-Wno-disabled-macro-expansion',
        cxx'-Wno-c++98-compat',
        cxx'-Wno-c++98-compat-pedantic',
        flag'-Wno-mismatched-tags',
        flag'-Wno-padded',
        flag'-Wno-global-constructors',
        cxx'-Wno-weak-vtables',
        cxx'-Wno-exit-time-destructors',
        flag'-Wno-covered-switch-default',
     -- cxx'-Qunused-arguments',
        flag'-Wno-switch-default',
        flag'-Wno-switch-enum',
        vers(3,9) {
          cxx'-Wno-undefined-var-template',
        },
        vers(5) {
          cxx'-Wno-inconsistent-missing-destructor-override',
        },
      },

      Or(lvl'strict', lvl'very_strict') {
        flag'-Wconversion',
        gcc(8) { flag'-Wcast-align=strict', }
      } /
      clang {
        flag'-Wno-conversion',
        flag'-Wno-sign-conversion',
      },
    },
  },

  opt'sanitizers' {
    lvl'off' {
      fl'-fno-sanitize=all'
    } / {
      clang {
        vers(3,1) {
          fl'-fsanitize=undefined',
          fl'-fsanitize=address', -- memory, thread are mutually exclusive
          flag'-fsanitize-address-use-after-scope',
          flag'-fno-omit-frame-pointer',
          flag'-fno-optimize-sibling-calls',
        }*
        vers(3,4) {
          fl'-fsanitize=leak', -- requires the address sanitizer
        },
      } /
      -- gcc
      {
        vers(4,8) {
          fl'-fsanitize=address', -- memory, thread are mutually exclusive
          flag'-fno-omit-frame-pointer',
          flag'-fno-optimize-sibling-calls',
        }*
        vers(4,9) {
          fl'-fsanitize=undefined',
          fl'-fsanitize=leak', -- requires the address sanitizer
        }
      },
    },
  },

  opt'control_flow' {
    lvl'off' {
      gcc(8) { flag'-fcf-protection=none' } /
      clang { fl'-fno-sanitize=cfi' },
    } /
    {
      gcc(8) {
        -- flag'-mcet',
        flag'-fcf-protection=full' --  full|branch|return|none
      } /
      And(lvl'allow_bugs', clang) {
        fl'-fsanitize=cfi', -- cfi-* only allowed with '-flto' and '-fvisibility=...'
        flag'-fvisibility=hidden',
        fl'-flto',
      },
    },
  },

  opt'sanitizers_extra' {
    lvl'thread' { flag'-fsanitize=thread', } /
    lvl'pointer' {
      gcc(8) {
        -- By default the check is disabled at run time.
        -- To enable it, add "detect_invalid_pointer_pairs=2" to the environment variable ASAN_OPTIONS.
        -- Using "detect_invalid_pointer_pairs=1" detects invalid operation only when both pointers are non-null.
        -- These options cannot be combined with -fsanitize=thread and/or -fcheck-pointer-bounds
        -- ASAN_OPTIONS=detect_invalid_pointer_pairs=2
        -- ASAN_OPTIONS=detect_invalid_pointer_pairs=1
        flag'-fsanitize=pointer-compare',
        flag'-fsanitize=pointer-subtract',
      }
    }
  },

  opt'reproducible_build_warnings' {
    gcc(4,9) {
      lvl'on' { flag'-Wdate-time' } / flag'-Wno-date-time'
    }
  },

  opt'color' {    
    Or(gcc(4,9), clang) {
      lvl'auto' { flag'-fdiagnostics-color=auto' } /
      lvl'never' { flag'-fdiagnostics-color=never' } /
      lvl'always' { flag'-fdiagnostics-color=always' },
    },
  },

  opt'elide_type' {
    lvl'on' {
     gcc(8) { cxx'-felide-type' }
    } /
    Or(gcc(8), clang(3,4)) {
      cxx'-fno-elide-type',
    },
  },

  opt'exceptions' {
    lvl'on' { flag'-fexceptions', } / flag'-fno-exceptions',
  },

  opt'rtti' {
    lvl'on' { cxx'-frtti' } / cxx'-fno-rtti',
  },

  opt'diagnostics_show_template_tree' {
    Or(gcc(8), clang) {
      lvl'on' { cxx'-fdiagnostics-show-template-tree' } / cxx'-fno-diagnostics-show-template-tree',
    },
  },

  opt'diagnostics_format' {
    lvl'fixits' {
      Or(gcc(7), clang(5)) {
        flag'-fdiagnostics-parseable-fixits'
      }
    } /
    lvl'patch' {
      gcc(7) { flag'-fdiagnostics-generate-patch' }
    } /
    lvl'print_source_range_info' {
      clang { flag'-fdiagnostics-print-source-range-info' }
    }
  },

  opt'warnings_as_error' {
    lvl'on' { flag'-Werror', } /
    lvl'basic' {
      flag'-Werror=non-virtual-dtor',
      flag'-Werror=return-type',
      flag'-Werror=init-self',
      gcc(5,1) {
        flag'-Werror=array-bounds',
        flag'-Werror=logical-op',
        flag'-Werror=logical-not-parentheses',
      } /
      clang {
        flag'-Werror=array-bounds',
        flag'-Werror=division-by-zero',
        vers(3,4) {
          flag'-Werror=logical-not-parentheses',
        }*
        vers(3,6) {
          flag'-Werror=delete-incomplete',
        }*
        vers(7) {
          flag'-Werror=dynamic-class-memaccess',
        }
      }
    } /
    flag'-Wno-error',
  }
} /

-- https://docs.microsoft.com/en-us/cpp/build/reference/linker-options?view=vs-2019
-- https://docs.microsoft.com/en-us/cpp/build/reference/compiler-options-listed-alphabetically?view=vs-2019
msvc {
  opt'stl_fix' {
    lvl'on' { flag'/DNOMINMAX', },
  },

  opt'debug' {
    lvl'off' { flag'/DEBUG:NONE' } / {
      flag'/RTC1',
      flag'/Od',
      lvl'on' { flag'/DEBUG' } / -- /DEBUG:FULL
      lvl'line_tables_only' { flag'/DEBUG:FASTLINK' },
      opt'optimization' { lvl'g' { flag'/Zi' } / flag'/ZI' } / flag'/ZI',
    }
  },

  opt'exceptions'{
    lvl'on' { flag'/EHc' } / { flag'/EHc-' }
  },

  opt'optimization' {
    lvl'0' { flag'/Ob0 /Od /Oi- /Oy-' } /
    lvl'g' { flag'/Ob1' } / {
      flag'/DNDEBUG',
      -- /O1 = /Og      /Os  /Oy /Ob2 /GF /Gy
      -- /O2 = /Og /Oi  /Ot  /Oy /Ob2 /GF /Gy
      lvl'1' { flag'/01', } /
      lvl'2' { flag'/O2', link'/OPT:REF', } /
      lvl'3' { flag'/O2', link'/OPT:REF', } /
      lvl'size' { flag'/O1', link'/OPT:REF', flag'/Gw' } /
      lvl'fast' { flag'/O2', link'/OPT:REF', flag'/fp:fast' }
    }
  },

  opt'lto' {
    lvl'off' { flag'/LTCG:OFF' } /
    { flag'/GL', link'/LTCG' }
  },

  opt'whole_program' {
    lvl'off' { flag'/GL-' } /
    { flag'/GL', flag'/Gw', link'/LTCG' }
  },

  opt'pedantic' {
    -lvl'off' {
      flag'/permissive-', -- implies /Zc:rvaluecast, /Zc:strictstrings, /Zc:ternary, /Zc:twoPhase
      cxx'/Zc:__cplusplus',
      -- cxx'/Zc:throwingNew',
    }
  },

  opt'rtti' {
    lvl'on' { flag'/GR' } / { flag'/GR-' }
  },

  opt'stl_debug' {
    lvl'off' { 
      flag'/D_HAS_ITERATOR_DEBUGGING=0'
    } / {
      flag'/D_DEBUG', -- set by /MDd /MTd or /LDd
      flag'/D_HAS_ITERATOR_DEBUGGING=1',
    }
  },

  opt'control_flow' {
    lvl'off' { flag'/guard:cf-', } /
    flag'/guard:cf',
  },

  opt'sanitizers' {
    lvl'on' {
      flag'/sdl',
    } /
    opt'stack_protector' {
      -lvl'off' { flag'/sdl-' },
    },
  },

  opt'stack_protector' {
    -lvl'off' {
      flag'/GS',
      flag'/sdl',
      lvl'strong' { flag'/RTC1', } / -- /RTCsu
      lvl'all' { flag'/RTC1', flag'/RTCc', },
    },
  },

  opt'shadow_warnings' {
    lvl'off' {
      flag'/wd4456', flag'/wd4459'
    } /
    Or(lvl'on', lvl'all') {
      flag'/w4456', flag'/w4459'
    } /
    lvl 'local' {
      flag'/w4456', flag'/wd4459'
    }
  },

  opt'warnings' {
    lvl'on' { flag'/W4', flag'/wd4244', flag'/wd4245' } /
    lvl'strict' { flag'/Wall', flag'/wd4820', flag'/wd4514', flag'/wd4710' } /
    lvl'very_strict' { flag'/Wall' } /
    lvl'off' { flag'/W0' },
  },

  opt'warnings_as_error' {
    lvl'on' { fl'/WX' } /
    lvl'off' { flag'/WX-' }
  },
}
end -- MakeAST

function create_ordered_keys(t)
  local ordered_keys = {}

  for k in pairs(t) do
    ordered_keys[#ordered_keys + 1] = k
  end

  table.sort(ordered_keys)
  return ordered_keys
end

function unpack_table_iterator(t)
  local i = 0
  return function()
    i = i + 1
    return unpack(t[i])
  end
end

Vbase = {
  _incidental={
    color=true,
    diagnostics_format=true,
    diagnostics_show_template_tree=true,
    elide_type=true,
    linker=true,
    reproducible_build_warnings=true,
    shadow_warnings=true,
    suggestions=true,
    warnings=true,
    warnings_as_error=true,
  },

  _opts={
    color=      {{'auto', 'never', 'always'},},
    control_flow={{'off', 'on', 'allow_bugs'},},
    coverage=   {{'off', 'on'},},
    cpu=        {{'generic', 'native'},},
    debug=      {{'off', 'on', 'line_tables_only', 'gdb', 'lldb', 'sce'},},
    diagnostics_format={{'fixits', 'patch', 'print_source_range_info'},},
    diagnostics_show_template_tree={{'off', 'on'},},
    elide_type= {{'off', 'on'},},
    exceptions= {{'off', 'on'},},
    linker=     {{'bfd', 'gold', 'lld', 'native'},},
    lto=        {{'off', 'on', 'fat', 'linker_plugin'},},
    fix_compiler_error={{'off', 'on'}, 'on'},
    optimization={{'0', 'g', '1', '2', '3', 'fast', 'size'},},
    pedantic=   {{'off', 'on', 'as_error'}, 'on'},
    pie=        {{'off', 'on', 'pic'},},
    relro=      {{'off', 'on', 'full'},},
    reproducible_build_warnings={{'off', 'on'},},
    rtti=       {{'off', 'on'},},
    stl_debug=  {{'off', 'on', 'allow_broken_abi', 'allow_broken_abi_and_bugs', 'assert_as_exception'},},
    stl_fix=    {{'off', 'on'}, 'on'},
    sanitizers= {{'off', 'on'},},
    sanitizers_extra={{'off', 'thread', 'pointer'},},
    shadow_warnings={{'off', 'on', 'local', 'compatible_local', 'all'}, 'off'},
    stack_protector={{'off', 'on', 'strong', 'all'},},
    suggestions={{'off', 'on'},},
    warnings=   {{'off', 'on', 'strict', 'very_strict'}, 'on'},
    warnings_as_error={{'off', 'on', 'basic'},},
    whole_program={{'off', 'on', 'strip_all'},},
  },

  _opts_build_type={
    debug={debug='on', stl_debug='on', control_flow='on', sanitizers='on'},
    release={cpu='native', linker='native', lto='on', optimization='2',},
    debug_optimized={linker='native', lto='on', optimization='g', debug='on',},
    minimum_size_release={cpu='native', linker='native', lto='on', optimization='size',},
  },

  indent = '',
  if_prefix = '',
  ignore={},

  start=noop, -- function(_) end,
  stop=function(_, filebase) return _:get_output() end,

  _strs={},
  print=function(_, s) _:write(s) _:write('\n') end,
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

    local write_logical=function(_,a,k,optname)
      _:write(' '.._._vcondkeyword.open)
      _:_vcond(a[1], optname)
      for i=2,#a do
        _:write(' '..k)
        _:_vcond(a[i], optname)
      end
      _:write(' '.._._vcondkeyword.close)
    end

    _._vcond=function(_, v, optname)
          if v._or      then write_logical(_, v._or, _._vcondkeyword._or, optname)
      elseif v._and     then write_logical(_, v._and, _._vcondkeyword._and, optname)
      elseif v._not     then _:write(' '.._._vcondkeyword._not) ; _:_vcond(v._not, optname);
      elseif v.lvl      then _:write(' '.._:_vcond_lvl(v.lvl, optname))
      elseif v.version  then _:write(' '.._._vcondkeyword._not..' '.._._vcondkeyword.open..' '.._:_vcond_verless(v.version[1], v.version[2])..' '.._._vcondkeyword.close)
      elseif v.compiler then _:write(' '.._:_vcond_comp(v.compiler))
      else error('Unknown cond ', ipairs(v))
      end
    end

    _._vcond_hasopt = _._vcond_hasopt or function(_, optname)
      return _._vcondkeyword._not..' '.._._vcondkeyword.open..' '.._:_vcond_lvl('default', optname).._._vcondkeyword.close
    end

    _.startopt=function(_, optname)
      _:_vcond_printflags()
      _:print(_.indent .. _._vcondkeyword._if .. _._vcondkeyword.ifopen .. ' ' .. _:_vcond_hasopt(optname) .. _._vcondkeyword.ifclose)
      if #_._vcondkeyword.openblock ~= 0 then
        _:print(_.indent .. _._vcondkeyword.openblock)
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
      if #_._vcondkeyword.openblock ~= 0 then
        _:print(_.indent .. _._vcondkeyword.openblock)
      end
    end

    _.elsecond=function(_)
      _:_vcond_printflags()
      if #_._vcondkeyword.closeblock ~= 0 then
        _:print(_.indent .. _._vcondkeyword.closeblock)
      end
      _:print(_.indent .. _._vcondkeyword._else)
      if #_._vcondkeyword.openblock ~= 0 then
        _:print(_.indent .. _._vcondkeyword.openblock)
      end
    end

    _.markelseif=function(_)
      _:_vcond_printflags()
      if #_._vcondkeyword.closeblock ~= 0 then
        _:print(_.indent .. _._vcondkeyword.closeblock)
      end
      _.if_prefix = _._vcondkeyword.else_of_else_if
    end

    _.stopcond=function(_)
      _:_vcond_printflags()
      if #_._vcondkeyword.endif ~= 0 then
        _:print(_.indent .. _._vcondkeyword.endif)
      end
    end

    _._vcond_flags_cxx = ''
    _._vcond_flags_link = ''
    _._vcond_printflags=function(_)
      if #_._vcond_flags_cxx ~= 0 or #_._vcond_flags_link ~= 0 then
        local s = _:_vcond_toflags(_._vcond_flags_cxx, _._vcond_flags_link)
        if s and #s ~= 0 then _:write(s) end
      end
      _._vcond_flags_cxx = ''
      _._vcond_flags_link = ''
    end

    local accu=function(k, f)
      return function(_, x)
        _[k] = _[k] .. f(_, x)
      end
    end

    _.cxx = accu('_vcond_flags_cxx', _.cxx)
    _.link = accu('_vcond_flags_link', _.link)
  end,

  _computed_options = nil,
  -- iterator: optname,args,default_value,ordered_args
  getoptions=function(_)
    local computed_options = _.__computed_options

    if not computed_options then
      computed_options = {}
      _._computed_options = computed_options
      local ignore = _.ignore

      for i,k in ipairs(create_ordered_keys(_._opts)) do
        if not ignore[k] then
          local v = _._opts[k]
          local ordered_args = v[1]
          local default_value = v[2] or 'default'
          if default_value ~= v[1][1] then
            ordered_args = {default_value}
            for i,arg in ipairs(v[1]) do
              if arg ~= default_value then
                ordered_args[#ordered_args + 1] = arg
              end
            end
          end
          computed_options[#computed_options + 1] = {k, v[1], default_value, ordered_args}
        end
      end
      -- nil value for iterator
      computed_options[#computed_options + 1] = {nil,nil,nil,nil}
    end

    return unpack_table_iterator(computed_options)
  end,

  _computed_build_types = nil,
  getbuildtype=function(_)
    local computed_build_types = _._computed_build_types
    if not computed_build_types then
      computed_build_types = {}
      _._computed_build_types = computed_build_types
      for i,k in pairs(create_ordered_keys(_._opts_build_type)) do
        local values = {}
        local profile = _._opts_build_type[k]
        for i,kv in pairs(create_ordered_keys(profile)) do
          values[#values + 1] = {kv, profile[kv]}
        end
        computed_build_types[#computed_build_types + 1] = {k, values}
      end
      computed_build_types[#computed_build_types + 1] = {nil,nil}
    end

    return unpack_table_iterator(computed_build_types)
  end,
}

local opts_krev = {}
for k,args in pairs(Vbase._opts) do
  local u = {}
  for _, v in ipairs(args[1]) do
    u[v] = true
  end
  if u['default'] then
    error('_opts[' .. k .. '] integrity error: "default" value is used')
  end
  table.insert(args[1], 1, 'default')
  opts_krev[k] = u
  opts_krev[k]['default'] = true
end
Vbase._opts_krev = opts_krev

-- check values of Vbase._opts_build_type
for name,opts in pairs(Vbase._opts_build_type) do
  for k,v in pairs(opts) do
    local u = opts_krev[k]
    if not u then
      error('_opts_build_type['.. name .. '][' .. k .. ']: unknown option')
    end
    if not u[v] then
      error('_opts_build_type['.. name .. '][' .. k .. '] = ' .. v .. ': unknown value')
    end
  end
end


function is_cond(t)
  return t.lvl or t._or or t._and or t._not or t.compiler or t.version
end

function evalflagselse(t, v, curropt)
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

function evalflags(t, v, curropt, no_stopcond)
  if is_cond(t) then
    if t.lvl and not opts_krev[curropt][t.lvl] then
       error('Unknown lvl "' .. t.lvl .. '" in ' .. curropt)
    end
    local r = v:startcond(t, curropt)
    if r ~= false and t._t then
      v.indent = v.indent .. '  '
      evalflags(t._t, v, curropt)
      v.indent = v.indent:sub(1, #v.indent-2)
    end
    if r ~= true and t._else then
      evalflagselse(t, v, curropt)
    end
    if not no_stopcond then
      v:stopcond(curropt)
    end
  elseif t.opt then
    if not v._opts[t.opt] then
      error('Unknown "' .. t.opt .. '" option')
    end
    if not v.ignore[t.opt] then
      local r = v:startopt(t.opt)
      if r ~= false then
        v.indent = v.indent .. '  '
        evalflags(t._t, v, t.opt)
        v.indent = v.indent:sub(1, #v.indent-2)
        v:stopopt(t.opt)
      end
      if r ~= true and t._else then
        evalflagselse(t, v, curropt)
      end
      v:stopcond(t.opt)
    elseif t._else then
      local newt = table.remove(t._else, 1)
      if newt._else then
        error('unimplemented')
      end
      if #t._else == 0 then
        t._else = nil
      else
        newt._else = t._else
      end
      evalflags(newt, v, curropt, no_stopcond)
    end
  elseif t.cxx or t.link then
    if t.cxx  then v:cxx(t.cxx, curropt) end
    if t.link then v:link(t.link, curropt) end
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

function run(is_C, filebase, ignore_options, generator_name, ...)
  local V = require(generator_name:gsub('.lua$', ''))
  insert_missing_function(V)

  for k,mem in pairs(V.ignore) do
    if not Vbase._opts[k] then
      error('Unknown ' .. k .. ' in ignore table')
    end
  end

  for name in pairs(ignore_options) do
    V.ignore[name] = true
  end

  V.is_C = is_C
  V.generator_name = generator_name
  local r = V:start(...)
  if r == false then
    os.exit(1)
  elseif type(r) == 'number' then
    os.exit(r)
  elseif r ~= nil and r ~= V then
    V = r
    insert_missing_function(V)
  end

  evalflags(MakeAST(is_C), V)

  local out = V:stop(filebase)
  if not out then
    return
  end

  local write_file = function(filename, data)
    local outfile, error = io.open(filename, 'w+')
    if outfile then
      outfile, error = outfile:write(data)
    end
    if error then
      io.stderr:write(arg[0] .. ': open("' .. filename .. '"):' .. error)
      os.exit(4)
    end
  end

  if type(out) == 'table' then
    for _,data in pairs(out) do
      if type(data) == 'table' then
        write_file(data[1], data[2])        
      else
        io.write(data)
      end
    end
  elseif filebase then
    write_file(filebase, out)
  else
    io.write(out)
  end
end

function help(out)
  out:write(arg[0] .. ' [-c] [-o filebase] [-f [-]option_list[,...]] {generator.lua} [-h|{options}...]\n\n  -c  Generator for C, not for C++\n')
end

local filebase
local ignore_options = {}
local os_C = false

cli={
  c={function() is_C=true end},
  h={function() help(io.stdout) os.exit(0) end},

  o={arg=true, function(value)
    filebase = (value ~= '-') and value or nil
  end},

  f={arg=true, function(value)
    for name in value:gmatch('([_%w]+)') do
      if not Vbase._opts[name] then
        io.stderr:write(arg[0] .. ": Unknown option: " .. name)
        os.exit(2)
      end
      ignore_options[name] = true
    end
    if value:sub(1,1) ~= '-' then
      local select_options = ignore_options
      ignore_options = {}
      for name in pairs(Vbase._opts) do
        if not select_options[name] then
          ignore_options[name] = true
        end
      end
    end
  end},
}

function getoption(flag)
  local opt = cli[flag]
  if not opt then
    io.stderr:write('Unknown option: -' .. opt .. ' in ' .. s .. '\n')
    os.exit(2)
  end
  return opt
end

i=1
while i <= #arg do
  local s = arg[i]
  if s:sub(1,1) ~= '-' then
    break
  end

  local opt = getoption(s:sub(2,2))
  local ipos = 2
  while not opt.arg do
    opt[1]()
    if #s == ipos then
      break
    end
    ipos = ipos + 1
    opt = getoption(s:sub(ipos, ipos))
  end

  if opt.arg then
    local value
    if #arg[i] ~= ipos then
      value = s:sub(ipos+1)
    else
      i = i+1
      value = arg[i]
      if not value then
        help(io.stderr)
        os.exit(2)
      end
    end
    opt[1](value)
  end

  i = i+1
end

if i > #arg then
  help(io.stderr)
  io.stderr:write('Missing generator file\n')  
  os.exit(1)
end

run(is_C, filebase, ignore_options, select(i, ...))
