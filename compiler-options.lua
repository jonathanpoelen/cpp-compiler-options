#!/usr/bin/env lua

local table_insert = table.insert
local unpack = table.unpack or unpack

local function has_value(t)
  return pairs(t)(t)
end

local function remove_empty_block(node)
  if #node ~= 0 then
    for k,inner_node in pairs(node) do
      if inner_node._if and not has_value(inner_node._t) or not has_value(inner_node) then
        assert(not inner_node._else)
        node[k] = nil
      end
    end
  end
end

local if_mt -- referenced by __unm
if_mt = {
  __call = function(self, node)
    assert(not self._t, '`_t` is not nil')

    if node._if then
      assert(not node._else)
      if not has_value(inner_node._t) then
        node = {}
      end
    else
      remove_empty_block(node)
    end

    self._t = node
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
  __unm = function(self)
    return -self._impl()
  end,
}

local function If(condition)
  return setmetatable({ _if=condition }, if_mt)
end

local function IfFunc(f)
  return setmetatable({ _impl=f }, if_mt_func)
end

local function Logical(op, conditions)
  local conds = {}
  for _,x in ipairs(conditions) do
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

local function _conditional_name(cond)
  return IfFunc(function(x)
    local r = If(cond)
    return x and r(x) or r
  end)
end

local function vers(op_and_version)
  local op, major, minor = op_and_version:match('^([<>!=]=?)(%d+)%.?(%d*)$')
  assert(op)
  return If({op=op, major=tonumber(major), minor=tonumber(minor) or 0})
end

local function _conditional_name_with_version(cond)
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

local function Compiler(name)
  return _conditional_name_with_version({compiler=name})
end

local function Platform(name)
  return _conditional_name({platform=name})
end

local function Linker(name)
  return _conditional_name({linker=name})
end

local function CompilerLike(compiler_like, compilers)
  local tools = {}
  for _,tool in ipairs(compilers) do
    table_insert(tools, tool()._if.compiler)
  end
  return _conditional_name_with_version({compiler_like=compiler_like, compilers=tools})
end

local function Or(...) return Logical('_or', {...}) end
local function And(...) return Logical('_and', {...}) end

local function lvl(x) return If({lvl=x}) end
local function opt(x) return If({opt=x}) end

