#!/usr/bin/ruby

# = DESCRIPTION
#
# Systir stands for "SYStem Testing In Ruby".  It's a framework for
# automating system-level tests using domain-specific language, and contains
# some tools and hints on how to construct and utilize your own domain language.
#
# The breakdown of using Systir for test automation is:
# 1. Tester defines test steps using project- and technology-specific language.
#    * Tests are written in files like +authentication+.+test+ and 
#      +order_placement+.+test+
# 2. The Toolsmith implements a driver to support the syntax of that language
#    * In a project-specific module, the Toolsmith writes an extension of the 
#      Systir::LanguageDriver class to support the macros used in *.test
# 3. The Tester's "scripts" are gathered up by Systir, executed, and a report 
#    is generated.
#    * Toolsmith writes a short script which uses Systest::Launcher to compose 
#      *.test files into a suite for execution.
#
# = TECHNICAL NOTE
# Under the hood, Systir is an extension of Test::Unit.  The output from 
# executing the test suite should therefor be familiar to a Ruby coder.  
# Additionally, it might be educational to the Toolsmith to understand that 
# LanguageDriver is a derivative of Test::Unit::TestCase, and that all *.test 
# files become test methods inside the TestCase which is then composed as a 
# Test::Unit::TestSuite
# 

require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'find'

#
# Systir contains classes and modules to support writing and launching
# high-level test scripts.
#
module Systir

	#
	# Systir::LanguageDriver is a special derivative of TestCase designed to
	# contain user code written to support more macro-fied testing scripts.
	#
	class LanguageDriver < Test::Unit::TestCase
		#include CatchallMethod

		# (INTERNAL USE) 
		# Sneaky trick to expose the private mix-in method +add_assertion+ from
		# Test::Unit::Assertions.  Helpers derivatives that make assertions are
		# able to have them counted because of this method.  
		# (See associate_helper.)
		def collect_assertion
			add_assertion
		end

		# == Description
		# Installs a back-reference from this Driver instance into the specified Helper
		# and returns a reference to that Helper.  Typically thismethod is called
		# on the same line you return the helper from once it's built.
		#
		# == Params
		# +helper+ :: The Helper instance you're handing control over to
		#
		# == Return
		# The same +helper+ reference that was sent in as a parameter.
		# 
		# == Details
		#
		# Since Helpers are usually built as support for domain-level syntax,
		# they usually require a direct reference to macro functions built into
		# the driver.  Additionally, the Helper may need to make assertions
		# defined in the driver, or test/unit itself, and only the Driver may
		# count assertions; the Helper must use a special internal implementation
		# of 'add_assertion' in order to increment the test's assertion count.
		#
		# Some aliases have been added to aid readability
		#
		def associate_helper(helper)
			unless helper.respond_to? :driver=
				raise "helper doesn't support 'driver=' method"
			end
			helper.driver = self
			return helper
		end
		alias_method :return_helper, :associate_helper
		alias_method :hand_off_to, :associate_helper

	end

	# = Description
	# Launcher is the utility for launching system test scripts.
	#
	module Launcher

		# 
		# Find and run all the system test scripts in the given directory.
		# Tests are identified by the .test file extension.
		#
		def self.find_and_run_all_tests(driver_class, dir='.')
			Find.find(dir) do |path|
				if File.basename(path) =~ /\.test$/
					import_test driver_class,path
				end
			end

			Test::Unit::UI::Console::TestRunner.run(driver_class.suite)
		end

		#
		# Run a specific test.  
		#
		def self.run_test(driver_class, test_filename)
			import_test driver_class,test_file
			Test::Unit::UI::Console::TestRunner.run driver_class.suite
		end

		#
		# Run a specific list of tests
		#
		def self.run_test_list(driver_class, test_filename_list)
			test_file_list.each do |path|
				import_test driver_class,path
			end
		end

		#
		# (INTERNAL USE)
		# Read contents of from_file, wrap text in 'def', 
		# add the resulting code as a new method on the given class
		# 
		def self.import_test(to_class, from_file)
			# Determine test and file names
			base = File.basename(from_file)
			base_minus_ext = base.sub(/\.test$/, '')

			# Transform the test script into a test method inside
			# the driver class:
			text = File.readlines(from_file)
			text = "def test_#{base_minus_ext}\n#{text}\nend\n";
			
			# Dynamically define the method:
			to_class.class_eval(text, base, 0)
		end

	end

	# = DESCRIPTION 
	# Systir::Helper is a module intended for mixing-in to classes defined 
	# to assist a project-specific Systir::LanguageDriver.
	# 
	#
	module Helper
		include Test::Unit::Assertions

		#
		# Construct a new Helper with a back reference to the language driver.
		# NOTE: the +driver+ argument is optional if you utilize <code>driver=</code>
		# or Systir::LanguageDriver.associate_helper
		# 
		def initialize(driver=nil)
			
		end

		#
		# Returns a reference to our owning LanguageDriver instance.
		#
		def driver
			unless @_driver
				raise "helper has no back reference to the driver! " +
					"The driver should have used hand_of_to()"
			end
			return @_driver

		end

		#
		# Sets the owning reference to a LanguageDriver.
		# This method is used by Systir::LanguageDriver#associate_helper.
		#
		def driver=(dr)
			@_driver = dr
		end
		
		# 
		# Redirects assertion counting into our owning LanguageDriver.
		# Assertions module will automatically attempt to store the count
		# within a Helper otherwise, leading to incorrect results.
		#
		private
		def add_assertion
			if driver
				driver.collect_assertion
			else
				raise "assertion made outside the context of a Driver or TestCase"
			end
		end

	end
end
