#!/usr/bin/ruby

# Manually configure the Ruby library load path to ensure example robustness
this_dir = File.dirname(__FILE__)
$LOAD_PATH << "#{this_dir}/../../src"
$LOAD_PATH << "#{this_dir}"

require 'systir'
require 'basic_driver'

testfile = ARGV[0]
unless testfile
  puts "Usage: run_test.rb <some.test>"
  exit 1
end

Systir::Launcher.new.run_test BasicDriver, testfile
