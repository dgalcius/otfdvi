#!/usr/bin/env texlua


--[[
otfdvi program. Author Deimantas Galcius deimantas(dot)galcius(at)gmail(dot)com
--]]

otfdvi  = otfdvi or { }
local version = "0.1"
otfdvi.version = version
otfdvi.self = "otfdvi"

local _name = "otfdvi"
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
local lustache = require("lustache")

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

--[[
local texmfvar = kpse.expand_var("$TEXMFSYSVAR")
local lua_font_dir = ""
local luaotfload_lookup_cache = texmfvar .. "/luatex-cache/generic/names/luaotfload-lookup-cache.luc"
local luaotfload_lookup_names = texmfvar .. "/luatex-cache/generic/names/luaotfload-names.luc"
local lookup_cache = dofile(luaotfload_lookup_cache)
local lookup_names = dofile(luaotfload_lookup_names)
--]]

--local font_cache = {}
--for i, j in pairs(lookup_cache) do
--   local s = string.split(i, '#')
--   font_cache[s[1]] = j[1]
--end

--print(inspect(font_cache))
--os.exit()
--print(inspect(lookup_cache["LatinModernRoman#655360"][1]))


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
--      print(inspect(op))
--      os.exit()
      if is_body then
--         print(inspect(op.fontname))
         otf, fontdata = getfontdata(op.fontname)
--         print(otf, inspect(fontdata))
--         os.exit(2)
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
--print(inspect(otffonts))
--os.exit(2)

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
   --[[
   unicodes = {
     [48] = "u0030",
     [49] = "u0031",
   }
   --]]
   
   --   local basename = v_s.otfdata.basename
--   print(inspect(v_s.otfdata.cache))
--   os.exit()
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

--print("XXXXX")
output = lustache:render(tmpl, view)
print("*****")
mkf:write(output)
mkf:close()
logw("Written to: ", mkfile, "\n")
print("Written to " .. mkfile, "\n")