local has_opt_mt = {
  __call = function(self, ...)
    -- assert(#self.levels > 0)
    return If({check_opt={optname=self.optname, levels=self.levels, exclude=self.exclude}})(...)
  end,
  with = function(self, ...)
    assert(not self._used)
    self._used = true

    local levels = self.levels
    local set = {}
    local lvl
    for _, cond in pairs({...}) do
      lvl = assert(cond._if.lvl)
      assert(not set[lvl])
      table_insert(levels, lvl)
      set[lvl] = true
    end

    assert(#levels ~= 0)
    return self
  end,
  without = function(self, ...)
    self.exclude = true
    return self:with(...)
  end,
}
has_opt_mt.__index = has_opt_mt

local function has_opt(optname)
  return setmetatable({optname=optname, levels={}}, has_opt_mt)
end

-- local windows = Platform('windows')
-- local macos = Platform('macos')
local linux = Platform('linux')
local mingw = Platform('mingw')

local gcc = Compiler('gcc')
local clang = Compiler('clang')
local clang_cl = Compiler('clang-cl')
local msvc = Compiler('msvc')
local icc = Compiler('icc')
local icl = Compiler('icl')
-- local emcc = Compiler('emcc')
local clang_emcc = Compiler('clang-emcc') -- virtual compiler, refer to clang version
local clang_like = CompilerLike('clang-like', {clang, clang_cl, clang_emcc})

-- for clang-emcc to emcc
-- local switch_to_real_compiler = {switch_to_special=true}

-- local msvc_linker = Linker('msvc')
local lld_link = Linker('lld-link')
local ld64 = Linker('ld64') -- Apple ld64

local function link(x) return { link=x } end
local function flag(x) return { cxx=x } end
local function fl(x) return { cxx=x, link=x } end
local function act(datas) return { act={datas} } end
local function reset_opt(name) return { reset_opt=name } end
function noop() end

local function _not_cond(elem)
  elem = elem._if
  return elem._not or {_not = elem}
end

local function match(t)
  assert(t[1]._if, 'not a condition')

  local first, curr_elem, merged_cond, next_elem
  for i,next_elem in ipairs(t) do
    assert(next_elem._if or i == #t, 'condition after a non condition')
    assert(not next_elem._else, 'contains a else')

    if next_elem._if then
      -- remove empty block and merge with next condition
      if not has_value(next_elem._t) then
        if merged_cond then
          merged_cond = {_and = {merged_cond, _not_cond(next_elem)}}
        else
          merged_cond = _not_cond(next_elem)
        end
        goto continue
      elseif merged_cond then
        next_elem._if = {_and = {merged_cond, next_elem._if}}
        merged_cond = nil
      end
    else
      remove_empty_block(next_elem)

      -- skip empty block
      if not has_value(next_elem) then
        assert(i == #t)
        break
      end

      if merged_cond then
        next_elem = {_if = merged_cond, _t = next_elem}
        merged_cond = nil
      end
    end

    if first then
      curr_elem._else = next_elem
      curr_elem = curr_elem._else
    else
      first = next_elem
      curr_elem = first
    end
    ::continue::
  end
  return {first}
end

local function if_else(condition, f)
  return match { condition { f(true) }, f() }
end

local function MakeAST(is_C)

local c, cxx
if is_C then
  c = flag
  cxx = noop
else
  c = noop
  cxx = flag
end

-- opt'build' ? -pipe Avoid temporary files, speeding up builds

-- gcc / clang:
-- all warnings by version: https://github.com/pkolbus/compiler-warnings

-- gcc:
-- g++ -Q --help=optimizers,warnings,target,params,common,undocumented,joined,separate,language__ -O3
-- https://gcc.gnu.org/onlinedocs/

-- clang:
-- https://clang.llvm.org/docs/index.html
-- https://clang.llvm.org/docs/DiagnosticsReference.html
-- https://clang.llvm.org/docs/ClangCommandLineReference.html
-- https://releases.llvm.org/10.0.0/tools/clang/docs/DiagnosticsReference.html
-- https://github.com/llvm-mirror/clang/blob/master/include/clang/Driver/Options.td
-- https://github.com/llvm-mirror/clang/blob/master/include/clang/Basic/Diagnostic.td

-- clang-cl
-- https://clang.llvm.org/docs/UsersManual.html#id9
-- or clang --driver-mode=cl -help

-- msvc
-- new warnings by version: https://learn.microsoft.com/en-us/cpp/error-messages/compiler-warnings/compiler-warnings-by-compiler-version
-- off by default: https://learn.microsoft.com/en-us/cpp/preprocessor/compiler-warnings-that-are-off-by-default
-- syntax (https://learn.microsoft.com/en-us/cpp/build/reference/compiler-option-warning-level)
--  /w1nnnn (/w14583) <- enable for report level 1
--  /wennnn (/we4583) <- as error
--  /wdnnnn (/wd4583) <- disable
-- https://github.com/microsoft/STL/wiki/Macro-_MSVC_STL_UPDATE
-- https://docs.microsoft.com/en-us/cpp/build/reference/linker-options
-- https://docs.microsoft.com/en-us/cpp/build/reference/compiler-options-listed-alphabetically

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
  return match {
    lvl'off' { undef },
    lvl'on' { def },
    { --[[lvl'with_optimization_1_or_above']]
      has_opt'optimization':without(lvl'0', lvl'g') {
        def
      }
    }
  }
end

-- cond: match expresison
-- f: ((code) -> string)
local msvc_select_warn = function(cond, prefix_ok, prefix_else, f)
  prefix_ok = '/w' .. prefix_ok
  prefix_else = '/w' .. prefix_else
  return match {
    cond(f(function(code) return prefix_ok .. code end)),
    f(function(code) return prefix_else .. code end)
  }
end

return --[[printAST]] {

opt'ndebug' {
  match {
    Or(msvc, icl) {
      ndebug_decl(flag'/DNDEBUG', flag'/UNDEBUG')
    }, {
      ndebug_decl(flag'-DNDEBUG', flag'-UNDEBUG')
    }
  }
},

Or(gcc, clang_like) {
  opt'warnings' {
    match {
      lvl'off' { flag'-w' },
      lvl'essential' {
        flag'-Wall',
        flag'-Wextra',
        c'-Wwrite-strings',
      },
      -- on, extensive
      match {
        gcc {
          flag'-Wall',
          -- flag'-Weffc++',
          flag'-Wextra',
          vers'<8' {
            flag'-Wcast-align',
          },
          flag'-Wcast-qual',
          flag'-Wdisabled-optimization',
          flag'-Wfloat-equal',
          flag'-Wformat-security',
          flag'-Wformat=2',
          -- flag'-Winline',
          flag'-Winvalid-pch',
          flag'-Wmissing-declarations',
          flag'-Wmissing-include-dirs',
          flag'-Wpacked',
          flag'-Wredundant-decls',
          flag'-Wundef',
          flag'-Wunused-macros',
          flag'-Wpointer-arith',
          -- flag'-Wstrict-overflow=2',
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
                          flag'-Wcast-align=strict',
                          flag'-Wformat-truncation=2', -- gcc-8 avoiding certain kinds of false positives
                          flag'-Wshift-overflow=2',
                          cxx'-Wclass-memaccess',

                          vers'>=14' {
                            flag'-Walloc-size',
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          },

          lvl'extensive' {
            -- flag'-Wstrict-overflow=2',
            vers'>=8' {
              flag'-Wstringop-overflow=4',
              vers'>=12' {
                flag'-Wuse-after-free=3',
              }
            }
          },
        },
        { --[[clang_like]]
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
          -- flag'-Qunused-arguments',

          -has_opt'switch_warnings':with(
            lvl'off',
            lvl'exhaustive_enum',
            lvl'exhaustive_enum_and_mandatory_default'
          ) {
            flag'-Wno-switch-enum',
          },

          -has_opt'covered_switch_default_warnings' {
            flag'-Wno-covered-switch-default'
          },

          opt'conversion_warnings' {
            match {
              lvl'conversion' {
                flag'-Wno-sign-compare',
                flag'-Wno-sign-conversion',
              },
              Or(lvl'float', lvl'sign') {
                flag'-Wno-conversion',
              },
            }
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

                    vers'>=16' {
                      -has_opt'unsafe_buffer_usage_warnings' {
                        flag'-Wno-unsafe-buffer-usage'
                      },
                    }
                  }
                }
              }
            }
          }
        },
      }
    },
  },

  match {
    gcc {
      opt'switch_warnings' {
        match {
          lvl'on' { flag'-Wswitch' }, -- enabled by -Wall
          lvl'exhaustive_enum' { flag'-Wswitch-enum' },
          lvl'mandatory_default' { flag'-Wswitch-default' },
          lvl'exhaustive_enum_and_mandatory_default' {
            flag'-Wswitch-default',
            flag'-Wswitch-enum',
          },
          { --[[lvl'off']]
            flag'-Wno-switch',
            flag'-Wno-switch-enum',
            flag'-Wno-switch-default',
          }
        }
      }
    },
    { --[[clang_like]]
      opt'switch_warnings' {
        -- -Wswitch-default is a noop with < 18.0
        match {
          lvl'on' {
            flag'-Wswitch', -- enabled by default
            flag'-Wno-switch-default',
          },
          lvl'mandatory_default' {
            flag'-Wswitch', -- enabled by default
            flag'-Wswitch-default',
          },
          lvl'exhaustive_enum' {
            flag'-Wswitch', -- do like gcc where -Wswitch-enum covers cases of -Wswitch
            flag'-Wswitch-enum',
            flag'-Wno-switch-default',
          },
          lvl'exhaustive_enum_and_mandatory_default' {
            flag'-Wswitch', -- do like gcc where -Wswitch-enum covers cases of -Wswitch
            flag'-Wswitch-enum',
            flag'-Wswitch-default',
          },
          { --[[lvl'off']]
            flag'-Wno-switch',
            flag'-Wno-switch-enum',
            flag'-Wno-switch-default',
          }
        }
      },

      opt'covered_switch_default_warnings' {
        match {
          lvl'off' { flag'-Wno-covered-switch-default' },
          flag'-Wcovered-switch-default',
        }
      },
    }
  },

  opt'unsafe_buffer_usage_warnings' {
    clang_like'>=16' {
      match {
        lvl'off' { flag'-Wno-unsafe-buffer-usage' },
        cxx'-Wunsafe-buffer-usage',
      }
    }
  },

  opt'diagnostics_show_template_tree' {
    Or(gcc'>=8', clang_like) {
      match {
        lvl'on' { cxx'-fdiagnostics-show-template-tree' },
        cxx'-fno-diagnostics-show-template-tree',
      }
    },
  },

  opt'elide_type' {
    match {
      lvl'on' { gcc'>=8' { cxx'-felide-type' } },
      Or(gcc'>=8', clang_like'>=3.4') { cxx'-fno-elide-type', },
    }
  },

  opt'exceptions' {
    match {
      lvl'on' {
        flag'-fexceptions',
        clang_emcc {
          flag'-sDISABLE_EXCEPTION_CATCHING=0',
        }
      },
      flag'-fno-exceptions',
    }
  },

  opt'rtti' {
    match {
      lvl'on' { cxx'-frtti' },
      cxx'-fno-rtti',
    }
  },

  opt'var_init' {
    Or(gcc'>=12', clang_like'>=8') {
      clang_like'<=15' {
        lvl'zero' {
          flag'-enable-trivial-auto-var-init-zero-knowing-it-will-be-removed-from-clang'
        }
      },
      match {
        lvl'pattern' {
          flag'-ftrivial-auto-var-init=pattern',
          gcc{ flag'-Wtrivial-auto-var-init' },
        },
        lvl'zero' {
          flag'-ftrivial-auto-var-init=zero',
          gcc{ flag'-Wtrivial-auto-var-init' },
        },
        --[[lvl'uninitialized']] {
          flag'-ftrivial-auto-var-init=uninitialized',
        },
      },
    },
  },

  opt'windows_abi_compatibility_warnings' {
    Or(gcc'>=10', clang_like) {
      match {
        lvl'on' { cxx'-Wmismatched-tags' },
        cxx'-Wno-mismatched-tags'
      }
    }
  },

  opt'warnings_as_error' {
    match {
      lvl'on' { flag'-Werror', },
      lvl'basic' {
        -- flag'-Werror=non-virtual-dtor',
        flag'-Werror=return-type',
        flag'-Werror=init-self',
        match {
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
          },
          { --[[clang_like]]
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
        }
      },
      flag'-Wno-error',
    }
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
    match {
      lvl'off' {
        fl'-fno-sanitize=all'
      },
      clang_cl {
        flag'-fsanitize=undefined',
        flag'-fsanitize=address', -- memory, thread are mutually exclusive
        flag'-fsanitize-address-use-after-scope',
      },
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
      },
      { --[[gcc]]
        vers'>=4.8' {
          fl'-fsanitize=address', -- memory, thread are mutually exclusive
          flag'-fno-omit-frame-pointer',
          flag'-fno-optimize-sibling-calls',

          vers'>=4.9' {
            fl'-fsanitize=undefined',
            fl'-fsanitize=leak', -- requires the address sanitizer

            vers'>=12' {
              fl'-fsanitize=bounds-strict',
            }
          }
        }
      }
    }
  },

  opt'control_flow' {
    match {
      clang_emcc {
        match {
          lvl'off' {
            link'-sASSERTIONS=0',
            link'-sSAFE_HEAP=0',
          },
          {
            -- Building with ASSERTIONS=1 causes STACK_OVERFLOW_CHECK=1
            link'-sASSERTIONS=1',
            link'-sDEMANGLE_SUPPORT=1',
            -- ASan does not work with SAFE_HEAP
            -has_opt'sanitizers':with(lvl'on') {
              link'-sSAFE_HEAP=1',
            },
          }
        }
      },
      lvl'off' {
        match {
          gcc'>=8' {
            flag'-fcf-protection=none'
          },
          { -- clang, clang_cl
            fl'-fno-sanitize=cfi',
            flag'-fcf-protection=none',
            flag'-fno-sanitize-cfi-cross-dso',
          }
        }
      },
      Or(gcc'>=8', -gcc) {
        match {
          -- gcc: flag'-mcet',
          -- clang_cl: flag'-fsanitize-cfi-cross-dso',
          lvl'branch' { flag'-fcf-protection=branch' },
          lvl'return' { flag'-fcf-protection=return' },
          flag'-fcf-protection=full',
        },

        And(lvl'allow_bugs', clang) {
          fl'-fsanitize=cfi', -- cfi-* only allowed with '-flto' and '-fvisibility=...'
          flag'-fvisibility=hidden',
          fl'-flto',
        }
      }
    }
  },

  opt'color' {
    Or(vers'>=4.9', -gcc --[[=clang_like]]) {
      match {
        lvl'auto' { flag'-fdiagnostics-color=auto' },
        lvl'never' { flag'-fdiagnostics-color=never' },
        --[[lvl'always']] { flag'-fdiagnostics-color=always' },
      }
    },
  },

  opt'reproducible_build_warnings' {
    gcc'>=4.9' {
      match {
        lvl'on' { flag'-Wdate-time' },
        flag'-Wno-date-time',
      }
    }
  },

  opt'diagnostics_format' {
    match {
      lvl'fixits' {
        Or(gcc'>=7', And(-gcc, vers'>=5') --[[=clang_like'>=5']]) {
          flag'-fdiagnostics-parseable-fixits'
        }
      },
      lvl'patch' {
        gcc'>=7' { flag'-fdiagnostics-generate-patch' }
      },
      { --[[lvl'print_source_range_info']]
        clang_like { flag'-fdiagnostics-print-source-range-info' }
      }
    }
  },

  opt'fix_compiler_error' {
    match {
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
      },
      -gcc --[[=clang_like]] {
        flag'-Wno-error=c++11-narrowing',
        flag'-Wno-reserved-user-defined-literal',
      }
    }
  },

  opt'lto' {
    match {
      lvl'off' { fl'-fno-lto' },
      gcc {
        fl'-flto',
        vers'>=5' {
          opt'warnings' {
            -- increases size of LTO object files, but enables diagnostics about ODR violations
            -lvl'off' { fl'-flto-odr-type-merging' },
          },
          match {
            lvl'fat' { flag'-ffat-lto-objects', },
            lvl'thin' { link'-fuse-linker-plugin' },
          }
        }
      },
      { --[[clang_like]]
        clang_cl {
          -- LTO require -fuse-ld=lld (link by default)
          link'-fuse-ld=lld',
        },
        match {
          And(Or(lvl'thin', lvl'on'), vers'>=6') {
            fl'-flto=thin'
          },
          fl'-flto',
        }
      }
    }
  },

  opt'shadow_warnings' {
    match {
      lvl'off' {
        flag'-Wno-shadow',
        clang_like'>=8' {
          flag'-Wno-shadow-field'
        }
      },
      lvl'on' { flag'-Wshadow' },
      lvl'all' {
        match {
          gcc { flag'-Wshadow' },
          flag'-Wshadow-all',
        }
      },
      gcc'>=7.1' {
        match {
          lvl'local' {
            flag'-Wshadow=local'
          },
          { --[[lvl'compatible_local']]
            flag'-Wshadow=compatible-local'
          }
        }
      }
    }
  },

  opt'float_sanitizers' {
    Or(gcc'>=5', clang_like'>=5') {
      match {
        lvl'on' {
          flag'-fsanitize=float-divide-by-zero',
          flag'-fsanitize=float-cast-overflow',
        },
        {
          flag'-fno-sanitize=float-divide-by-zero',
          flag'-fno-sanitize=float-cast-overflow',
        },
      }
    },
  },

  opt'integer_sanitizers' {
    match {
      clang_like'>=5' {
        match {
          lvl'on' { flag'-fsanitize=integer', },
          flag'-fno-sanitize=integer',
        }
      },
      gcc'>=4.9' {
        lvl'on' {
          flag'-ftrapv',
          flag'-fsanitize=undefined',
        },
      }
    }
  },

},

opt'conversion_warnings' {
  Or(gcc, clang_like, icc) {
    match {
      lvl'on' {
        flag'-Wconversion',
        flag'-Wsign-compare',
        flag'-Wsign-conversion',
      },
      lvl'conversion' {
        flag'-Wconversion',
      },
      lvl'float' {
        match {
          gcc{
            vers'>=4.9' {
              flag'-Wfloat-conversion',
            }
          },
          flag'-Wfloat-conversion',
        }
      },
      lvl'sign' {
        flag'-Wsign-compare',
        flag'-Wsign-conversion',
      },
      lvl'all' {
        flag'-Wconversion',
        gcc { flag'-Warith-conversion' }
      },
      { --[[lvl'off']]
        flag'-Wno-conversion',
        flag'-Wno-sign-compare',
        flag'-Wno-sign-conversion',
      },
    }
  },
},

