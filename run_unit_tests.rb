#!/usr/bin/ruby 

require 'test/unit'
require 'find'

unless ENV['PROJ_HOME']
  puts "PROJ_HOME not set"
	exit 1
end

# Hack-ish method of scanning files for TestCase class names.
# (See comment in the seek loop down below for explanation)
def each_testcase_name(fname)
	File.readlines(fname).each do |line|
		if line =~ /^\s*class\s+(Test\w+).*TestCase/
		  yield $1
		end
	end
end

suite = Test::Unit::TestSuite.new
Find.find("#{File.dirname(__FILE__)}/test") do |fname|
	if fname =~ /.*test_.*\.rb$/
		require fname
		
		# NOTE
		# Normally you don't have to do such a silly thing as hunt for the 
		# test cases.  But in this case, we have to stop test/unit from 
		# auto-running our tests, since there is a class in test_systir.rb that
		# is indeed a TestCase subclass but we mustn't execute it.
		# As a result, we need to manually construct a TestSuite.
		each_testcase_name(fname) do |tcname|
			suite << eval("#{tcname}.suite")
		end
	end
end
#GO!
Test::Unit::UI::Console::TestRunner.run suite
