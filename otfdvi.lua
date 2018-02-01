#!/usr/bin/env texlua

local kpse = kpse
kpse.set_program_name("luatex")

local inspect  = require("inspect")
local dvi      = require("dvi")
local lustache = require("lustache")

local lua_font_dir = kpse.expand_var("$TEXMFSYSVAR")
lua_font_dir = lua_font_dir  ..  "/luatex-cache/generic/fonts/otl/"

local filein  = arg[1] or 'sample2e.dvi'
local fileout = 'out.dvi'
local psmapfile = 'ttfonts.map'
local mkfile = '__Makefile'
local fontprefix = "font"
local debug = false
local verbose = false

local fhi = assert(io.open(filein, 'rb'))
local fho = assert(io.open(fileout, 'wb'))
local psf = assert(io.open(psmapfile, 'w'))
local mkf = assert(io.open(mkfile, 'w'))

local content = dvi.parse(fhi) -- get table
local dvimodified = {}         

local function is_otf(fontname)
   local s = false
   local j, i = string.match(fontname, '%[(.*)%]:(.*)')
   return (j or s) and true, j
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
            otffonts[op.num] = { fontname = op.fontname , basename = basename, charlist = {}, design_size = (op.design_size / 65536) }
            ifonts[op.num] = { charlist = {} }
            ifonts[op.num].index = 0
            op.fontname = fontprefix .. tostring(op.num)
         else
            op.fontname = fontprefix .. tostring(op.num)
         end
      end
   end

   if op._opcode == "fntnum" then
      currfontnum = op.index
      ---!FIXME
--      if (otffonts[currfontnum] and true) then
--         ifonts[currfontnum].index = 0
--      end
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



-- print(inspect(otffonts))
-- print(lua_font_dir)

for i_s, v_s in pairs(otffonts) do
   local fontname = fontprefix .. i_s
   local uni, metadata = get_glyphlist(v_s.basename)
   otffonts[i_s].glyphlist = reverse_table(uni)
   otffonts[i_s].metadata = metadata
end

-- print(inspect(otffonts))
-- print(inspect(#fonts[14].charlist))

function output_enc(fontname, list, glyphlist)
   local encfile = fontname .. ".enc"
--   local glyfile = fontname .. ".gly"
   local efh = assert(io.open(encfile, 'w'))
--   local glyh = assert(io.open(glyfile, 'w'))
   local s_enc = "/" .. fontname .. "[\n"
   for i = 1, 256 do
      j = glyphlist[list[i]] or ".notdef"
      --debug_print(j)
      --debug_print( not j == ".notdef")
    --  if not j == ".notdef" then
    --     debug_print(">>" .. j)
    --     glyh:write("/" .. j .. ";" .. list[i] .. "\n")
    --  end
      s_enc = s_enc .. "/" .. j .. "\n"
    end
   s_enc = s_enc .. "] def\n"
   efh:write(s_enc)
   io.close(efh)
--   io.close(glyh)
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
end

-- template for lustache
local lm = assert(io.open('lu_Makefile', 'r'))
local tmpl = lm.read(lm, '*all')

output = lustache:render(tmpl, view)
mkf:write(output)
mkf:close()