Or(gcc, clang, clang_emcc) {
  opt'stl_hardening' {
    -- https://gcc.gnu.org/onlinedocs/libstdc++/manual/using_macros.html
    -- https://libcxx.llvm.org/Hardening.html (libc++-18)
    -- _LIBCPP_DEBUG is a pre-hardening mode
    -- Note: gcc-11 supports `-stdlib=libc++` (if configured to support this).
    --       clang supports `-stdlib=libstdc++`.
    -lvl'off' {
      match {
        lvl'fast' {
          cxx'-D_GLIBCXX_ASSERTIONS',
          cxx'-D_LIBCPP_HARDENING_MODE=_LIBCPP_HARDENING_MODE_FAST',
        },
        lvl'extensive' {
          cxx'-D_GLIBCXX_ASSERTIONS',
          cxx'-D_LIBCPP_HARDENING_MODE=_LIBCPP_HARDENING_MODE_EXTENSIVE',
        },
        lvl'debug' {
          cxx'-D_GLIBCXX_ASSERTIONS',
          cxx'-D_LIBCPP_HARDENING_MODE=_LIBCPP_HARDENING_MODE_DEBUG',
        },
        --[[lvl'debug_with_broken_abi']] {
          cxx'-D_GLIBCXX_DEBUG',
          has_opt'pedantic':without(lvl'off') {
            cxx'-D_GLIBCXX_DEBUG_PEDANTIC'
          },
          match {
            clang_like'<18' {
              -- debug allocator has a bug: https://bugs.llvm.org/show_bug.cgi?id=39203
              vers'>=8' {
                cxx'-D_LIBCPP_DEBUG=1',
              },
            },
            -- gcc or recent clang
            {
              cxx'-D_LIBCPP_HARDENING_MODE=_LIBCPP_HARDENING_MODE_DEBUG',
              -- https://libcxx.llvm.org/Hardening.html#abi-options
              cxx'-D_LIBCPP_ABI_BOUNDED_ITERATORS',
              cxx'-D_LIBCPP_ABI_BOUNDED_ITERATORS_IN_STRING',
              cxx'-D_LIBCPP_ABI_BOUNDED_ITERATORS_IN_VECTOR',
              cxx'-D_LIBCPP_ABI_BOUNDED_UNIQUE_PTR',
              cxx'-D_LIBCPP_ABI_BOUNDED_ITERATORS_IN_STD_ARRAY',
            }
          },
        }
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

  match {
    clang_emcc {
      opt'optimization' {
        match {
          lvl'0' { fl'-O0' },
          lvl'g' { fl'-Og' },
          lvl'1' { fl'-O1' },
          lvl'2' { fl'-O2' },
          lvl'3' { fl'-O3' },
          lvl'fast' {
            fl'-O3',
            -- The LLVM wasm backend avoids traps by adding more code around each possible trap
            -- (basically clamping the value if it would trap).
            -- That code may not run in older VMs, though.
            fl'-mnontrapping-fptoint',
          },
          lvl'size' { fl'-Os' },
          { --[[lvl'z']]
            fl'-Oz'
            -- -- This greatly reduces the size of the support JavaScript code
            -- -- Note that this increases compile time significantly.
            -- fl'--closure 1',
          },
        }
      },

      opt'debug_level' {
        match {
          lvl'0' { flag'-g0' },
          lvl'1' { flag'-g1' },
          lvl'2' { flag'-g2' },
          lvl'3' { flag'-g3' },
        }
      },

      opt'debug' {
        match {
          lvl'off' { flag'-g0' },
          -has_opt'debug_level' {
            flag'-g',
          }
        }
      },
    },

    --[[Or(gcc, clang)]] {
      gcc'>=12' {
        -- This flag is enabled by default unless -fno-inline is active.
        -- But -fno-inline is the default when not optimizing.
        cxx'-ffold-simple-inlines',
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

      opt'debug_level' {
        match {
          lvl'0' { flag'-g0' },
          lvl'1' { match {has_opt'debug':with(lvl'gdb') { flag'-ggdb1' }, flag'-g1' } },
          lvl'2' { match {has_opt'debug':with(lvl'gdb') { flag'-ggdb2' }, flag'-g2' } },
          lvl'3' { match {has_opt'debug':with(lvl'gdb') { flag'-ggdb3' }, flag'-g3' } },
          lvl'line_tables_only' {
            match {
              clang { flag'-gline-tables-only' },
              { flag'-g' }
            }
          },
          lvl'line_directives_only' {
            match {
              clang { flag'-gline-directives-only' },
              { flag'-g' }
            }
          },
        }
      },

      opt'debug' {
        match {
          lvl'off' { flag'-g0' },
          lvl'on' {
            -has_opt'debug_level' {
              flag'-g',
            }
          },
          lvl'gdb' {
            -has_opt'debug_level' {
              flag'-ggdb'
            },
          },
          clang {
            match {
              lvl'lldb' { flag'-glldb' },
              lvl'sce' { flag'-gsce' },
              lvl'dbx' { flag'-gdbx' },
              flag'-g',
            }
          },
          --[[gcc]] {
            lvl'vms' { flag'-gvms' },
          },
          -- flag'-fasynchronous-unwind-tables', -- Increased reliability of backtraces
        }
      },

      opt'optimization' {
        match {
          lvl'0' { flag'-O0' },
          lvl'g' { flag'-Og' },
          {
            link'-Wl,-O1',
            match {
              lvl'1' { flag'-O1' },
              lvl'2' { flag'-O2' },
              lvl'3' { flag'-O3' },
              lvl'size' { flag'-Os' },
              lvl'z' {
                match {
                  Or(clang, gcc'>=12') { flag'-Oz' },
                  flag'-Os',
                }
              },
              --[[lvl'fast']] {
                -- -Ofast is deprecated with clang-19
                match {
                  clang { flag'-O3', flag'-ffast-math' },
                  flag'-Ofast',
                }
              }
            }
          }
        }
      },

      opt'cpu' {
        match {
          lvl'generic' { fl'-mtune=generic' },
          { fl'-march=native', fl'-mtune=native', }
        }
      },

      opt'linker' {
        match {
          lvl'mold' {
            link'-fuse-ld=mold'  -- >= gcc-12
          },
          lvl'native' {
            match {
              gcc { link'-fuse-ld=gold' },
              link'-fuse-ld=lld'
            }
          },
          lvl'bfd' {
            link'-fuse-ld=bfd'
          },
          Or(lvl'gold', gcc'<9') {
            link'-fuse-ld=gold'
          },
          opt'lto' {
            match {
              -- -flto is incompatible with -fuse-ld=lld
              And(-lvl'off', gcc) {
                link'-fuse-ld=gold'
              },
              link'-fuse-ld=lld',
            }
          },
          link'-fuse-ld=lld',
        }
      },

      opt'whole_program' {
        match {
          lvl'off' {
            flag'-fno-whole-program',
            clang'>=3.9' { fl'-fno-whole-program-vtables' }
          },
          {
            match {
              ld64 {
                link'-Wl,-dead_strip',
                link'-Wl,-S', -- Remove debug information
              },
              {
                link'-s',
                lvl'strip_all'{
                  link'-Wl,--gc-sections', -- Remove unused sections
                  link'-Wl,--strip-all',
                }
              }
            },

            match {
              gcc {
                fl'-fwhole-program'
              },
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
          }
        }
      },

      -- https://airbus-seclab.github.io/c-compiler-security/
      -- g++ --help=hardened
      opt'stack_protector' {
        match {
          lvl'off' {
            fl'-Wno-stack-protector',
            flag'-U_FORTIFY_SOURCE'
          },
          {
            flag'-Wstack-protector', -- only active when -fstack-protector is active
            match {
              Or(gcc'>=12', clang'>=14') {
                flag'-D_FORTIFY_SOURCE=3'
              },
              -- >= gcc-4.1
              flag'-D_FORTIFY_SOURCE=2',
            },
            match {
              lvl'strong' {
                match {
                  gcc {
                    vers'>=4.9' {
                      fl'-fstack-protector-strong',
                      vers'>=8' {
                        fl'-fstack-clash-protection'
                      }
                    }
                  },
                  --[[clang]] {
                    fl'-fstack-protector-strong',
                    fl'-fsanitize=safe-stack',
                    vers'>=11' {
                      fl'-fstack-clash-protection'
                    }
                  }
                }
              },
              lvl'all' {
                fl'-fstack-protector-all',
                match {
                  gcc'>=8' {
                    fl'-fstack-clash-protection'
                  },
                  --[[clang]] {
                    fl'-fsanitize=safe-stack',
                    vers'>=11' {
                      fl'-fstack-clash-protection'
                    }
                  }
                }
              },
              fl'-fstack-protector',
            },

            -- ShadowCallStack is an instrumentation pass, currently only implemented for aarch64
            -- ShadowCallStack is intended to be a stronger alternative to -fstack-protector
            -- On aarch64, you also need to pass -ffixed-x18 unless your target already reserves x18.
            clang {
              fl'-fsanitize=shadow-call-stack',
            }
          },
        }
      },

      -- https://airbus-seclab.github.io/c-compiler-security/
      -- g++ --help=hardened
      opt'relro' {
        match {
          lvl'off' { link'-Wl,-z,norelro', },
          lvl'on'  { link'-Wl,-z,relro', },
          { --[[lvl'full']]
            link'-Wl,-z,relro,-z,now,-z,noexecstack',
            opt'linker' {
              -- -Wl,-z,separate-code is invalid with gold linker
              -Or(Or(lvl'gold', gcc'<9'), And(lvl'native', gcc)) {
                link'-Wl,-z,separate-code'
              }
            }
          }
        }
      },

      opt'pie' {
        match {
          lvl'off' { link'-no-pic' },
          lvl'on'  { link'-pie' },
          lvl'fpie'{ flag'-fpie' },
          lvl'fpic'{ flag'-fpic' },
          lvl'fPIE'{ flag'-fPIE' },
          lvl'fPIC'{ flag'-fPIC' },
          --[[lvl'static']] { link'-static-pie' }
        }
      },

      opt'other_sanitizers' {
        match {
          lvl'thread' { flag'-fsanitize=thread', },
          lvl'memory' {
            clang'>=5' {
              flag'-fsanitize=memory',
              flag'-fno-omit-frame-pointer',
            }
          },
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
        }
      },

      opt'noexcept_warnings' {
        gcc'>=4.9' {
          match {
            lvl'on' { cxx'-Wnoexcept' },
            { cxx'-Wno-noexcept' }
          }
        }
      },

      -- https://gcc.gnu.org/onlinedocs/gcc/Static-Analyzer-Options.html
      opt'analyzer' {
        gcc'>=10' {
          match {
            lvl'off' {
              flag'-fno-analyzer'
            },
            { -- lvl'on'
              flag'-fanalyzer',

              opt'analyzer_too_complex_warning' {
                match {
                  lvl'on' {
                    flag'-Wanalyzer-too-complex'
                  },
                  { -- lvl'off'
                    flag'-Wno-analyzer-too-complex'
                  }
                }
              },

              opt'analyzer_verbosity' {
                match {
                  lvl'0' { flag'-fanalyzer-verbosity=0' },
                  lvl'1' { flag'-fanalyzer-verbosity=1' },
                  lvl'2' { flag'-fanalyzer-verbosity=2' },
                  --[[lvl'3']] { flag'-fanalyzer-verbosity=3' }
                }
              },
            },
          }
        }
      },
    }
  },
},

lld_link {
  opt'lto' {
    match {
      lvl'off' { flag'-fno-lto' },
      Or(lvl'thin', lvl'on') { flag'-flto=thin' },
      fl'-flto',
    }
  },

  opt'whole_program' {
    match {
      lvl'off' { flag'-fno-whole-program' },
      opt'lto' {
        -lvl'off' {
          fl'-fwhole-program-vtables'
        }
      }
    }
  },
},

Or(msvc, clang_cl, icl) {
  opt'exceptions' {
    match {
      lvl'on' {
        flag'/EHsc',
        flag'/D_HAS_EXCEPTIONS=1',
      },
      {
        flag'/EHs-',
        flag'/D_HAS_EXCEPTIONS=0',
      }
    }
  },

  opt'rtti' {
    match {
      lvl'on' {
        flag'/GR'
      },
      flag'/GR-'
    }
  },

  -- https://github.com/microsoft/STL/wiki/STL-Hardening
  -- https://learn.microsoft.com/en-us/cpp/standard-library/iterator-debug-level
  -- https://github.com/MicrosoftDocs/cpp-docs/blob/main/docs/standard-library/iterator-debug-level.md
  -- _MSVC_STL_HARDENING (Controlled by some other setting, e.g. implied by /sdl TODO check that, not with _MSC_VER=1941 / VS 2022 17.11)
  -- _MSVC_STL_HARDENING_* ("Fine-Grained")
  -- _MSVC_STL_DESTRUCTOR_TOMBSTONES
  -- _ITERATOR_DEBUG_LEVEL (break ABI)
  -- _HAS_ITERATOR_DEBUGGING (deprecated(?) in 16.x)
  -- _SECURE_SCL (deprecated in 12.x)
  --
  -- _ITERATOR_DEBUG_LEVEL  _SECURE_SCL    _HAS_ITERATOR_DEBUGGING
  -- 0 (Release default) =  0 (disabled) + 0 (disabled)
  -- 1                   =  1 (enabled)  + 0 (disabled)
  -- 2 (Debug default)   = (not relevant)+ 1 (enabled in Debug mode)
  --
  -- deduce from stl/inc/yvals.h
  --                         _SECURE_SCL=0  _SECURE_SCL=1
  -- _ITERATOR_DEBUG_LEVEL=0      ok            error
  -- _ITERATOR_DEBUG_LEVEL=1     error           ok
  -- _ITERATOR_DEBUG_LEVEL=2     error           ok
  --
  --                         _HAS_ITERATOR_DEBUGGING=0  _HAS_ITERATOR_DEBUGGING=1
  -- _ITERATOR_DEBUG_LEVEL=0            ok                        error
  -- _ITERATOR_DEBUG_LEVEL=1            ok                        error
  -- _ITERATOR_DEBUG_LEVEL=2           error                       ok
  opt'stl_hardening' {
    -- Or(msvc'>=17', clang_cl'>=12') -> hardening mode
    match {
      lvl'off' {
        -- cxx'/U_DEBUG',
        cxx'/D_MSVC_STL_HARDENING=0',
        cxx'/D_MSVC_STL_DESTRUCTOR_TOMBSTONES=0',
        cxx'/D_ITERATOR_DEBUG_LEVEL=0',
        -- old macros
        cxx'/D_HAS_ITERATOR_DEBUGGING=0',
        flag'/D_SECURE_SCL=0',
      },
      Or(lvl'fast', lvl'extensive') {
        cxx'/D_MSVC_STL_HARDENING=1',
      },
      lvl'debug' {
        cxx'/D_MSVC_STL_HARDENING=1',
        cxx'/D_MSVC_STL_DESTRUCTOR_TOMBSTONES=1',
      },
      --[[lvl'debug_with_broken_abi']] {
        flag'/D_DEBUG',
        -- cxx'/D_ITERATOR_DEBUG_LEVEL=2', -- enabled with /D_DEBUG
        cxx'/D_MSVC_STL_HARDENING=1',
        cxx'/D_MSVC_STL_DESTRUCTOR_TOMBSTONES=1',
      }
    }
  },

  opt'stl_fix' {
    lvl'on' { flag'/DNOMINMAX', },
  },

  -- msvc and clang_cl
  -icl {
    opt'debug_level' {
      lvl'line_tables_only' {
        clang_cl { flag'-gline-tables-only' },
        flag'/DEBUG:FASTLINK'
      },
      lvl'line_directives_only' {
        clang_cl { flag'-gline-directives-only' }
      },
    },

    opt'debug' {
      match {
        lvl'off' { link'/DEBUG:NONE' },
        {
          flag'/RTC1',
          flag'/Od',
          match {
            lvl'on' { flag'/DEBUG' }, -- /DEBUG:FULL
          },

          -- The /Zo option is available starting in Visual Studio 2013 Update 3.
          -- It's enabled by default when you specify debugging information with /Zi or /Z7.
          -- It's disabled by the /ZI compiler option.
          match {
            opt'optimization' {
              match {
                lvl'g' { flag'/Zi' },
                -- /ZI cannot be used with /GL
                opt'whole_program' {
                  match { lvl'off' { flag'/ZI' }, flag'/Zi' }
                },
                flag'/ZI'
              }
            },
            -- /ZI cannot be used with /GL
            opt'whole_program' {
              match { lvl'off' { flag'/ZI' }, flag'/Zi' }
            },
            flag'/ZI',
          }
        }
      }
    },

    opt'optimization' {
      match {
        lvl'0' {
          flag'/Ob0',
          flag'/Od',
          flag'/Oi-',
          flag'/Oy-',
        },
        lvl'g' { flag'/Ob1' },
        -- /O1 = /Og      /Os  /Oy /Ob2 /GF /Gy
        -- /O2 = /Og /Oi  /Ot  /Oy /Ob2 /GF /Gy
        lvl'1' { flag'/O1', },
        lvl'2' { flag'/O2', },
        lvl'3' { flag'/O2', },
        Or(lvl'size', lvl'z') { flag'/O1', flag'/GL', flag'/Gw' },
        --[[lvl'fast']] { flag'/O2', flag'/fp:fast' }
      }
    },

    opt'linker' {
      clang_cl {
        match {
          Or(lvl'lld', lvl'native') {
            link'-fuse-ld=lld'
          },
          lvl'mold' {
            link'-fuse-ld=mold'
          },
        }
      }
    },

    opt'control_flow' {
      match { lvl'off' { flag'/guard:cf-' }, flag'/guard:cf' },
    },

    opt'whole_program' {
      match {
        lvl'off' {
          flag'/GL-'
        },
        {
          flag'/GL',
          flag'/Gw',
          link'/LTCG',
          lvl'strip_all'{
            link'/OPT:REF',
          },
        }
      }
    },

    opt'pedantic' {
      -lvl'off' {
        flag'/permissive-', -- implies /Zc:rvalueCast, /Zc:strictStrings, /Zc:ternary, /Zc:twoPhase
        cxx'/Zc:__cplusplus',
        -- cxx'/Zc:throwingNew',

        msvc {
          msvc_select_warn(lvl'as_error', 'e', '1', function(f) return {
            flag(f(4608)), -- 'union_member' has already been initialized by another union member in the initializer list, 'union_member'
            cxx(f(4928)), -- illegal copy-initialization; more than one user-defined conversion has been implicitly applied

            vers'>=19.31' {
              cxx(f(5254)), -- language feature 'terse static assert' requires compiler flag '/std:c++17'

              vers'>=19.38' {
                flag(f(5110)), -- __VA_OPT__ is an extension prior to C++20 or C23
              }
            }
          } end),

          match {
            has_opt'msvc_isystem' {
              cxx'/we4471', -- Forward declaration of an unscoped enumeration must have an underlying type
              cxx'/we5052', -- Keyword 'keyword-name' was introduced in C++ version and requires use of the 'option' command-line option
            },
            {
              cxx'/w14471',
            }
          }
        }
      }
    },

    -- https://airbus-seclab.github.io/c-compiler-security/
    opt'stack_protector' {
      match {
        lvl'off' {
          flag'/GS-',
        },
        {
          flag'/GS',
          flag'/sdl',
          match {
            lvl'strong' {
              flag'/RTC1', -- /RTCsu
              msvc'>=16.7' {
                flag'/guard:ehcont',
                link'/CETCOMPAT',
              },
            },
            lvl'all' { flag'/RTC1', flag'/RTCc', },
          },
          has_opt'control_flow':without(lvl'off') {
            flag'/guard:cf',
          },
        }
      }
    },
  }
},

match {
  -- warnings:
  -- https://docs.microsoft.com/en-us/cpp/error-messages/compiler-warnings/compiler-warnings-c4000-c5999?view=vs-2019
  -- https://docs.microsoft.com/en-us/cpp/build/reference/compiler-option-warning-level?view=vs-2019
  msvc {
    -- https://learn.microsoft.com/en-us/cpp/build/reference/analyze-code-analysis
    opt'analyzer' {
      vers'>=15' {
        match {
          lvl'off' {
            flag'/analyze-'
          },
          { -- lvl'on'
            flag'/analyze'
          }
        }
      }
    },

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
              vers'>=17.4' { -- MSVC 19.34
                cxx'/Zc:enumTypes',
                vers'>=17.5' { -- MSVC 19.35
                  cxx'/Zc:templateScope',
                }
              }
            }
          },
        }
      }
    },

    opt'msvc_crt_secure_no_warnings' {
      match {
        lvl'on' { flag'/D_CRT_SECURE_NO_WARNINGS=1' },
        lvl'off' { flag'/U_CRT_SECURE_NO_WARNINGS' }
      }
    },

    opt'msvc_diagnostics_format' {
      vers'>=17' {
        match {
          lvl'classic' { flag'/diagnostics:classic' },
          lvl'column' { flag'/diagnostics:column' },
          --[[lvl'caret']] { flag'/diagnostics:caret' },
        }
      }
    },

    -- https://devblogs.microsoft.com/cppblog/broken-warnings-theory/
    vers'<15.16' {
      reset_opt'msvc_isystem'
    },
    match {
      opt'msvc_isystem' {
        match {
          lvl'external_as_include_system_flag' {
            if_else(vers'<16.10', function(b)
              return act({
                cxx='/external:env:INCLUDE /external:W0' .. (b and ' /experimental:external' or ''),
                system_flag='/external:I',
              })
            end)
          },
          -lvl'assumed' {
            vers'<16.10' {
              flag'/experimental:external'
            },
            flag'/external:W0',

            match {
              lvl'anglebrackets' {
                flag'/external:anglebrackets',
              },
              -- include_and_caexcludepath
              {
                flag'/external:env:INCLUDE',
                flag'/external:env:CAExcludePath',
              },
            }
          }
        },

        opt'msvc_isystem_with_template_from_non_external' {
          match {
            lvl'off' {
              flag'/external:template',
            }, {
              flag'/external:template-',
            }
          }
        },
      }
    },

    opt'warnings' {
      match {
        lvl'off' {
          flag'/W0'
        },
        lvl'essential' {
          flag'/W4',
          -- /external:... ignores warnings starting with C47XX
          flag'/wd4711', -- function selected for inline expansion (enabled by /OB2)
        },
        lvl'on' {
          -- enable warning that aren't off by default.
          flag'/W4',

          -- /external:... ignores warnings starting with C47XX
          flag'/wd4711', -- function selected for inline expansion (enabled by /OB2)

          -- off by default

          cxx'/w14265', -- Class has virtual functions, but its non-trivial destructor (-Wnon-virtual-dtor)
          flag'/w14296', -- expression is always false (-Wtautological-unsigned-zero-compare / -Wtype-limits)
          flag'/w14444', -- top level '__unaligned' is not implemented in this context
          flag'/w14545', -- expression before comma evaluates to a function which is missing an argument list
          flag'/w14546', -- function call before comma missing argument list
          flag'/w14547', -- 'operator' : operator before comma has no effect; expected operator with side-effect
          flag'/w14548', -- expression before comma has no effect; expected expression with side-effect
          flag'/w14549', -- 'operator' : operator before comma has no effect; did you intend 'operator'?
          flag'/w14555', -- expression has no effect; expected expression with side-effect
          flag'/w14557', -- '__assume' contains effect 'effect'
          cxx'/w14608', -- 'union_member' has already been initialized by another union member in the initializer list, 'union_member'
          cxx'/w14692', -- 'function': signature of non-private member contains assembly private native type 'native_type'
          cxx'/w14822', -- 'member' : local class member function does not have a body
          flag'/w14905', -- wide string literal cast to 'LPSTR'
          flag'/w14906', -- string literal cast to 'LPWSTR'
          flag'/w14917', -- 'declarator' : a GUID can only be associated with a class, interface or namespace
          cxx'/w14928', -- illegal copy-initialization; more than one user-defined conversion has been implicitly applied
          cxx'/w14596', -- illegal qualified name in member declaration

          vers'>=15.3' {
            -has_opt'msvc_isystem' {
              cxx'/w14263', -- member function does not override any base class virtual member function
              cxx'/w14264', -- no override available for virtual member function from base 'class'; function is hidden (-Woverloaded-virtual)
            },
            cxx'/w15038', -- member 'member1' will be initialized after data member 'member2' (-Wreorder-ctor / -Wreorder)

            vers'>=16.10' {
              cxx'/w15233', -- explicit lambda capture 'identifier' is not used
              flag'/w15240', -- attribute is ignored in this syntactic position

              vers'>=17.4' {
                cxx'/w15263', -- calling 'std::move' on a temporary object prevents copy elision (-Wpessimizing-move)
                -has_opt'msvc_isystem' {
                  flag'/w15262', -- -Wimplicit-fallthrough, active only with /std:c++17 or newer
                },

                vers'>=19.00' {
                  flag'/w14426', -- Optimization flags changed after including header
                  -has_opt'msvc_isystem' {
                    flag'/w14654', -- Code placed before include of precompiled header line will be ignored.
                  },
                  flag'/w15031', -- #pragma warning(pop): likely mismatch
                  flag'/w15032', -- detected #pragma warning(push) with no corresponding #pragma warning(pop)

                  vers'>=19.15' {
                    cxx'/w14643', -- Forward declaring 'identifier' in namespace std is not permitted by the C++ Standard.

                    vers'>=19.22' {
                      cxx'/w14855', -- implicit capture of 'this' via '[=]' is deprecated in 'version'

                      vers'>=19.25' {
                        -has_opt'msvc_isystem' {
                          cxx'/w15204', -- Class with virtual functions but trivial destructor destructor (-Wnon-virtual-dtor)
                        },

                        vers'>=19.29' {
                          cxx'/w15233', -- explicit lambda capture 'identifier' is not used

                          vers'>=19.30' {
                            -has_opt'msvc_isystem' {
                              cxx'/w15246', -- the initialization of a subobject should be wrapped in braces
                            },
                            flag'/w15249', -- 'bitfield' of type 'enumeration_name' has named enumerators with values that cannot be represented in the given bit field width of 'bitfield_width'.

                            vers'>=19.32' {
                              flag'/w15258', -- explicit capture of 'symbol' is not required for this use

                              vers'>=19.37' {
                                cxx'/w15267', -- definition of implicit copy constructor/assignment operator for 'type' is deprecated because it has a user-provided assignment operator/copy constructor

                                -- last compiler version: 19.43
                                -- https://learn.microsoft.com/en-us/cpp/error-messages/compiler-warnings/compiler-warnings-by-compiler-version
                                -- https://learn.microsoft.com/en-us/cpp/preprocessor/compiler-warnings-that-are-off-by-default
                                -- https://github.com/microsoft/STL/wiki/Macro-_MSVC_STL_UPDATE
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        },
        -- extensive
        {
          flag'/Wall',

          -- Warnings in MSVC's std or other libs
          cxx'/wd4342', -- behavior change: 'function' called, but a member operator was called in previous versions
          cxx'/wd4350', -- behavior change: 'member1' called instead of 'member2'
          cxx'/wd4355', -- 'this' used in base member initializing list
          flag'/wd4370', -- layout of class has changed from a previous version of the compiler
          flag'/wd4371', -- layout of class may have changed from a previous version
          flag'/wd4514', -- Unreferenced inline function has been removed
          flag'/wd4571', -- SEH exceptions aren't caught since Visual C++ 7.1
          flag'/wd4577', -- 'noexcept' used with no exception handling mode specified
          cxx'/wd4582', -- Constructor is not implicitly called
          cxx'/wd4583', -- Destructor not implicitly called
          cxx'/wd4587', -- 'anonymous_structure': behavior change: constructor is no longer implicitly called
          cxx'/wd4588', -- 'anonymous_structure': behavior change: destructor is no longer implicitly called
          flag'/wd4686', -- 'user-defined type' : possible change in behavior, change in UDT return calling convention
          flag'/wd4710', -- Function not inlined
          flag'/wd4711', -- Function selected for inline expansion (enabled by /OB2)
          flag'/wd4820', -- Added padding to members
          flag'/wd4866', -- compiler may not enforce left-to-right evaluation order for call to operator_name
          cxx'/wd4868', -- Evaluation order not guaranteed in braced initializing list
          -- flag'/wd5045', -- Spectre mitigation (15.7)
          cxx'/wd5024', -- Move constructor was implicitly defined as deleted
          cxx'/wd5025', -- Move assignment operator was implicitly defined as deleted
          cxx'/wd5026', -- Move constructor implicitly deleted
          cxx'/wd5027', -- Move assignment operator implicitly deleted
          cxx'/wd5243', -- using incomplete class 'class-name' can cause ODR violation due to ABI l

          -has_opt'msvc_isystem' {
            flag'/wd4464', -- relative include path contains '..'
            flag'/wd4548', -- Expression before comma has no effect
            cxx'/wd4623', -- Default constructor implicitly deleted
            cxx'/wd4625', -- Copy constructor implicitly deleted
            cxx'/wd4626', -- Copy assignment operator implicitly deleted
            flag'/wd4668', -- 'symbol' is not defined as a preprocessor macro
            cxx'/wd5204', -- Class with virtual functions but trivial destructor (-Wnon-virtual-dtor)
            vers'>=15' {
              cxx'/wd4582', -- 'type': constructor is not implicitly called
              cxx'/wd4583', -- 'type': destructor is not implicitly called
              vers'>=17.4' {
                flag'/wd5262', -- -Wimplicit-fallthrough, active only with /std:c++17 or newer
                vers'>=19' {
                  flag'/wd4774', -- format not a string literal
                }
              }
            }
          },

          vers'>=16' {
            flag'/wd4800', -- Implicit conversion from 'type' to bool. Possible information loss

            vers'>=19.39' {
              flag'/wd4975', -- modopt '[modifier]' was ignored for formal parameter 'parameter'

              vers'>=19.40' {
                flag'/wd4860', -- 'object name': compiler zero initialized 'number' bytes of storage
                flag'/wd4861', -- compiler zero initialized 'number' bytes of storage
                flag'/wd5273', -- behavior change: _Alignas on anonymous type no longer ignored (promoted members will align)
                flag'/wd5274', -- behavior change: _Alignas no longer applies to the type 'type' (only applies to declared data objects)

                vers'>=19.41' {
                  flag'/wd5306', -- parameter array behavior change: overload 'identifier 1' resolved to 'identifier 2'

                  vers'>=19.43' {
                    flag'/wd5277', -- type trait optimization for 'class name' is disabled
                  }
                }
              }
            }
          }
        }
      }
    },

    opt'conversion_warnings' {
      -- conversion
      msvc_select_warn(Or(lvl'off', lvl'sign'), 'd', '1', function(f) return {
        flag(f(4244)), -- 'conversion_type': conversion from 'type1' to 'type2', possible loss of data
        flag(f(4245)), -- 'conversion_type': conversion from 'type1' to 'type2', signed/unsigned mismatch
        flag(f(4365)), -- Signed/unsigned mismatch (implicit conversion)
      } end), -- else: on, all, float, conversion

      -- sign
      msvc_select_warn(Or(lvl'on', lvl'all', lvl'sign'), '1', 'd', function(f) return {
        flag(f(4018)), -- 'operator': unsigned/negative constant mismatch
        flag(f(4388)), -- Signed/unsigned mismatch (equality comparison)
        flag(f(4289)), -- 'equality-operator': signed/unsigned mismatch
      } end) -- else: off, float, conversion
    },

    opt'switch_warnings' {
      match {
        Or(lvl'on', lvl'mandatory_default') {
          flag'/wd4061', -- enumerator 'identifier' in switch of enum 'enumeration' is not explicitly handled by a case label (-Wswitch-enum)
          flag'/w14062', -- enumerator 'identifier' in switch of enum 'enumeration' is not handled (-Wswitch)
        },
        Or(lvl'exhaustive_enum', lvl'exhaustive_enum_and_mandatory_default') {
          flag'/w14061',
          flag'/w14062',
        },
        { --[[lvl'off']]
          flag'/wd4061',
          flag'/wd4062',
        }
      }
    },

    opt'shadow_warnings' {
      vers'>=19' {
        match {
          lvl'off' {
            flag'/wd4456', -- declaration of 'identifier' hides previous local declaration
            flag'/wd4459', -- declaration of 'identifier' hides global declaration
          },
          Or(lvl'on', lvl'all') {
            flag'/w14456',
            flag'/w14459',
          },
          lvl'local' {
            flag'/w4456',
            flag'/wd4459'
          }
        }
      }
    },

    opt'suggestions' {
      msvc_select_warn(lvl'off', 'd', '1', function(f) return {
        cxx(f(5239)), -- potentially-throwing function called from a function declared __declspec(nothrow).
      } end)
    },

    opt'warnings_as_error' {
      match {
        lvl'on' { flag'/WX' },
        lvl'off' { flag'/WX-' },
        { -- lvl'basic'
          cxx'/we4455', -- Wliteral-suffix
          cxx'/we4150', -- Wdelete-incomplete
          flag'/we4716', -- Wreturn-type
          flag'/we2124', -- Wdivision-by-zero
        }
      }
    },

    opt'lto' {
      match {
        lvl'off' {
          flag'/LTCG:OFF'
        },
        {
          flag'/GL',
          link'/LTCG'
        }
      }
    },

    opt'sanitizers' {
      match {
        vers'>=16.9' {
          flag'/fsanitize=address',
          flag'/fsanitize-address-use-after-return'
        },
        match {
          lvl'on' {
            flag'/sdl',
          },
          opt'stack_protector' {
            -lvl'off' { flag'/sdl-' },
          },
        }
      }
    },
  },

  icl {
    opt'warnings' {
      match {
        lvl'off' {
          flag'/w'
        },
        {
          flag'/W2',
          flag'/Qdiag-disable:1418,2259', -- external function definition with no prior declaration
                                          -- "type" to "type" may lose significant bits
        }
      }
    },

    opt'warnings_as_error' {
      match {
        lvl'on' {
          flag'/WX',
        },
        lvl'basic' {
          flag'/Qdiag-error:1079,39,109' -- return-type, div-by-zero, array-bounds
        }
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

    opt'debug_level' {
      Or(lvl'line_tables_only', lvl'line_directives_only') {
        flag'/debug:minimal',
      }
    },

    opt'debug' {
      match {
        lvl'off' { link'/DEBUG:NONE' },
        {
          flag'/RTC1',
          flag'/Od',
          match {
            lvl'on' { flag'/debug:full' },
          },
          match {
            has_opt'optimization':with(lvl'g') {
              flag'/Zi'
            },
            -- /ZI cannot be used with /GL
            opt'whole_program' {
              match { lvl'off' { flag'/ZI' }, flag'/Zi' }
            },
            flag'/ZI',
          }
        }
      }
    },

    opt'optimization' {
      match {
        lvl'0' {
          flag'/Ob0',
          flag'/Od',
          flag'/Oi-',
          flag'/Oy-',
        },
        lvl'g' { flag'/Ob1' },
        {
          flag'/GF',
          match {
            lvl'1' { flag'/O1', },
            lvl'2' { flag'/O2', },
            lvl'3' { flag'/O2', },
            lvl'z' { flag'/O3', },
            lvl'size' { flag'/Os', },
            --[[lvl'fast']] { flag'/fast' }
          }
        }
      }
    },

    opt'stack_protector' {
      match {
        lvl'off' {
          flag'/GS-',
        },
        {
          flag'/GS',
          match {
            lvl'strong' {
              flag'/RTC1', -- /RTCsu
            },
            lvl'all' {
              flag'/RTC1',
              flag'/RTCc',
            },
          }
        },
      }
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
      match {
        lvl'off' {
          flag'/guard:cf-',
          flag'/mconditional-branch=keep',
        },
        {
          flag'/guard:cf',
          match {
            lvl'branch' {
              flag'/mconditional-branch:all-fix',
              flag'/Qcf-protection:branch',
            },
            lvl'on' {
              flag'/mconditional-branch:all-fix',
              flag'/Qcf-protection:full',
            }
          }
        }
      }
    },

    opt'cpu' {
      match { lvl'generic' { fl'/Qtune:generic' }, fl'/QxHost' },
    },
  },

  icc {
    opt'warnings' {
      match {
        lvl'off' {
          flag'-w'
        },
        lvl'essential' {
          flag'-Wall',
        },
        -- on, extensive
        {
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
        }
      }
    },

    opt'switch_warnings' {
      match {
        Or(lvl'on', lvl'exhaustive_enum') { flag'-Wswitch-enum' },
        lvl'mandatory_default' { flag'-Wswitch-default' },
        lvl'exhaustive_enum_and_mandatory_default' {
          flag'-Wswitch',
        },
        {
          flag'-Wno-switch'
        },
      }
    },

    opt'warnings_as_error' {
      match {
        lvl'on' {
          flag'-Werror',
        },
        lvl'basic' {
          flag'-diag-error=1079,39,109' -- return-type, div-by-zero, array-bounds
        }
        -- flag'-Wno-error', does not work
      }
    },

    -- opt'pedantic' -- -pedantic does not work ???
    opt'pedantic' {
      match {
        lvl'off' {
          flag'-fgnu-keywords',
        },
        {
          flag'-fno-gnu-keywords',
        }
      }
    },

    opt'shadow_warnings' {
      match {
        lvl'off' {
          flag'-Wno-shadow',
        },
        Or(lvl'on', lvl'all') {
          flag'-Wshadow'
        }
      }
    },

    opt'stl_hardening' {
      match {
        lvl'debug_with_broken_abi' {
          cxx'-D_GLIBCXX_DEBUG',
          has_opt'pedantic':without(lvl'off') {
            cxx'-D_GLIBCXX_DEBUG_PEDANTIC'
          },
        },
        -lvl'off' {
          cxx'-D_GLIBCXX_ASSERTIONS',
        }
      },
    },

    opt'debug' {
      match {
        lvl'off' { flag '-g0' },
        flag'-g',
      }
    },

    opt'optimization' {
      match {
        lvl'0' { flag'-O0', },
        lvl'g' { flag'-O1', },
        lvl'1' { flag'-O1', },
        lvl'2' { flag'-O2', },
        lvl'3' { flag'-O3', },
        lvl'z' { flag'-fast', },
        lvl'size' { flag'-Os', },
        --[[lvl'fast']] { flag'-Ofast' }
      }
    },

    opt'stack_protector' {
      match {
        lvl'off' {
          fl'-fno-protector-strong',
          flag'-U_FORTIFY_SOURCE'
        },
        {
          flag'-D_FORTIFY_SOURCE=2',
          match {
            lvl'strong' { fl'-fstack-protector-strong', },
            lvl'all' { fl'-fstack-protector-all', },
            fl'-fstack-protector',
          }
        },
      }
    },

    opt'relro' {
      match {
        lvl'off' { link'-Xlinker-znorelro', },
        lvl'on'  { link'-Xlinker-zrelro', },
        { --[[lvl'full']]
          link'-Xlinker-zrelro',
          link'-Xlinker-znow',
          link'-Xlinker-znoexecstack',
        },
      }
    },

    opt'pie' {
      match {
        lvl'off'{ link'-no-pic', },
        lvl'on' { link'-pie', },
        lvl'fpie'{ flag'-fpie', },
        lvl'fpic'{ flag'-fpic', },
        lvl'fPIE'{ flag'-fPIE', },
        lvl'fPIC'{ flag'-fPIC', },
      }
    },

    opt'sanitizers' {
      lvl'on' { flag'-ftrapuv' }
    },

    opt'integer_sanitizers' {
      match {
        lvl'on' { flag'-funsigned-bitfields' },
        flag'-fno-unsigned-bitfields'
      }
    },

    opt'float_sanitizers' {
      lvl'on' {
        flag'-fp-stack-check',
        flag'-fp-trap=common',
        -- flag'-fp-trap=all',
      }
    },

    opt'linker' {
      match {
        lvl'bfd' { link'-fuse-ld=bfd' },
        lvl'gold' { link'-fuse-ld=gold' },
        lvl'mold' { link'-fuse-ld=mold' },
        link'-fuse-ld=lld'
      }
    },

    opt'lto' {
      match {
        lvl'off' { fl'-no-ipo', },
        {
          fl'-ipo',
          lvl'fat' {
            linux {
              fl'-ffat-lto-objects',
            }
          }
        }
      }
    },

    opt'control_flow' {
      match {
        lvl'off' {
          flag'-mconditional-branch=keep',
          flag'-fcf-protection=none',
        },
        lvl'branch' {
          flag'-mconditional-branch=all-fix',
          flag'-fcf-protection=branch',
        },
        lvl'on' {
          flag'-mconditional-branch=all-fix',
          flag'-fcf-protection=full',
        }
      }
    },

    opt'exceptions' {
      match { lvl'on' { flag'-fexceptions' }, flag'-fno-exceptions' },
    },

    opt'rtti' {
      match { lvl'on' { cxx'-frtti' }, cxx'-fno-rtti' },
    },

    opt'cpu' {
      match { lvl'generic' { fl'-mtune=generic' }, fl'-xHost' },
    },

  },

  mingw {
    opt'windows_bigobj' {
      flag'-Wa,-mbig-obj',
    },
  },
}

}
end -- MakeAST

local function create_ordered_keys(t)
  local ordered_keys = {}

  for k in pairs(t) do
    table_insert(ordered_keys, k)
  end

  table.sort(ordered_keys)
  return ordered_keys
end

local function unpack_table_iterator(t)
  local i = 0
  return function()
    i = i + 1
    return unpack(t[i])
  end
end

local function table_iterator(t)
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
local function escape(c) return escaped_table[c] end
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

local Vbase = {
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
      values={'off', 'on'},
      description='Enables an static analysis. It can have false positives and false negatives. It is a bug-finding tool, rather than a tool for proving program correctness. Available only with GCC and MSVC.',
      incidental=true,
    },

    analyzer_too_complex_warning={
      values={'off', 'on'},
      description='By default, the analysis silently stops if the code is too complicated for the analyzer to fully explore and it reaches an internal limit. This option warns if this occurs. Available only with GCC.',
      incidental=true,
    },

    analyzer_verbosity={
      values={
        {'0', 'At this level, interprocedural call and return events are displayed, along with the most pertinent state-change events relating to a diagnostic. For example, for a double-free diagnostic, both calls to free will be shown.'},
        {'1', 'As per the previous level, but also show events for the entry to each function.'},
        {'2', 'As per the previous level, but also show events relating to control flow that are significant to triggering the issue (e.g. “true path taken” at a conditional). This level is the default.'},
        {'3', 'As per the previous level, but show all control flow events, not just significant ones.'},
      },
      description='Controls the complexity of the control flow paths that are emitted for analyzer diagnostics. Available only with GCC.',
      incidental=true,
    },

    color={
      values={'auto', 'never', 'always'},
      incidental=true,
    },

    control_flow={
      values={'off', 'on', 'branch', 'return', 'allow_bugs'},
      description='Insert extra runtime security checks to detect attempts to compromise your code.',
    },

    conversion_warnings={
      values={
        'off',
        {'on', 'Combine conversion and sign value'},
        {'sign', 'Warn for implicit conversions that may change the sign (lke `unsigned_integer = signed_integer`) or a comparison between signed and unsigned values could produce an incorrect result when the signed value is converted to unsigned.'},
        {'float', 'Warn for implicit conversions that reduce the precision of a real value.'},
        {'conversion', 'Warn for implicit conversions that may alter a value.'},
        {'all', 'Like conversion and also warn about implicit conversions from arithmetic operations even when conversion of the operands to the same type cannot change their values.'},
      },
      default='on',
      description='Warn for implicit conversions that may alter a value.',
      incidental=true,
    },

    coverage={
      values={'off', 'on'},
    },

    covered_switch_default_warnings={
      values={'on', 'off'},
      default='on',
      description='Warning for default label in switch which covers all enumeration values.',
      incidental=true,
    },

    cpu={
      values={'generic', 'native'},
    },

    debug={
      values={
        'off',
        'on',
        'gdb',
        'lldb',
        {'vms',  'Alpha/VMS debug format (used by DEBUG on Alpha/VMS systems).'},
        {'codeview', 'CodeView debug format (used by Microsoft Visual C++ on Windows).'},
        'dbx',
        'sce',
      },
      description='Produce debugging information in the operating system\'s.',
    },

    debug_level={
      values={
        '0', '1', '2', '3',
        {'line_tables_only', 'Emit debug line number tables only.'},
        {'line_directives_only', 'Emit debug line info directives only.'},
      },
      description='Specify debugging level',
    },

    diagnostics_format={
      values={'fixits', 'patch', 'print_source_range_info'},
      description='Emit fix-it hints in a machine-parseable format.',
      incidental=true,
    },

    diagnostics_show_template_tree={
      values={'off', 'on'},
      description='Enables printing a tree-like structure showing the common and differing parts of the types.',
      incidental=true,
      unavailable='c',
    },

    elide_type={
      values={'off', 'on'},
      description='Prints diagnostics showing common parts of template types as "[...]".',
      incidental=true,
      unavailable='c',
    },

    exceptions={
      values={'off', 'on'},
      description='Enable C++ exceptions.',
    },

    fix_compiler_error={
      values={'off', 'on'},
      default='on',
      description='Transforms some warnings into errors to comply with the standard.',
      incidental=true,
    },

    float_sanitizers={
      values={'off', 'on'},
    },

    integer_sanitizers={
      values={'off', 'on'},
    },

    linker={
      values={'bfd', 'gold', 'lld', 'mold', 'native'},
      description='Configure linker.',
      incidental=true,
    },

    lto={
      values={'off', 'on', 'normal', 'fat', 'thin'},
      description='Enable Link Time Optimization.',
    },

    msvc_conformance={
      values={'all', 'all_without_throwing_new'},
      default='all',
      description='Standard conformance options.',
    },

    msvc_crt_secure_no_warnings={
      values={'off', 'on'},
      default='on',
      description='Disable CRT warnings with MSVC.',
      incidental=true,
    },

    msvc_diagnostics_format={
      values={
        {'classic', 'Which reports only the line number where the issue was found.'},
        {'column', 'Includes the column where the issue was found. This can help you identify the specific language construct or character that is causing the issue.'},
        {'caret', 'Includes the column where the issue was found and places a caret (^) under the location in the line of code where the issue was detected.'},
      },
      default='caret',
      description='Controls the display of error and warning information (https://learn.microsoft.com/en-us/cpp/build/reference/diagnostics-compiler-diagnostic-options?view=msvc-170).',
      incidental=true,
    },

    msvc_isystem={
      values={
        'anglebrackets',
        'include_and_caexcludepath',
        'external_as_include_system_flag',
        {'assumed', 'Do not activate /external:W0, but considers the option as activated so that warning=on or more activates more warnings.'},
      },
      description='Warnings concerning external header (https://devblogs.microsoft.com/cppblog/broken-warnings-theory).',
      incidental=true,
    },

    msvc_isystem_with_template_from_non_external={
      values={'off', 'on'},
      description='Warnings concerning template in an external header (requires msvc_isystem).',
      incidental=true,
      unavailable='c',
    },

    ndebug={
      values={'off', 'on', 'with_optimization_1_or_above'},
      default='with_optimization_1_or_above',
      description='Enable NDEBUG macro (disable assert macro).',
    },

    noexcept_warnings={
      values={'off', 'on'},
      description='Warn when a noexcept-expression evaluates to false because of a call to a function that does not have a non-throwing exception specification (i.e. "throw()" or "noexcept") but is known by the compiler to never throw an exception.',
      incidental=true,
      unavailable='c',
    },

    optimization={
      values={
        {'0', 'Not optimize.'},
        {'g', 'Enable debugging experience.'},
        {'1', 'Optimize.'},
        {'2', 'Optimize even more.'},
        {'3', 'Optimize yet more.'},
        {'fast', 'Enables all optimization=3 and disregard strict standards compliance.'},
        {'size', 'Optimize for size.'},
        {'z', 'Optimize for size aggressively (/!\\ possible slow compilation with emcc).'},
      },
      description='Optimization level.',
    },

    other_sanitizers={
      values={'off', 'thread', 'pointer', 'memory'},
      description='Enable other sanitizers.',
    },

    pedantic={
      values={'off', 'on', 'as_error'},
      default='on',
      description='Issue all the warnings demanded by strict ISO C and ISO C++.',
    },

    pie={
      values={'off', 'on', 'static', 'fpic', 'fPIC', 'fpie', 'fPIE'},
      description='Controls position-independent code generation.',
    },

    relro={
      values={'off', 'on', 'full'},
      description='Specifies a memory segment that should be made read-only after relocation, if supported.',
    },

    reproducible_build_warnings={
      values={'off', 'on'},
      description='Warn when macros "__TIME__", "__DATE__" or "__TIMESTAMP__" are encountered as they might prevent bit-wise-identical reproducible compilations.',
      incidental=true,
    },

    rtti={
      values={'off', 'on'},
      description='Disable generation of information about every class with virtual functions for use by the C++ run-time type identification features ("dynamic_cast" and "typeid").',
      unavailable='c',
    },

    sanitizers={
      values={'off', 'on'},
      description='Enable sanitizers (asan, ubsan, etc).',
    },

    stl_hardening={
      values={
        {'off'},
        {'fast', 'A set of security-critical checks that can be done with relatively little overhead in constant time and are intended to be used in production. No impact on the ABI.'},
        {'extensive', 'All the checks from fast mode and some additional checks for undefined behavior that incur relatively little overhead but aren’t security-critical. No impact on the ABI.'},
        {'debug', 'Enables all the available checks, including heuristic checks that might have significant performance overhead as well as internal library assertions. No impact on the ABI.'},
        {'debug_with_broken_abi', 'Debug mode with ABI incompatibility for more check.'},
      },
      description='Hardening allows turning some instances of undefined behavior in the standard library into a contract violation.',
      unavailable='c',
    },

    stl_fix={
      values={'off', 'on'},
      default='on',
      description='Enable /DNOMINMAX with msvc.',
    },

    shadow_warnings={
      values={'off', 'on', 'local', 'compatible_local', 'all'},
      default='off',
      incidental=true,
    },

    stack_protector={
      values={'off', 'on', 'strong', 'all'},
      description='Emit extra code to check for buffer overflows, such as stack smashing attacks.',
    },

    suggestions={
      values={'off', 'on'},
      description='Warn for cases where adding an attribute may be beneficial.',
      incidental=true,
    },

    switch_warnings={
      values={'on', 'off', 'exhaustive_enum', 'mandatory_default', 'exhaustive_enum_and_mandatory_default'},
      default='on',
      description='Warnings concerning the switch keyword.',
      incidental=true,
    },

    unsafe_buffer_usage_warnings={
      values={'on', 'off'},
      description='Enable -Wunsafe-buffer-usage with clang (https://clang.llvm.org/docs/SafeBuffers.html).',
      incidental=true,
    },

    var_init={
      values={
        {'uninitialized', 'Doesn\'t initialize any automatic variables (default behavior of Gcc and Clang).'},
        {'pattern', 'Initialize automatic variables with byte-repeatable pattern (0xFE for Gcc, 0xAA for Clang).'},
        {'zero', 'zero Initialize automatic variables with zeroes.'},
      },
      description='Initialize all stack variables implicitly, including padding.',
    },

    warnings={
      values={
        'off',
        {'on', 'Activates essential warnings and extras.'},
        {'essential', 'Activates essential warnings, typically -Wall -Wextra or /W4).'},
        {'extensive', 'Activates essential warnings, extras and some that may raise false positives'},
      },
      default='on',
      description='Warning level.',
      incidental=true,
    },

    warnings_as_error={
      values={'off', 'on', 'basic'},
      description='Make all or some warnings into errors.',
      -- incidental=true,
    },

    whole_program={
      values={'off', 'on', 'strip_all'},
      description='Assume that the current compilation unit represents the whole program being compiled. This option should not be used in combination with lto.',
    },

    windows_abi_compatibility_warnings={
      values={'off', 'on'},
      default='off',
      description='In code that is intended to be portable to Windows-based compilers the warning helps prevent unresolved references due to the difference in the mangling of symbols declared with different class-keys.',
      incidental=true,
      unavailable='c',
    },

    windows_bigobj={
      values={'on'},
      default='on',
      description='Increases that addressable sections capacity.',
    },
  },

  -- sorted by "importance"
  _opts_by_category={
    {'Warning', {
      'warnings',
      'warnings_as_error',
      'conversion_warnings',
      'covered_switch_default_warnings',
      'fix_compiler_error',
      'msvc_crt_secure_no_warnings',
      'noexcept_warnings',
      'reproducible_build_warnings',
      'shadow_warnings',
      'suggestions',
      'switch_warnings',
      'unsafe_buffer_usage_warnings',
      'windows_abi_compatibility_warnings',
    }},

    {'Pedantic', {
      'msvc_conformance',
      'pedantic',
      'stl_fix',
    }},

    {'Debug', {
      'debug',
      'debug_level',
      'stl_hardening',
      'control_flow',
      'sanitizers',
      'float_sanitizers',
      'integer_sanitizers',
      'other_sanitizers',
      'var_init',
      'ndebug',
      'optimization',
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
      'stl_hardening',
    }},

    {'Analyzer', {
      'analyzer',
      'analyzer_too_complex_warning',
      'analyzer_verbosity',
    }},

    -- other categories are automatically put in Other
  },

  _opts_build_type={
    debug={
      control_flow='on',
      debug='on',
      sanitizers='on',
      stl_hardening='debug',
    },
    release={
      -- linker='native',
      lto='on',
      optimization='3',
    },
    debug_optimized={
      debug='on',
      -- linker='native',
      lto='on',
      optimization='g',
    },
    minimum_size_release={
      -- linker='native',
      lto='on',
      optimization='size',
    },
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

  startoptcond = noop, -- function(self, name) end
  stopopt = noop, -- function(self) end

  startcond = noop, -- function(self, x, optname) end
  elsecond = noop, -- function(self, optname) end
  stopcond = noop, -- function(self, optname) end

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
        elseif notv.compiler_like then
          self:write(' ' .. self:_vcond_compiler_like(notv.compiler_like, true, notv.compilers))
        elseif notv.platform then self:write(' ' .. self:_vcond_platform(notv.platform, true))
        elseif notv.linker   then self:write(' ' .. self:_vcond_linker(notv.linker, true))
        elseif notv.check_opt then
          local o = notv.check_opt
          self:write(' ' .. self:_vcond_check_opt(o.optname, o.levels, o.exclude, true))
        else                      self:write(' ' .. self._vcondkeyword._not
                                          .. ' ' .. self._vcondkeyword.open)
                                  self:_vcond(notv, optname)
                                  self:write(' ' .. self._vcondkeyword.close)
        end
      elseif v.lvl      then self:write(' ' .. self:_vcond_lvl(v.lvl, optname))
      elseif v.major    then self:write(' ' .. self._vcond_version(self, v.op, v.major, v.minor))
      elseif v.compiler then self:write(' ' .. self:_vcond_compiler(v.compiler))
        elseif v.compiler_like then
          self:write(' ' .. self:_vcond_compiler_like(v.compiler_like, false, v.compilers))
      elseif v.platform then self:write(' ' .. self:_vcond_platform(v.platform))
      elseif v.linker   then self:write(' ' .. self:_vcond_linker(v.linker))
      elseif v.check_opt then
        local o = v.check_opt
        self:write(' ' .. self:_vcond_check_opt(o.optname, o.levels, o.exclude))
      else error('Unknown cond ' .. pairs(v)(v))
      end
    end

    self.eq_op = function(self, not_)
      if not_ then
        return self._vcondkeyword.not_eq
      end
      return self._vcondkeyword.eq
    end

    self._vcond_check_opt = self._vcond_check_opt or function(self, optname, levels, exclude, not_)
      if #levels == 0 then
        return self:_vcond_lvl('default', optname, not not_)
      end

      local strings = {}
      for _,lvl in pairs(levels) do
        table_insert(strings, self:_vcond_lvl(lvl, optname))
      end

      local cond = self._vcondkeyword.open .. ' '
                .. table.concat(strings, ' ' .. self._vcondkeyword._or .. ' ')
                .. ' ' .. self._vcondkeyword.close

      if exclude then
        return self:_vcond_lvl('default', optname, not not_)
            .. ' ' .. self._vcondkeyword._and
            .. ' ' .. self._vcondkeyword._not
            .. ' ' .. cond
      end

      return self:propagate_not(cond, not_)
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

    self._vcond_to_compiler_like = self._vcond_to_compiler_like
    or self._vcond_to_compiler_like_map and function(self, compiler_like)
      return self._vcond_to_compiler_like_map[compiler_like]
        or error('Unknown ' .. compiler_like .. ' tool')
    end
    or function(self, compiler_like, compilers)
      local t = {' '}
      table.insert(t, self._vcondkeyword.open)
      table.insert(t, self:_vcond_compiler(compilers[1]))
      for i=2,#compilers do
        table.insert(t, ' ')
        table.insert(t, self._vcondkeyword._or)
        table.insert(t, ' ')
        table.insert(t, self:_vcond_compiler(compilers[i]))
      end
      table.insert(t, ' ')
      table.insert(t, self._vcondkeyword.close)
      return table.concat(t, '')
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

    self._vcond_compiler_like = self._vcond_compiler_like or function(self, compiler_like, not_, compilers)
      if not_ then
        return self._vcondkeyword._not .. self:_vcond_to_compiler_like(compiler_like, compilers)
      end
      return self:_vcond_to_compiler_like(compiler_like, compilers)
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

    self._vcond_resetopt = self._vcond_resetopt or function(self, optname)
      return self:_vcond_to_opt(optname) .. ' = ' .. self:_vcond_to_lvl('default', optname)
    end

    self.resetopt = self.resetopt or function(self, optname)
      self:print(self.indent .. self:_vcond_resetopt(optname))
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
    local computed_options = self._computed_options

    if not computed_options then
      computed_options = {}
      self._computed_options = computed_options
      local ignore = self.ignore
      local lang = self.lang

      for _,k in ipairs(create_ordered_keys(self._koptions)) do
        local filter = ignore[k]
        local option = self._koptions[k]
        if filter ~= true and lang ~= option.unavailable then
          if filter then
            local newvalues = {}
            for _,value in ipairs(option.values) do
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
          local default_value = option.default or 'default'
          option.default = default_value

          local ordered_values = option.values
          if default_value ~= ordered_values[1] then
            ordered_values = {default_value}
            for _,value in pairs(option.values) do
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
      for _,k in pairs(create_ordered_keys(self._opts_build_type)) do
        local values = {}
        local profile = self._opts_build_type[k]
        for _,kv in pairs(create_ordered_keys(profile)) do
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
      -- 'default' will be inserted later at index 1
      -- it is therefore necessary to shift the description index of 1
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
      local check_opt = t._if.check_opt
      if check_opt then
        if not v._koptions[check_opt.optname] then
          error('Unknown "' .. check_opt.optname .. '" option')
        end
      end

      if check_opt and v.ignore[check_opt.optname] == true then
        evalflags(t._else, v, curropt)
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
    end

  elseif t.cxx or t.link then
    if t.cxx  then v:cxx(t.cxx, curropt) end
    if t.link then v:link(t.link, curropt) end

  elseif t.act then
    local r = v:act(t.act[1], curropt)
    if r == false or r == nil then
      error('Unknown action: ' .. t.act[1])
    elseif r ~= true then
      error('Error with Action ' .. t.act[1] .. ': ' .. r)
    end

  elseif t.reset_opt then
    v:resetopt(t.reset_opt)

  else
    for _,x in pairs(t) do
      evalflags(x, v, curropt)
    end
  end
end

local function clone_table(t)
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

local function insert_missing_function(V)
  for k,mem in pairs(Vbase) do
    if not V[k] then
      V[k] = mem
    end
  end
end

local _g_generators = {}
local function get_generator(name)
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

local function run(ast, is_C, filebase, ignore_options, generator_name, ...)
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

local function help(out)
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

local function check_optname(cond, optname)
  if not cond then
    io.stderr:write(arg[0] .. ": Unknown option: " .. optname .. '\n')
    os.exit(2)
  end
end

local function check_optvalue(cond, optname, optvalue)
  if not cond then
    io.stderr:write(arg[0] .. ": Unknown value: " .. optvalue .. ' in ' .. optname .. '\n')
    os.exit(2)
  end
end

-- {[0]=enabled, remove:bool, [platform_or_compiler_or_linker]=true, ...}
local tools_filter = {
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

local function push_run_params()
  local params = {is_C, filebase, ignore_options}
  table_insert(run_params, params)
  filebase = nil
  ignore_options = {}
  is_C = false
  return params
end

local cli={
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
      for optname, optdata in pairs(Vbase._koptions) do
        local v = select_options[optname]
        if not v then
          ignore_options[optname] = true
        elseif v ~= true then
          local t = {}
          for k in pairs(optdata.values) do
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

local function getoption(s, pos)
  local flag = s:sub(pos, pos)
  local opt = cli[flag]
  if not opt then
    io.stderr:write('Unknown option: -' .. flag .. ' in ' .. s .. '\n')
    os.exit(2)
  end
  return opt
end

local opti=1
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
    opt = getoption(s, ipos)
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

local ast_c = nil
local ast_cpp = nil
local ast

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

    local function printAST(ast, prefix)
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
