#!/usr/bin/ruby

$LOAD_PATH << File.dirname(__FILE__) + "/lib"
require 'systir'
require 'pizza_driver'

Systir::Launcher.new.find_and_run_all_tests(PizzaDriver)
