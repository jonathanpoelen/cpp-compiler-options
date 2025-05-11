local known_opts = {}
local errors = {}

local _color_map = {
  '\027[34m',
  '\027[35m',
  -- specific color for certain values
  on='\027[32m',
  off='\027[31m',
  default='\027[37m',
}

local _color_value1 = '34'
local _color_value2 = '35'
local _color_on = '32'
local _color_off = '31'
local _color_default = '37'
local _color_reverse = ';7'
local _color_sep = '37'
local _color_desc = '\027[37m'
local _color_cat = '\027[1m'
local _color_reset = '\027[m'

local html_header = [[<!DOCTYPE html>
<html>
<head>
<title>C++ Compiler Options reference</title>
<style>

:root {
  --fg: #000;
  --bg: #fff;
  --bg-group: #eee;

  --bg-code: #fff;

  --border-group: #555;

  --link-color: #2244fe;
  --link-visited: #643096;
  --link-hover: #21b277;

  --bg-group-header: #444;
  --fg-group-header: #fff;
  --fg-group-header-hover: #a0ff00;
}

@media (prefers-color-scheme: dark) {
  :root {
    --fg: #f3f3f3;
    --bg: #000;
    --bg-group: #222;

    --bg-code: #333;

    --border-group: #555;

    --link-color: #b8daff;
    --link-visited: #d8affe;
    --link-hover: #81faa7;
  }
}

html {
  background: var(--bg);
  color: var(--fg);
}

a {
  color: var(--link-color);
}

a:hover, a:hover:visited {
  color: var(--link-hover);
}

a:visited {
  color: var(--link-visited);
}


code {
  font-size: 1em;
  background: var(--bg-code);
}

ul {
  margin: 0;
  padding: 0 0 0 1em;
}

li {
  margin-bottom: .2em;
}

dl {
  padding: 0;
  margin: 0;
}

dd {
  margin: 1em;
}

dt {
  padding: .5em;
  border-radius: .5em .5em 0 0;
  background: var(--bg-group-header);
}

dt, .option-name > a {
  color: var(--fg-group-header);
}

.option-name > a:hover, .option-name > a:focus {
  color: var(--fg-group-header-hover);
}

.group {
  border: 2px solid var(--border-group);
  border-radius: .5em;
  background-color: var(--bg-group);
  margin-bottom: 1em;
}

.option-desc {
  display: inline-block;
  margin:  0 0 .5em 0;
}


.header-link, .linked-header {
  display: inline-block;
}

.header-link {
  margin: 0;
  padding: 0 .5em 0 0;
}


#nav {
  display: flex;
  flex-wrap: wrap;
}

.nav-option {
  border: 2px solid var(--border-group);
  border-radius: .5em;
  background-color: var(--bg-group);
  padding: 0 1em 1em 1em;
  margin: 0 0 1em 1em;
}

.nav-option > ul > li {
  margin: 0;
  padding: 0;
}
.nav-option > ul > li > a {
  margin: 0;
  padding: .1em 0;
  display: inline-block;
}

</style>
</head>
<body>

<p>This page lists the available options for the <a href="https://github.com/jonathanpoelen/cpp-compiler-options/">C++ Compiler Options</a> project.</p>
]]

local html_footer = '</body></html>'

-- template
--[[

<title_start>Options</title_end> (when profile)

<category_start>{cat}<category_end>
<option_list_start>
loop{
  <option_list_sep> (except first block)
  <option_name_start>{opt.name}</option_name_end>
  <option_desc_block_start>
    <option_desc_start>{opt.desc}</option_desc_end>
    <value_list_start>
    loop{
      <value_list_sep> (except first block)
      <value_name_start>
        <value_on> | <value_off> | <value_default> | <even_value> | <odd_value>
        (<default_value>)
        <value_name_end_style>
        {value.name}
      </value_name_end>
      <value_desc_start>{value.desc}</value_desc_end> | <value_nodesc>
    }
    </value_list_end>
  </option_desc_block_end>
}
</option_list_end>

(when profile)

<title_start>Profiles</title_end>

<profile_list_start>
loop{
  <profile_list_sep> (except first block)
  <profile_name_start>{opt.name}</profile_name_end>
  <profile_option_list_start>
  loop{
    <profile_option_list_sep> (except first block)
    <profile_option_name_and_value_start>
      {option.name}
      <profile_option_name_and_value_sep>
      {option.value}
    </profile_option_name_and_value_end>
  }
  </profile_option_list_end>
}
</profile_list_end>

]]

