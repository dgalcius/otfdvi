utils = dofile("../../otfdvi/utils.lua")

describe("Busted unit testing framework", function()
  describe("should be awesome", function()
    it("should be easy to use", function()
      assert.truthy("Yup.")
    end)

    it("should provide some shortcuts to common functions", function()
      assert.are.unique({
        { thing = 1 },
        { thing = 2 },
        { thing = 3 }
      })
    end)

    it("should parse dvi font name", function()
          assert.are.equal(
             utils.parse_fontname("[lmroman10-regular]:+tlig;").base, "lmroman10-regular"
          )
    end)
  end)
end)

--    test_fonts = {
--   '[lmroman10-regular]:+tlig;',
--   '[latinmodern-math.otf]:mode=base;script=math;language=DFLT;',
--   'LatinModernRoman/B:mode=node;script=latn;language=DFLT;+tlig;',
--   'LatinModernRoman/I:mode=node;script=latn;language=DFLT;+tlig;',
--   'LatinModernRoman:mode=node;script=latn;language=DFLT;+tlig;',
--}
