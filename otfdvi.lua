#!/usr/bin/env texlua

kpse.set_program_name("luatex")

local inspect = require("inspect")
local dvi     = require("dvi")

local filein  = arg[1] or 'sample2e.dvi'
local fileout = 'out.dvi'
local fhi = assert(io.open(filein, 'rb'))
local fho = assert(io.open(fileout, 'wb'))
local content = dvi.parse(fhi)
local dvimodified = {}

local fonts = {}
local fontprefix = "font"

local function is_otf(fontname)
   local s = false
   j = string.match(fontname, '(%a):(%a)')
   print(inspect(j))
   return s
end

i = is_otf("cmex10")
print(inspect(i))

i = is_otf("[lmroman10-regular]:+tlig;")
print(inspect(i))

os.exit()

for _, op  in ipairs(content) do
   if op._opcode == "pre" then
   --   print(inspect(op))
      op.comment = "otfdvi output " .. os.date("%Y.%m.%d:%H%M%S")
   end

   if op._opcode == "fntdef" then
      if fonts[op.num] == nil then
         fonts[op.num] = { fontname = op.fontname }
         if is_otf(op.fontname) == true then
            op.fontname = fontprefix .. tostring(op.num)
         end
      end

      
   end
   table.insert(dvimodified, op)
end

print(inspect(fonts))

dvi.dump(fho, dvimodified)

