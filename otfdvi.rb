#!/usr/bin/env ruby

require 'ostruct'
require 'rubygems'
require 'dvilib'
require 'optparse'
require 'yaml'
require 'fileutils'
require 'logger'
require 'minitest/autorun'

prgname = 'otfdvi'
prgfullname = 'Convert otfdvi (luaatex+fontspec) to dvips dvi'
prgversion = '0.0.1'
prgcredit = 'deimi@vtex.lt'

options = {}
optparse = OptionParser.new do|opts|
   # Set a banner, displayed at the top
   # of the help screen.
   opts.banner = "Usage: #{prgname} 
                  [OPTIONS] INPUT.DVI OUTPUT.DVI\n #{prgfullname}.\n  "
   opts.define_tail "\nEmail bug reports to #{prgcredit}"
   # Define the options, and what they do
   options[:debug] = false
   opts.on( '-d', '--debug', 'Print debug info [font tables, settings]' ) do
   options[:debug] = true
   end
   options[:verbose] = false
   opts.on( '--verbose', 'Be verbose' ) do
   options[:verbose] = true
   end
   options[:output] = "out.dvi"
   opts.on( '-c', '--output [FILE]', 'Write DVI output to [FILE]. 
                                      Default out.dvi' ) do |file|
   options[:output] = file
   end
   options[:dryrun] = false
   opts.on( '--dryrun', 'Do not perform actions.' ) do
   options[:dryrun] = true
   end
   options[:inplace] = false
   opts.on( '--inplaces', 'Output == Input' ) do
   options[:inplace] = true
   end
   options[:auto] = true
   opts.on( '--no-auto', 'Run make with all pdf' ) do
   options[:auto] = false
   end
   options[:htf] = true
   opts.on( '--no-htf', 'Do not generate htf fonts' ) do
   options[:htf] = false
   end
   options[:psmap] = "ttfonts.map"
   opts.on( '-u', '--psmap [FILE]', 'Output Postscript map file to [FILE]' ) do|file|
   options[:psmap] = file
   end

      opts.on( '-v', '--version', 'Print version' ) do
      puts "#{prgfullname}, v.#{prgversion}. #{prgcredit}"
      exit
   end
   options[:cfgfile] = prgname + '.yml'
   opts.on( '-c', '--cfgfile [FILE]', "read configuration file. 
                                       Default #{prgname}.yml" ) do|file|
   options[:cfgfile] = file
   end
   opts.on( '-h', '--help', 'Display this screen' ) do
     puts opts
     exit
   end
 end

begin
optparse.parse!
rescue OptionParser::InvalidOption => e
 puts e
 puts optparse
 exit 1
end

debug = options[:debug]
auto = options[:auto]
htf = options[:htf]


class Font
  attr_accessor :name
  attr_accessor :type # 0 - tfm; 1 - otf
  attr_accessor :otffilename, :script, :feature
  attr_accessor :charlist
  
  def initialize(name)
    @name = name
    @type = 0
    parsename(name)
    @charlist = Array.new()
  end

  def parsename(s)
    if s =~ /\[(.*.)\]:(.*?)/
      @type = 1
      @otffilename = $1
    end
    if s =~ /file:(.*?):script=(.*?);.*?;/
      @type = 1
      @otffilename = $1
      @script = $2
    end
  end
  
  def is_otf?()
    @type == 1 ? true : false  
  end

  def is_tfm?()
    @type == 0 ? true : false
  end

  def add_to_charlist(char)
    @charlist << char if not @charlist.include?(char)
  end
end

class TestFont < Minitest::Test
  def setup
    @font = Font.new("[lmroman10-regular]:+tlig;")
    @font2 = Font.new("file:lmroman17-regular:script=latn;+trep;+tlig;")
  end

  def test_if_otffont
    assert_equal true , @font.is_otf?
    assert_equal false, @font.is_tfm?
    assert_equal true, @font2.is_otf?
  end

end


TestFont.new("test1").run if debug

def otftocss(otf, font)
  f = Hash.new
  g = Hash.new
  run = "luaotfload-tool -n --find=file:#{otf} -i"
  result = Kernel.`(run)#`
  result.lines.each do |l|
    if l =~ /\s*(.*?):\s*(.*?)\s*\n/
      f[$1] = $2 if f[$1].nil?
    end
  end
 
  puts otf
  #puts f
  
  g["font-weight"] = f["weight"] if f["weight"] != "normal"
  g["font-style"] = "italic"  if f["italicangle"].to_i != 0
  g["font-family"] = "monospace" if f["monospaced"] == "true"
  puts g
  x = "htfcss: " + font + " " + g.map{|i,j| i + ": " + j + ";"}.join(" ")
  return x
end

logger = Logger.new(STDOUT)
logger.datetime_format = '%Y-%m-%d %H:%M:%S'

fileout = options[:output]
ymlfile = File.join(File.dirname(__FILE__), options[:cfgfile])
config = YAML.load_file(ymlfile)


mktempf = "otfdvi.Makefile"
mktemp = File.read(mktempf)

if !File.exist?(ymlfile)
 puts "Can't find config file #{ymlfile}. Aborting"
 exit
end
logger.info("Read config file: #{ymlfile}")

filein = ARGV[0]
fileout = ARGV[1] || fileout
fileout = filein if options[:inplace]
fileoutbase = File.basename(fileout, ".*")
psfileout = fileoutbase + ".ps"
pdffileout = fileoutbase + ".pdf"


logger.info("File in: #{filein}")
logger.info("File out: #{fileout}")
aglyphlist = Hash.new
adobeglyphlistfile = config[:adobe_glyph_list]
f = File.readlines(adobeglyphlistfile)
f.each do |l|
  next if l=~/^#/
  l=~/(.*?);(.*?)\n/
  aglyphlist[$2] = $1
end
logger.info("Read adobe glyph list: #{adobeglyphlistfile}")

dvi = Dvi.parse(File.open(filein, "rb"))
logger.info("Parse DVI file: #{filein}")




fonts = Hash.new
## Hash
## font = Font.new()
## font.id
## font.name
## font.type
## font.is_otf? .is_tfm?
## font.otffilename
## font.charlist == charset

currentfontnum = 0

dvi_modified = Array.new()
dvi.each do |op|
  #  puts op.inspect
  if op.class == Dvi::Opcode::Pre
    now = Time.now.strftime("%Y.%m.%d:%H%M")
    op.comment = " #{prgname} output #{now}"
  end

  if op.class == Dvi::Opcode::FntDef
    fontnum = op.num
    fonts[fontnum] = Font.new(op.fontname) if fonts[fontnum].nil?
    puts op.fontname
  
    if fonts[fontnum].is_otf?
      puts "#{op.fontname} => font#{fontnum}" if debug
      op.fontname = "font#{fontnum}" 
    end
  end
     
  if op.class == Dvi::Opcode::FntNum
    currentfontnum = op.index
  end

  if op.class == Dvi::Opcode::SetChar || op.class == Dvi::Opcode::Set
    if fonts[currentfontnum].is_otf?
      fonts[currentfontnum].add_to_charlist(op.index)
      i = fonts[currentfontnum].charlist.index(op.index)
      op.index = i
    end
  end

  dvi_modified << op
  
end


fx = File.open(fileout, "wb")
Dvi.write(fx, dvi_modified)
logger.info("Write DVI(modified) file: #{fileout}")

psmapfile = options[:psmap]

mkfile = config[:Makefile]
mk = File.open(mkfile, "w")

otffiles = Array.new
encfiles = Array.new
tfmfiles = Array.new
htffiles = Array.new
tfmtargets = Array.new

target_tmp=<<END
%{fontname}.tfm: %{otffontname} .FORCE
	otftotfm --literal-encoding=%{fontname}.enc --vendor=UKWN   $(verbose) --name=%{fontname} --map-file=%{psmapfile}  --no-updmap --warn-missing %{otffontname} 
END

fonts.keys.each do |fontid|
  if fonts[fontid].is_otf?
    puts "OTF: " + fonts[fontid].name if debug
    fontname  = "font#{fontid}"
    tfmfiles << fontname + ".tfm"
    otffontname = fonts[fontid].otffilename + ".otf"
    otffiles << otffontname
  
    encname = fontname
    encfile = encname + ".enc"
    encfiles << encfile
    htffile = fontname + ".htf" if htf
    htffiles << htffile if htf
    fh = File.open(encfile, "w")
    fhi = File.open(htffile, "w") if htf
    fh.puts "/#{encname} ["
    fhi.puts "#{fontname} 0 #{fonts[fontid].charlist.size-1}" if htf
    x = fonts[fontid].charlist.map{|i| "/" + aglyphlist["%04X" % i] }
    y = Array.new(256){|i| x[i] || "/.notdef"}
    fh.puts y
    fhi.puts fonts[fontid].charlist.map{|i| "'&#x" + "%04X" % i + ";' '' #{i.chr}(#{aglyphlist["%04X" % i]})" } if htf
    fh.puts "] def"
    fhi.puts "#{fontname} 0 #{fonts[fontid].charlist.size-1}" if htf
  
    cssstring = otftocss(otffontname, fontname) if htf
    fhi.puts cssstring if htf
    fh.close
    fhi.close if htf
  
    tfmtarget = target_tmp % { :fontname => fontname, :otffontname => otffontname , :psmapfile => psmapfile, :glyphlist => adobeglyphlistfile}
  
    tfmtargets << tfmtarget

    logger.info("Write encoding file: #{encfile} for #{otffontname}")
    logger.info("Write hyper text font file: #{htffile}") if htf
  else
    puts "TFM: " + fonts[fontid].name if debug
  end
end  

output = File.basename(fileout, ".*")
mkbody = mktemp % { :otffonts => otffiles.join(" "),
                    :encfiles => encfiles.join(" "),
                    :tfmfiles => tfmfiles.join(" "),
                    :htffiles => htffiles.join(" "),
                    :psmapfile => psmapfile,
                    :output => output,
                    :verbose => options[:verbose] ? '--verbose' : '' ,
}

mk.puts mkbody
mk.puts tfmtargets
  
mk.close
logger.info("Write Makefile: #{mkfile}")

if auto then
  run = "make -f #{mkfile} all pdf clean"
  logger.info("run system: #{run}")
  x = Kernel.exec(run)#`
  File.unlink mkfile
else
  run = "make -f #{mkfile} all "
  logger.info("run system: #{run}")
  x = Kernel.`(run)#`
end
