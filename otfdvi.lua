#!/usr/bin/env texlua

--[[
otfdvi program. Author Deimantas Galcius deimantas(dot)galcius(at)gmail(dot)com
--]]

local _name = "otfdvi"
local version = "0.1"
local exit = os.exit
local kpse = kpse
local kpse_version = kpse.version()
kpse.set_program_name("luatex")

require("l-lpeg")
require("l-file")
local utils = require(file.dirname(lua.startupfile) .."/otfdvi/utils")
local inspect  = require("inspect")
--print(inspect(package.loaded, {depth = 1}))
--print(inspect(file.dirname(lua.startupfile), {depth = 1}))
--exit()
local dvi      = require("dvi")
print("ZZZZZ")
local lustache = require("lustache")
print("KKKKKK")

local options = {
--   filein  = arg_left[1],
   --   fileout = arg_left[2] or "out.dvi",
   filein = "",
   fileout = "out.dvi",
   psmapfile = "ttfonts.map",
   mkfile = "__Makefile",
   fontprefix = "font", 
   htf = false,
   debug = false,
   verbose = false,
   config = "otfdvi.conf.lua",
   outputdir = "",
   dryrun = false,
   inplace = false,
   auto = false,
}

getopt = require("alt_getopt")



local function do_print_version()
   print(_name .. " version " .. version .. " licence GNU GPL v2.0")
   print("report problems to https://github.com/dgalcius/otfdvi/issues")
   exit()
end

local function do_print_help()
   print("Print help")
   exit()
end

local long_opts = {
   verbose = "V",
   help    = "h",
   auto    = "a",
   config  = "c",
   debug   = "d",
   fontprefix = "f",
   htf     = "H",
   log     = "l",
   mkfile  = "m",
   psmap   = "p",
--   len     = 1,
--   output  = "o",
--   set_value = "S",
--   ["set-output"] = "o"
   version = "v"
}

local optarg
local optind
opts,optind,optarg = getopt.get_ordered_opts (arg, "hVvadHo:n:S:c:f:l:m:p:", long_opts)
      

for i, option in ipairs (opts) do
---   if optarg [i] then
--      print("option `" .. v .. "': " .. optarg [i] .. "\n")
--   else
--      print ("option `" .. v .. "'\n")
--   end
   if option == 'v' then
      do_print_version()
   end
   if option == 'h' then
      do_print_help()
   end

   if option == 'a' then
      options.auto = true
   end

   if option == 'd' then
      options.debug = true
   end

   if option == 'H' then
      options.htf = true
   end

   if option == 'c' then
      options.config = optarg[i]
   end

   if option == 'f' then
      options.fontprefix = optarg[i]
   end

   if option == 'l' then
      options.logfile = optarg[i]
   end

   if option == 'm' then
      options.mkfile = optarg[i]
   end

   if option == 'p' then
      options.psmapfile = optarg[i]
   end

end

local j = 1
local arg_left = {}
for i = optind,#arg do
   --io.write (string.format ("ARGV [%s] = %s\n", i, arg [i]))
   arg_left[j] = arg[i]
   j = j + 1
end

options.filein = arg_left[1]
options.fileout = arg_left[2] or options.fileout
options.logfile = options.logfile or file.nameonly(options.filein) .. ".otfdvi.log"

--[[
optarg,optind = getopt.get_opts (arg, "hVvo:n:S:", long_opts)
for k,v in pairs (optarg) do
   io.write ("fin-option `" .. k .. "': " .. v .. "\n")
end
--]]

-- END Options --

local texmfvar = kpse.expand_var("$TEXMFSYSVAR")
local lua_font_dir = ""
local luaotfload_lookup_cache = texmfvar .. "/luatex-cache/generic/names/luaotfload-lookup-cache.luc"
local luaotfload_lookup_names = texmfvar .. "/luatex-cache/generic/names/luaotfload-names.luc"
local lookup_cache = dofile(luaotfload_lookup_cache)
local lookup_names = dofile(luaotfload_lookup_names)
local font_cache = {}
for i, j in pairs(lookup_cache) do
   local s = string.split(i, '#')
   font_cache[s[1]] = j[1]
end
--print(inspect(font_cache))
--os.exit()
--print(inspect(lookup_cache["LatinModernRoman#655360"][1]))


-- TeX Live 2017
if kpse_version == "kpathsea version 6.2.3" then
   lua_font_dir = texmfvar  ..  "/luatex-cache/generic/fonts/otl/"
