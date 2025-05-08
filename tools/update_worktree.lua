#!/usr/bin/env lua

-- mkdir w
-- for d in bjam cmake meson premake5 scons xmake ; do git worktree add w/$d ; done

local function readfile(filename)
  local f,e = io.open(filename)
  if e then
    error(filename .. ': ' .. e)
  end
  local r = f:read'*a'
  f:close()
  return r
end

local function writefile(filename, ...)
  local f,e = io.open(filename, 'w')
  if e then
    error(filename .. ': ' .. e)
  end
  f:write(...)
  f:close()
end


local readme = readfile('README.md')
local changelog = readfile('CHANGELOG.md')
local start_options = readme:find('# Options', 0, true)
local end_options = readme:find('# Use generated files', start_options, true)

local options_md = readme:sub(start_options, end_options - 2)

for _,t in ipairs({
  -- name, H2 in md, comm, cfile, cppfile, extra_files
  {'bjam', 'Bjam', '#', 'c.jam', 'cpp.jam', },
  {'cmake', 'CMake', '#', 'c.cmake', 'cpp.cmake', },
  {'meson', 'Meson', '#', 'c/meson.build', 'cpp/meson.build', {
    ['output/c/meson_options.txt'] = 'w/meson/c/meson_options.txt',
    ['output/cpp/meson_options.txt'] = 'w/meson/cpp/meson_options.txt',
  }},
  {'premake5', 'Premake5', '--', 'c.lua', 'cpp.lua', },
  {'scons', 'SCons', '#', 'c/SConscript', 'cpp/SConscript', },
  {'xmake', 'xmake', '--', 'c/flags.lua', 'cpp/flags.lua', {
    ['output/c/xmake_options.lua'] = 'w/xmake/c/xmake.lua',
    ['output/cpp/xmake_options.lua'] = 'w/xmake/cpp/xmake.lua',
  }},
}) do
  start_build = readme:find('## ' .. t[2], end_options, true)
  start_build = readme:find('```', start_build, true)
  end_build = readme:find('```', start_build + 7, true)
  build_md = readme:sub(start_build, end_build + 4):gsub('output/cpp/'..t[1], t[5])

  md = build_md .. '\n' .. options_md
  header = t[3] .. '  ' .. md:gsub('\n', '\n' .. t[3] .. '  ')
  header = header:gsub('%s*\n', '\n')

  filebase = 'w/'..t[1]..'/'
  writefile(filebase..'README.md', md)
  writefile(filebase..'CHANGELOG.md', changelog)
  writefile(filebase..t[4], header, '\n\n', readfile('output/c/'..t[1]))
  writefile(filebase..t[5], header, '\n\n', readfile('output/cpp/'..t[1]))

  for src,dst in pairs(t[6] or {}) do
    writefile(dst, readfile(src))
  end
end
