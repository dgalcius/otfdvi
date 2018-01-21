#!/usr/bin/env texlua

local kpse = kpse
kpse.set_program_name("luatex")
-- kpse.set_program_name("texlua")
local lua_font_dir = kpse.expand_var("$TEXMFSYSVAR")
lua_font_dir = lua_font_dir  ..  "/luatex-cache/generic/fonts/otl/"

-- local foo = require("lmroman10-regular")

local debug = false
local inspect = require("inspect")
local dvi     = require("dvi")
-- local lustache= require("lustache")
-- print (inspect(foo["creator"]))
-- print (inspect(foo["resources"]["filename"]))
-- print (inspect(foo["resources"]["unicodes"]))

-- i = kpse.find_file("lmroman10-bold.lua", "opentype fonts")
-- local info = fontloader.info("lmroman10-bold.otf")
-- filename = "lmroman10-bold.otf"
-- local font = fontloader.open(filename)
-- local metrics = fontloader.to_table(font)
-- myfont = fontloader.load_font(filename)
-- print(inspect(metrics.glyphs))


local filein  = arg[1] or 'sample2e.dvi'
local fileout = 'out.dvi'
local psmapfile = 'ttfonts.map'
local mkfile = '__Makefile'
local fhi = assert(io.open(filein, 'rb'))
local fho = assert(io.open(fileout, 'wb'))
local psf = assert(io.open(psmapfile, 'w'))
local mkf = assert(io.open(mkfile, 'w'))

local content = dvi.parse(fhi)
local dvimodified = {}

local otffonts = {}
local fontprefix = "font"

local otffiles = {}
local encfiles = {}
local tfmfiles = {}
local htffiles = {}
local mk_tfm_targets = {}
local mk_target_template = [[
{{{ fontname }}}.tfm: {{{ otffontname } .FORCE
	otftotfm --literal-encoding={{{ fontname }}}.enc --vendor=UKWN   $(verbose) --name={{{ fontname }}} --map-file={{{ psmapfile }}}  --no-updmap --warn-missing {{{ otffontname }}} 
END
]]

local function is_otf(fontname)
   local s = false
   local j, i = string.match(fontname, '%[(.*)%]:(.*)')
   return (j or s) and true, j
end

local currfontnum = 0
local ifonts = { }
local otf = false

for _, op  in ipairs(content) do
   
   if op._opcode == "pre" then
       op.comment = " otfdvi output " .. os.date("%Y.%m.%d:%H%M")
   end

   if op._opcode == "fntdef" then
      if is_otf(op.fontname) == true then
         if debug == true then
            print(op.fontname .. " => " .. fontprefix .. tostring(op.num))
         end
         local _, basename = is_otf(op.fontname)
         
         if otffonts[op.num] == nil then
            otffonts[op.num] = { fontname = op.fontname , basename = basename, charlist = {} }
            ifonts[op.num] = { charlist = {} }
            op.fontname = fontprefix .. tostring(op.num)
         end
      end
   end

   if op._opcode == "fntnum" then
      currfontnum = op.index
      ifonts[currfontnum].index = 0 
   end

   if op._opcode == "setchar" or op._opcode == "set" then
      if (otffonts[currfontnum] and true) then -- if otf font
         charlist = otffonts[currfontnum].charlist
         uclist = ifonts[currfontnum].charlist
         -- print(inspect(uclist[op.index]))
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

dvi.dump(fho, dvimodified)

function reverse_table(t)
   local s = {}
   for x, y in pairs(t) do
      s[y] = x
   end
   return s
end


function generate_glyphlist(name)
   local fontfile = lua_font_dir .. name .. ".lua"
   local ghfile = name .. ".glyphlist"
   local gh = assert(io.open(ghfile, 'w'))
   local luafont = dofile(fontfile)
   local uni = luafont["resources"]["unicodes"]
   for glyph, ucode in pairs(uni) do
      gh:write("/" .. glyph .. ";" .. ucode .. "\n")
   end
   io.close(gh)
   return uni
end

-- print(inspect(otffonts))
-- print(lua_font_dir)

for i_s, v_s in pairs(otffonts) do
   local fontname = fontprefix .. i_s
   local uni = generate_glyphlist(v_s.basename)
   otffonts[i_s].glyphlist = reverse_table(uni)
end

-- print(inspect(otffonts))
--print(inspect(#fonts[14].charlist))

function output_enc(fontname, list, glyphlist)
   local encfile = fontname .. ".enc"
   local glyfile = fontname .. ".glyphlist"
   local efh = assert(io.open(encfile, 'w'))
   local glyh = assert(io.open(glyfile, 'w'))
   local s = "/" .. fontname .. "[\n"
   for i = 1, 256 do
      j = glyphlist[list[i]] or ".notdef"
      -- print(j, list[i])
      if not j == ".notdef" then
         glyh:write("/" .. j .. ";" .. list[i] .. "\n")
      end
      s = s .. "/" .. j .. "\n"
    end
   s = s .. "] def\n"
   efh:write(s)
   io.close(efh)
   io.close(glyh)
end

for i, v in pairs(otffonts) do
   fontname = fontprefix .. i
   output_enc(fontname, v.charlist, v.glyphlist)
   --output_htf(fontname, v.charlist, v.glyphlist)
end

