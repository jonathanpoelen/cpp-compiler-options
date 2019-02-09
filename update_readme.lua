#!/usr/bin/env lua

local README = arg[0]:gsub('[^/]+$','') .. 'README.md'

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

local options = io.popen('./compiler-options.lua generators/options.lua', 'r'):read('a')
contents = contents
:gsub('(<!%-%- summary %-%->)\n.+(\n<!%-%- /summary %-%->)', '%1' .. summary:gsub('%%%%', '%%') .. '%2')
:gsub('(<!%-%- %./compiler%-options%.lua generators/options%.lua color %-%->\n```ini\n).+(```\n<!%-%- %./compiler%-options%.lua %-%->)', '%1' .. options .. '%2')

io.open(README, 'w'):write(contents)
