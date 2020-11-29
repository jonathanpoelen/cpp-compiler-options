#!/usr/bin/env lua

--[[
local _print_ast_ordered_vars = {
  '_if',
  '_else',
  '_t'
}
local _kprint_ast_var_filter = {
  _t=true,
  _if=true,
  _else=true,
  _subelse=true
}

function printAST(ast, prefix)
  if type(ast) == 'table' then
    io.stdout:write('{\n')
    prefix = prefix or ''
    local newprefix = prefix..'  '

    for _,k in pairs(_print_ast_ordered_vars) do
      if ast[k] then
        io.stdout:write(newprefix..k..': ')
        printAST(ast[k], newprefix)
      end
    end

    for k,x in pairs(ast) do
      if not _kprint_ast_var_filter[k] then
        io.stdout:write(newprefix..k..': ')
        printAST(x, newprefix)
      end
    end
    io.stdout:write(prefix..'}\n')
  elseif ast then
    io.stdout:write(ast..'\n')
  else
    io.stdout:write('nil\n')
  end
  return ast
end
]]


function has_value(t)
  for k in pairs(t) do
    return true
  end
  return false
end

function has_data(x)
  return has_value(x._t) or (x._else and has_value(x._else))
end

function ramify(x)
  if x._if then
    if not has_data(x) then
      x = {}
    end
  else
    for k,y in pairs(x) do
      if y._if and not has_data(y) then
        x[k] = nil
      end
    end
  end
  return x
end

local if_mt = {
  __call = function(_, x)
    assert(not _._t, '`_t` is not nil')

    _._t = ramify(x)
    return _
  end,
  __div = function(_, x)
    local subelse = _._subelse or _
    assert(subelse._if and not subelse._else, 'replace `x / y / z` with `x / { y / z }`')

    x = x and ramify(x)

    _._subelse = x
    subelse._else = x
    return _
  end,
  __unm = function(_)
    assert(_._if, 'not a conditional expression')
    return setmetatable({ _if={_not=_._if}, _t=_._t, _subelse=_._subelse }, if_mt)
  end,
}

local opt_mt = {
  __call = if_mt.__call,
  __div = if_mt.__div,
}

function If(condition)
  return setmetatable({ _if=condition }, if_mt)
end

