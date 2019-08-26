_m = {} or _m

local kpse = kpse
kpse.set_program_name("luatex")
local kpse_version = kpse.version()
local inspect = require("inspect")

require("l-lpeg")
require("l-file")

local texmfsysvar = kpse.expand_var("$TEXMFSYSVAR")
local texmfvar = kpse.expand_var("$TEXMFVAR")
local texmfvar = kpse.expand_var("$TEXMFSYSVAR")
-- global
lua_font_dir = ""
local luaotfload_lookup_cache = texmfvar .. "/luatex-cache/generic/names/luaotfload-lookup-cache.luc"
local luaotfload_lookup_cache_sys = texmfsysvar .. "/luatex-cache/generic/names/luaotfload-lookup-cache.luc"
local luaotfload_lookup_names = texmfvar .. "/luatex-cache/generic/names/luaotfload-names.luc"
local luaotfload_lookup_names_sys = texmfsysvar .. "/luatex-cache/generic/names/luaotfload-names.luc"

if file.is_readable(luaotfload_lookup_cache) then
else
   luaotfload_lookup_cache = luaotfload_lookup_cache_sys
   if file.is_readable(luaotfload_lookup_cache) then
   else
      print("Not found luaotfload_lookup_cache: ", luaotfload_lookup_cache)
      os.exit(9)
   end
end
-- print("luaotfload_lookup_cache:\n", luaotfload_lookup_cache)

if file.is_readable(luaotfload_lookup_names) then
else
   luaotfload_lookup_names = luaotfload_lookup_names_sys
   if file.is_readable(luaotfload_lookup_names) then
   else
      print("Not found luaotfload_lookup_names: ", luaotfload_lookup_names)
      os.exit(9)
   end
end
-- print("luaotfload_lookup_names:\n", luaotfload_lookup_names)
-- print("texmfvar:\n ", texmfvar)

local function resolve_path(suffix, vartable)
   local f = vartable[1] .. suffix
   if file.is_readable(f) then
      print("Found: ", f)
   else
      f = vartable[2] .. suffix 
      if file.is_readable(f) then
         print("Found: ", f)
      else
         print("Not found: ", f)
         os.exit(9)
      end
   end
   return f
end

local lua_font_dir = "/luatex-cache/generic/fonts/otl/"
-- TeX Live 2017
if kpse_version == "kpathsea version 6.2.3" then
   lua_font_dir = "/luatex-cache/generic/fonts/otl/"
end
-- TeX Live 2016
if kpse_version == "kpathsea version 6.2.3/dev" then
   lua_font_dir = "/luatex-cache/generic/fonts/otl/"
end
-- TeX Live 2016
if kpse_version == "kpathsea version 6.2.2" then
   lua_font_dir = "/luatex-cache/generic/fonts/otl/"
end
-- TeX Live 2015
if kpse_version == "kpathsea version 6.2.1" then
   lua_font_dir = "/luatex-cache/generic/fonts/otf/"
end

--lua_font_dir = texmfsysvar .. lua_font_dir
lua_font_dir = texmfvar .. lua_font_dir

--print(luaotfload_lookup_names)
local otf_lookup = dofile(luaotfload_lookup_cache)
local otf_names  = dofile(luaotfload_lookup_names)
--local lc = {}
--for i, j in pairs(lookup_cache) do
--   print(i, j[1])
--   s = string.split(i, ':') 
--   lc[s[1]] = j[1]
--end
--print(inspect(lc))
--os.exit()
--]]

--local lookup_names = dofile(luaotfload_lookup_names)
 --print(inspect(lookup_names))
local function parse_features(s)
   local _s = {}
   local _l = s
   if s == '' then
      _s = nil
   end

   _lx = string.split(_l, ';')
   for _, _ly in ipairs(_lx) do
      if _ly == "" then
         break
      end
      _ly = string.gsub(_ly, '^+', '', 1)
      _li, _lj = string.match(_ly, '(.*)=(.*)')

      if _li == nil then
         _s[_ly] = true
      else
         _s[_li] = tonumber(_lj)
      end
   end

    return _s
end

local function parse_fontname(fontname)
   print(fontname)
   local s, d, x
   local lang_ = "DFLT"
   local base_, ext_, name_, rest_, shape_, filename_
   local _feat = {}