local html_option_name_attrs = ' class="option-name"'

local function get_template(html, colorize, show_profile, verbose)
  if html then
    return {
      verbose = true,

      title_start = '<h1>',
      title_end = '</h1>\n\n',

      category_start = show_profile and '<h2>' or '<h1>',
      category_end = show_profile and '</h2>\n\n' or '</h1>\n\n',

      option_list_start = '<dl>\n\n',
      option_list_sep = '\n',
      option_list_end = '\n</dl>\n',

      option_name_start = '<div class="group"><dt' .. html_option_name_attrs .. '>',
      option_name_end = '</dt>\n',

      option_desc_block_start = '<dd>\n',
      option_desc_block_end = '</dd></div>\n',

      option_desc_start = '  <span class="option-desc">',
      option_desc_end = '</span>',

      value_list_start = '\n  <ul>\n',
      value_list_sep = '',
      value_list_end = '  </ul>\n',

      value_name_start = '    <li class="',
      value_name_end_style = '"><code class="value">',
      value_name_end = '</code>',

      value_color_map = {
        'even-value',
        'odd-value',
        ' default-value',
        -- specific color for certain values
        on = 'value-on',
        off = 'value-off',
        default = 'value-default',
      },

      value_desc_start = ': ',
      value_desc_end = '</li>\n',
      value_nodesc = '</li>\n',

      -- profile

      profile_list_start = '<dl>\n\n',
      profile_list_sep = '\n',
      profile_list_end = '\n</dl>\n',

      profile_name_start = '<div class="group"><dt class="profile">',
      profile_name_end = '</dt>\n',

      profile_option_list_start = '<dd><ul>\n',
      profile_option_list_sep = '\n',
      profile_option_list_end = '\n</ul></dd></div>\n',

      profile_option_name_and_value_start = '  <li><code class="option-name">',
      profile_option_name_and_value_sep = '</code> = ',
      profile_option_name_and_value_end = '</code></li>',
    }
  else
    return {
      verbose = verbose,

      title_start = '',
      title_end = ':\n\n',

      category_start = (colorize and _color_cat or '') .. '# ',
      category_end = (colorize and _color_reset or '') .. ':\n\n',

      option_list_start = '',
      option_list_sep = verbose and '\n' or '',
      option_list_end = '',

      option_name_start = '',
      option_name_end = verbose and '\n'
                     or (colorize and '\027[' .. _color_sep .. 'm' or '') .. ' = ',

      option_desc_block_start = verbose and colorize and _color_desc or '',
      option_desc_block_end = verbose and colorize and _color_reset or '',

      option_desc_start = verbose and '  ' or '',
      option_desc_end = '\n',

      value_list_start = '',
      value_list_sep = verbose and '' or ' ',
      value_list_end = verbose and '' or (colorize and _color_reset or '') .. '\n',

      value_name_start = (verbose and '  - ' or '') .. (colorize and '\027[' or ''),
      value_name_end_style = colorize and 'm' or '',
      value_name_end = colorize and (verbose and '\027[0;' .. _color_sep .. 'm' or '\027[m') or '',

      value_color_map = {
        colorize and _color_value1 or '',
        colorize and _color_value2 or '',
        colorize and _color_reverse or '', -- default
        -- specific color for certain values
        on = colorize and _color_on or '',
        off = colorize and _color_off or '',
        default = colorize and _color_default or '',
      },

      value_desc_start = ': ',
      value_desc_end = '\n',
      value_nodesc = verbose and '\n' or '',

      -- profile

      profile_list_start = '',
      profile_list_sep = '\n',
      profile_list_end = '',

      profile_name_start = '',
      profile_name_end = '\n',

      profile_option_list_start = '',
      profile_option_list_sep = '',
      profile_option_list_end = '',

      profile_option_name_and_value_start = ' - ',
      profile_option_name_and_value_sep = ' = ',
      profile_option_name_and_value_end = '\n',
    }
  end
