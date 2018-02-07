#!/usr/bin/env texlua

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
local luaotfload_lookup_cache = texmfvar .. "/luatex-cache/generic/names/luaotfload-lookup-cache.lua"
local lookup_cache = dofile(luaotfload_lookup_cache)
--print(inspect(lookup_cache))
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

local function is_otf(fontname)
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

--- local psmap = read_psfonts()
-- print(inspect(psmap[1]))
-- os.exit()

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

function getfontdata(fontname)
   local d = {}
   print(fontname)
   print(inspect(d))
   os.exit()
   return d
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

for _, op  in ipairs(content) do
   if op._opcode == "pre" then
      op.comment = " otfdvi output " .. os.date("%Y.%m.%d:%H%M")
      debug_print(op.comment)
   end

   if op._opcode == "fntdef" then
      debug_print(inspect(op))
      fontdata = getfontdata(op.fontname)
      print(inspect(fontdata))
      os.exit()
      if is_otf(op.fontname) == true then
         debug_print(op.fontname .. " => " .. fontprefix .. tostring(op.num))
         local _, basename, otfdata = is_otf(op.fontname)
         if otffonts[op.num] == nil then
            otffonts[op.num] = { fontname = op.fontname,
                                 basename = basename,
                                 charlist = {},
                                 design_size = (op.design_size / 65536),
                                 design_size_dvi = op.design_size,
                                 otfdata = otfdata,
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

function get_real_font_file(v_s)
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
- read '<otf-font-file>.lua'
--]]
function get_glyphlist(v_s)
   --   local fontfile = lua_font_dir .. name .. ".lua"
   local fontfile = get_real_font_file(v_s)
   print(inspect(fontfile))
--   os.exit()
   local luafont = dofile(fontfile)
   print(inspect(v_s.otfdata))
   local ghfile = v_s.basename .. ".glyphs"
   local gh = assert(io.open(ghfile, 'w'))
   local uni = luafont["resources"]["unicodes"]
   local metadata = luafont["metadata"]
   for glyph, ucode in pairs(uni) do
      gh:write("/" .. glyph .. ";" .. ucode .. "\n")
   end
   io.close(gh)
   return uni, metadata
end

for i_s, v_s in pairs(otffonts) do
   local fontname = fontprefix .. i_s
   local uni, metadata = get_glyphlist(v_s)
   otffonts[i_s].glyphlist = reverse_table(uni)
   otffonts[i_s].metadata = metadata
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
   otfname = v.basename .. ".otf"
   glyphsfontname = v.basename .. ".glyphs"
   table.insert(view.targets, {fontname = fontname, otffontname =  otfname, glyphsfontname = glyphsfontname, design_size = v.design_size } )
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



