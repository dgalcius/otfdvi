_m = {} or _m

local kpse = kpse
kpse.set_program_name("luatex")
local kpse_version = kpse.version()
local inspect = require("inspect")

require("l-lpeg")
require("l-file")

local texmfsysvar = kpse.expand_var("$TEXMFSYSVAR")
local texmfvar = kpse.expand_var("$TEXMFVAR")
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
print("luaotfload_lookup_cache: ", luaotfload_lookup_cache)

if file.is_readable(luaotfload_lookup_names) then
else
   luaotfload_lookup_names = luaotfload_lookup_names_sys
   if file.is_readable(luaotfload_lookup_names) then
   else
      print("Not found luaotfload_lookup_names: ", luaotfload_lookup_names)
      os.exit(9)
   end
end
print("luaotfload_lookup_names: ", luaotfload_lookup_names)
print("texmfvar: ", texmfvar)


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
print("++kpse version++:", kpse_version)
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

--print(luaotfload_lookup_names)
local lookup_cache = dofile(luaotfload_lookup_cache)
--print(inspect(lookup_cache))
--os.exit()
--
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

function parse_fontname(fontname)
   local s, d
   local lang_ = "DFLT"
   local base_, ext_, name_, rest_, shape_
--   print("fontname: ", fontname)
   s = string.split(fontname, ':')
   name_, rest_ = s[1], s[2]
   s = string.match(name_, '%[(.*)%]')
   if s then
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
   --- kaka --
   local x, feat_ = string.match(rest_, '(.*)%+(.*)')
    if x then
   else
      x = rest_
   end

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
   }
   return d
end

function lua_font_name(filename, fls)
--   log:write("  function_lua_font_name: " .. filename .. "\n")
   local shortname, basename
   local t_f, t_meta, t_format, t_filename, l_f
   if filename == nil then
      print("f:lua_font_name: filename == nil. Aborting")
      os.exit(2)
   end

   local font_lua = string.lower(filename) .. ".luc"
   local font_lua_full = fls[font_lua]
   print("font lua(   ): " .. font_lua)
   print("font lua(fls): " .. font_lua_full)
   os.exit(2)

   otf_filename = filename .. ".otf"
   local full_path  = kpse.lookup(otf_filename, "opentype fonts")
   print("font full path", full_path)
   if full_path == nil then
      full_path = kpse.lookup(lc[filename][1], "opentype fonts")
   end
--   print(filename, full_path)
   if full_path then
      shortname = file.basename(full_path)
   else
--      print(shortname, filename)
      shortname = font_cache[string.lower(filename)]
--      print(shortname, filename)
      if shortname then
         local index = lookup_names.files.base.system[shortname]
--         print(index)
         l_f = lookup_names.mappings[index]
      end
      
      if l_f then
         full_path = l_f.fullpath
      end

--      print("full: " .. full_path)
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
--   os.exit(2)
   return full_path, t_f, shortname
end


function getfontdata(fontname, fls)
   local tfm = kpse.lookup(fontname .. ".tfm")
   local d = {}
   local tmeta
   local _otf = false
--   local s = function() print(fontname, "otf: " .. inspect(_otf)) end
--   s()
   local dvi_filename, fullpath, script, features, mode, language, shape  = nil
   local tmp = nil
   if not tfm then
      _otf = true
      x = parse_fontname(fontname)
      dvi_filename = fontname
      basename = x.base
      language = x.lang
      features = x.feat
      mode = x.mode
      shape = x.shape
      -- [lmroman10-regular]:trep;+tlig;
      -- [latinmodern-math.otf]:mode=base;script=math;language=DFLT;
      print("**")
      print("font dvi: " .. inspect(fontname))
      print("font base: " .. inspect(x.base))
      fullpath, tmeta, shortname  = lua_font_name(x.base,fls)
      print("font full:", fullpath)
      print("/**")
--      print(basename, x.base)
--      print(_otf, fullpath)
--      print("TMETA: start")
--      print(inspect(tmeta))
--      print("TMETA: stop")
      

      d = { dvi_filename = dvi_filename,
            filename = shortname,
            basename = basename,
            fullpath = fullpath,
            script = script,
            features = features,
            mode = mode,
            language = language,
            shape = shape,
            cache = tmeta,
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

_m.getfontdata = getfontdata
_m.parse_fontname = parse_fontname
_m.parse_fls = flsparse
return _m
