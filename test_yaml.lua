#!/usr/bin/env texlua

local kpse = kpse
kpse.set_program_name("luatex")

local inspect = require("inspect")
local dvi = require("dvi")
local lfs = require("lfs")


print(arg[0])
config = require("otfdvi.config.config.lua")
print(config.Makefile)

--print(inspect(lfs))
-- print(inspect(lfs.attributes(arg[0])))

