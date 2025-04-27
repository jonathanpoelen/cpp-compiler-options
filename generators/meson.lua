local table_insert = table.insert

local meson_compilers = {
  icc='intel',
  icl='intel-cl',
  ['clang-emcc']='emscripten',
}

return {
  ignore={
  --  optimization=true,
  --  debug=true, -- reserved
    msvc_isystem={external_as_include_system_flag=true},
  },

  tobuildoption=function(self, optname)
    return self.optprefix .. optname
  end,

  _option_strs = {},

  start=function(self, optprefix)
    local prefixfunc = self.is_C and 'jln_c' or 'jln'

    self.optprefix = optprefix and optprefix:gsub('-', '_') or ''
    self.prefixfunc = prefixfunc

    self._vcond_to_compiler_like_map = {
      ['clang-like'] = '___' .. prefixfunc .. '_is_clang_like',
    }

    self:_vcond_init({
      _not='not',
      _and='and',
      _or='or',
      openblock='',
      closeblock='',
      _else='else',
      endif='endif',
      compiler='___' .. prefixfunc .. '_compiler_id',
      linker='___' .. prefixfunc .. '_linker_id',
    })

    self:print_header('#')

    -- create default build types
    -- @{
    self:write('if get_variable(\'' .. prefixfunc .. '_use_profile_buildtype\', false)\n  '
            .. '___jln_options_by_modes = {\n')
    local buildtypes = {
      debug='debug',
      release='release',
      debug_optimized='debugoptimized',
      minimum_size_release='minsize',
    }
    for buildtypename, opts in self:getbuildtype() do
      buildtypename = buildtypes[buildtypename] or error('Unknown build type: ' .. buildtypename)
      self:write('    \'' .. buildtypename .. '\': {\n')
      for _,opt in pairs(opts) do
        self:write('      \'' .. opt[1] .. '\': \'' .. opt[2] .. '\',\n')
      end
      self:write('    },\n')
    end
    self:write('  }\nelse\n  ___jln_options_by_modes = {}\nendif\n\n')
    -- @}

    local option_strs = self._option_strs
    self:write([[
___]] .. prefixfunc .. [[_default_flags = get_variable(']] .. prefixfunc .. [[_default_flags', {}) + get_variable(']] .. prefixfunc .. [[_buildtype_flags', ___jln_options_by_modes).get(get_option('buildtype'), {})
if get_option('warning_level') == '0'
  ___]] .. prefixfunc .. [[_warnings = 'off'
else
  ___]] .. prefixfunc .. [[_warnings = ___]] .. prefixfunc .. [[_default_flags.get('warnings', get_option(']] .. self:tobuildoption('warnings') .. [['))
endif
___]] .. prefixfunc .. [[_flags = {
]])
    for option in self:getoptions() do
      local name = self:tobuildoption(option.name)
      table_insert(option_strs, "option('" .. name .. "', type : 'combo', choices : ['"
        .. table.concat(option.values, "', '") .. "'], value : '" .. option.default
        .. "', description : '" .. quotable_desc(option) .. "')")
      if option.name == 'warnings' then
        self:write("  '" .. option.name .. "': ___" .. prefixfunc .. "_warnings,\n")
      else
        self:write("  '" .. option.name .. "': ___" .. prefixfunc .. "_default_flags.get('" .. option.name .. "', get_option('" .. name .. "')),\n")
      end
    end

    local lang = self.lang

    self.platforms = {
      mingw="(host_machine.system() == 'windows' and ___"
            .. self.prefixfunc .. "_compiler_id == 'gcc')",
      windows="host_machine.system() == 'windows'",
      linux="host_machine.system() == 'linux'",
      macos="host_machine.system() == 'macos'",
    }

    self.not_platforms = {
      mingw="not " .. self.platforms['mingw'],
      windows="host_machine.system() != 'windows'",
      linux="host_machine.system() != 'linux'",
      macos="host_machine.system() != 'macos'",
    }

    self:print([[}

]] .. prefixfunc .. [[_custom_]] .. lang .. [[_flags = []
]] .. prefixfunc .. [[_custom_link_flags = []

___]] .. prefixfunc .. [[_compiler = meson.get_compiler(']] .. lang .. [[')
___]] .. prefixfunc .. [[_compiler_id = ___]] .. prefixfunc .. [[_compiler.get_id()
if ___]] .. prefixfunc .. [[_compiler_id == 'emscripten'
  ___]] .. prefixfunc .. [[_compiler_version = ___]] .. prefixfunc .. [[_compiler.get_define('__clang_major__.__clang_minor__').replace(' ', '')
  ___]] .. prefixfunc .. [[_is_clang_like = true
else
  ___]] .. prefixfunc .. [[_compiler_version = ___]] .. prefixfunc .. [[_compiler.version()
  ___]] .. prefixfunc .. [[_is_clang_like = ['clang', 'emscripten', 'icx', 'icx-cl'].contains(___]] .. prefixfunc .. [[_compiler_id)
endif
___]] .. prefixfunc .. [[_linker_id = ___]] .. prefixfunc .. [[_compiler.get_linker_id()

___]] .. prefixfunc .. [[_custom_flags = get_variable(']] .. prefixfunc .. [[_custom_flags', []) + [___]] .. prefixfunc .. [[_flags]

foreach ___]] .. prefixfunc .. [[_flags : ___]] .. prefixfunc .. [[_custom_flags
  ]] .. prefixfunc .. [[_]] .. lang .. [[_flags = []
  ]] .. prefixfunc .. [[_link_flags = []

]])
  end,

  _vcond_resetopt=function(self, optname) return "___" .. self.prefixfunc .. "_flags += {'" .. optname .. "': 'default'}" end,

  _vcond_to_opt=function(self, optname) return "___" .. self.prefixfunc .. "_flags.get('" .. optname .. "', 'default')" end,
  _vcond_to_compiler=function(self, compiler) return "'" .. (meson_compilers[compiler] or compiler) .. "'" end,
  _vcond_version=function(self, op, major, minor) return "___" .. self.prefixfunc .. "_compiler_version.version_compare('" .. op .. major .. '.' .. minor .. "')" end,
  _vcond_platform=function(self, platform, not_)
    return (not_ and self.not_platforms or self.platforms)[platform]
  end,

  cxx=function(self, x) return "'" .. x .. "', " end,
  link=function(self, x) return "'" .. x .. "', " end,

  act=function(self, datas, optname)
    self:print(self.indent .. '# unimplementable')
    return true
  end,

  _vcond_toflags=function(self, cxx, links)
    return (#cxx ~= 0 and self.indent .. self.prefixfunc .. '_' .. self.lang .. '_flags += [' .. cxx .. ']\n' or '')
        .. (#links ~= 0 and self.indent .. self.prefixfunc .. '_link_flags += [' .. links .. ']\n' or '')
  end,

  stop=function(self, filebase)
    local meson_options = table.concat(self._option_strs, '\n') .. '\n'
    local meson_build = self:get_output() .. [[

  ]] .. self.prefixfunc .. [[_custom_]] .. self.lang .. [[_flags += []] .. self.prefixfunc .. [[_]] .. self.lang .. [[_flags]
  ]] .. self.prefixfunc .. [[_custom_link_flags += []] .. self.prefixfunc .. [[_link_flags]
endforeach
]]

    return filebase and {
      {filebase .. '_options.txt', meson_options},
      {filebase, meson_build}
    } or '# meson_options.txt\n' .. meson_options ..
     '\n\n# meson.build\n' .. meson_build
  end
}