end

local table_insert = table.insert

local function add_opt(option)
  known_opts[option.name] = {option.kvalues}
end

local function without_space_otherwise_error(self, s)
  if s:find(' ') then
    table_insert(errors, '"' .. s .. '" contains a space')
  end
end

local function is_available(self, optname)
  return self._koptions[optname].unavailable ~= self.lang
end

local function table_insert_if_not_first(is_first, t, s)
  if not is_first then
    table_insert(t, s)
  end
end

local function html_escape_rep_sym(s)
  if s == '&' then
    return '&amp;'
  end
  return '&lt;'
end

local function to_html_url(url)
  local dot = ''
  -- exclude final dot
  if url:sub(-1) == '.' then
    dot = '.'
    url = url:sub(1, -2)
  end
  return '<a href="' .. url .. '">' .. url .. '</a>' .. dot
end

local function html_escape(s)
  s = s
    :gsub('/!\\', '⚠')
    :gsub('[&<]', html_escape_rep_sym)
    :gsub('`([^`]+)`', '`<code>%1</code>`')
    :gsub('https?://[^) ]+', to_html_url)
  return s
end

local function ansi_escape(s)
  -- TODO url support
  return s
end

local function to_html_id(s)
  return s:gsub('[^%w_ ]', ''):gsub(' ', '-'):lower()
end

local function html_linkable_header(tag, s, id)
  id = id or to_html_id(s)
  -- 🔗 = U+1F517
  return '<div><a class="header-link" href="#' .. id .. '">🔗</a><'
      .. tag .. ' class="linked-header" id="' .. id .. '">' .. s
      .. '</' .. tag .. '>' .. '</div>\n\n'
end