end

-- TeX Live 2015
if kpse_version == "kpathsea version 6.2.1" then
   lua_font_dir = texmfvar  ..  "/luatex-cache/generic/fonts/otf/"
end




local filein  = options.filein
local fileout = options.fileout
local logfile = options.logfile
local log = assert(io.open(logfile, 'w'))
local logw = function(...) log:write(...) end
logw("---", " !", "current time", "\n")
local psmapfile = options.psmapfile
local mkfile = options.mkfile
local fontprefix = options.fontprefix
local htf = options.htf
local debug = options.debug
local verbose = options.verbose
local conf_file = options.config
logw("options:\n", inspect(options), "\n")

local dirname = file.dirname(arg[0])
local settings = require(file.join(dirname, conf_file))
logw("settings:\n", inspect(settings), "\n")


logw("kpse_version: ", kpse_version, "\n")
logw("lua_font_dir: ", lua_font_dir, "\n")

local fhi = assert(io.open(filein, 'rb'))
local fho = assert(io.open(fileout, 'wb'))
local psf = assert(io.open(psmapfile, 'w'))
local mkf = assert(io.open(mkfile, 'w'))


local content = dvi.parse(fhi) -- get table
local dvimodified = {}         

local function REMOVE_X_is_otf(fontname)
   print(fontname)
   local s = false
   local filename, script, features, mode, language, shape = nil, nil, nil, nil, nil, nil
   -- [lmroman10-regular]:trep;+tlig;
   filename, features = string.match(fontname, '%[(.*)%]:(.*)')
   -- "file:lmroman10-regular:script=latn;+trep;+tlig;"
   if filename == nil then
      filename, script, features  = string.match(fontname, 'file:(.*):script=(.*);(.*)')
   end
   --  LatinModernRoman:mode=node;script=latn;language=DFLT;+tlig;
   if filename == nil then
      filename, mode, script, language, features  = string.match(fontname, '(.*):mode=(.*);script=(.*);language=(.*);(.*);')

    end

   
   local fi, fj = string.match(filename, '(.*)/(.*)$')

   if fi == nil then
   else
      filename = fi
      shape = fj 
   end
   
   local f = { filename = filename, mode = mode, script = script, language = language, features = features, shape = shape}
   return (filename or script) and true, filename, f
end

--[[
function read_psfonts()
   local d = {}
   local s = ""
   local f = kpse.lookup("psfonts.map")
   local fh = assert(io.open(f, 'r'))
   for line in fh:lines() do
      --tfm_file, fnt_name, enc_name, enc_file, pfb_file  = string.match(line, '(.*)%s(.*)%s"(.*)"%s<(.*)%s<(.*)')
      tfm_file, rest = string.match(line, '(.*)%s')
      print(tfm_file, rest)
      os.exit()
      table.insert(d, {tfm_file, fnt_name, enc_name, enc_file, pfb_file})
   end
   return d
end
--]]

--- local psmap = read_psfonts()
-- print(inspect(psmap[1]))
-- os.exit()



function REMOVE_Xget_real_font_file(v_s)
   local fontfile = lua_font_dir .. v_s.basename .. ".lua"
   local s = file.is_readable(fontfile)
--   print(fontfile, inspect(s))
   if s == false then

      local i = ""
      if v_s.otfdata.shape == nil then
         i = v_s.fontname .. "#" .. v_s.design_size_dvi
      else
         i = v_s.fontname .. "#" .. string.lower(v_s.otfdata.shape) .. "#" .. v_s.design_size_dvi
      end
--      print(inspect(lookup_cache))
      local otffile = lookup_cache[i][1]
      fontfile = lua_font_dir .. file.nameonly(otffile) .. ".lua"
      s = file.is_readable(fontfile)
   end
   if s == false then
      print("Not found .lua file for font: ", v_s.basename, v_s.fontname)
      os.exit()
   end
   return fontfile
end


--[[
fontdata:
   filename:
   fullpath:
   shape: I, BI, B
   style: Italic, Bold, BoldItalic
   mode:
   script:
   language:
   features:
   otf:
 --]]

function X_lua_font_name(filename)
   log:write("  function_lua_font_name: " .. filename .. "\n")
