#!/usr/bin/env texlua

local exit = os.exit
local kpse = kpse
local version = kpse.version()
kpse.set_program_name("luatex")

require("l-lpeg")
require("l-file")
local inspect  = require("inspect")
local dvi      = require("dvi")
local lustache = require("lustache")

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
if version == "kpathsea version 6.2.3" then
   lua_font_dir = texmfvar  ..  "/luatex-cache/generic/fonts/otl/"
end

-- TeX Live 2015
if version == "kpathsea version 6.2.1" then
   lua_font_dir = texmfvar  ..  "/luatex-cache/generic/fonts/otf/"
end





local filein  = arg[1] or 'sample2e.dvi'
local fileout = 'out.dvi'
local logfile = file.nameonly(fileout) .. ".otfdvi.log"
local log = assert(io.open(logfile, 'w'))
local logw = function(...) log:write(...) end
logw("---", " !", "current time", "\n")
local psmapfile = 'ttfonts.map'
local mkfile = '__Makefile'
local fontprefix = "font"
local htf = true
local debug = false
local verbose = false

local dirname = file.dirname(arg[0])
local conf_file = conf_file or "otfdvi.conf.lua"
local settings = require(file.join(dirname, conf_file))

local fhi = assert(io.open(filein, 'rb'))
local fho = assert(io.open(fileout, 'wb'))
local psf = assert(io.open(psmapfile, 'w'))
local mkf = assert(io.open(mkfile, 'w'))


local content = dvi.parse(fhi) -- get table
local dvimodified = {}         

local function X_is_otf(fontname)
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



function Xget_real_font_file(v_s)
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

function lua_font_name(filename)
   log:write("  luafontname:\n")
   local otf = false
   local shortname, basename
   local t_f, t_meta, t_format, t_filename, l_f
   otf_filename = filename .. ".otf"
   local full_path  = kpse.lookup(otf_filename)
   if full_path then
      shortname = file.basename(full_path)
   else
      shortname = font_cache[filename]
      if shortname then
         local index = lookup_names.files.base.system[shortname]
         l_f = lookup_names.mappings[index]
--         print(inspect(ll, {depth = 1}))
--         print(inspect(l_f, {depth = 1}))
--         exit()
      end
      
      if l_f then
         fullpath = l_f.fullpath
      end
      
   end

   log:write("    shortname: ", tostring(shortname), "\n")
   log:write("    fullname: ", tostring(fullpath), "\n")

   if shortname == nil then
      print("Font name: " .. filename .. " not found in font cache " .. luaotfload_lookup_cache)
      print(inspect(lookup_names.files.bare, {depth = 2} ))
      shortname = lookup_names[filename]
   end
   log:write("    lua_font_dir: ", tostring(lua_font_dir), "\n")

   basename = file.nameonly(shortname)
   if l_f then
      if l_f.subfont then
         basename = file.nameonly(shortname) .. "-" .. l_f.subfont
      end
   end
   
   basename = string.lower(basename)
   local lua_path = lua_font_dir .. basename .. '.luc'
   log:write("    lua_path(try): ", tostring(lua_path), "\n")
   if file.is_readable(lua_path) then
      
      log:write("    lua_path(real): ", tostring(lua_path), "\n")
      t_f = dofile(lua_path)
      otf = true
      
   end
      
   
   return otf, t_filename, t_f, shortname, basename
end

function getfontdata(fontname)
   log:write("- getfontdata:\n")
   log:write("  dvifnt: '", fontname, "'\n")
   local tfm = kpse.lookup(fontname .. ".tfm")

--   local f = get_real_font_file(opcode)
   local d = {}
   local tmeta
   local _otf = false
   local s = function() print(fontname, "otf: " .. inspect(_otf)) end
--   s()
   local dvi_filename, fullpath, script, features, mode, language, shape  = nil
   local tmp = nil
   if not tfm then
      -- [lmroman10-regular]:trep;+tlig;
      dvi_filename, features = string.match(fontname, '%[(.*)%]:(.*)')
      if dvi_filename then
         _otf, fullpath, tmeta, shortname, basename  = lua_font_name(dvi_filename)
      end

      -- "file:lmroman10-regular:script=latn;+trep;+tlig;"
      if dvi_filename == nil then
         dvi_filename, script, features  = string.match(fontname, 'file:(.*):script=(.*);(.*)')
         if dvi_filename then
            _otf, fullpath, tmeta, shortname, basename  = lua_font_name(dvi_filename)
         end
      end
      --  LatinModernRoman:mode=node;script=latn;language=DFLT;+tlig;
      if dvi_filename == nil then
         dvi_filename, mode, rest  = string.match(fontname, '(.*):mode=(.*);(.*)$')
         log:write("  matched: ", dvi_filename, "\n")
         if dvi_filename then
            _otf, fullpath, tmeta, shortname, basename  = lua_font_name(dvi_filename)
            log:write("  lua_font_name: ", tostring(_otf), "\n")
            --exit()
         end
      end

      if dvi_filename == nil then
      else
         local fi, fj = string.match(dvi_filename, '(.*)/(.*)$')
      end

      if fi == nil then
      else
         dvi_filename = fi
         shape = fj 
      end
   
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

   end
   
   return _otf, d
end

--[[

local test_fonts = {
   'LatinModernRoman/B:mode=node;script=latn;language=DFLT;+tlig;',
   'LatinModernRoman/I:mode=node;script=latn;language=DFLT;+tlig;',
   'LatinModernRoman:mode=node;script=latn;language=DFLT;+tlig;',
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

for _, op  in ipairs(content) do
   local is_body = true

   if op._opcode == "post" then
     is_body = false   
   end
   
   if op._opcode == "pre" then
      op.comment = " otfdvi output " .. os.date("%Y.%m.%d:%H%M")
      debug_print(op.comment)
   end

   if op._opcode == "fntdef" then
      debug_print(inspect(op))
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
--   local basename = v_s.otfdata.basename
   local unicodes = v_s.otfdata.cache.resources.unicodes
   local metadata = v_s.otfdata.cache.metadata
   write_glyphlist(ghfilename, unicodes)
   otffonts[i_s].glyphlist = reverse_table(unicodes)
   otffonts[i_s].metadata = metadata
   otffonts[i_s].glyphsfile = ghfilename
--   print(inspect(otffonts[i_s], {depth = 2}))
--   exit()

end

function output_enc(fontname, list, glyphlist)
   local encfile = fontname .. ".enc"
   local efh = assert(io.open(encfile, 'w'))
   local s_enc = "/" .. fontname .. "[\n"
   for i = 1, 256 do
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
   fontname = fontprefix .. i
   table.insert(view.targets, { fontname = fontname,
                                otffontname =  v.basename,
                                glyphsfontname = v.glyphsfile,
                                design_size = v.design_size }
   )
   output_enc(fontname, v.charlist, v.glyphlist)
   htf = htf and output_htf(fontname, v.charlist, v.glyphlist, v.metadata)
end

-- template for lustache
tmpl = file.join(dirname, settings['mkfile_tmpl'])
local lm = assert(io.open(tmpl, 'r'))
local tmpl = lm.read(lm, '*all')

output = lustache:render(tmpl, view)
mkf:write(output)
mkf:close()



