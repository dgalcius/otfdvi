#!/usr/bin/env texlua



local utils = dofile("../../otfdvi/utils.lua")
local inspect = require("inspect")
test_fonts = {
   '[lmroman10-regular]:+tlig;',
   '[latinmodern-math.otf]:mode=base;script=math;language=DFLT;',
   'LatinModernRoman/B:mode=node;script=latn;language=DFLT;+tlig;',
   'LatinModernRoman/I:mode=node;script=latn;language=DFLT;+tlig;',
   'LatinModernRoman:mode=node;script=latn;language=DFLT;+tlig;',
   '[latinmodern-math.otf]:mode=base;script=math;language=DFLT;+ssty=0;'
}

for i, font in ipairs(test_fonts) do
   print(font)
   d = {}
   d  = utils.parse_fontname(font)
   print(inspect(d))
end

assert(utils.parse_fontname('[lmroman10-regular]:+tlig;').lang == "DFLT")
assert(utils.parse_fontname('LatinModernRoman/I:mode=node;script=latn;language=DFLT;+tlig;').shape == "I")
assert(utils.parse_fontname('[latinmodern-math.otf]:mode=base;script=math;language=DFLT;').ext == "otf")

-- assert(utils.parse_features('') == nil)
assert(utils.parse_features('tlig;').tlig  == true )
assert(utils.parse_features('+ssty=0;').ssty == 0 )
-- i = utils.parse_features('tlig;')
--assert({ ["kaka"] = 1} == { ["kaka"] = 1})
i = utils.parse_features('+ssty=0;')
print(inspect(i))
--[[

--]]
