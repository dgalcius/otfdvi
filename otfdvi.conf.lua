return {
   mkfile_out = "__Makefile",
   mkfile_tmpl = "otfdvi.tmpl.Makefile",
   lua_font_dir = kpse.expand_var("$TEXMFSYSVAR").."/luatex-cache/generic/fonts/otl/",
   fileout = 'out.dvi',
   psmapfile = 'ttfonts.map',
   fontprefix = "font",
   --   fontprefix = math.rand() .. font
   htf = false ,
}
