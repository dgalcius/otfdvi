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

local inspect  = require("inspect")
--print(inspect(package.loaded, {depth = 3}))
--print(inspect(file.dirname(lua.startupfile), {depth = 1}))

require("l-lpeg")
require("l-file")
local utils = require(file.dirname(lua.startupfile) .."/otfdvi/utils")
local flsparse        = utils.parse_fls
local reverse_table   = utils.reverse_table
local output_enc      = utils.output_enc
local write_glyphlist = utils.write_glyphlist
--
local dvi      = require("dvi")
local lustache = require("lustache")

local options = {
   filein = "",
   fileout = "out.dvi",
   psmapfile = "ttfonts.map",
   mkfile = "__Makefile",
   fontprefix = "font", 
   htf = false,
   debug = false,
   verbose = false,
   config = "otfdvi.conf.lua",
   --   outputdir = "./.otfdvi/",
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
   output  = "o",
--   set_value = "S",
--   ["set-output"] = "o"
   version = "v"
}

local optarg
local optind
opts,optind,optarg = getopt.get_ordered_opts (arg, "hVvadHo:n:S:c:f:l:m:p:", long_opts)
      

for i, option in ipairs (opts) do

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

   if option == 'o' then
      options.fileout = optarg[i]
   end

end

local j = 1
local arg_left = {}
for i = optind,#arg do
   arg_left[j] = arg[i]
   j = j + 1
end

options.filein = arg_left[1]
options.fileout = arg_left[2] or options.fileout
options.logfile = options.logfile or file.nameonly(options.filein) .. ".otfdvi.log"

local filein  = options.filein
local fileout = options.fileout
local logfile = options.logfile
local flsfile = file.nameonly(options.filein) .. ".fls"
local log = assert(io.open(logfile, 'w'))
local logw = function(...) log:write(...) end
logw("---", " !", "current time", "\n")
local outputdir = options.outputdir
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

local fls = nil
if file.is_readable(flsfile) then
   fls = flsparse(flsfile)
end
local content = dvi.parse(fhi) -- get dvi file as lua table
local dvimodified = {}

function debug_print(s)
   if debug then
      print(s)
   end
end

local currfontnum = 0
local otffonts = {}
local ifonts = {}
local otf = false -- is_otf?
local fontdata = {}
local is_body = true --until opcode = post

logw("********** OPCODES ************** \n")
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
      logw(inspect(op), "\n")
      if is_body then
         otf, fontdata = getfontdata(op.fontname, op.design_size, op.scale, fls, { ["verbose"] = verbose } )
--         print(otf, inspect(fontdata))
--         os.exit(9)
         if otf then
            debug_print(op.fontname .. " => " .. fontprefix .. tostring(op.num))
            logw(op.fontname .. " => " .. fontprefix .. tostring(op.num), "\n")
            if otffonts[op.num] == nil then
               otffonts[op.num] = { fontname = op.fontname,
                                    basename = fontdata.filename,
                                    charlist = {},
                                    design_size = (op.design_size / 65536),
                                    design_size_dvi = op.design_size,
                                    scale = (op.scale / 65536),
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

   if op._opcode == "fntnum" or op._opcode == "fnt" then
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
logw(" ****** STOP OPCODES ****** \n")

debug_print(inspect(otffonts))
dvi.dump(fho, dvimodified) -- write modified DVI

logw("Output: ", fileout, "\n")
print("Written to " .. fileout)

--[[
- read '<otf-font-file>.lua'
--]]

for i_s, v_s in pairs(otffonts) do
   logw(" *** OTFFONT *** \n")   
   logw(inspect(v_s), "\n")
   local _resources, _runi, _metadata = {}, {}, {}
   local _f = nil
   local ghfilename = fontprefix .. i_s .. ".glyphs"
   _f = assert(dofile(v_s.otfdata.luafont))
   _resources = _f.resources
   _coverage = {}
   for _, _feat in ipairs(_f.resources.sequences) do
      if type(_feat.features) == "table" then
         if _feat.features["ssty"] or nil then
            _coverage = _feat.steps[1].coverage
         end
      end
   end

   local unicodes = {}
   for _i, _j in ipairs (v_s.charlist) do
      if _coverage[_j] then
         _j = _coverage[_j][1]
      end
      v_s.charlist[_i] = _j
   end
   for _i, _j in ipairs (v_s.charlist) do
      unicodes[_j] = "uni" .. string.format("%04X",_j)
   end

   _runi = reverse_table(_resources.unicodes)
   _metadata = _f.metadata

   for _i, _j in ipairs (otffonts[i_s].charlist) do
      unicodes[_j] = _runi[_j] or unicodes[_j]
   end
   logw("unicodes",  inspect(unicodes), "\n")

   write_glyphlist(ghfilename, reverse_table(unicodes))
   otffonts[i_s].glyphlist = reverse_table(unicodes)
   otffonts[i_s].metadata = metadata
   otffonts[i_s].glyphsfile = ghfilename
   otffonts[i_s].otffontnamefull = _resources.filename
   otffonts[i_s].otffontname = file.basename(_resources.filename)
   otffonts[i_s].otffonttype = file.suffixonly(_resources.filename)

   logw(" *** END OTFFONT *** \n")   
end

function XXoutput_htf(fontname, list, glyphlist, metadata)
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
   otffonttype = v.otffonttype
   otffontname = v.otffontname
   fullpath = v.otffontnamefull
   glyphsfontname = v.glyphsfile
   design_size = v.design_size
   scale = v.scale
   script = v.otfdata.script
   mode = v.otfdata.mode
   language = v.otfdata.language
   feature = v.otfdata.features
   fontname = fontprefix .. i
   table.insert(view.targets,
                {       fontname = fontname,
                     otffontname = otffontname,
                        fullpath = fullpath,
                  glyphsfontname = glyphsfontname,
                  design_size = design_size,
                          scale = scale,
                          script = script,
                          mode = mode,
                          language = language,
                          feature = feature,
                          otffonttype = otffonttype,
                }
   )

   output_enc(fontname, v.charlist, v.glyphlist)
   htf = htf and output_htf(fontname, v.charlist, v.glyphlist, v.metadata)
end

-- template for lustache
tmpl = file.join(dirname, settings['mkfile_tmpl'])
local lm = assert(io.open(tmpl, 'r'))
local tmpl = lm.read(lm, '*all')

output = lustache:render(tmpl, view)
print("*****")
mkf:write(output)
mkf:close()
logw("Written to: ", mkfile, "\n")
print("Written to " .. mkfile, "\n")

