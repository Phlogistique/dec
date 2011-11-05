#!/usr/bin/env ruby
# This program is free software. It comes without any warranty, to the extent
# permitted by applicable law. You can redistribute it and/or modify it under
# the terms of the Do What The Fuck You Want To Public License, Version 2, as
# published by Sam Hocevar. See http://sam.zoy.org/wtfpl/COPYING for more
# details.
require 'fileutils'
include FileUtils

programs = {
  "zip" => %w"unzip",
  "rar" => %w"unrar x",
  "tar" => %w"tar xf",
  "7z" => %w"7z x"
}
programs.default = %w"7z x"

archive = ARGV[0]

basename, ext = File.basename(archive).scan(/^(.+)\.((?:tar.)?[^\.]+)$/).flatten

unless basename and ext
  STDERR.puts %(Can't parse filename "#{archive}")
  exit
end

ext = "tar" if ext =~ /^tar/

program = programs[ext]

unless program
  STDERR.puts %(Extension "#{ext}" not supported)
  exit
end

tmpname = "." + basename
mkdir tmpname
cd tmpname
unless system(*(program << File.join("..", archive)))
  STDERR.puts %(Decompression failed!)
  exit
end
files = Dir.entries(".") - [".", ".."]
cd ".."

if files.length == 0
  STDERR.puts %(No files in the archive!)
  rmdir tmpname
  exit
end

STDERR.print "Decompressed to "
if files.length == 1
  mv File.join(tmpname, files[0]), "."
  rmdir tmpname
  puts files[0]
else
  mv tmpname, basename
  puts basename
end

rm archive

