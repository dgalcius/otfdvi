#!/usr/bin/env texlua

kpse.set_program_name("luatex")

local debug = true
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
   local j, i = string.match(fontname, '%[(.*)%]:(.*)')
   return (j or s) and true, j
end

--a, b = is_otf("cmex10")
-- a, b = is_otf("[lmroman10-regular]:+tlig;")
--print(a, b)
-- print(inspect(i))

--s = string.match("cmr19", '(%a+)')
--print(s)
--os.exit()
--i = is_otf("[lmroman10-regular]:+tlig;")
--print(inspect(i))

-- os.exit()
local currentfontnum = 0 

for _, op  in ipairs(content) do
   
   if op._opcode == "pre" then
   --   print(inspect(op))
      op.comment = "otfdvi output " .. os.date("%Y.%m.%d:%H%M%S")
   end

   if op._opcode == "fntdef" then
      if fonts[op.num] == nil then
         fonts[op.num] = { fontname = op.fontname , charlist = {} }
         if is_otf(op.fontname) == true then
            if debug == true then
               print(op.fontname .. " => " .. fontprefix .. tostring(op.num))
            end
            op.fontname = fontprefix .. tostring(op.num)
         end
      end
   end

   if op._opcode == "fntnum" then
      print(inspect(op))
      print(inspect(fonts[25].fontname))
      currentfontnum = op.index
   end

   if op._opcode == "setchar" or op._opcode == "set" then
     if is_otf(fonts[currentfontnum].fontname) == true then
        -- table.insert(fonts[currentfontnum].charlist, op.index)
        if fonts[currentfontnum].charlist[op.index] == nil then
        -- fonts[currentfontnum].charlist[op.index] = true
        -- i = #fonts[currentfontnum].charlist - 1
           -- op.index = i
        end
     end
   end
   
   table.insert(dvimodified, op)
end

print(inspect(fonts))

-- dvi.dump(fho, dvimodified)

