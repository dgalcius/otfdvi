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

fonttable = Array.new
#ftable2 = Hash.new# [op.fontname, op.scale, op.checksum, op.design_size]=> {op.num, cnt}

## fonttable =
## { id => 15
##  fontname = > "file:lmroman10-regular:script=latn;+trep;+tlig;"
##  chars => [A, B, 1]
## }


dvi.each do |op|
 ## Get RUNTIMEINFO
  if op.class == Dvi::Opcode::FntDef
    puts op.inspect
   if !fonttable.include?([op.fontname, op.scale, op.checksum, op.design_size])
     fonttable <<  [op.fontname, op.scale, op.checksum, op.design_size]
     puts "Font table entry: #{[op.fontname, op.scale, op.checksum, op.design_size].inspect}"
   end
 end
end

puts "STOP"
