#!/usr/bin/env texlua

local kpse = kpse
local version = kpse.version()
kpse.set_program_name("luatex")


require("l-lpeg")
require("l-file")
local inspect  = require("inspect")
local dvi      = require("dvi")
local lustache = require("lustache")

local l = require("luaotfload-database.lua")
--require("lualibs")
--local l, m, n =
--require "fontloader-basics-gen.lua"
--print(inspect(l))
--print(l, m, n)
--os.exit()

local texmfvar = kpse.expand_var("$TEXMFSYSVAR")
local lua_font_dir = ""
local lua_font_names = texmfvar .. "/luatex-cache/generic/names/"

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
   local filename, script, features, mode, language = nil, nil, nil, nil, nil
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

   return (filename or script) and true, filename
end

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
      if is_otf(op.fontname) == true then
         debug_print(op.fontname .. " => " .. fontprefix .. tostring(op.num))
         local _, basename = is_otf(op.fontname)
         if otffonts[op.num] == nil then
            otffonts[op.num] = { fontname = op.fontname ,
                                 basename = basename,
                                 charlist = {},
                                 design_size = (op.design_size / 65536) }
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
function get_glyphlist(name)
   local fontfile = lua_font_dir .. name .. ".lua"
   local luafont = dofile(fontfile)
   local ghfile = name .. ".glyphs"
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
   local uni, metadata = get_glyphlist(v_s.basename)
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



