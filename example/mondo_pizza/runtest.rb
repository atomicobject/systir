#!/usr/bin/ruby

require 'systest_launcher'
require 'pizza_driver'

ARGV.each do |f|
  SystestLauncher.runtest(PizzaDriver, f)
end
