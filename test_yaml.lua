#!/usr/bin/env texlua

local kpse = kpse
kpse.set_program_name("luatex")

local inspect = require("inspect")
local dvi = require("dvi")
local lfs = require("lfs")

function basename(str, ext)
   local name = string.gsub(str, "(.*/)(.*)" .. ext, "%2")
   return name
end

print(arg[0])
-- cf = "foo"
cf = arg[0]

conf_file = basename(cf, '.lua') .. ".conf.lua"


   
config = require("otfdvi.conf.lua")
print(config.Makefile)

--print(inspect(lfs))
-- print(inspect(lfs.attributes(arg[0])))

