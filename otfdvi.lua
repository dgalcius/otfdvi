#!/usr/bin/env texlua

kpse.set_program_name("luatex")

local inspect = require("inspect")
local dvi     = require("dvi")

local filein  = arg[1] or 'sample2e.dvi'
local fileout = 'out.dvi'
local fhi = assert(io.open(filein, 'rb'))
local fho = assert(io.open(fileout, 'wb'))
content = dvi.parse(fhi)
dvi.dump(fho, content)

