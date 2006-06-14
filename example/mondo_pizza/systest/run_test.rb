#!/usr/bin/ruby
require 'idealizer'
require 'fileutils'

# Manually configure the Ruby library load path to ensure example robustness
$LOAD_PATH << File.dirname(__FILE__) + "/../../../lib"

require 'systir'
require 'pizza_driver'

testfile = ARGV[0]
unless testfile
  puts "Usage: run_test.rb <some.test>"
  exit 1
end

if File.extname(testfile) == '.idea'
	puts "Converting idea file to test file..."
	outfile = testfile.gsub('.idea', '.test')
  FileUtils.rm outfile if File.exist?(outfile)
	converter = TestFileMarkup.new
	
	out = converter.convert(testfile)
	output = File.new(outfile, File::CREAT|File::WRONLY, 0644)
  output.puts out
	output.close
	testfile = outfile
end

Systir::Launcher.new.run_test PizzaDriver, testfile
