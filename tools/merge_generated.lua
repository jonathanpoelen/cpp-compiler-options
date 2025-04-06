#!/usr/bin/env lua

local function atorset(t, k)
  local l = t[k]
  if not l then
    l = {}
    t[k] = l
  end
  return l
end

local prefix = arg[1]
if prefix:sub(#prefix) ~= '/' then
  prefix = prefix .. '/'
end
local subat = #prefix + 1
local tree = {} -- [compiler][version] = path
local categories = {} -- [cat] = true
for i=2,#arg do
  local filename = arg[i]:sub(subat)
  local comp, vers, cat = filename:match('^([^/]+)/%1-(%d[^-]+)-(.*)')
  if not comp then
    comp, cat = filename:match('^([^/]+)/%1-(.*)')
    vers = ''
  end
  -- print(comp, vers, cat)
  if comp then
    local l = atorset(atorset(tree, comp), vers)
    categories[cat] = true
    l[#l+1] = arg[i]
  end
end

-- os.exit()

local function get_file_contents(path)
  local f, err = io.open(path)
  if err then
    error(path .. ': ' .. err)
  end
  local s = f:read('*a')
  f:close()
  return s
end

local function load_files(prefix)
  local t = {}
  for cat in pairs(categories) do
    t[cat] = get_file_contents(prefix .. cat)
  end
  return t
end

local function append_table(t, ...)
  for x in ... do
    t[#t+1] = x
  end
  return t
end

local function split_lines(s, t)
  t = t or {}
  if s then
    return append_table(t, s:gmatch('[^\n]+'))
  end
  return t
end

local function tokeys(t, tk)
  tk = tk or {}
  for _,x in pairs(t) do
    tk[x] = x
  end
  return tk
end

local function write_ktable(t, path)
  t[''] = nil
  t = append_table({}, pairs(t))
  table.sort(t)
  local f = io.open(path, 'w+')
  f:write(table.concat(t,'\n'))
  f:write('\n')
  f:close()
  return t
end

local function remove_file(path)
  print(path)
  os.remove(path)
end

local function create_debug_file(prefix, files_contents)
  local lines = tokeys(
    split_lines(files_contents['debug'],
      split_lines(files_contents['sanitizers'])))

  -- debug_full file
  local debug_full = tokeys(split_lines(files_contents['stl_debug']), tokeys(lines))
  write_ktable(debug_full, prefix .. 'debug_full')

  -- debug_full_broken_abi file
  local debug_full_broken_abi = tokeys(split_lines(files_contents['stl_debug_broken_abi']), lines)
  write_ktable(debug_full_broken_abi, prefix .. 'debug_full_broken_abi')
end

for comp,versions in pairs(tree) do
  -- extract sorted version
  local t = {} -- {number, vers:string}
  for vers in pairs(versions) do
    t[#t+1] = {tonumber(vers) or 0, vers}
  end
  table.sort(t, function(a,b) return a[1] < b[1] end)
  local prefixcompbase = prefix .. comp .. '/' .. comp .. '-'
  local prefixcomp = (t[1][1] ~= 0 and prefixcompbase .. t[1][2] .. '-' or prefixcompbase)
  local files_contents = load_files(prefixcomp)
  create_debug_file(prefixcomp, files_contents)
  for i=2,#t do
    prefixcomp = prefixcompbase .. t[i][2] .. '-'
    local current_files_contents = load_files(prefixcomp)
    local is_same = true
    for cat in pairs(files_contents) do
      if files_contents[cat] ~= current_files_contents[cat] then
        is_same = false
        break
      end
    end

    if is_same then
      for cat in pairs(files_contents) do
        remove_file(prefixcomp .. cat)
      end
    else
      files_contents = current_files_contents
      create_debug_file(prefixcomp, files_contents)
    end
  end
end
