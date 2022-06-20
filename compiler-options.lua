#!/usr/bin/env lua

local table_insert = table.insert
local unpack = table.unpack or unpack

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

local if_mt -- referenced by __unm
if_mt = {
  __call = function(self, x)
    assert(not self._t, '`_t` is not nil')

    self._t = ramify(x)
    return self
  end,
  __div = function(self, x)
    local subelse = self._subelse or self
    assert(subelse._if and not subelse._else, 'replace `x / y / z` with `x / { y / z }`')

    x = x and ramify(x)

    self._subelse = x
    subelse._else = x
    return self
  end,
  __unm = function(self)
    return setmetatable({ _if={_not=self._if}, _t=self._t, _subelse=self._subelse }, if_mt)
  end,
}

local if_mt_func = {
  __call = function(self, ...)
    return self._impl(...)
  end,
  __div = function(self, x)
    return self._impl() / x
  end,
  __unm = function(self)
    return -self._impl()
  end,
}

function If(condition)
  return setmetatable({ _if=condition }, if_mt)
end

function IfFunc(f)
  return setmetatable({ _impl=f }, if_mt_func)
end

function Logical(op, ...)
  local conds = {}
  for k,x in ipairs({...}) do
    if x._impl then
      x = x._impl()
    elseif type(x) == 'function' then
      x = x()
    end
    assert(x._if and not x._t)
    assert(not x._if.opt)
    if x._if[op] then
      for _,cond in ipairs(x._if[op]) do
        table_insert(conds, cond)
      end
    else
      table_insert(conds, x._if)
    end
  end
  return If({[op]=conds})
end

function _conditional_name(cond)
  return IfFunc(function(x)
    local r = If(cond)
    return x and r(x) or r
  end)
end

function _conditional_name_with_version(cond)
  return IfFunc(function(x_or_op_and_version)
    if type(x_or_op_and_version) == 'string' then
      local ret = vers(x_or_op_and_version)
      ret._if = {_and={cond, ret._if}}
      return ret
    else
      local r = If(cond)
      return x_or_op_and_version and r(x_or_op_and_version) or r
    end
  end)
end

function Compiler(name)
  return _conditional_name_with_version({compiler=name})
end

function Platform(name)
  return _conditional_name({platform=name})
end

function Linker(name)
  return _conditional_name({linker=name})
end

function CompilerGroup(...)
  local conds = {}
  for _,tool in ipairs({...}) do
    table_insert(conds, tool()._if)
  end
  return _conditional_name_with_version({_or=conds})
end

function Or(...) return Logical('_or', ...) end
function And(...) return Logical('_and', ...) end

function vers(op_and_version)
  local op, major, minor = op_and_version:match('^([<>!=]=?)(%d+)%.?(%d*)$')
  assert(op)
  return If({op=op, major=tonumber(major), minor=tonumber(minor) or 0})
end

function lvl(x) return If({lvl=x}) end
function opt(x) return If({opt=x}) end

local windows = Platform('windows')
local linux = Platform('linux')
local macos = Platform('macos')
local mingw = Platform('mingw')

local gcc = Compiler('gcc')
local clang = Compiler('clang')
local clang_cl = Compiler('clang-cl')
local msvc = Compiler('msvc')
local icc = Compiler('icc')
local icl = Compiler('icl')
-- local emcc = Compiler('emcc')
local clang_emcc = Compiler('clang-emcc') -- virtual compiler, refer to clang version
local clang_like = CompilerGroup(clang, clang_cl, clang_emcc)

-- for clang-emcc to emcc
-- local switch_to_real_compiler = {switch_to_special=true}

-- local msvc_linker = Linker('msvc')
local lld_link = Linker('lld-link')
local ld64 = Linker('ld64') -- Apple ld64

function link(x) return { link=x } end
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

-- gcc and clang:
-- g++ -Q --help=optimizers,warnings,target,params,common,undocumented,joined,separate,language__ -O3
-- all warnings by version: https://github.com/pkolbus/compiler-warnings

-- clang:
-- https://clang.llvm.org/docs/DiagnosticsReference.html
-- https://releases.llvm.org/10.0.0/tools/clang/docs/DiagnosticsReference.html
-- https://github.com/llvm-mirror/clang/blob/master/include/clang/Driver/Options.td
-- https://github.com/llvm-mirror/clang/blob/master/include/clang/Basic/Diagnostic.td

-- clang-cl
-- https://clang.llvm.org/docs/UsersManual.html#id9

-- icc, icpc and icl:
-- icc / icpc (linux) -diag-enable warn -diag-dump
-- icl (windows) /Qdiag-enable:warn -Qdiag-dump
-- https://www.intel.com/content/www/us/en/develop/documentation/cpp-compiler-developer-guide-and-reference/top/compiler-reference/compiler-options/alphabetical-list-of-compiler-options.html
-- https://www.intel.com/content/www/us/en/develop/documentation/cpp-compiler-developer-guide-and-reference/top/compiler-reference/compiler-options/deprecated-and-removed-compiler-options.html

-- icx, icpx, dpcpp are clang compiler
-- icx -qnextgen-diag

-- emcc
-- List of all compiler & linker options: https://emscripten.org/docs/tools_reference/emcc.html
-- List of all -s options: https://github.com/emscripten-core/emscripten/blob/main/src/settings.js

local ndebug_decl = function(def, undef)
  return {
    lvl'off' { undef } /
    lvl'on' { def } /
    --[[lvl'with_optimization_1_or_above']] {
      opt'optimization' {
        -Or(lvl'0', lvl'g') {
          def
        }
      }
    }
  }
end

