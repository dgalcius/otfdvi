_m = {} or _m

local inspect = require("inspect")

local texmfvar = kpse.expand_var("$TEXMFSYSVAR")
local lua_font_dir = ""
local luaotfload_lookup_cache = texmfvar .. "/luatex-cache/generic/names/luaotfload-lookup-cache.luc"
local luaotfload_lookup_names = texmfvar .. "/luatex-cache/generic/names/luaotfload-names.luc"
local lookup_cache = dofile(luaotfload_lookup_cache)
local lc = {}
for i, j in pairs(lookup_cache) do
   s = string.split(i, ':')
   lc[s[1]] = j 
end
local lookup_names = dofile(luaotfload_lookup_names)
local font_cache = {}
for i, j in pairs(lookup_cache) do
   local s = string.split(i, '#')
   font_cache[s[1]] = j[1]
end

function parse_fontname(fontname)
   local s, d
   local lang_ = "DFLT"
   local base_, ext_, name_, rest_
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

function lua_font_name(filename)
--   log:write("  function_lua_font_name: " .. filename .. "\n")
   local otf = false
   local shortname, basename
   local t_f, t_meta, t_format, t_filename, l_f
   if filename == nil then
      print("f:lua_font_name: filename == nil. Aborting")
      os.exit(2)
   end
   otf_filename = filename .. ".otf"
   local full_path  = kpse.lookup(otf_filename, "opentype fonts")
--   print(inspect(lc[filename][1]))
--   os.exit()
   if full_path == nil then
      full_path = kpse.lookup(lc[filename][1], "opentype fonts")
   end
   print(filename, full_path)
   os.exit()
   if full_path then
      shortname = file.basename(full_path)
   else
      print(shortname, filename)
      shortname = font_cache[string.lower(filename)]
      print(shortname, filename)
      if shortname then
         local index = lookup_names.files.base.system[shortname]
         print(index)
         l_f = lookup_names.mappings[index]
      end
      
      if l_f then
         full_path = l_f.fullpath
      end

      print("full: " .. full_path)
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
   local lua_path = lua_font_dir .. basename .. '.luc'
--   log:write("    (try): ", tostring(lua_path), "\n")
   if file.is_readable(lua_path) then
      
--      log:write("    (read): ", tostring(lua_path), "\n")
      t_f = dofile(lua_path)
      otf = true
      
   end
   return otf, full_path, t_f, shortname
end


function getfontdata(fontname)
   local tfm = kpse.lookup(fontname .. ".tfm")
   local d = {}
   local tmeta
   local _otf = false
--   local s = function() print(fontname, "otf: " .. inspect(_otf)) end
--   s()
   local dvi_filename, fullpath, script, features, mode, language, shape  = nil
   local tmp = nil
   if not tfm then
      print("NOT TFM")
      x = parse_fontname(fontname)
      print("AFTER")
      print(inspect(x))
  --    exit()
      dvi_filename = fontname
      basename = x.base
      language = x.lang
      features = x.feat
      mode = x.mode
      shape = x.shape
      -- [lmroman10-regular]:trep;+tlig;
      -- [latinmodern-math.otf]:mode=base;script=math;language=DFLT;
      print("font dvi font: " .. inspect(fontname))
      print("font base: " .. inspect(x.base))
      _otf, fullpath, tmeta, shortname  = lua_font_name(x.base)
      -- print(basename, x.base)
 
      -- "file:lmroman10-regular:script=latn;+trep;+tlig;"
      --  LatinModernRoman:mode=node;script=latn;language=DFLT;+tlig;
      --      log:write("  lua_font_name: ", tostring(_otf), "\n")
      --exit()
   
--   local f = { filename = filename, mode = mode, script = script, language = language, features = features, shape = shape}
--   return (filename or script) and true, filename, f
--]]
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
--      print(inspect(d, { depth = 1}))
--      exit()

   end

   return _otf, d
end

   
_m.getfontdata = getfontdata
_m.parse_fontname = parse_fontname
return _m