--   print("fontname: ", fontname)
   s = string.split(fontname, ':')
   name_, rest_ = s[1], s[2]
   s = string.match(name_, '%[(.*)%]')
   if s then
      filename_ = s
      s = string.split(s, ".")
      base_, ext_ = s[1], s[2]
   else
      base_ = name_
   end

   s1, s2 = string.match(base_, '(.*)/(.*)')
   if s1 then
      base_ = s1
   end
   if s2 then
      shape_ = s2
   end
   if rest_ then
      x, feat_ = string.match(rest_, '(.*)%+(.*)')
   else
      x = fontname
   end
-- feat_ = parse_features(feat_)
   if x then
   else
      x = rest_
   end

--   print(x)

   s = string.split(x, ";")
   for _i, _j in ipairs(s) do
      l = string.split(_j, "=")
      if l[1] == "mode" then
         mode_ = l[2]
      end

      if l[1] == "script" then
         script_ = l[2]
      end

      if l[1] == "language" then
         lang_ = l[2]
      end
   end

   d = {
--      rest = rest_,
--      name = name_,
      base = base_,
      ext = ext_,
      feat = feat_,
      mode = mode_,
      lang = lang_,
      script = script_,
      shape = shape_,
      filename = filename_,
   }
   return d
end

function lua_font_lookup_cache(filename, scale, shape, options)
   local _l, _font_lua, _font_lua_full = nil, nil, nil
   local _s = ""
   if shape then
      _s = filename .. '#' .. string.lower(shape) .. "#" .. scale
   else
      _s = filename .. "#" .. scale
   end
   print(_s)
    
   _l = nil or otf_lookup[_s][1]
   print(_l)
   if _l then
      _font_lua = file.nameonly(_l) .. ".luc"
      _font_lua_full = lua_font_dir .. string.lower(_font_lua)
   end
   return _font_lua_full
end

function lua_font_name_fls(filename, desing_size, scale, fls, options)
--   print(inspect(options))
--   os.exit(2)
   local font_lua = string.lower(filename) .. ".luc"
   local _font_lua_full = fls[string.lower(filename) .. ".luc"]
      or fls[string.lower(filename) .. ".lua"]
      or lua_font_dir .. string.lower(filename) .. ".luc"
      or lua_font_dir .. string.lower(filename) .. ".lua"
   local font_lua_l = nil
   if not _font_lua_full then
      if otf_lookup[filename .. "#" .. scale] then
         font_lua_l = otf_lookup[filename .. "#" .. scale ][1]
      end
      if font_lua_l then
         font_lua = file.nameonly(font_lua_l) .. ".luc"
         _font_lua_full = lua_font_dir .. font_lua
-- OK         _id = otf_names.files.base.texmf[font_lua_l]
      end
   end

   if options.verbose  then
      print("font lua(   ): " .. font_lua)
      print("font lua(fls): " .. _font_lua_full)
   end

   if not _font_lua_full then
      print("Not found:", string.lower(filename) .. ".(lua|luc)")
      os.exit(9)
   end
   return _font_lua_full
end

function lua_font_name_nofls(filename, dsize, scale, fls)
   local otf_full_path, t_f, otf_shortname
   local font_lua, font_lua_full
   otf_filename = filename .. ".otf"
   font_lua = filename .. ".luc"
   font_lua_full = resolve_path(lua_font_dir .. basename .. '.luc',
                                {texmfvar, texmfsysvar})
   print("font_lua: " .. font_lua)
   print("font_lua_full: " .. font_lua_full)
   t_f = dofile(font_lua_full)
   otf_full_path = t_f.resources.filename
   otf_shortname = file.basename(otf_full_path)

--[[
   os.exit(2)
   local full_path  = kpse.lookup(otf_filename, "opentype fonts")
   print("font full path", full_path)
--   print(filename, full_path)
   if full_path then
      shortname = file.basename(full_path)
   else
      shortname = font_cache[string.lower(filename)]
      if shortname then
         local index = lookup_names.files.base.system[shortname]
--         print(index)
         l_f = lookup_names.mappings[index]
      end
      
      if l_f then
         full_path = l_f.fullpath
      end
   end


--   log:write("    shortname: ", tostring(shortname), "\n")
--   log:write("    fullname: ", tostring(full_path), "\n")

--         print(inspect(ll, {depth = 1}))
--         print(inspect(l_f, {depth = 1}))
--         exit()

   if shortname == nil then
      print("Font name: " .. filename .. " not found in font cache " .. luaotfload_lookup_cache)
      -- print(inspect(lookup_names.files.bare, {depth = 2} ))
      shortname = lookup_names[filename]
   end

   basename = file.nameonly(shortname)
   if l_f then
      if l_f.subfont then
         basename = file.nameonly(shortname) .. "-" .. l_f.subfont
      end
   end
   
   basename = string.lower(basename)
   --   local lua_path = lua_font_dir .. basename .. '.luc'
   print("lua_font_dir: ** ", lua_font_dir)
   local lua_path = resolve_path(lua_font_dir .. basename .. '.luc',
                                {texmfvar, texmfsysvar})
--   print(lua_font_dir, lua_path)
--   os.exit()
--   log:write("    (try): ", tostring(lua_path), "\n")
      t_f = dofile(lua_path)
      --   print(inspect(t_f, {depth = 2}))
      print(full_path, shortname)


   print("font lua(   ): " .. font_lua)
   print("font lua(fls): " .. font_lua_full)
--]]

   return otf_full_path, t_f, otf_shortname
