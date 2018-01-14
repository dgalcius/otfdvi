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

for _, op  in ipairs(content) do
   if op._opcode == "pre" then
   --   print(inspect(op))
      op.comment = "otfdvi output " .. os.date("%Y.%m.%d:%H%M%S")
   end

   table.insert(dvimodified, op) 
end


dvi.dump(fho, dvimodified)

