#!/usr/bin/ruby

require 'systir'
require 'pizza_driver'

Systir::Launcher.new.find_and_run_all_tests(PizzaDriver)
