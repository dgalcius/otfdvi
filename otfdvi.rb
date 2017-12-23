#!/usr/bin/env ruby

require 'ostruct'
require 'rubygems'
require 'dvilib'
require 'optparse'
require 'yaml'
require 'fileutils'

prgname = 'otfdvi'
prgfullname = 'Convert otfdvi (fontspec) to dvips dvi'
prgversion = '0.0.1'
prgcredit = 'deimi@vtex.lt'

options = {}
optparse = OptionParser.new do|opts|
   # Set a banner, displayed at the top
   # of the help screen.
   opts.banner = "Usage: #{prgname} [OPTIONS] INPUT.DVI OUTPUT.DVI\n #{prgfullname}.\n  "
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
   options[:dryrun] = false
   opts.on( '--dryrun', 'Check if FILES differ' ) do
   options[:dryrun] = true
   end
      opts.on( '-v', '--version', 'Print version' ) do
      puts "#{prgfullname}, v.#{prgversion}. #{prgcredit}"
      exit
   end
   options[:cfgfile] = prgname + '.yml'
   opts.on( '-c', '--cfgfile [FILE]', "read configuration file. Default #{prgname}.yml" ) do|file|
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

ymlfile = File.join(File.dirname(__FILE__), options[:cfgfile])

if !File.exist?(ymlfile)
 puts "Can't find config file #{ymlfile}. Aborting"
 exit
end


filein = ARGV[0]
fileout = ARGV[1]

dvi = Dvi.parse(File.open(filein, "rb"))

fonttable = Hash.new
#ftable2 = Hash.new# [op.fontname, op.scale, op.checksum, op.design_size]=> {op.num, cnt}

## fonttable =
## { id => 15
##  fontname = > "file:lmroman10-regular:script=latn;+trep;+tlig;"
##  chars => [A, B, 1]
## }

# fonttable = {
#   "lmroman10-regular" => [A,B,Z],
#  }

aglyphlist = Hash.new
adobeglist = "glyphlist.txt"
f = File.readlines(adobeglist)
f.each do |l|
  next if l=~/^#/
  l=~/(.*?);(.*?)\n/
  aglyphlist[$2] = $1
end


fontnumtable = Hash.new

currentfontnum = 0

dvi.each do |op|
  ## Get RUNTIMEINFO
#  puts op.inspect
  if op.class == Dvi::Opcode::FntDef
    #     puts op.inspect
    puts op.fontname
    fontid = [op.fontname, op.scale, op.checksum, op.design_size].join('-')
    fontnum = op.num
    if fontnumtable[fontid].nil?
      fontnumtable[fontid] = fontnum
    end
    
    ##    if !fonttable[fontid].is_empty?
    if fonttable[fontnum].nil?
      fonttable[fontnum] = Array.new
    end
 end
    
  if op.class == Dvi::Opcode::FntNum
    currentfontnum = op.index
  end

   if op.class == Dvi::Opcode::SetChar
     fonttable[currentfontnum] <<  "%04X" % op.index
  end

end


psmapfile = File.basename(filein, ".dvi") + ".map"
psmap = File.open(psmapfile, "w")
mkfile = "00Makfile"
mk = File.open(mkfile, "w")
mk.puts "default: "
#mk.puts "\n%.tfm: %.otf"
#mk.puts "\totftotfm"

puts fonttable.inspect
puts i = fonttable[14][0]
puts aglyphlist[i]
fonttable.each do |font,symlist|
  fontname = "font-#{font}"
  encfont = fontname + ".enc"
  f = File.open(encfont, "w")
  f.puts "/#{fontname} ["
  symlist.each do |sym|
    f.puts "/" + aglyphlist[sym]
  end
  f.puts "] def"
  f.close
  puts fontname + " <" + encfont + " < xxxx.pfb" 
end

psmap.close
mk.close
puts "STOP"