--   log:write("  filename: " .. filename .. "\n")
   local otf = false
   local shortname, basename
   local t_f, t_meta, t_format, t_filename, l_f
   otf_filename = filename .. ".otf"
   local full_path  = kpse.lookup(otf_filename, "opentype fonts")
   -- print(full_path)
   if full_path then
      shortname = file.basename(full_path)
   else
      shortname = font_cache[filename]
      if shortname then
         local index = lookup_names.files.base.system[shortname]
         l_f = lookup_names.mappings[index]
      end
      
      if l_f then
         full_path = l_f.fullpath
      end
      
   end


   log:write("    shortname: ", tostring(shortname), "\n")
   log:write("    fullname: ", tostring(full_path), "\n")

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
   log:write("    (try): ", tostring(lua_path), "\n")
   if file.is_readable(lua_path) then
      
      log:write("    (read): ", tostring(lua_path), "\n")
      t_f = dofile(lua_path)
      otf = true
      
   end
      
   
   return otf, full_path, t_f, shortname
end

function X_parse_fontname(fontname)
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
      base = name_
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
   }
   return d
end
function getfontdata(fontname)
   log:write("getfontdata:\n")
   log:write("  dvi: '", fontname, "'\n")
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


test_fonts = {
--   '[lmroman10-regular]:+tlig;',
--   '[latinmodern-math.otf]:mode=base;script=math;language=DFLT;',
   'LatinModernRoman/B:mode=node;script=latn;language=DFLT;+tlig;',
--   'LatinModernRoman/I:mode=node;script=latn;language=DFLT;+tlig;',
--   'LatinModernRoman:mode=node;script=latn;language=DFLT;+tlig;',
}
for i, font in ipairs(test_fonts) do
   print(font)
   d, l = utils.getfontdata(font)
  print(d, inspect(l))
end
exit()
--[[

local test_fonts = {
   


}
for i, j in ipairs(test_fonts) do
--   print(i, j, is_otf(j))
   _, _, k = is_otf(j)
   print(inspect(k))
end
os.exit()

--]]


function debug_print(s)
   if debug then
      print(s)
   end
end
local currfontnum = 0
local otffonts = {}
local ifonts = { }
local otf = false -- is_otf?
local fontdata = {}
local is_body = true --until opcode = post

for _, op  in ipairs(content) do


   if op._opcode == "post" then
     is_body = false   
   end
   
   if op._opcode == "pre" then
      op.comment = " otfdvi output " .. os.date("%Y.%m.%d:%H%M")
      debug_print(op.comment)
   end

   if op._opcode == "fntdef" then
      debug_print(inspect(op))

      if is_body then
         otf, fontdata = getfontdata(op.fontname)
         if otf then
            debug_print(op.fontname .. " => " .. fontprefix .. tostring(op.num))
            -- local _, basename, otfdata = is_otf(op.fontname)
            if otffonts[op.num] == nil then
               otffonts[op.num] = { fontname = op.fontname,
                                    basename = fontdata.filename,
                                    charlist = {},
                                    design_size = (op.design_size / 65536),
                                    design_size_dvi = op.design_size,
                                    otfdata = fontdata,
               }
               ifonts[op.num] = { charlist = {} }
               ifonts[op.num].index = 0
            end
            op.fontname = fontprefix .. tostring(op.num)
         end
      else
         op.fontname = fontprefix .. tostring(op.num) -- # in postamble
      end
   end

   if op._opcode == "fntnum" then
      currfontnum = op.index
   end

   if op._opcode == "setchar" or op._opcode == "set" then
      if (otffonts[currfontnum] and true) then -- if otf font
         charlist = otffonts[currfontnum].charlist
         uclist = ifonts[currfontnum].charlist
         index = ifonts[currfontnum].index

         if uclist[op.index] == nil then -- char is not in a list yet
            table.insert(charlist, op.index)
            uclist[op.index] = index
            index = index + 1
            otffonts[currfontnum].charlist = charlist
            ifonts[currfontnum].charlist = uclist
            ifonts[currfontnum].index = index 
         end
         
         op.index = ifonts[currfontnum].charlist[op.index]
      end
   end

   table.insert(dvimodified, op)
end

debug_print(inspect(otffonts))

dvi.dump(fho, dvimodified) -- write modified DVI
logw("Output: ", fileout, "\n")
print("Written to " .. fileout)


function reverse_table(t)
   local s = {}
   for x, y in pairs(t) do
      s[y] = x
   end
   return s
end


--[[
- read '<otf-font-file>.lua'
--]]
function write_glyphlist(filename, unicodes)
   -- * -- * --
   local gh = assert(io.open(filename, 'w'))
   for glyph, ucode in pairs(unicodes) do
      gh:write("/" .. glyph .. ";" .. ucode .. "\n")
   end
   io.close(gh)
   return true