function Logical(op, ...)
  local conds={}
  for k,x in ipairs({...}) do
    if type(x) == 'function' then
      x = x()
    end
    assert(x._if and not x._t)
    assert(not x._if.opt)
    if x._if[op] then
      for _,cond in ipairs(x._if[op]) do
        conds[#conds+1] = cond
      end
    else
      conds[#conds+1] = x._if
    end
  end
  return If({[op]=conds})
end

function Compiler(name)
  return function(x_or_major, minor)
    if type(x_or_major) == 'number' then
      return If({_and={
        {compiler=name},
        (x_or_major < 0)
        and {_not={version={-x_or_major, minor or 0}}}
        or {version={x_or_major, minor or 0}}
      }})
    else
      local r = If({compiler=name})
      return x_or_major and r(x_or_major) or r
    end
  end
end

function Linker(name)
  return function(x)
    local r = If({linker=name})
    return x and r(x) or r
  end
end

local unpack = table.unpack or unpack

function ToolGroup(...)
  local tools = {...}
  return function(x, y)
    if type(x) == 'number' then
      local t = {}
      for _,tool in ipairs(tools) do
        t[#t+1] = tool(x, y)
      end
      return Or(unpack(t))
    end

    local r = Or(unpack(tools))
    return x and r(x) or r
  end
end

function Or(...) return Logical('_or', ...) end
function And(...) return Logical('_and', ...) end

function vers(major, minor) return If({version={major, minor or 0}}) end
function lvl(x) return If({lvl=x}) end
function opt(x) return If({opt=x}) end

local gcc = Compiler('gcc')
local clang = Compiler('clang')
local clang_cl = Compiler('clang-cl')
local msvc = Compiler('msvc')
local clang_like = ToolGroup(clang, clang_cl)

-- local msvc_linker = Linker('msvc')
local lld_link = Linker('lld-link')
local ld64 = Linker('ld64') -- Apple ld64

function link(x) return { link=(x:match('^[-/]') and x or '-l'..x) } end
function flag(x) return { cxx=x } end
function fl(x) return { cxx=x, link=x } end
function act(id, datas) return { act={id, datas} } end
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
return --[[printAST]] {

-- https://clang.llvm.org/docs/UsersManual.html#id9
Or(gcc, clang_like) {
  opt'warnings' {
    lvl'off' {
      flag'-w'
    } / {
      gcc {
        flag'-Wall',
        flag'-Wextra',
        flag'-Wcast-align',
        flag'-Wcast-qual',
        flag'-Wdisabled-optimization',
        flag'-Wfloat-equal',
        flag'-Wformat-security',
        flag'-Wformat=2',
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
        cxx'-Wmissing-declarations',
        cxx'-Wnon-virtual-dtor',
        cxx'-Wold-style-cast',
        cxx'-Woverloaded-virtual',
        c'-Wbad-function-cast',
        c'-Winit-self', -- enabled by -Wall in C++
        c'-Wjump-misses-init',
        c'-Wnested-externs',
        c'-Wold-style-definition',
        c'-Wstrict-prototypes',
        c'-Wwrite-strings',

        vers(4,7) {
          flag'-Wsuggest-attribute=noreturn',
          cxx'-Wzero-as-null-pointer-constant',
          flag'-Wlogical-op',
       -- flag'-Wno-aggressive-loop-optimizations',
       -- flag'-Wnormalized=nfc',
          flag'-Wvector-operation-performance',
          flag'-Wdouble-promotion',
          flag'-Wtrampolines', -- C only with a nested function ?

          vers(4,8) {
            cxx'-Wuseless-cast',

            vers(4,9) {
              cxx'-Wconditionally-supported',
              flag'-Wfloat-conversion',

              vers(5,1) {
                flag'-Wformat-signedness',
                flag'-Warray-bounds=2', -- This option is only active when -ftree-vrp is active (default for -O2 and above). level=1 enabled by -Wall.
             -- flag'-Wctor-dtor-privacy',
                cxx'-Wstrict-null-sentinel',
                cxx'-Wsuggest-override',

                vers(6,1) {
                  flag'-Wduplicated-cond',
                  flag'-Wnull-dereference', -- This option is only active when -fdelete-null-pointer-checks is active, which is enabled by optimizations in most targets.

                  vers(7) {
                    cxx'-Waligned-new',

                    vers(7,1) {
                      flag'-Walloc-zero',
                      flag'-Walloca',
                      flag'-Wformat-overflow=2',
                   -- flag'-Wformat-truncation=1', -- enabled by -Wformat. Works best with -O2 and higher. =2 = calls to bounded functions whose return value is used
                   -- flag'-Wformat-y2k', -- strftime formats that may yield only a two-digit year.
                      flag'-Wduplicated-branches',

                      vers(8) {
                        cxx'-Wclass-memaccess',
                      }
                    }
                  }
                }
              }
            }
          }
        }
      } /

      clang_like {
        flag'-Weverything',
        flag'-Wno-documentation',
        flag'-Wno-documentation-unknown-command',
        flag'-Wno-newline-eof',
     -- flag'-Wno-range-loop-analysis',
     -- flag'-Wno-disabled-macro-expansion',
        cxx'-Wno-c++98-compat',
        cxx'-Wno-c++98-compat-pedantic',
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

          vers(5) {
            cxx'-Wno-inconsistent-missing-destructor-override',

            vers(9) {
              cxx'-Wno-ctad-maybe-unsupported',

              vers(11) {
                cxx'-Wno-suggest-destructor-override',
              }
            }
          }
        }
      },

      Or(lvl'strict', lvl'very_strict') {
        gcc(8) { flag'-Wcast-align=strict', }
      }
    },
  },

  opt'conversion_warnings' {
    lvl'on' {
      flag'-Wconversion',
      flag'-Wsign-compare',
      flag'-Wsign-conversion',
    } /
    lvl'conversion'{
      flag'-Wconversion',
    } /
    lvl'sign'{
      flag'-Wsign-compare',
      flag'-Wsign-conversion',
    } /
    {
      flag'-Wno-conversion',
      flag'-Wno-sign-compare',
      flag'-Wno-sign-conversion',
    },
  },

  opt'microsoft_abi_compatibility_warning' {
    lvl'on' {
      Or(gcc(10), clang_like) { cxx'-Wmismatched-tags' }
    } / {
      Or(gcc(10), clang_like) { cxx'-Wno-mismatched-tags' }
    }
  },

  opt'warnings_as_error' {
    lvl'on' { flag'-Werror', } /
    lvl'basic' {
      -- flag'-Werror=non-virtual-dtor',
      flag'-Werror=return-type',
      flag'-Werror=init-self',
      gcc(5,1) {
        flag'-Werror=array-bounds',
        flag'-Werror=logical-op',
        flag'-Werror=logical-not-parentheses',
      } /
      clang_like {
        flag'-Werror=array-bounds',
        flag'-Werror=division-by-zero',

        vers(3,4) {
          flag'-Werror=logical-not-parentheses',

          vers(3,6) {
            cxx'-Werror=delete-incomplete',

            vers(7) {
              cxx'-Werror=dynamic-class-memaccess',
            }
          }
        }
      }
    } /
    flag'-Wno-error',
  },

  opt'suggestions' {
    -lvl'off' {
      gcc {
        flag'-Wsuggest-attribute=pure',
        flag'-Wsuggest-attribute=const',
        vers(5) {
          cxx'-Wsuggest-final-types',
          cxx'-Wsuggest-final-methods',
       -- flag'-Wsuggest-attribute=format',
          vers(5,1) {
            flag'-Wnoexcept',
          },
        }
      }
    },
  },

  opt'sanitizers' {
    lvl'off' {
      fl'-fno-sanitize=all'
    } /
    clang_cl {
      flag'-fsanitize=undefined',
      flag'-fsanitize=address', -- memory, thread are mutually exclusive
      flag'-fsanitize-address-use-after-scope',
    } /
    clang {
      vers(3,1) {
        fl'-fsanitize=undefined',
        fl'-fsanitize=address', -- memory, thread are mutually exclusive
        flag'-fsanitize-address-use-after-scope',
        flag'-fno-omit-frame-pointer',
        flag'-fno-optimize-sibling-calls',
        vers(3,4) {
          fl'-fsanitize=leak', -- requires the address sanitizer
        },
      }
    } /
    gcc {
      vers(4,8) {
        fl'-fsanitize=address', -- memory, thread are mutually exclusive
        flag'-fno-omit-frame-pointer',
        flag'-fno-optimize-sibling-calls',

        vers(4,9) {
          fl'-fsanitize=undefined',
          fl'-fsanitize=leak', -- requires the address sanitizer
        }
      }
    },
  },

  opt'control_flow' {
    lvl'off' {
      gcc(8) { flag'-fcf-protection=none' } /
      clang_cl { flag'-fcf-protection=none', flag'-fno-sanitize-cfi-cross-dso' },
      clang { fl'-fno-sanitize=cfi' },
    } /
    Or(gcc(8), clang_cl) {
      -- gcc: flag'-mcet',
      -- clang_cl: flag'-fsanitize-cfi-cross-dso',
      lvl'branch' { flag'-fcf-protection=branch' } /
      lvl'return' { flag'-fcf-protection=return' } /
      { flag'-fcf-protection=full' }
    } /
    And(lvl'allow_bugs', clang) {
      fl'-fsanitize=cfi', -- cfi-* only allowed with '-flto' and '-fvisibility=...'
      flag'-fvisibility=hidden',
      fl'-flto',
    }
  },

  opt'color' {
    Or(gcc(4,9), clang_like) {
      lvl'auto' { flag'-fdiagnostics-color=auto' } /
      lvl'never' { flag'-fdiagnostics-color=never' } /
      lvl'always' { flag'-fdiagnostics-color=always' },
    },
  },

  opt'reproducible_build_warnings' {
    gcc(4,9) {
      lvl'on' { flag'-Wdate-time' } / flag'-Wno-date-time'
    }
  },

  opt'diagnostics_format' {
    lvl'fixits' {
      Or(gcc(7), clang_like(5)) {
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

  opt'fix_compiler_error' {
    lvl'on' {
      gcc {
        vers(4,7) {
          cxx'-Werror=narrowing',

          vers(7,1) {
            cxx'-Werror=literal-suffix', -- no warning name before 7.1
          }
        }
      },
      flag'-Werror=write-strings'
    } /
    clang_like {
      flag'-Wno-error=c++11-narrowing',
      flag'-Wno-reserved-user-defined-literal',
    }
  },

},

Or(gcc, clang) {
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
    Or(lvl'gold', gcc(-9)) { link'-fuse-ld=gold' } /
    opt'lto' {
      -- -flto is incompatible with -fuse-ld=lld
      And(-lvl'off', gcc) {
        link'-fuse-ld=gold'
      } /
      link'-fuse-ld=lld',
    } /
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
        lvl'fat' { flag'-ffat-lto-objects', } /
        lvl'thin' { link'-fuse-linker-plugin' }
      }
    } /
    And(lvl'thin', clang(6)) { fl'-flto=thin' } /
    fl'-flto',
  },

  opt'optimization' {
    lvl'0' { fl'-O0' } /
    lvl'g' { fl'-Og' } / {
      flag'-DNDEBUG',
      link'-Wl,-O1',
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
      ld64 {
        link'-Wl,-dead_strip',
        link'-Wl,-S', -- Remove debug information
      } /
      {
        link'-s',
        lvl'strip_all'{
          link'-Wl,--gc-sections', -- Remove unused sections
          link'-Wl,--strip-all',
        }
      },
      gcc {
        fl'-fwhole-program'
      } /
      clang {
        vers(3,9) {
          opt'lto' {
            -lvl'off' {
              fl'-fwhole-program-vtables'
            }
          },
          vers(7) {
            fl'-fforce-emit-vtables',
          }
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
          vers(11) {
            fl'-fstack-clash-protection'
          }
        }
      } /
      fl'-fstack-protector',
      -- ShadowCallStack is an instrumentation pass, currently only implemented for aarch64
      -- ShadowCallStack is intended to be a stronger alternative to -fstack-protector
      -- On aarch64, you also need to pass -ffixed-x18 unless your target already reserves x18.
      clang {
        fl'-fsanitize=shadow-call-stack',
      }
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
    lvl'off' {
      flag'-Wno-shadow',
      clang(8) {
        flag'-Wno-shadow-field'
      }
    } /
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
},

lld_link {
  opt'lto' {
    lvl'off' { flag'-fno-lto', } /
    lvl'thin' { flag'-flto=thin' } /
    fl'-flto',
  },

  opt'whole_program' {
    lvl'off' { flag'-fno-whole-program', } /
    opt'lto'{
      -lvl'off' {
        fl'-fwhole-program-vtables'
      }
    },
  },
},

-- https://docs.microsoft.com/en-us/cpp/build/reference/linker-options?view=vs-2019
-- https://docs.microsoft.com/en-us/cpp/build/reference/compiler-options-listed-alphabetically?view=vs-2019
-- https://clang.llvm.org/docs/UsersManual.html#id9
-- or clang --driver-mode=cl -help
Or(msvc, clang_cl) {
  opt'stl_fix' {
    lvl'on' { flag'/DNOMINMAX', },
  },

  opt'debug' {
    lvl'off' { flag'/DEBUG:NONE' } / {
      flag'/RTC1',
      flag'/Od',
      lvl'on' { flag'/DEBUG' } / -- /DEBUG:FULL
      lvl'line_tables_only' { flag'/DEBUG:FASTLINK' },

      opt'optimization' {
        lvl'g' { flag'/Zi' } /
        -- /ZI cannot be used with /GL
        opt'whole_program' {
          lvl'off' { flag'/ZI' } / flag'/Zi'
        } /
        flag'/ZI'
      } /
      -- /ZI cannot be used with /GL
      opt'whole_program' {
        lvl'off' { flag'/ZI' } / flag'/Zi'
      } /
      flag'/ZI',
    }
  },

  opt'exceptions'{
    lvl'on' {
      flag'/EHsc',
      flag'/D_HAS_EXCEPTIONS=1',
    } / {
      flag'/EHs-',
      flag'/D_HAS_EXCEPTIONS=0',
    }
  },

  opt'optimization' {
    lvl'0' {
      flag'/Ob0',
      flag'/Od',
      flag'/Oi-',
      flag'/Oy-',
    } /
    lvl'g' { flag'/Ob1' } / {
      flag'/DNDEBUG',
      -- /O1 = /Og      /Os  /Oy /Ob2 /GF /Gy
      -- /O2 = /Og /Oi  /Ot  /Oy /Ob2 /GF /Gy
      lvl'1' { flag'/O1', } /
      lvl'2' { flag'/O2', } /
      lvl'3' { flag'/O2', } /
      lvl'size' { flag'/O1', flag'/Gw' } /
      lvl'fast' { flag'/O2', flag'/fp:fast' }
    }
  },

  opt'whole_program' {
    lvl'off' {
      flag'/GL-'
    } /
    {
      flag'/GL',
      flag'/Gw',
      link'/LTCG',
      lvl'strip_all'{
        link'/OPT:REF',
      },
    }
  },

  opt'pedantic' {
    -lvl'off' {
      flag'/permissive-', -- implies /Zc:rvaluecast, /Zc:strictstrings, /Zc:ternary, /Zc:twoPhase
      cxx'/Zc:__cplusplus',
      -- cxx'/Zc:throwingNew',
    }
  },

  opt'rtti' {
    lvl'on' {
      flag'/GR'
    } /
    { flag'/GR-' }
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
    lvl'off' {
      flag'/guard:cf-',
    } /
    flag'/guard:cf',
  },

  opt'stack_protector' {
    lvl'off' {
      flag'/GS-',
    } /
    {
      flag'/GS',
      flag'/sdl',
      lvl'strong' { flag'/RTC1', } / -- /RTCsu
      lvl'all' { flag'/RTC1', flag'/RTCc', },
    },
  },
},

-- warnings:
-- https://docs.microsoft.com/en-us/cpp/error-messages/compiler-warnings/compiler-warnings-c4000-c5999?view=vs-2019
-- https://docs.microsoft.com/en-us/cpp/build/reference/compiler-option-warning-level?view=vs-2019
msvc {
  -- https://devblogs.microsoft.com/cppblog/broken-warnings-theory/
  -- vers(19,14)
  opt'msvc_isystem' {
    lvl'external_as_include_system_flag' {
      act('msvc_external', {
        cxx={
          '/experimental:external',
          '/external:W0',
        },
        SYSTEM_FLAG='/external:I',
      }),
    } / {
      flag'/experimental:external',
      flag'/external:W0',

      lvl'anglebrackets' {
        flag'/external:anglebrackets',
      } /
      -- include_and_caexcludepath
      {
        flag'/external:env:INCLUDE',
        flag'/external:env:CAExcludePath',
      },
    },

    opt'msvc_isystem_with_template_from_non_external' {
      lvl'off' { flag'/external:template', } / flag'/external:template-',
    },

    opt'warnings' {
      lvl'off' {
        flag'/W0'
      } /
      {
        -- /external:... ignores warnings start with C47XX
        flag'/wd4710', -- Function not inlined
        flag'/wd4711', -- Function selected for inline expansion (enabled by /OB2)

        -vers(19,21) {
          flag'/wd4774', -- format not a string literal
        },

        lvl'on' {
          flag'/W4',
        } /
        -- strict / very_strict
        {
          flag'/Wall',

          flag'/wd4571', -- SEH exceptions aren't caught since Visual C++ 7.1
          flag'/wd4355', -- 'this' used in base member initializing list
          flag'/wd4548', -- Expression before comma has no effect
          flag'/wd4577', -- 'noexcept' used with no exception handling mode specified; termination on exception is not guaranteed.
          flag'/wd4820', -- Added padding to members
          flag'/wd5039', -- Pointer/ref to a potentially throwing function passed to an 'extern "C"' function (with -EHc)

          flag'/wd4464', -- relative include path contains '..'
          flag'/wd4868', -- Evaluation order not guaranteed in braced initializing list
          flag'/wd5045', -- Spectre mitigation

          lvl'strict' {
            flag'/wd4583', -- Destructor not implicitly called
            flag'/wd4619', -- Unknown warning number
          },
        }
      }
    },
  } /
  opt'warnings' {
    lvl'off' { flag'/W0' } /
    lvl'on' {
      flag'/W4',
      flag'/wd4711', -- Function selected for inline expansion (enabled by /OB2)
    } /
    -- strict / very_strict
    {
      flag'/Wall',

      -- Warnings in MSVC's std
      flag'/wd4355', -- 'this' used in base member initializing list
      flag'/wd4514', -- Unreferenced inline function has been removed
      flag'/wd4548', -- Expression before comma has no effect
      flag'/wd4571', -- SEH exceptions aren't caught since Visual C++ 7.1
      flag'/wd4577', -- 'noexcept' used with no exception handling mode specified; termination on exception is not guaranteed.
      flag'/wd4625', -- Copy constructor implicitly deleted
      flag'/wd4626', -- Copy assignment operator implicitly deleted
      flag'/wd4668', -- Preprocessor macro not defined
      flag'/wd4710', -- Function not inlined
      flag'/wd4711', -- Function selected for inline expansion (enabled by /OB2)
      -vers(19,21) {
        flag'/wd4774', -- format not a string literal
      },
      flag'/wd4820', -- Added padding to members
      flag'/wd5026', -- Move constructor implicitly deleted
      flag'/wd5027', -- Move assignment operator implicitly deleted
      flag'/wd5039', -- Pointer/ref to a potentially throwing function passed to an 'extern "C"' function (with -EHc)

      -- Warnings in other libs
      flag'/wd4464', -- relative include path contains '..'
      flag'/wd4868', -- Evaluation order not guaranteed in braced initializing list
      flag'/wd5045', -- Spectre mitigation

      lvl'strict' {
        flag'/wd4061', -- Enum value in a switch not explicitly handled by a case label
        flag'/wd4266', -- No override available (function is hidden)
        flag'/wd4583', -- Destructor not implicitly called
        flag'/wd4619', -- Unknown warning number
        flag'/wd4623', -- Default constructor implicitly deleted
        flag'/wd5204', -- Class with virtual functions but no virtual destructor
      },
    }
  },

  opt'conversion_warnings' {
    lvl'on' {
      flag'/w14244', -- 'conversion_type': conversion from 'type1' to 'type2', possible loss of data
      flag'/w14245', -- 'conversion_type': conversion from 'type1' to 'type2', signed/unsigned mismatch
      flag'/w14388', -- Signed/unsigned mismatch (equality comparison)
      flag'/w14365', -- Signed/unsigned mismatch (implicit conversion)
    } /
    lvl'conversion'{
      flag'/w14244',
      flag'/w14365',
    } /
    lvl'sign'{
      flag'/w14388',
      flag'/w14245',
    } /
    {
      flag'/wd4244',
      flag'/wd4365',
      flag'/wd4388',
      flag'/wd4245',
    },
  },

  opt'shadow_warnings' {
    lvl'off' {
      flag'/wd4456', -- declaration of 'identifier' hides previous local declaration
      flag'/wd4459', -- declaration of 'identifier' hides global declaration
    } /
    Or(lvl'on', lvl'all') {
      flag'/w4456',
      flag'/w4459',
    } /
    lvl'local' {
      flag'/w4456',
      flag'/wd4459'
    }
  },

  opt'warnings_as_error' {
    lvl'on' { fl'/WX' } /
    lvl'off' { flag'/WX-' }
  },

  opt'lto' {
    lvl'off' {
      flag'/LTCG:OFF'
    } /
    {
      flag'/GL',
      link'/LTCG'
    }
  },

  opt'sanitizers' {
    lvl'on' {
      flag'/sdl',
    } /
    opt'stack_protector' {
      -lvl'off' { flag'/sdl-' },
    },
  },
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
    conversion_warnings=true,
    warnings_as_error=true,
  },

  _opts={
    color=      {{'auto', 'never', 'always'},},
    control_flow={{'off', 'on', 'branch', 'return', 'allow_bugs'},},
    coverage=   {{'off', 'on'},},
    cpu=        {{'generic', 'native'},},
    debug=      {{'off', 'on', 'line_tables_only', 'gdb', 'lldb', 'sce'},},
    diagnostics_format={{'fixits', 'patch', 'print_source_range_info'},},
    diagnostics_show_template_tree={{'off', 'on'},},
    elide_type= {{'off', 'on'},},
    exceptions= {{'off', 'on'},},
    fix_compiler_error={{'off', 'on'}, 'on'},
    linker=     {{'bfd', 'gold', 'lld', 'native'},},
    lto=        {{'off', 'on', 'fat', 'thin'},},
    microsoft_abi_compatibility_warning={{'off', 'on'}, 'off'},
    msvc_isystem={{'anglebrackets', 'include_and_caexcludepath', 'external_as_include_system_flag'},},
    msvc_isystem_with_template_from_non_external={{'off', 'on',},},
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
    conversion_warnings={{'off', 'on', 'sign', 'conversion'}, 'on'},
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

  startoptcond=noop, -- function(_, name) end,
  stopopt=noop, -- function(_) end,

  startcond=noop, -- function(_, x, optname) end,
  elsecond=noop, -- function(_, optname) end,
  stopcond=noop, -- function(_, optname) end,

  cxx=noop,
  link=noop,
  act=function(_, name, datas, optname) error('Unknown action: ' .. name) end,

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
      elseif v._not     then _:write(' '.._._vcondkeyword._not..' '.._._vcondkeyword.open)
                             _:_vcond(v._not, optname)
                             _:write(' '.._._vcondkeyword.close)
      elseif v.lvl      then _:write(' '.._:_vcond_lvl(v.lvl, optname))
      elseif v.version  then _:write(' '.._._vcondkeyword._not..' '.._._vcondkeyword.open..
                                     ' '.._._vcond_verless(_, v.version[1], v.version[2])..
                                     ' '.._._vcondkeyword.close)
      elseif v.compiler then _:write(' '.._:_vcond_compiler(v.compiler))
      elseif v.linker   then _:write(' '.._:_vcond_linker(v.linker))
      else error('Unknown cond ', ipairs(v))
      end
    end

    _._vcond_hasopt = _._vcond_hasopt or function(_, optname)
      return _._vcondkeyword._not..' '.._._vcondkeyword.open..' '.._:_vcond_lvl('default', optname).._._vcondkeyword.close
    end

    _.startoptcond=function(_, optname)
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

    _.stopcond=function(_)
      _:_vcond_printflags()
      if #_._vcondkeyword.endif ~= 0 then
        _:print(_.indent .. _._vcondkeyword.endif)
      end
    end

    _._vcond_flags_cxx = ''
    _._vcond_flags_link = ''
    _._vcond_toflags = _._vcond_toflags or function(_, cxx, link)
      return cxx and link and cxx .. link or cxx or link
    end
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
        local filter = ignore[k]
        if filter ~= true then
          local v = _._opts[k]
          if filter then
            local newargs = {}
            for j,arg in ipairs(v[1]) do
              if not filter[arg] then
                newargs[#newargs+1] = arg
              end
            end
            v = {newargs, filter[v[2]] or v[2]}
          end

          local ordered_args = v[1]
          local default_value = v[2] or 'default'
          if default_value ~= v[1][1] then
            ordered_args = {default_value}
            for i,arg in pairs(v[1]) do
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
  for _, v in pairs(args[1]) do
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


function evalflagselse(t, v, curropt)
  if t._else then
    v:elsecond(curropt)
    v.indent = v.indent .. '  '
    evalflags(t._else, v, curropt)
    v.indent = v.indent:sub(1, #v.indent-2)
  end
end

function evalflags(t, v, curropt)
  if t._if then
    local opt = t._if.opt
    if opt then
      if not v._opts[opt] then
        error('Unknown "' .. opt .. '" option')
      end
      if v.ignore[opt] ~= true then
        local r = v:startoptcond(opt)
        if r ~= false then
          v.indent = v.indent .. '  '
          evalflags(t._t, v, opt)
          v.indent = v.indent:sub(1, #v.indent-2)
          v:stopopt(opt)
        end
        if r ~= true then
          evalflagselse(t, v, curropt)
        end
        v:stopcond(opt)
      elseif t._else then
        evalflags(t._else, v, curropt)
      end
    else
      local r = v:startcond(t._if, curropt)
      if r ~= false and t._t then
        v.indent = v.indent .. '  '
        evalflags(t._t, v, curropt)
        v.indent = v.indent:sub(1, #v.indent-2)
      end
      if r ~= true then
        evalflagselse(t, v, curropt)
      end
      v:stopcond(curropt)
    end
  elseif t.cxx or t.link then
    if t.cxx  then v:cxx(t.cxx, curropt) end
    if t.link then v:link(t.link, curropt) end
  elseif t.act then
    local r = v:act(t.act[1], t.act[2], curropt)
    if r == false or r == nil then
      error('Unknown action: ' .. t.act[1])
    elseif r ~= true then
      error('Error with Action ' .. t.act[1] .. ': ' .. r)
    end
  else
    for k,x in pairs(t) do
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

  -- printAST(MakeAST(is_C),'')
  -- io.stdout:flush()
  -- os.exit(1)

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
local is_C = false

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