end


function lua_font_name(filename, design_size, scale, fls, options)
--   log:write("  function_lua_font_name: " .. filename .. "\n")
   if filename == nil then
      print("f:lua_font_name: filename == nil. Aborting")
      os.exit(2)
   end
   
   local func_lua_name = lua_font_name_nofls
   if fls then
      func_lua_name = lua_font_name_fls 
   end
   
   return func_lua_name(filename, design_size, scale, fls, options)
end

function getfontdata(fontname, design_size, scale, fls, options)
--   print("TFM FLS", fls[fontname..".tfm"])
   local tfm = fls[fontname..".tfm"] or kpse.lookup(fontname .. ".tfm")
--   print("TFM", inspect(tfm))
   local d = {}
--   local tmeta
   local _otf = false
--   local s = function() print(fontname, "otf: " .. inspect(_otf)) end
--   s()
   local lua_font = nil
   if not tfm then
      _otf = true
      x = parse_fontname(fontname)
      if options.verbose then
--         print("**")
--         print("font dvi: " .. inspect(fontname))
--         print("font base: " .. inspect(x.base))
--         print("/**")
      end
      local _shape = x.shape
      local _filename = x.filename

      if not _filename then
         lua_font = lua_font_lookup_cache(fontname, scale, _shape, options)
      else
         lua_font = lua_font_name(x.base, design_size, scale, fls, options)
      end
      
      --lua_fontX = lua_font_name(x.base, design_size, scale, fls, options)
      -- print(inspect(lua_font))
--      os.exit(8)


      d = { 
                filename = shortname,
                basename = x.base,
                  script = x.script,
                features = x.feat,
                    mode = x.mode,
                language = x.lang,
                   shape = x.shape,
                 luafont = lua_font,
      }
   end
   
   return _otf, d
end

local function flsparse(_file)
   local m = {}
   local line, l = ""
   fh = assert(io.open(_file, 'r'))
   while true do
      line =  fh:read()
      if  line == nil then break end
      l = string.match(line, "INPUT (.*)")
      if l then
         m[file.basename(l)] = l
      end
   end
   return m
end

local function reverse_table(t)
   local s = {}
   for x, y in pairs(t) do
      s[y] = x
   end
   return s
end

local function output_enc(fontname, list, glyphs)
   local glyphlist = reverse_table(glyphs)
   local encfile = fontname .. ".enc"
   local efh = assert(io.open(encfile, 'w'))
   local s_enc = "/" .. fontname .. "[\n"
--   print(list[1], string.format("%04X",list[1]), glyphlist[list[1]])
--   print(list[2], string.format("%04X",list[2]), glyphlist[list[2]])
   --   exit()
--   glyphlist[list[1]] = "u1D465"
--   print(inspect(glyphlist))
--   print(inspect(list))

   for i = 1, 256 do
      --      print(list[i])
      j = glyphlist[list[i]] or ".notdef"
      s_enc = s_enc .. "/" .. j .. "\n"
    end
   s_enc = s_enc .. "] def\n"
   efh:write(s_enc)
   io.close(efh)
end

local function write_glyphlist(filename, unicodes)
   local gh = assert(io.open(filename, 'w'))
   for glyph, ucode in pairs(unicodes) do
      gh:write("/" .. glyph .. ";" .. ucode .. "\n")
   end
   io.close(gh)
   return true
end


_m.getfontdata = getfontdata
_m.parse_fontname = parse_fontname
_m.parse_features = parse_features
_m.parse_fls = flsparse
_m.reverse_table = reverse_table
_m.output_enc = output_enc
_m.write_glyphlist = write_glyphlist
return _m