end

for i_s, v_s in pairs(otffonts) do
   local ghfilename = fontprefix .. i_s .. ".glyphs"
   --print(inspect(otffonts[i_s].charlist))
   local unicodes = {}
   for _i, _j in ipairs (otffonts[i_s].charlist) do
      unicodes[_j] = "u".. string.format("%04X",_j)
   end
   
--   local basename = v_s.otfdata.basename
   local runi = reverse_table(v_s.otfdata.cache.resources.unicodes)
   for _i, _j in ipairs (otffonts[i_s].charlist) do
      unicodes[_j] = runi[_j] or unicodes[_j]
   end

--   print(inspect(unicodes, { depth = 1 }))
--   exit()
   local metadata = v_s.otfdata.cache.metadata
   write_glyphlist(ghfilename, reverse_table(unicodes))
   otffonts[i_s].glyphlist = reverse_table(unicodes)
   otffonts[i_s].metadata = metadata
   otffonts[i_s].glyphsfile = ghfilename
--   print(inspect(otffonts[i_s], {depth = 2}))
--   exit()

end

function output_enc(fontname, list, glyphs)
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

function cssinfo(m)
   --[[
      family: sans-serif, serif, monospace, cursive, fantasy
      family: Noto Sans, sans-serif
      font-family: <fontname>, monospace (if monospaced)
      font-style: normal, italic, oblique
      font-weight: 100, 200, normal, 500, 600, bold, 900, etc.
      font-variant: normal, small-caps, etc.
      font-stretch: condensed, normal, expanded
      font-feature-settings: 
      /* enable small caps and use second swash alternate */
      font-feature-settings: "smcp", "swsh" 2;
      font-language-override: "SRB"; /* Serbian OpenType language tag */ 
      @font-face {
      font-family: main;
      src: url(fonts/ffmeta.woff) format("woff");
      font-variant: discretionary-ligatures;
      }
   --]]

   local file = m.fontname .. ".mdata"
   local fh = assert(io.open(file, 'w'))
   fh:write(inspect(m))
   fh:close()
   local weight = m.weight
   local width  = m.width
   local style  = "normal"
   local family = nil

   if m.italicangle < 0 then
      style = "italic"
   end
   
   if m.monospaced == 'true' then
      family = {["font-family"] = "monospace" }
   end
   
   return { ["font-weight"] = weight, ["font-style"] = style, family }   
end

function output_htf(fontname, list, glyphlist, metadata)
   local file = fontname .. ".htf"
   local fh = assert(io.open(file, 'w'))
   local ss = fontname .. " 0 " .. (#list-1) .. '\n'
   local s = ss -- start
   for i, j in ipairs(list) do
      s = s .. "'&#x" .. string.format("%04X",j) ..";' ''  "
      s = s .. string.format("    %-12s",glyphlist[j]) .. " " .. " " .. string.format("%-5s\n",j)
   end
   s = s .. ss -- stop
   css = cssinfo(metadata)
   htfcss = "htfcss: " .. fontname .. " "
   for i, j in pairs(css) do
      htfcss = htfcss .. i .. ": " .. j .. "; "
   end
   s = s .. "\n" .. htfcss
--   print(htfcss)
--   os.exit()
   fh:write(s)
   io.close(fh)
   return true
end

view = {} -- view model for lustache
view.output = fileout
view.psmapfile = psmapfile
view.verbose = verbose
view.targets = {}
for i, v in pairs(otffonts) do
--   print(inspect(v.otfdata, {depth = 2} ))
--   exit()
   fontname = fontprefix .. i
   table.insert(view.targets, { fontname = fontname,
                                otffontname =  v.basename,
                                glyphsfontname = v.glyphsfile,
                                design_size = v.design_size,
                                -- script = 'math',
                                fullpath = v.otfdata.fullpath
                              }
   )
   output_enc(fontname, v.charlist, v.glyphlist)
   htf = htf and output_htf(fontname, v.charlist, v.glyphlist, v.metadata)
end

-- template for lustache
tmpl = file.join(dirname, settings['mkfile_tmpl'])
local lm = assert(io.open(tmpl, 'r'))
local tmpl = lm.read(lm, '*all')

print("XXXXX")
output = lustache:render(tmpl, view)
print("*****")
mkf:write(output)
mkf:close()
logw("Written to: ", mkfile, "\n")
print("Written to " .. mkfile, "\n")



