#!/usr/bin/env lua

local README = arg[0]:gsub('[^/]+$','') .. '/../README.md'

local f, err = io.open(README)
if not f then
  error(err)
end

local H = {}
local summary = ''
local pre='                     '
local contents = ''
local incode = false

while true do
  local line = f:read('L')
  if not line then
    break
  end

  contents = contents .. line

  if line:find('^```') then
    incode = not incode
  end

  if not incode then
    local found, lvl = line:find('^(#+)')
    if found then
      H[lvl] = (H[lvl] or 0) + 1
      H[lvl+1] = 0
      local title = line:sub(lvl + 2, -2)
      local link = title:lower():gsub(' ', '-'):gsub('[^-_a-zA-Z0-9]', '')
      summary = summary .. '\n' .. pre:sub(0, (lvl-1)*4) .. tostring(H[lvl]) .. '. [' .. title .. '](#' .. link .. ')'
    end
  end
end

local options = io.popen('./compiler-options.lua generators/list_options.lua --categorized', 'r'):read('a')
local notdefaults = {}
for opt,v in options:gmatch('([-_%w]+) = ([-_%w]+)') do
  if v ~= 'default' then
    local t = notdefaults[v]
    if not t then
      t = {}
      notdefaults[v] = t
    end
    t[#t+1] = opt
  end
end

local strnotdefaults1 = {}
local strnotdefaults2 = {}
for k,l in pairs(notdefaults) do
  if #l == 1 then
    strnotdefaults1[#strnotdefaults1+1] = '- `' .. l[1] .. '` is `' .. k .. '`'
  else
    table.sort(l)
    strnotdefaults2[#strnotdefaults2+1] = '- The following values are `' .. k
                                     .. '`:\n  - `' .. table.concat(l, '`\n  - `') .. '`'
  end
end
table.sort(strnotdefaults1)
table.sort(strnotdefaults2)
contents = contents
:gsub('(<!%-%- summary %-%->)\n.+(\n<!%-%- /summary %-%->)', '%1' .. summary:gsub('%%%%', '%%') .. '%2')
:gsub('(<!%-%- %./compiler%-options%.lua generators/list_options%.lua %-%-color %-%-categorized %-%->\n```ini\n)[^`]*(```\n<!%-%- %./compiler%-options%.lua %-%->).-[^<]*',
  '%1' .. options .. '%2\n\nIf not specified:\n\n'
  .. table.concat(strnotdefaults1, '\n') .. '\n'.. table.concat(strnotdefaults2, '\n') .. '\n\n')

io.open(README, 'w'):write(contents)
