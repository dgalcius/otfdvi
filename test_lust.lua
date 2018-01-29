#!/usr/bin/env lua

print(package.path)
os.exit()
local lustache = require("lustache")
local inspect = require("inspect")
local yaml = require("lyaml")

local foo = { { kaka = "zzz"}}
tmpl = [[
start
{{#ffo}
- item {{name}} {{foo}}
{{/ffo}}
stop

]]

--y = yaml.dump(s)
--print(inspect(y))
--os.exit()
--print(yaml.dump(foo))

--local lm = assert(io.open('lu_Makefile', 'r'))
-- local s = lm:read("*all")
print("LU output")
--output = lustache.render(lustache, tmpl,)

t = [[
{{#ffo}}
<b>{{name}} and {{surname}}</b>
{{/ffo}}
]]

v = {
  ffo = {
    { name = "Moe", surname = "aa" },
    { name = "Larry", surname = "bb" },
    { name = "Curly", surname = "kaka" }
  }
}


output = lustache:render(t, v)


print(output)