local function html_urlize_title(s)
  local title
  local title_id
  local titles = {}
  local new_title = true
  -- search h1, h2 and dt with attrs
  s = s:gsub('<([dh][t1-6])([^>]*)>(.-)</[^>]+>', function(tag, attrs, s)
    if tag == 'h1' or tag == 'h2' then
      title = s
      title_id = to_html_id(s)
      new_title = true
      return html_linkable_header(tag, s, title_id)

    elseif tag == 'dt' and attrs == html_option_name_attrs then
      local id = to_html_id(s)
      if title_id then
        id = title_id .. '--' .. id
      end
      if new_title then
        new_title = false
        table_insert(titles, {title or 'Options', {}})
      end
      table_insert(titles[#titles][2], {s, id})
      return '<dt' .. attrs .. ' id="' .. id .. '"><a href="#'
          .. id .. '">' .. s .. '</a></dt>'

    else
      return '<' .. tag .. attrs .. '>' .. s .. '</' .. tag .. '>'
    end
  end)
  return s, titles
end

return {
  start=function(self, ...)
    -- cli options
    local show_profile, colorize, categorized, verbose, html

    -- cli and parse
    -- @{
    local cli = {
      ['--categorized']=function() categorized=true end,
      ['--profile']=function() show_profile=true end,
      ['--color']=function() colorize=true end,
      ['--verbose']=function() verbose=true end,
      ['--html']=function() html=true end,
      ['-v']=function() verbose=true end,
    }

    for _,v in ipairs({...}) do
      local opt = cli[v]
      if not opt then
        local f = (v == '-h' or v == '--help') and io.stdout or io.stderr
        f:write(self.generator_name .. ' [{-h | --help] [{-v | --verbose}] [--categorized] [--profile] [--color]\n')
        f:flush()
        return false
      end
      opt()
    end
    -- @}

    -- reset table, populated with add_opt()
    known_opts = {}

    local template = get_template(html, colorize, show_profile, verbose)
    local value_color_map = template.value_color_map
    verbose = template.verbose

    local escaped = html and html_escape or ansi_escape

    local string_parts = {}
    -- {opt_name: string = [string, used: bool]}
    local stringify_options = {}

    if not categorized then
      table.insert(string_parts, template.option_list_start)
    end

    -- init option

    local icolor
    local desc
    local color = ''
    local first_opt = true
    local first_value

    for option in self:getoptions() do
      add_opt(option)

      -- option separation

      table_insert_if_not_first(first_opt, string_parts, template.option_list_sep)
      first_opt = false

      -- option name

      table_insert(string_parts, template.option_name_start)
      table_insert(string_parts, option.name)
      table_insert(string_parts, template.option_name_end)

      -- start description

      table_insert(string_parts, template.option_desc_block_start)

      -- option description

      if verbose and option.description then
        table_insert(string_parts, template.option_desc_start)
        table_insert(string_parts, escaped(option.description))
        table_insert(string_parts, template.option_desc_end)
      end

      -- option values

      table_insert(string_parts, template.value_list_start)

      icolor = 0
      first_value = true
      for i,opt_value in ipairs(option.ordered_values) do
        -- value separation

        table_insert_if_not_first(first_value, string_parts, template.value_list_sep)
        first_value = false

        -- value name

        table_insert(string_parts, template.value_name_start)
        if colorize then
          color = value_color_map[opt_value]
          if not color then
            color = value_color_map[icolor % 2 + 1]
            icolor = icolor + 1
          end
          table_insert(string_parts, color)
        end
        -- default
        if i == 1 then
          table_insert(string_parts, value_color_map[3])
        end
        table_insert(string_parts, template.value_name_end_style)
        table_insert(string_parts, opt_value)
        table_insert(string_parts, template.value_name_end)

        -- value description

        desc = verbose and option.value_descriptions[i]
        if desc then
          table_insert(string_parts, template.value_desc_start)
          table_insert(string_parts, escaped(desc))
          table_insert(string_parts, template.value_desc_end)
        else
          table_insert(string_parts, template.value_nodesc)
        end
      end

      table_insert(string_parts, template.value_list_end)

      table_insert(string_parts, template.option_desc_block_end)

      if categorized then
        stringify_options[option.name] = {table.concat(string_parts)}
        string_parts = {}
        first_opt = true
      end
    end

    -- init categories

    if categorized then
      local color_cat = colorize and _color_cat or ''
      local opt

      local push_title = function(name)
        table_insert(string_parts, template.category_start)
        table_insert(string_parts, name)
        table_insert(string_parts, template.category_end)
      end

      -- populate categories

      string_parts = {}

      for _,infos in ipairs(self._opts_by_category) do
        push_title(infos[1])

        table_insert(string_parts, template.option_list_start)

        first_opt = true
        for _,optname in ipairs(infos[2]) do
          table_insert_if_not_first(first_opt, string_parts, template.option_list_sep)
          first_opt = false
          opt = stringify_options[optname]
          opt[2] = true
          table_insert(string_parts, opt[1])
        end

        table_insert(string_parts, template.option_list_end)
        table_insert(string_parts, '\n\n')
      end

      -- populate "Other" category

      first_opt = true
      push_title('Other options')
      table_insert(string_parts, template.option_list_start)
      for option in self:getoptions() do -- getoptions() is always sorted
        opt = stringify_options[option.name]
        if not opt[2] then
          table_insert_if_not_first(first_opt, string_parts, template.option_list_sep)
          first_opt = false
          table_insert(string_parts, opt[1])
        end
      end
    end

    table_insert(string_parts, template.option_list_end)

    -- populate profile

    if show_profile then
      table_insert(string_parts, '\n\n')
      table_insert(string_parts, template.title_start)
      table_insert(string_parts, 'Profiles')
      table_insert(string_parts, template.title_end)

      first_opt = true
      table_insert(string_parts, template.profile_list_start)
      for name, opts in self:getbuildtype() do
        -- list separator
        table_insert_if_not_first(first_opt, string_parts, template.profile_list_sep)
        first_opt = false

        -- profile name
        table_insert(string_parts, template.profile_name_start)
        table_insert(string_parts, name)
        table_insert(string_parts, template.profile_name_end)

        first_value = true
        table_insert(string_parts, template.profile_option_list_start)
        for _,opt_name_and_value in ipairs(opts) do
          -- list separator
          table_insert_if_not_first(first_value, string_parts, template.profile_option_list_sep)
          first_value = false

          -- option name and value
          table_insert(string_parts, template.profile_option_name_and_value_start)
          table_insert(string_parts, opt_name_and_value[1])
          table_insert(string_parts, template.profile_option_name_and_value_sep)
          table_insert(string_parts, opt_name_and_value[2])
          table_insert(string_parts, template.profile_option_name_and_value_end)
        end
        table_insert(string_parts, template.profile_option_list_end)
      end
      table_insert(string_parts, template.profile_list_end)
    end

    -- print

    local s = table.concat(string_parts)
    if html then
      io.stdout:write(html_header)

      local tids
      s, tids = html_urlize_title(s)

      -- print navigation

      local string_parts = {
        html_linkable_header('h1', 'Navigation'),
        '<nav><div id="nav">',
      }

      table_insert(string_parts, '<div class="nav-option"><h2>Menu</h2><ul>')
      for _, title in ipairs({'Navigation', 'Options', show_profile and 'Profiles' or nil}) do
        table_insert(string_parts, '<li><a href="#')
        table_insert(string_parts, to_html_id(title))
        table_insert(string_parts, '">')
        table_insert(string_parts, title)
        table_insert(string_parts, '</a></li>\n')
      end
      table_insert(string_parts, '</ul></div>')

      for _,tid in ipairs(tids) do
        table_insert(string_parts, '<div class="nav-option">\n<h2>')
        table_insert(string_parts, tid[1])
        table_insert(string_parts, '</h2><ul>\n')
        for _,subtitle_info in ipairs(tid[2]) do
          table_insert(string_parts, '<li><a href="#')
          table_insert(string_parts, subtitle_info[2])
          table_insert(string_parts, '">')
          table_insert(string_parts, subtitle_info[1])
          table_insert(string_parts, '</a></li>\n')
        end
        table_insert(string_parts, '</ul></div>\n')
      end

      table_insert(string_parts, '</div></nav>\n')
      io.stdout:write(table.concat(string_parts))
    end

    if show_profile then
      local title = template.title_start .. 'Options' .. template.title_end
      if html then
        title = html_urlize_title(title)
      end
      io.stdout:write(title)
    end

    if html then
      io.stdout:write('<p>The first value corresponds to the one used by default, and the value `<code>default</code>` has no associated behavior.</p>\n\n')
    end

    io.stdout:write(s)

    if html then
      io.stdout:write(html_footer)
    end

    io.stdout:flush()
  end,

  resetopt=function(self, optname)
    local known = known_opts[optname]
    if not known then
      if is_available(self, optname) then
        table_insert(errors, '_koptions[' .. optname .. ']: unknown key')
      end
    end
  end,

  startoptcond=function(self, optname)
    local known = known_opts[optname]
    if not known then
      if is_available(self, optname) then
        table_insert(errors, '_koptions[' .. optname .. ']: unknown key')
      end
    else
      known[2] = true
    end
  end,

  startcond=function(self, x, optname)
    if x.lvl then
      local known = known_opts[optname]
      if not known then
        if is_available(self, optname) then
          table_insert(errors, '_koptions[' .. optname .. ']: unknown key')
        end
      elseif not known[1][x.lvl] then
        table_insert(errors, '_koptions[' .. optname .. ']: unknown value: ' .. x.lvl)
      else
        known[2] = true
      end
    elseif x._not then
      self:startcond(x._not, optname)
    else
      local sub = x._and or x._or
      if sub then
        for _,y in ipairs(sub) do
          self:startcond(y, optname)
        end
      end
    end
  end,

  stop=function()
    for k,opts in pairs(known_opts) do
      if not opts[2] then
        table_insert(errors, '_koptions[' .. k .. ']: not used in the tree')
      end
    end
    if #errors ~= 0 then
      error(table.concat(errors, '\n'))
    end
  end,

  cxx=without_space_otherwise_error,
  link=without_space_otherwise_error,
  act=function() return true end,
}
