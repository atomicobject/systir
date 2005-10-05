#!/usr/bin/ruby

# Manually configure the Ruby library load path to ensure example robustness
$LOAD_PATH << File.dirname(__FILE__) + "/lib"

require 'systir'
require 'pizza_driver'

testfile = ARGV[0]
unless testfile
  puts "Usage: run_test.rb <some.test>"
  exit 1
end

Systir::Launcher.new.run_test PizzaDriver, testfile