return --[[printAST]] {

opt'ndebug' {
  Or(msvc, icl) { ndebug_decl(flag'/DNDEBUG', flag'/UNDEBUG') }
                / ndebug_decl(flag'-DNDEBUG', flag'-UNDEBUG')
},

Or(gcc, clang_like) {
  opt'warnings' {
    lvl'off' {
      flag'-w'
    } / {
      gcc {
        flag'-Wall',
     -- flag'-Weffc++',
        flag'-Wextra',
        flag'-Wcast-align',
        flag'-Wcast-qual',
        flag'-Wdisabled-optimization',
        flag'-Wfloat-equal',
        flag'-Wformat-security',
        flag'-Wformat=2',
     -- flag'-Winline',
        flag'-Winvalid-pch',
        flag'-Wmissing-include-dirs',
        flag'-Wpacked',
        flag'-Wredundant-decls',
        flag'-Wundef',
        flag'-Wunused-macros',
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

        opt'switch_warnings' {
          lvl'on' { flag'-Wswitch' } / -- enabled by -Wall
          lvl'exhaustive_enum' { flag'-Wswitch-enum' } /
          lvl'mandatory_default' { flag'-Wswitch-default' } /
          lvl'exhaustive_enum_and_mandatory_default' {
            flag'-Wswitch-default',
            flag'-Wswitch-enum',
          } /
          { flag'-Wno-switch' }
        },

        vers'>=4.7' {
          flag'-Wsuggest-attribute=noreturn',
          cxx'-Wzero-as-null-pointer-constant',
          flag'-Wlogical-op',
       -- flag'-Wno-aggressive-loop-optimizations',
       -- flag'-Wnormalized=nfc',
          flag'-Wvector-operation-performance',
          flag'-Wdouble-promotion',
          flag'-Wtrampolines', -- C only with a nested function ?

          vers'>=4.8' {
            cxx'-Wuseless-cast',

            vers'>=4.9' {
              cxx'-Wconditionally-supported',
              flag'-Wfloat-conversion',

              vers'>=5.1' {
                flag'-Wformat-signedness',
                flag'-Warray-bounds=2', -- This option is only active when -ftree-vrp is active (default for -O2 and above). level=1 enabled by -Wall.
             -- flag'-Wctor-dtor-privacy',
                cxx'-Wstrict-null-sentinel',
                cxx'-Wsuggest-override',

                vers'>=6.1' {
                  flag'-Wduplicated-cond',
                  flag'-Wnull-dereference', -- This option is only active when -fdelete-null-pointer-checks is active, which is enabled by optimizations in most targets.

                  vers'>=7' {
                    cxx'-Waligned-new',

                    vers'>=7.1' {
                      flag'-Walloc-zero',
                      flag'-Walloca',
                      flag'-Wformat-overflow=2',
                   -- flag'-Wformat-truncation=1', -- enabled by -Wformat. Works best with -O2 and higher. =2 = calls to bounded functions whose return value is used
                   -- flag'-Wformat-y2k', -- strftime formats that may yield only a two-digit year.
                      flag'-Wduplicated-branches',

                      vers'>=8' {
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
      -- clang_like
      {
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
     -- cxx'-Qunused-arguments',

        opt'switch_warnings' {
          Or(lvl'on', lvl'mandatory_default') {
            flag'-Wno-switch-enum',
          } /
          Or(lvl'exhaustive_enum', lvl'exhaustive_enum_and_mandatory_default') {
            flag'-Wswitch-enum',
          } /
          lvl'off' {
            flag'-Wno-switch',
            flag'-Wno-switch-enum',
          }
        } / {
          flag'-Wno-switch',
          flag'-Wno-switch-enum',
        },

        opt'covered_switch_default_warnings' {
          lvl'off' { flag'-Wno-covered-switch-default', } /
          flag'-Wcovered-switch-default'
        },

        vers'>=3.9' {
          cxx'-Wno-undefined-var-template',

          vers'>=5' {
            cxx'-Wno-inconsistent-missing-destructor-override',

            vers'>=9' {
              cxx'-Wno-ctad-maybe-unsupported',

              vers'>=10' {
                cxx'-Wno-c++20-compat',

                vers'>=11' {
                  cxx'-Wno-suggest-destructor-override',
                }
              }
            }
          }
        }
      },

      Or(lvl'strict', lvl'very_strict') {
        gcc'>=8' { flag'-Wcast-align=strict', }
      }
    },
  },

  opt'diagnostics_show_template_tree' {
    Or(gcc'>=8', clang) {
      lvl'on' { cxx'-fdiagnostics-show-template-tree' } / cxx'-fno-diagnostics-show-template-tree',
    },
  },

  opt'elide_type' {
    lvl'on' {
      gcc'>=8' { cxx'-felide-type' }
    } /
    Or(gcc'>=8', clang'>=3.4') {
      cxx'-fno-elide-type',
    },
  },

  opt'exceptions' {
    lvl'on' {
      flag'-fexceptions',
      clang_emcc {
        flag'-sDISABLE_EXCEPTION_CATCHING=0',
      }
    } /
    flag'-fno-exceptions',
  },

  opt'rtti' {
    lvl'on' { cxx'-frtti' } / cxx'-fno-rtti',
  },

  opt'var_init' {
    lvl'pattern' {
      Or(gcc'>=12', clang'>=8') { flag'-ftrivial-auto-var-init=pattern' }, }
  },

  opt'windows_abi_compatibility_warnings' {
    Or(gcc'>=10', clang_like) {
      lvl'on' { cxx'-Wmismatched-tags' } /
      { cxx'-Wno-mismatched-tags' }
    }
  },

  opt'warnings_as_error' {
    lvl'on' { flag'-Werror', } /
    lvl'basic' {
      -- flag'-Werror=non-virtual-dtor',
      flag'-Werror=return-type',
      flag'-Werror=init-self',
      gcc {
        flag'-Werror=div-by-zero',

        vers'>=5.1' {
          flag'-Werror=array-bounds',
          flag'-Werror=logical-op',
          flag'-Werror=logical-not-parentheses',

          vers'>=7' {
            cxx'-Werror=literal-suffix',
          }
        }
      } /
      -- clang_like
      {
        flag'-Werror=array-bounds',
        flag'-Werror=division-by-zero',

        vers'>=3.4' {
          flag'-Werror=logical-not-parentheses',

          vers'>=3.6' {
            cxx'-Werror=delete-incomplete',

            vers'>=6' {
              cxx'-Werror=user-defined-literals',

              vers'>=7' {
                cxx'-Werror=dynamic-class-memaccess',
              }
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
        vers'>=5' {
          cxx'-Wsuggest-final-types',
          cxx'-Wsuggest-final-methods',
       -- flag'-Wsuggest-attribute=format',
          vers'>=5.1' {
            cxx'-Wnoexcept',
          },
        }
      }
    },
  },

  -- ASAN_OPTIONS=strict_string_checks=1:detect_stack_use_after_return=1:check_initialization_order=1:strict_init_order=1:detect_invalid_pointer_pairs=2
  opt'sanitizers' {
    lvl'off' {
      fl'-fno-sanitize=all'
    } /
    clang_cl {
      flag'-fsanitize=undefined',
      flag'-fsanitize=address', -- memory, thread are mutually exclusive
      flag'-fsanitize-address-use-after-scope',
    } /
    Or(clang, clang_emcc) {
      vers'>=3.1' {
        fl'-fsanitize=undefined',
        fl'-fsanitize=address', -- memory, thread are mutually exclusive
        flag'-fsanitize-address-use-after-scope',
        flag'-fno-omit-frame-pointer',
        flag'-fno-optimize-sibling-calls',
        clang {
          vers'>=3.4' {
            fl'-fsanitize=leak', -- requires the address sanitizer
          },
          vers'>=6' {
            opt'stack_protector' {
              -lvl'off' {
                flag'-fsanitize-minimal-runtime',
              }
            }
          },
        },
      }
    } /
    -- gcc
    {
      vers'>=4.8' {
        fl'-fsanitize=address', -- memory, thread are mutually exclusive
        flag'-fno-omit-frame-pointer',
        flag'-fno-optimize-sibling-calls',

        vers'>=4.9' {
          fl'-fsanitize=undefined',
          fl'-fsanitize=leak', -- requires the address sanitizer
        }
      }
    }
  },

  opt'control_flow' {
    clang_emcc {
      lvl'off' {
        link'-sASSERTIONS=0',
        link'-sSAFE_HEAP=0',
      } / {
        -- Building with ASSERTIONS=1 causes STACK_OVERFLOW_CHECK=1
        link'-sASSERTIONS=1',
        link'-sDEMANGLE_SUPPORT=1',
        -- ASan does not work with SAFE_HEAP
        opt'sanitizers' {
          -lvl'on' { link'-sSAFE_HEAP=1' },
        } / {
          link'-sSAFE_HEAP=1'
        },
      }
    } /
    lvl'off' {
      gcc'>=8' {
        flag'-fcf-protection=none'
      } /
      -- clang, clang_cl
      {
        fl'-fno-sanitize=cfi',
        flag'-fcf-protection=none',
        flag'-fno-sanitize-cfi-cross-dso',
      }
    } /
    Or(gcc'>=8', -gcc) {
      -- gcc: flag'-mcet',
      -- clang_cl: flag'-fsanitize-cfi-cross-dso',
      lvl'branch' { flag'-fcf-protection=branch' } /
      lvl'return' { flag'-fcf-protection=return' } /
      { flag'-fcf-protection=full' },

      And(lvl'allow_bugs', clang) {
        fl'-fsanitize=cfi', -- cfi-* only allowed with '-flto' and '-fvisibility=...'
        flag'-fvisibility=hidden',
        fl'-flto',
      }
    }
  },

  opt'color' {
    Or(gcc'>=4.9', -gcc --[[=clang_like]]) {
      lvl'auto' { flag'-fdiagnostics-color=auto' } /
      lvl'never' { flag'-fdiagnostics-color=never' } /
      lvl'always' { flag'-fdiagnostics-color=always' },
    },
  },

  opt'reproducible_build_warnings' {
    gcc'>=4.9' {
      lvl'on' { flag'-Wdate-time' } / flag'-Wno-date-time'
    }
  },

  opt'diagnostics_format' {
    lvl'fixits' {
      Or(gcc'>=7', And(-gcc, vers'>=5') --[[=clang_like'>=5']]) {
        flag'-fdiagnostics-parseable-fixits'
      }
    } /
    lvl'patch' {
      gcc'>=7' { flag'-fdiagnostics-generate-patch' }
    } /
    lvl'print_source_range_info' {
      clang { flag'-fdiagnostics-print-source-range-info' }
    }
  },

  opt'fix_compiler_error' {
    lvl'on' {
      gcc {
        vers'>=4.7' {
          cxx'-Werror=narrowing',

          vers'>=7.1' {
            cxx'-Werror=literal-suffix', -- no warning name before 7.1
          }
        }
      },
      flag'-Werror=write-strings'
    } /
    -gcc --[[=clang_like]] {
      flag'-Wno-error=c++11-narrowing',
      flag'-Wno-reserved-user-defined-literal',
    }
  },

  opt'lto' {
    lvl'off' {
      fl'-fno-lto',
    } /
    gcc {
      fl'-flto',
      vers'>=5' {
        opt'warnings' {
          -lvl'off' { fl'-flto-odr-type-merging' }, -- increases size of LTO object files, but enables diagnostics about ODR violations
        },
        lvl'fat' { flag'-ffat-lto-objects', } /
        lvl'thin' { link'-fuse-linker-plugin' }
      }
    } /
    -- clang_like
    {
      clang_cl {
        -- LTO require -fuse-ld=lld (link by default)
        link'-fuse-ld=lld',
      },
      And(lvl'thin', vers'>=6') {
        fl'-flto=thin'
      } /
      fl'-flto',
    }
  },

  opt'shadow_warnings' {
    lvl'off' {
      flag'-Wno-shadow',
      Or(clang_cl, clang'>=8') {
        flag'-Wno-shadow-field'
      }
    } /
    lvl'on' { flag'-Wshadow' } /
    lvl'all' {
      gcc { flag'-Wshadow' } /
      flag'-Wshadow-all',
    } /
    gcc'>=7.1' {
      lvl'local' {
        flag'-Wshadow=local'
      } /
      lvl'compatible_local' {
        flag'-Wshadow=compatible-local'
      }
    }
  },

  opt'float_sanitizers' {
    Or(gcc'>=5', clang'>=5', clang_cl) {
      lvl'on' {
        flag'-fsanitize=float-divide-by-zero',
        flag'-fsanitize=float-cast-overflow',
      } / {
        flag'-fno-sanitize=float-divide-by-zero',
        flag'-fno-sanitize=float-cast-overflow',
      },
    },
  },

  opt'integer_sanitizers' {
    Or(clang'>=5', clang_cl) {
      lvl'on' { flag'-fsanitize=integer', } /
      flag'-fno-sanitize=integer',
    } /
    gcc'>=4.9' {
      lvl'on' {
        flag'-ftrapv',
        flag'-fsanitize=undefined',
      },
    }
  },

},

opt'conversion_warnings' {
  Or(gcc, clang_like, icc) {
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
},

Or(gcc, clang, clang_emcc) {
  opt'stl_debug' {
    -lvl'off' {
      lvl'assert_as_exception' {
        cxx'-D_LIBCPP_DEBUG_USE_EXCEPTIONS'
      },
      Or(lvl'allow_broken_abi', lvl'allow_broken_abi_and_bugs') {
        clang {
          -- debug allocator has a bug: https://bugs.llvm.org/show_bug.cgi?id=39203
          Or(vers'>=8', lvl'allow_broken_abi_and_bugs') {
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

  opt'pedantic' {
    -lvl'off' {
      flag'-pedantic',
      lvl'as_error' {
        flag'-pedantic-errors',
      },
    },
  },
},

clang_emcc {
  opt'optimization' {
    lvl'0' { fl'-O0' } /
    lvl'g' { fl'-Og' } /
    {
      lvl'1' { fl'-O1' } /
      lvl'2' { fl'-O2' } /
      lvl'3' { fl'-O3' } /
      lvl'fast' {
        fl'-O3',
        -- The LLVM wasm backend avoids traps by adding more code around each possible trap
        -- (basically clamping the value if it would trap).
        -- That code may not run in older VMs, though.
        fl'-mnontrapping-fptoint',
      } /
      lvl'size' { fl'-Os' } /
      lvl'z' {
        fl'-Oz'
        -- -- This greatly reduces the size of the support JavaScript code
        -- -- Note that this increases compile time significantly.
        -- fl'--closure 1',
      },
    }
  },

  opt'debug' {
    lvl'off' { flag'-g0' } /
    flag'-g',
  },
} /

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
    lvl'off' { flag'-g0' } /
    lvl'gdb' { flag'-ggdb' } /
    clang {
      lvl'line_tables_only' { flag'-gline-tables-only' } /
      lvl'lldb' { flag'-glldb' } /
      lvl'sce' { flag'-gsce' } /
      flag'-g'
    } /
    flag'-g',
    -- flag'-fasynchronous-unwind-tables', -- Increased reliability of backtraces
  },

  opt'optimization' {
    lvl'0' { flag'-O0' } /
    lvl'g' { flag'-Og' } /
    {
      link'-Wl,-O1',
      lvl'1' { flag'-O1' } /
      lvl'2' { flag'-O2' } /
      lvl'3' { flag'-O3' } /
      lvl'size' { flag'-Os' } /
      lvl'z' { clang { flag'-Oz' } / flag'-Os' } /
      lvl'fast' { flag'-Ofast' }
    }
  },

  opt'cpu' {
    lvl'generic' { fl'-mtune=generic' } /
    { fl'-march=native', fl'-mtune=native', }
  },

  opt'linker' {
    lvl'native' {
      gcc { link'-fuse-ld=gold' } /
      link'-fuse-ld=lld'
    } /
    lvl'bfd' {
      link'-fuse-ld=bfd'
    } /
    Or(lvl'gold', gcc'<9') {
      link'-fuse-ld=gold'
    } /
    opt'lto' {
      -- -flto is incompatible with -fuse-ld=lld
      And(-lvl'off', gcc) {
        link'-fuse-ld=gold'
      } /
      link'-fuse-ld=lld',
    } /
    link'-fuse-ld=lld',
  },

  opt'whole_program' {
    lvl'off' {
      flag'-fno-whole-program',
      clang'>=3.9' { fl'-fno-whole-program-vtables' }
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
        vers'>=3.9' {
          opt'lto' {
            -lvl'off' {
              fl'-fwhole-program-vtables'
            }
          },
          vers'>=7' {
            fl'-fforce-emit-vtables',
          }
        }
      }
    }
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
        gcc {
          vers'>=4.9' {
            fl'-fstack-protector-strong',
            vers'>=8' {
              fl'-fstack-clash-protection'
            }
          }
        } /
        clang {
          fl'-fstack-protector-strong',
          fl'-fsanitize=safe-stack',
          vers'>=11' {
            fl'-fstack-clash-protection'
          }
        }
      } /
      lvl'all' {
        fl'-fstack-protector-all',
        gcc'>=8' {
          fl'-fstack-clash-protection'
        } /
        clang {
          fl'-fsanitize=safe-stack',
          vers'>=11' {
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
    lvl'full'{
      link'-Wl,-z,relro,-z,now,-z,noexecstack',
      opt'linker' {
        -Or(Or(lvl'gold', gcc'<9'), And(lvl'native', gcc)) {
          link'-Wl,-z,separate-code'
        }
      }
    },
  },

  opt'pie' {
    lvl'off'{ link'-no-pic', } /
    lvl'on' { link'-pie', } /
    lvl'static' { link'-static-pie', } /
    lvl'fpie'{ flag'-fpie', } /
    lvl'fpic'{ flag'-fpic', } /
    lvl'fPIE'{ flag'-fPIE', } /
    lvl'fPIC'{ flag'-fPIC', },
  },

  opt'other_sanitizers' {
    lvl'thread' { flag'-fsanitize=thread', } /
    lvl'memory' {
      clang'>=5' {
        flag'-fsanitize=memory',
      }
    } /
    lvl'pointer' {
      gcc'>=8' {
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

  opt'noexcept_warnings' {
    gcc'>=4.9' {
      lvl'on' { cxx'-Wnoexcept' } /
      { cxx'-Wno-noexcept' }
    }
  },

  opt'analyzer' {
    gcc'>=10' {
      lvl'off' {
        flag'-fno-analyzer'
      } / {
        flag'-fanalyzer',
        lvl'taint' {
          flag'-fanalyzer-checker=taint'
        },

        opt'analyzer_too_complex_warning' {
          lvl'on' {
            flag'-Wanalyzer-too-complex'
          } / --[[lvl'off']] {
            flag'-Wno-analyzer-too-complex'
          }
        },

        opt'analyzer_verbosity' {
          lvl'0' { flag'-fanalyzer-verbosity=0' } /
          lvl'1' { flag'-fanalyzer-verbosity=1' } /
          lvl'2' { flag'-fanalyzer-verbosity=2' } /
          --[[lvl'3']] { flag'-fanalyzer-verbosity=3' }
        },
      },
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
Or(msvc, clang_cl, icl) {
  opt'exceptions'{
    lvl'on' {
      flag'/EHsc',
      flag'/D_HAS_EXCEPTIONS=1',
    } / {
      flag'/EHs-',
      flag'/D_HAS_EXCEPTIONS=0',
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

  opt'stl_fix' {
    lvl'on' { flag'/DNOMINMAX', },
  },

  -- msvc and clang_cl
  -icl {
    opt'debug' {
      lvl'off' { flag'/DEBUG:NONE' } / {
        flag'/RTC1',
        flag'/Od',
        lvl'on' { flag'/DEBUG' } / -- /DEBUG:FULL
        lvl'line_tables_only' {
          clang_cl { flag'-gline-tables-only' },
          flag'/DEBUG:FASTLINK'
        },

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

    opt'optimization' {
      lvl'0' {
        flag'/Ob0',
        flag'/Od',
        flag'/Oi-',
        flag'/Oy-',
      } /
      lvl'g' { flag'/Ob1' } /
      {
        -- /O1 = /Og      /Os  /Oy /Ob2 /GF /Gy
        -- /O2 = /Og /Oi  /Ot  /Oy /Ob2 /GF /Gy
        lvl'1' { flag'/O1', } /
        lvl'2' { flag'/O2', } /
        lvl'3' { flag'/O2', } /
        Or(lvl'size', lvl'z') { flag'/O1', flag'/GL', flag'/Gw' } /
        lvl'fast' { flag'/O2', flag'/fp:fast' }
      }
    },

    opt'control_flow' {
      lvl'off' {
        flag'/guard:cf-',
      } /
      flag'/guard:cf',
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
        flag'/permissive-', -- implies /Zc:rvalueCast, /Zc:strictStrings, /Zc:ternary, /Zc:twoPhase
        cxx'/Zc:__cplusplus',
        -- cxx'/Zc:throwingNew',
      }
    },

    opt'stack_protector' {
      lvl'off' {
        flag'/GS-',
      } /
      {
        flag'/GS',
        flag'/sdl',
        lvl'strong' {
          flag'/RTC1', -- /RTCsu
          msvc'>=16.7' {
            flag'/guard:ehcont',
            link'/CETCOMPAT',
          },
        } /
        lvl'all' { flag'/RTC1', flag'/RTCc', },
      },
    },
  }
},

-- warnings:
-- https://docs.microsoft.com/en-us/cpp/error-messages/compiler-warnings/compiler-warnings-c4000-c5999?view=vs-2019
-- https://docs.microsoft.com/en-us/cpp/build/reference/compiler-option-warning-level?view=vs-2019
msvc {
  opt'windows_bigobj' {
    flag'/bigobj',
  },

  opt'msvc_conformance' {
    Or(lvl'all', lvl'all_without_throwing_new') {
      flag'/Zc:inline',
      flag'/Zc:referenceBinding',
      lvl'all' {
        flag'/Zc:throwingNew',
      },
      vers'>=15.6' {
        cxx'/Zc:externConstexpr',
        vers'>=16.5' {
          flag'/Zc:preprocessor',
          vers'>=16.8' {
            cxx'/Zc:lambda',
          }
        },
      }
    }
  },

  opt'msvc_crt_secure_no_warnings' {
    lvl'on' { flag'/D_CRT_SECURE_NO_WARNINGS=1' } /
    lvl'off' { flag'/U_CRT_SECURE_NO_WARNINGS' }
  },

  -- https://devblogs.microsoft.com/cppblog/broken-warnings-theory/
  -- vers'>=19.14'
  opt'msvc_isystem' {
    lvl'external_as_include_system_flag' {
      act('msvc_external', {
        cxx={
          '/experimental:external',
          '/external:env:INCLUDE',
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

        vers'<19.21' {
          flag'/wd4774', -- format not a string literal
        },

        lvl'on' {
          flag'/W4',
          flag'/wd4514', -- Unreferenced inline function has been removed
        } /
        -- strict / very_strict
        {
          flag'/Wall',

          flag'/wd4514', -- Unreferenced inline function has been removed

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

    opt'switch_warnings' {
      Or(lvl'on', lvl'mandatory_default') {
        flag'/w14062',
      } /
      Or(lvl'exhaustive_enum', lvl'exhaustive_enum_and_mandatory_default') {
        flag'/w14061',
        flag'/w14062',
      } /
      lvl'off' { flag'/wd4061', flag'/wd4062' }
    },
  } /
  opt'warnings' {
    lvl'off' { flag'/W0' } /
    lvl'on' {
      flag'/W4',
      flag'/wd4514', -- Unreferenced inline function has been removed
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
      vers'<19.21' {
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
    lvl'on' { flag'/WX' } /
    lvl'off' { flag'/WX-' } /
    -- lvl'basic'
    {
      cxx'/we4455', -- Wliteral-suffix
      cxx'/we4150', -- Wdelete-incomplete
      flag'/we4716', -- Wreturn-type
      flag'/we2124', -- Wdivision-by-zero
    }
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
    vers'>=16.9' {
      flag'/fsanitize=address',
      flag'/fsanitize-address-use-after-return'
    } / {
      lvl'on' {
        flag'/sdl',
      } /
      opt'stack_protector' {
        -lvl'off' { flag'/sdl-' },
      },
    }
  },
},

icl {
  opt'warnings' {
    lvl'off' {
      flag'/w'
    } / {
      flag'/W2',
      flag'/Qdiag-disable:1418,2259', -- external function definition with no prior declaration
                                      -- "type" to "type" may lose significant bits
    }
  },

  opt'warnings_as_error' {
    lvl'on' {
      flag'/WX',
    } /
    lvl'basic' {
      flag'/Qdiag-error:1079,39,109' -- return-type, div-by-zero, array-bounds
    }
  },

  opt'windows_bigobj' {
    flag'/bigobj',
  },

  opt'msvc_conformance' {
    Or(lvl'all', lvl'all_without_throwing_new') {
      flag'/Zc:inline',
      flag'/Zc:strictStrings',
      lvl'all' {
        flag'/Zc:throwingNew',
      },
    }
  },

  opt'debug' {
    lvl'off' { flag'/debug:NONE' } / {
      flag'/RTC1',
      flag'/Od',
      lvl'on' { flag'/debug:full' } /
      lvl'line_tables_only' { flag'/debug:minimal' },

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

  opt'optimization' {
    lvl'0' {
      flag'/Ob0',
      flag'/Od',
      flag'/Oi-',
      flag'/Oy-',
    } /
    lvl'g' { flag'/Ob1' } /
    {
      flag'/GF',
      lvl'1' { flag'/O1', } /
      lvl'2' { flag'/O2', } /
      lvl'3' { flag'/O2', } /
      lvl'z' { flag'/O3', } /
      lvl'size' { flag'/Os', } /
      lvl'fast' { flag'/fast' }
    }
  },

  opt'stack_protector' {
    lvl'off' {
      flag'/GS-',
    } /
    {
      flag'/GS',
      lvl'strong' {
        flag'/RTC1', -- /RTCsu
      } /
      lvl'all' { flag'/RTC1', flag'/RTCc', },
    },
  },

  opt'sanitizers' {
    lvl'on' { flag'/Qtrapuv' }
  },

  opt'float_sanitizers' {
    lvl'on' {
      flag'/Qfp-stack-check',
      flag'/Qfp-trap:common',
    -- flag'/Qfp-trap=all',
    }
  },

  opt'control_flow' {
    lvl'off' {
      flag'/guard:cf-',
      flag'/mconditional-branch=keep',
    } / {
      flag'/guard:cf',
      lvl'branch' {
        flag'/mconditional-branch:all-fix',
        flag'/Qcf-protection:branch',
      } /
      lvl'on' {
        flag'/mconditional-branch:all-fix',
        flag'/Qcf-protection:full',
      }
    }
  },

  opt'cpu' {
    lvl'generic' { fl'/Qtune:generic' } / fl'/QxHost',
  },

} /

icc {
  opt'warnings' {
    lvl'off' {
      flag'-w'
    } / {
      flag'-Wall',
      flag'-Warray-bounds',
      flag'-Wcast-qual',
      flag'-Wchar-subscripts',
      flag'-Wdisabled-optimization',
      flag'-Wenum-compare',
      flag'-Wextra',
      flag'-Wfloat-equal',
      flag'-Wformat-security',
      flag'-Wformat=2',
      flag'-Winit-self',
    -- flag'-Winline',
      flag'-Winvalid-pch',
      flag'-Wmaybe-uninitialized',
      flag'-Wmissing-include-dirs',
      flag'-Wnarrowing',
      flag'-Wnonnull',
      flag'-Wparentheses',
      flag'-Wpointer-sign',
      flag'-Wreorder',
      flag'-Wsequence-point',
      flag'-Wtrigraphs',
      flag'-Wundef',
      flag'-Wunused-function',
      flag'-Wunused-but-set-variable',
      flag'-Wunused-variable',
      flag'-Wpointer-arith',
      cxx'-Wdeprecated',
      cxx'-Wnon-virtual-dtor',
      cxx'-Woverloaded-virtual',
      c'-Wold-style-definition',
      c'-Wstrict-prototypes',
      c'-Wwrite-strings',

      opt'switch_warnings' {
        Or(lvl'on', lvl'exhaustive_enum') { flag'-Wswitch-enum' } /
        lvl'mandatory_default' { flag'-Wswitch-default' } /
        lvl'exhaustive_enum_and_mandatory_default' {
          flag'-Wswitch',
        } / {
          flag'-Wno-switch'
        },
      },
    }
  },

  opt'warnings_as_error' {
    lvl'on' {
      flag'-Werror',
    } /
    lvl'basic' {
      flag'-diag-error=1079,39,109' -- return-type, div-by-zero, array-bounds
    }
    -- flag'-Wno-error', does not work
  },

  -- opt'pedantic' -- -pedantic does not work ???
  opt'pedantic' {
    lvl'off' {
      flag'-fgnu-keywords',
    } / {
      flag'-fno-gnu-keywords',
    }
  },

  opt'shadow_warnings' {
    lvl'off' {
      flag'-Wno-shadow',
    } /
    Or(lvl'on', lvl'all') {
      flag'-Wshadow'
    }
  },

  opt'stl_debug' {
    -lvl'off' {
      Or(lvl'allow_broken_abi', lvl'allow_broken_abi_and_bugs') {
        cxx'-D_GLIBCXX_DEBUG',
      }
      / cxx'-D_GLIBCXX_ASSERTIONS',
    },
  },

  opt'debug' {
    lvl'off' { flag '-g0' } /
    flag'-g',
  },

  opt'optimization' {
    lvl'0' { flag'-O0', } /
    lvl'g' { flag'-O1', } /
    {
      lvl'1' { flag'-O1', } /
      lvl'2' { flag'-O2', } /
      lvl'3' { flag'-O3', } /
      lvl'z' { flag'-fast', } /
      lvl'size' { flag'-Os', } /
      lvl'fast' { flag'-Ofast' }
    }
  },

  opt'stack_protector' {
    lvl'off' {
      fl'-fno-protector-strong',
      flag'-U_FORTIFY_SOURCE'
    } /
    {
      flag'-D_FORTIFY_SOURCE=2',
      lvl'strong' {
        fl'-fstack-protector-strong',
      } /
      lvl'all' {
        fl'-fstack-protector-all',
      } /
      fl'-fstack-protector',
    },
  },

  opt'relro' {
    lvl'off' { link'-Xlinker-znorelro', } /
    lvl'on'  { link'-Xlinker-zrelro', } /
    lvl'full'{
      link'-Xlinker-zrelro',
      link'-Xlinker-znow',
      link'-Xlinker-znoexecstack',
    },
  },

  opt'pie' {
    lvl'off'{ link'-no-pic', } /
    lvl'on' { link'-pie', } /
    lvl'fpie'{ flag'-fpie', } /
    lvl'fpic'{ flag'-fpic', } /
    lvl'fPIE'{ flag'-fPIE', } /
    lvl'fPIC'{ flag'-fPIC', },
  },

  opt'sanitizers' {
    lvl'on' { flag'-ftrapuv' }
  },

  opt'integer_sanitizers' {
    lvl'on' { flag'-funsigned-bitfields' }
    / flag'-fno-unsigned-bitfields'
  },

  opt'float_sanitizers' {
    lvl'on' {
      flag'-fp-stack-check',
      flag'-fp-trap=common',
    -- flag'-fp-trap=all',
    }
  },

  opt'linker' {
    lvl'bfd' { link'-fuse-ld=bfd' } /
    lvl'gold' { link'-fuse-ld=gold' } /
    link'-fuse-ld=lld'
  },

  opt'lto' {
    lvl'off' { fl'-no-ipo', } / {
      fl'-ipo',
      lvl'fat' {
        linux {
          fl'-ffat-lto-objects',
        }
      }
    }
  },

  opt'control_flow' {
    lvl'off' {
      flag'-mconditional-branch=keep',
      flag'-fcf-protection=none',
    } / {
      lvl'branch' {
        flag'-mconditional-branch=all-fix',
        flag'-fcf-protection=branch',
      } /
      lvl'on' {
        flag'-mconditional-branch=all-fix',
        flag'-fcf-protection=full',
      }
    }
  },

  opt'exceptions' {
    lvl'on' { flag'-fexceptions', } / flag'-fno-exceptions',
  },

  opt'rtti' {
    lvl'on' { cxx'-frtti' } / cxx'-fno-rtti',
  },

  opt'cpu' {
    lvl'generic' { fl'-mtune=generic' } / fl'-xHost',
  },

},

mingw {
  opt'windows_bigobj' {
    flag'-Wa,-mbig-obj',
  },
},

}
end -- MakeAST

function create_ordered_keys(t)
  local ordered_keys = {}

  for k in pairs(t) do
    table_insert(ordered_keys, k)
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

function table_iterator(t)
  local i = 0
  return function()
    i = i + 1
    return t[i]
  end
end

local escaped_table = {
  ['"']='\\"',
  ["'"]="\\'",
  ['\\']='\\\\',
}
function escape(c) return escaped_table[c] end
function quotable(str, q)
  if str then
    if q == '' then
      return str
    end
    q = q and '[' .. q .. ']' or '[\\\"\']'
    return str:gsub(q, escape)
  end
  return ''
end

function quotable_desc(option, newline, q)
  if #option.value_descriptions ~= 0 then
    newline = (newline or '\\n')
    local str = ''
    local desc
    for i,name in ipairs(option.values) do
      desc = option.value_descriptions[i]
      if desc then
        str = str .. newline .. ' - ' .. name .. ': ' .. desc
      end
    end
    return quotable((option.description or '') .. str, q)
  end
  return quotable(option.description, q)
end

Vbase = {
  --[[
    {
      optname={
        values=table[string | table[string(name), string(description)] ],
        default=string | nil,
        description=string | nil,
        incidental=bool,
        unavailable=string | nil
      }
    }
    incidental: options that do not change the ABI (useful for bjam)
    unavailable: language for which this option is not available (c or cpp)
  ]]
  _koptions={
    analyzer={
      values={'off', 'on', 'taint'},
      description='enables an static analysis of program flow which looks for “interesting” interprocedural paths through the code, and issues warnings for problems found on them (much more expensive than other GCC warnings)',
      incidental=true,
    },

    analyzer_too_complex_warning={
      values={'off', 'on'},
      description='By default, the analysis silently stops if the code is too complicated for the analyzer to fully explore and it reaches an internal limit. This option warns if this occurs.',
      incidental=true,
    },

    analyzer_verbosity={
      values={
        {'0', 'At this level, interprocedural call and return events are displayed, along with the most pertinent state-change events relating to a diagnostic. For example, for a double-free diagnostic, both calls to free will be shown.'},
        {'1', 'As per the previous level, but also show events for the entry to each function.'},
        {'2', 'As per the previous level, but also show events relating to control flow that are significant to triggering the issue (e.g. “true path taken” at a conditional). This level is the default.'},
        {'3', 'As per the previous level, but show all control flow events, not just significant ones.'},
      },
      description='controls the complexity of the control flow paths that are emitted for analyzer diagnostics',
      incidental=true,
    },

    color={
      values={'auto', 'never', 'always'},
      incidental=true,
    },

    control_flow={
      values={'off', 'on', 'branch', 'return', 'allow_bugs'},
      description='insert extra runtime security checks to detect attempts to compromise your code',
    },

    conversion_warnings={
      values={'off', 'on', 'sign', 'conversion'},
      default='on',
      description='warn for implicit conversions that may alter a value',
      incidental=true,
    },

    coverage={
      values={'off', 'on'},
    },

    covered_switch_default_warnings={
      values={'on', 'off'},
      default='on',
      description='warning for default label in switch which covers all enumeration values',
      incidental=true,
    },

    cpu={
      values={'generic', 'native'},
    },

    debug={
      values={'off', 'on', 'line_tables_only', 'gdb', 'lldb', 'sce'},
      description='produce debugging information in the operating system\'s',
    },

    diagnostics_format={
      values={'fixits', 'patch', 'print_source_range_info'},
      description='emit fix-it hints in a machine-parseable format',
      incidental=true,
    },

    diagnostics_show_template_tree={
      values={'off', 'on'},
      description='enables printing a tree-like structure showing the common and differing parts of the types',
      incidental=true,
      unavailable='c',
    },

    elide_type={
      values={'off', 'on'},
      description='prints diagnostics showing common parts of template types as "[...]"',
      incidental=true,
      unavailable='c',
    },

    exceptions={
      values={'off', 'on'},
      description='enable C++ exception',
    },

    fix_compiler_error={
      values={'off', 'on'},
      default='on',
      description='transforms some warnings into errors to comply with the standard',
      incidental=true,
    },

    float_sanitizers={
      values={'off', 'on'},
    },

    integer_sanitizers={
      values={'off', 'on'},
    },

    linker={
      values={'bfd', 'gold', 'lld', 'native'},
      description='configure linker',
      incidental=true,
    },

    lto={
      values={'off', 'on', 'fat', 'thin'},
      description='enable Link Time Optimization',
    },

    msvc_isystem={
      values={'anglebrackets', 'include_and_caexcludepath', 'external_as_include_system_flag'},
      description='warnings concerning external header (https://devblogs.microsoft.com/cppblog/broken-warnings-theory)',
      incidental=true,
    },

    msvc_isystem_with_template_from_non_external={
      values={'off', 'on'},
      description='warnings concerning template in an external header (requires msvc_isystem)',
      incidental=true,
      unavailable='c',
    },

    msvc_conformance={
      values={'all', 'all_without_throwing_new'},
      default='all',
      description='standard conformance options',
    },

    msvc_crt_secure_no_warnings={
      values={'off', 'on'},
      default='on',
      description='disable CRT warnings',
      incidental=true,
    },

    ndebug={
      values={'off', 'on', 'with_optimization_1_or_above'},
      default='with_optimization_1_or_above',
      description='enable NDEBUG macro (disable assert macro)',
    },

    noexcept_warnings={
      values={'off', 'on'},
      description='Warn when a noexcept-expression evaluates to false because of a call to a function that does not have a non-throwing exception specification (i.e. "throw()" or "noexcept") but is known by the compiler to never throw an exception.',
      incidental=true,
      unavailable='c',
    },

    optimization={
      values={
        {'0', 'not optimize'},
        {'g', 'enable debugging experience'},
        {'1', 'optimize'},
        {'2', 'optimize even more'},
        {'3', 'optimize yet more'},
        {'fast', 'enables all optimization=3 and disregard strict standards compliance'},
        {'size', 'optimize for size'},
        {'z', 'optimize for size aggressively (/!\\ possible slow compilation)'}
      },
      description='optimization level',
    },

    other_sanitizers={
      values={'off', 'thread', 'pointer', 'memory'},
      description='enable other sanitizers',
    },

    pedantic={
      values={'off', 'on', 'as_error'},
      default='on',
      description='issue all the warnings demanded by strict ISO C and ISO C++',
    },

    pie={
      values={'off', 'on', 'static', 'fpic', 'fPIC', 'fpie', 'fPIE'},
      description='controls position-independent code generation',
    },

    relro={
      values={'off', 'on', 'full'},
      description='specifies a memory segment that should be made read-only after relocation, if supported.',
    },

    reproducible_build_warnings={
      values={'off', 'on'},
      description='warn when macros "__TIME__", "__DATE__" or "__TIMESTAMP__" are encountered as they might prevent bit-wise-identical reproducible compilations',
      incidental=true,
    },

    rtti={
      values={'off', 'on'},
      description='disable generation of information about every class with virtual functions for use by the C++ run-time type identification features ("dynamic_cast" and "typeid")',
      unavailable='c',
    },

    sanitizers={
      values={'off', 'on'},
      description='enable sanitizers (asan, ubsan, etc)',
    },

    stl_debug={
      values={'off', 'on', 'allow_broken_abi', 'allow_broken_abi_and_bugs', 'assert_as_exception'},
      description='controls the debug level of the STL',
      unavailable='c',
    },

    stl_fix={
      values={'off', 'on'},
      default='on',
      description='enable /DNOMINMAX with msvc',
    },

    shadow_warnings={
      values={'off', 'on', 'local', 'compatible_local', 'all'},
      default='off',
      incidental=true,
    },

    stack_protector={
      values={'off', 'on', 'strong', 'all'},
      description='emit extra code to check for buffer overflows, such as stack smashing attacks',
    },

    suggestions={
      values={'off', 'on'},
      description='warn for cases where adding an attribute may be beneficial',
      incidental=true,
    },

    switch_warnings={
      values={'on', 'off', 'exhaustive_enum', 'mandatory_default', 'exhaustive_enum_and_mandatory_default'},
      default='on',
      description='warnings concerning the switch keyword',
      incidental=true,
    },

    var_init={
      values={'pattern'},
      description='initialize all stack variables implicitly, including padding',
    },

    warnings={
      values={'off', 'on', 'strict', 'very_strict'},
      default='on',
      description='warning level',
      incidental=true,
    },

    warnings_as_error={
      values={'off', 'on', 'basic'},
      description='make all or some warnings into errors',
      -- incidental=true,
    },

    whole_program={
      values={'off', 'on', 'strip_all'},
      description='Assume that the current compilation unit represents the whole program being compiled. This option should not be used in combination with lto.',
    },

    windows_abi_compatibility_warnings={
      values={'off', 'on'},
      default='off',
      description='In code that is intended to be portable to Windows-based compilers the warning helps prevent unresolved references due to the difference in the mangling of symbols declared with different class-keys',
      incidental=true,
      unavailable='c',
    },

    windows_bigobj={
      values={'on'},
      default='on',
      description='increases that addressable sections capacity',
    },
  },

  _opts_by_category={
    {'Warning', {
      'analyzer',
      'analyzer_too_complex_warning',
      'analyzer_verbosity',
      'conversion_warnings',
      'covered_switch_default_warnings',
      'fix_compiler_error',
      'windows_abi_compatibility_warnings',
      'msvc_crt_secure_no_warnings',
      'noexcept_warnings',
      'reproducible_build_warnings',
      'shadow_warnings',
      'suggestions',
      'switch_warnings',
      'warnings',
      'warnings_as_error',
    }},
    {'Pedantic', {
      'pedantic',
      'stl_fix',
      'msvc_conformance',
    }},
    {'Debug', {
      'control_flow',
      'debug',
      'float_sanitizers',
      'integer_sanitizers',
      'ndebug',
      'optimization',
      'other_sanitizers',
      'sanitizers',
      'stl_debug',
      'var_init',
    }},
    {'Optimization', {
      'cpu',
      'linker',
      'lto',
      'optimization',
      'whole_program',
    }},
    {'C++', {
      'exceptions',
      'rtti',
    }},
    {'Hardening', {
      'control_flow',
      'relro',
      'stack_protector',
    }},
    -- other categories are automatically put in Other
  },

  _opts_build_type={
    debug={debug='on', stl_debug='on', control_flow='on', sanitizers='on',},
    release={linker='native', lto='on', optimization='3',},
    debug_optimized={linker='native', lto='on', optimization='g', debug='on',},
    minimum_size_release={linker='native', lto='on', optimization='size',},
  },

  indent = '  ',
  if_prefix = '',
  -- table of optname=true or {optname={optvalue=true}}
  ignore = {},

  start = noop, -- function(self) end,
  stop = function(self, filebase) return self:get_output() end,

  _strs = {},
  print = function(self, s) self:write(s) self:write('\n') end,
  print_header = function(self, prefix)
    self:write(prefix)
    self:write(' File generated with https://github.com/jonathanpoelen/cpp-compiler-options\n\n')
  end,
  write = function(self, s) table_insert(self._strs, s) end,
  get_output = function(self) return table.concat(self._strs) end,

  startoptcond = noop, -- function(self, name) end,
  stopopt = noop, -- function(self) end,

  startcond = noop, -- function(self, x, optname) end,
  elsecond = noop, -- function(self, optname) end,
  stopcond = noop, -- function(self, optname) end,

  cxx = noop,
  link = noop,
  act = function(self, name, datas, optname) error('Unknown action: ' .. name) end,

  _vcond_init = function(self, keywords)
    self._vcondkeyword = keywords or {}
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
     eq = ' == ',
     not_eq = ' != ',
     less = ' < ',
     less_eq = ' <= ',
     greater = ' > ',
     greater_eq = ' >= ',
     version = 'compversion',
     compiler = 'compiler',
     linker = 'linker',
     platform = 'platform',
     options = 'options',
    }) do
      if not self._vcondkeyword[k] then
        self._vcondkeyword[k] = v
      end
    end
    self._vcondkeyword['='] = self._vcondkeyword.eq
    self._vcondkeyword['!='] = self._vcondkeyword.not_eq
    self._vcondkeyword['<'] = self._vcondkeyword.less
    self._vcondkeyword['<='] = self._vcondkeyword.less_eq
    self._vcondkeyword['>'] = self._vcondkeyword.greater
    self._vcondkeyword['>='] = self._vcondkeyword.greater_eq
    self._vcondkeyword.ifopen = self._vcondkeyword.ifopen or self._vcondkeyword.open
    self._vcondkeyword.ifclose = self._vcondkeyword.ifclose or self._vcondkeyword.close
    self._vcondkeyword.endif = self._vcondkeyword.endif or self._vcondkeyword.closeblock
    if #self._vcondkeyword.ifopen ~= 0 then self._vcondkeyword.ifopen = ' ' .. self._vcondkeyword.ifopen .. ' ' end
    if #self._vcondkeyword.ifclose ~= 0 then self._vcondkeyword.ifclose = ' ' .. self._vcondkeyword.ifclose end

    local write_logical = function(self, a, k, optname)
      self:write(' ' .. self._vcondkeyword.open)
      self:_vcond(a[1], optname)
      for i=2,#a do
        self:write(' ' .. k)
        self:_vcond(a[i], optname)
      end
      self:write(' ' .. self._vcondkeyword.close)
    end

    local reverse_ops = {
      ['=']='!=',
      ['<']='>=',
      ['>']='<=',
      ['<=']='>',
      ['>=']='<',
      ['!=']='=',
    }

    self._vcond = function(self, v, optname)
          if v._or      then write_logical(self, v._or, self._vcondkeyword._or, optname)
      elseif v._and     then write_logical(self, v._and, self._vcondkeyword._and, optname)
      elseif v._not     then
        local notv = v._not
            if notv.lvl      then self:write(' ' .. self:_vcond_lvl(notv.lvl, optname, true))
        elseif notv.major    then self:write(' ' .. self._vcond_version(self, reverse_ops[notv.op], notv.major, notv.minor))
        elseif notv.compiler then self:write(' ' .. self:_vcond_compiler(notv.compiler, true))
        elseif notv.platform then self:write(' ' .. self:_vcond_platform(notv.platform, true))
        elseif notv.linker   then self:write(' ' .. self:_vcond_linker(notv.linker, true))
        else                      self:write(' ' .. self._vcondkeyword._not
                                          .. ' ' .. self._vcondkeyword.open)
                                  self:_vcond(notv, optname)
                                  self:write(' ' .. self._vcondkeyword.close)
        end
      elseif v.lvl      then self:write(' ' .. self:_vcond_lvl(v.lvl, optname), false)
      elseif v.major    then self:write(' ' .. self._vcond_version(self, v.op, v.major, v.minor))
      elseif v.compiler then self:write(' ' .. self:_vcond_compiler(v.compiler), false)
      elseif v.platform then self:write(' ' .. self:_vcond_platform(v.platform), false)
      elseif v.linker   then self:write(' ' .. self:_vcond_linker(v.linker), false)
      else error('Unknown cond ', ipairs(v))
      end
    end

    self.eq_op = function(self, not_)
      if not_ then
        return self._vcondkeyword.not_eq
      end
      return self._vcondkeyword.eq
    end

    self._vcond_to_opt = self._vcond_to_opt or function(self, optname)
      return self._vcondkeyword.options .. "['" .. optname .. "']"
    end

    self._vcond_to_lvl = self._vcond_to_lvl or function(self, lvl, optname)
      return "'" .. lvl .. "'"
    end

    self._vcond_to_version = self._vcond_to_version or function(self, major, minor)
      return "'" .. tostring(major) .. '.' .. tostring(minor) .. "'"
    end

    self._vcond_to_compiler = self._vcond_to_compiler or function(self, compiler)
      return "'" .. compiler .. "'"
    end

    self._vcond_to_linker = self._vcond_to_linker or function(self, linker)
      return "'" .. linker .. "'"
    end

    self._vcond_to_platform = self._vcond_to_platform or function(self, platform)
      return "'" .. platform .. "'"
    end

    self._vcond_lvl = self._vcond_lvl or function(self, lvl, optname, not_)
      return self:_vcond_to_opt(optname) .. self:eq_op(not_) .. self:_vcond_to_lvl(lvl, optname)
    end

    self._vcond_version = self._vcond_version or function(self, op, major, minor)
      return self._vcondkeyword.version .. self._vcondkeyword[op] .. self:_vcond_to_version(major, minor)
    end

    self._vcond_compiler = self._vcond_compiler or function(self, compiler, not_)
      return self._vcondkeyword.compiler .. self:eq_op(not_) .. self:_vcond_to_compiler(compiler)
    end

    self._vcond_linker = self._vcond_linker or function(self, linker, not_)
      return self._vcondkeyword.linker .. self:eq_op(not_) .. self:_vcond_to_linker(linker)
    end

    self._vcond_platform = self._vcond_platform or function(self, platform, not_)
      return self._vcondkeyword.platform .. self:eq_op(not_) .. self:_vcond_to_platform(platform)
    end

    self.propagate_not = function(self, string_expr, not_)
      if not_ then
        return self:not_expr(string_expr)
      end
      return string_expr
    end

    self.not_expr = self.not_expr or function(self, string_expr)
      return ' ' .. self._vcondkeyword._not
          .. ' ' .. self._vcondkeyword.open
          .. ' ' .. string_expr
          .. ' ' .. self._vcondkeyword.close
    end

    self.startoptcond = function(self, optname)
      self:_vcond_printflags()
      self:print(self.indent .. self._vcondkeyword._if .. self._vcondkeyword.ifopen
              .. ' ' .. self:_vcond_lvl('default', optname, true) .. self._vcondkeyword.ifclose)
      if #self._vcondkeyword.openblock ~= 0 then
        self:print(self.indent .. self._vcondkeyword.openblock)
      end
    end

    self.startcond = function(self, x, optname)
      self:_vcond_printflags()
      self:write(self.indent .. self.if_prefix .. self._vcondkeyword._if .. self._vcondkeyword.ifopen)
      self.if_prefix = ''
      self:_vcond(x, optname)
      self:print(self._vcondkeyword.ifclose)
      if #self._vcondkeyword.openblock ~= 0 then
        self:print(self.indent .. self._vcondkeyword.openblock)
      end
    end

    self.elsecond = function(self)
      self:_vcond_printflags()
      local oldindent = self.indent
      self.indent = oldindent:sub(1, #oldindent-2)
      if #self._vcondkeyword.closeblock ~= 0 then
        self:print(self.indent .. self._vcondkeyword.closeblock)
      end
      self:print(self.indent .. self._vcondkeyword._else)
      if #self._vcondkeyword.openblock ~= 0 then
        self:print(self.indent .. self._vcondkeyword.openblock)
      end
      self.indent = oldindent
    end

    self.stopcond = function(self)
      self:_vcond_printflags()
      self.indent = self.indent:sub(1, #self.indent-2)
      if #self._vcondkeyword.endif ~= 0 then
        self:print(self.indent .. self._vcondkeyword.endif)
      end
    end

    self._vcond_flags_cxx = ''
    self._vcond_flags_link = ''
    self._vcond_toflags = self._vcond_toflags or function(self, cxx, link)
      return cxx and link and cxx .. link or cxx or link
    end
    self._vcond_printflags = function(self)
      if #self._vcond_flags_cxx ~= 0 or #self._vcond_flags_link ~= 0 then
        local s = self:_vcond_toflags(self._vcond_flags_cxx, self._vcond_flags_link)
        if s and #s ~= 0 then self:write(s) end
      end
      self._vcond_flags_cxx = ''
      self._vcond_flags_link = ''
    end

    local accu = function(k, f)
      return function(t, x)
        t[k] = t[k] .. f(t, x)
      end
    end

    self.cxx = accu('_vcond_flags_cxx', self.cxx)
    self.link = accu('_vcond_flags_link', self.link)
  end,

  _computed_options = nil,
  -- iterator of option:
  -- {
  --   name=string,
  --   values=table[string],
  --   ordered_values=table[string],
  --   default=string,
  --   description=string | nil,
  --   value_descriptions=table[string]
  --   incidental=bool,
  -- }
  getoptions=function(self)
    local computed_options = self.__computed_options

    if not computed_options then
      computed_options = {}
      self._computed_options = computed_options
      local ignore = self.ignore
      local lang = self.lang

      for i,k in ipairs(create_ordered_keys(self._koptions)) do
        local filter = ignore[k]
        local option = self._koptions[k]
        if filter ~= true and lang ~= option.unavailable then
          if filter then
            local newvalues = {}
            for j,value in ipairs(option.values) do
              if not filter[value] then
                table_insert(newvalues, value)
              end
            end
            option = {
              values=newvalues,
              default=filter[option.default] or option.default,
              description=option.description,
              value_descriptions=option.value_descriptions,
              incidental=option.incidental,
            }
          end

          option.name = k
          default_value = option.default or 'default'
          option.default = default_value

          local ordered_values = option.values
          if default_value ~= ordered_values[1] then
            ordered_values = {default_value}
            for i,value in pairs(option.values) do
              if value ~= default_value then
                table_insert(ordered_values, value)
              end
            end
          end
          option.ordered_values = ordered_values
          table_insert(computed_options, option)
        end
      end
    end

    return table_iterator(computed_options)
  end,

  _computed_build_types = nil,

  -- iterator of (catname, option_names)
  getbuildtype=function(self)
    local computed_build_types = self._computed_build_types
    if not computed_build_types then
      computed_build_types = {}
      self._computed_build_types = computed_build_types
      for i,k in pairs(create_ordered_keys(self._opts_build_type)) do
        local values = {}
        local profile = self._opts_build_type[k]
        for i,kv in pairs(create_ordered_keys(profile)) do
          table_insert(values, {kv, profile[kv]})
        end
        table_insert(computed_build_types, {k, values})
      end
      table_insert(computed_build_types, {nil, nil})
    end

    return unpack_table_iterator(computed_build_types)
  end,
}

-- post treatment of _koptions:
--   check not 'default' value
--   add kvalues (dict[value]=true)
--   add value_descriptions (dict[i]=description)
for optname,option in pairs(Vbase._koptions) do
  local kvalues = {}
  local value_descriptions = {}
  for k,v in ipairs(option.values) do
    if type(v) == 'table' then
      value_descriptions[k+1] = v[2]
      v = v[1]
      option.values[k] = v
    end
    kvalues[v] = true
  end
  if kvalues['default'] then
    error('Vbase._koptions[' .. optname .. '] integrity error: "default" value is used')
  end
  table.insert(option.values, 1, 'default')
  option.value_descriptions = value_descriptions
  option.kvalues = kvalues
  kvalues.default = true
end

-- check values of Vbase._opts_build_type
for name,options in pairs(Vbase._opts_build_type) do
  for optname,v in pairs(options) do
    local opt = Vbase._koptions[optname]
    if not opt then
      error('Vbase._opts_build_type['.. name .. ']: unknown option ' .. optname)
    end
    if not opt.kvalues[v] then
      error('Vbase._opts_build_type['.. name .. ']: unknown value ' .. optname .. '.' .. v)
    end
  end
end

-- check _opts_by_category
for _,cat in pairs(Vbase._opts_by_category) do
  for _,optname in ipairs(cat[2]) do
    if not Vbase._koptions[optname] then
      error('Vbase._opts_by_category: unknown option ' .. optname)
    end
  end
end


function evalflagselse(t, v, curropt)
  if t._else then
    v:elsecond(curropt)
    evalflags(t._else, v, curropt)
  end
end

function evalflags(t, v, curropt)
  if t._if then
    local opt = t._if.opt
    if opt then
      if not v._koptions[opt] then
        error('Unknown "' .. opt .. '" option')
      end
      if v.ignore[opt] ~= true then
        local r = v:startoptcond(opt)
        v.indent = v.indent .. '  '
        if r ~= false then
          evalflags(t._t, v, opt)
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
      v.indent = v.indent .. '  '
      if r ~= false and t._t then
        evalflags(t._t, v, curropt)
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

function clone_table(t)
  local newt = {}
  for k,v in pairs(t) do
    if type(v) == 'table' then
      newt[k] = clone_table(v)
    else
      newt[k] = v
    end
  end
  return newt
end

_g_generators = {}
function get_generator(name)
  name = name:gsub('.lua$', '')
  local generator = _g_generators[name]

  if generator then
    return clone_table(generator)
  end

  generator = require(name)
  insert_missing_function(generator)

  -- check values of ignore
  for k,mem in pairs(generator.ignore) do
    local opt = Vbase._koptions[k]
    if not opt then
      error('Unknown ' .. k .. ' in ignore table')
    end

    if mem and mem ~= true then
      local kval = opt.kvalues
      for value,ok in pairs(mem) do
        if value == 'default' then
          error('value ' .. k .. '.' .. value .. ' is reserved')
        end
        if not kval[value] then
          error('Unknown ' .. k .. '.' .. value .. ' in ignore table')
        end
      end
    end
  end

  _g_generators[name] = generator
  return clone_table(generator)
end

function insert_missing_function(V)
  for k,mem in pairs(Vbase) do
    if not V[k] then
      V[k] = mem
    end
  end
end

function run(ast, is_C, filebase, ignore_options, generator_name, ...)
  local V = get_generator(generator_name)

  -- add ignore from cli
  for name,x in pairs(ignore_options) do
    local y = V.ignore[name]
    if x == true then
      V.ignore[name] = true
    elseif y ~= true then
      if y then
        -- merge tables
        for name2 in pairs(x) do
          y[name2] = true
        end
      else
        V.ignore[name] = x
      end
    end
  end

  V.is_C = is_C
  V.lang = is_C and 'c' or 'cpp'
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

  evalflags(ast, V)

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
  local prefix = string.rep(' ', #arg[0]+1)
  out:write(arg[0] .. ' [-p] [-c|-C] [-o outfilebase]\n'
         .. prefix .. '[-f [-]{option_name[=value_name][,...]}]\n'
         .. prefix .. '[-t [-]{tool_or_platform[,...]]\n'
         .. prefix .. '[-d option_name=value_name[,...]]\n'
         .. prefix .. '{generator.lua} [-h|{options}...]\n'
         .. prefix .. '[--- same options]\n\n' .. [==[
  -p  Print an AST.
  -c  Generator for C, not for C++.
  -C  Generator for C++, not for C. (default)
  -t  Restrict to a list of platform, compiler or linker.
      When the list is prefixed with '-', values are removed from current AST.
      Use -C list to display the list of tools and platforms.
  -f  Restrict to a list of option/value.
      When the list is prefixed by '-', options/values are removed.
  -d  Set new default value. An empty string for value_name is equivalent
      to 'default'.
]==])
end

function check_optname(cond, optname)
  if not cond then
    io.stderr:write(arg[0] .. ": Unknown option: " .. optname .. '\n')
    os.exit(2)
  end
end

function check_optvalue(cond, optname, optvalue)
  if not cond then
    io.stderr:write(arg[0] .. ": Unknown value: " .. optvalue .. ' in ' .. optname .. '\n')
    os.exit(2)
  end
end

-- {[0]=enabled, remove:bool, [platform_or_compiler_or_linker]=true, ...}
tools_filter = {
  enabled=false,
  remove=false,
  ktools_filter={},
  tools={
    {'platform', {
      'linux',
      'macos',
      'mingw',
      'windows',
    }},
    {'compiler', {
      'gcc',
      'clang',
      'clang-cl',
      'msvc',
      'icc',
      'icl',
    }},
    {'linker', {
      'ld64',
      'lld-link',
    }},
  }
}

local filebase
local ignore_options = {}
local is_C = false
local print_ast = false
local run_params = {}

function push_run_params()
  local params = {is_C, filebase, ignore_options}
  table_insert(run_params, params)
  filebase = nil
  ignore_options = {}
  is_C = false
  return params
end

cli={
  c={function() is_C=true end},
  C={function() is_C=false end},
  h={function() help(io.stdout) os.exit(0) end},
  p={function() print_ast=true end},

  o={arg=true, function(value)
    filebase = (value ~= '-') and value or nil
  end},

  -- Set new default value
  d={arg=true, function(value)
    for optname,optvalue in value:gmatch('([_%w]+)=([_%w]*)') do
      local option = Vbase._koptions[optname]
      check_optname(option, optname)

      if optvalue == '' or optvalue == 'default' then
        option.default = nil
      else
        check_optvalue(option.kvalues[optvalue], optname, optvalue)
        option.default = optvalue
      end
    end
  end},

  -- Restrict to a list of platform, compiler or linker.
  t={arg=true, function(value)
    if value == 'list' then
      local newline = false
      for _,t in ipairs(tools_filter.tools) do
        if newline then
          print()
        end
        print(t[1] .. ':')
        for _,tool in ipairs(t[2]) do
          print('- ' .. tool)
        end
        newline = true
      end
      os.exit(0)
    end

    -- make ktools {tool=true} and ktypes {['compiler'|...]}=true}
    local ktools = tools_filter.ktools
    if not ktools then
      ktools = {}
      local ktypes = {}
      for _,t in ipairs(tools_filter.tools) do
        ktypes[t[1]] = true
        for _,tool in ipairs(t[2]) do
          ktools[tool] = true
        end
      end
      tools_filter.ktools = ktools
      tools_filter.ktypes = ktypes
    end

    tools_filter.enabled = true
    if value:match('^-') then
      tools_filter.remove = true
      value = value:sub(2)
    end

    local ktools_filter = tools_filter.ktools_filter
    for tool in value:gmatch('([-_%w]+)') do
      if ktools[tool] then
        ktools_filter[tool] = true
      else
        io.stderr:write('Unknown tool: ' .. tool .. ' with -C\n')
        help(io.stderr)
        os.exit(1)
      end
    end
  end},

  -- Restrict to a list of option/value.
  f={arg=true, function(value)
    for optname,optvalue in value:gmatch('([_%w]+)=?([_%w]*)') do
      local option = Vbase._koptions[optname]
      check_optname(option, optname)

      if optvalue ~= '' then
        check_optvalue(option.kvalues[optvalue], optname, optvalue)
        local t = ignore_options[optname]
        if t then
          -- optname takes priority over optname=xxx
          if t ~= true then
            t[optvalue] = true
          end
        else
          ignore_options[optname] = {[optvalue]=true}
        end
      else
        ignore_options[optname] = true
      end
    end

    if value:sub(1,1) ~= '-' then
      local select_options = ignore_options
      ignore_options = {}
      for optname in pairs(Vbase._koptions) do
        local v = select_options[optname]
        if not v then
          ignore_options[optname] = true
        elseif v ~= true then
          local t = {}
          for k in pairs(optkv[optname]) do
            if not v[k] then
              t[k] = true
            end
          end
          ignore_options[optname] = t
        end
      end
    end
  end},
}

function getoption(s, pos)
  local flag = s:sub(2,2)
  local opt = cli[flag]
  if not opt then
    io.stderr:write('Unknown option: -' .. flag .. ' in ' .. s .. '\n')
    os.exit(2)
  end
  return opt
end

opti=1
while opti <= #arg do
  local s = arg[opti]

  -- is a generator name
  if s:sub(1,1) ~= '-' then
    if print_ast then
      push_run_params()
      break
    end

    while opti <= #arg do
      local params = push_run_params()

      -- find separator of generator
      for i=opti,#arg do
        s = arg[i]
        if s == '---' then
          opti = opti + 1
          break
        end
        table_insert(params, s)
      end

      opti = opti + #params - 3
      s = arg[opti]

      -- the next group start with a named option
      if s and s:sub(1,1) == '-' then
        break
      end
    end

    if opti > #arg then
      opti = opti - 1
      break
    end
  end

  local opt = getoption(s, 2)
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
    if #arg[opti] ~= ipos then
      value = s:sub(ipos+1)
    else
      opti = opti+1
      value = arg[opti]
      if not value then
        help(io.stderr)
        os.exit(2)
      end
    end
    opt[1](value)
  end

  opti = opti+1
end

if opti > #arg and not print_ast then
  io.stderr:write('Missing generator file\n\n')
  help(io.stderr)
  os.exit(1)
end

ast_c = nil
ast_cpp = nil

for _, params in ipairs(run_params) do
  if params[1] then
    ast_c = ast_c or MakeAST(true)
    ast = ast_c
  else
    ast_cpp = ast_cpp or MakeAST(false)
    ast = ast_cpp
  end

  if tools_filter.enabled then
    local keep = not tools_filter.remove
    local ktypes = tools_filter.ktypes
    local ktools_filter = tools_filter.ktools_filter

    function filter_cond(t) --: true = keep, false = remove, nil = unchanged
      for k,v in pairs(t) do
        if k == '_and' then
          for _,x in ipairs(v) do
            local r = filter_cond(x)
            if r == false then
              return false
            end
          end
        elseif k == '_or' then
          local r
          local is_true = false
          local is_nil = false
          local newt = {}
          for _,x in ipairs(v) do
            r = filter_cond(x)
            if r ~= false then
              table_insert(newt, x)
              if r == nil then
                is_nil = true
              else
                is_true = true
              end
            end
          end
          t._or = newt
          if is_nil then
            return nil
          end
          return is_true
        elseif k == '_not' then
          local r = filter_cond(v)
          if r ~= nil then
            return not r
          end
        elseif k == '_if' then
          return filter_cond(v)
        elseif ktypes[k] then
          return keep == (ktools_filter[v] or false)
        end
      end
    end

    function filter_ast(t)
      if t._if then
        local r = filter_cond(t._if)
        if r == false then
          if not t._else or filter_ast(t._else) == false then
            return false
          end
          t._if = t._if._not or {_not=t._if}
          t._t = t._else
          t._else = nil
          return nil
        elseif r == true then
          t._else = nil
        elseif t._else and filter_ast(t._else) == false then
          t._else = nil
        end
      end

      if t._t then
        t = t._t
      end

      if #t > 0 then
        local return_false = true
        for k,v in ipairs(t) do
          if filter_ast(v) == false then
            t[k] = nil
          else
            return_false = false
          end
        end
        if return_false then
          return false
        end
      end
    end

    if filter_ast(ast) == false then
      ast = {}
    end
  end

  if print_ast then
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
        local newprefix = prefix..'  '

        for _,k in ipairs(_print_ast_ordered_vars) do
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
      else
        io.stdout:write(ast..'\n')
      end
      return ast
    end

    printAST(ast, '')
    io.stdout:flush()
  else
    run(ast, unpack(params))
  end
end
