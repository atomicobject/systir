require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'find'


module Test
	#
	# Test::System contains classes and modules to support writing and launching
	# system-test-level scripts.
	#
	module System
		# Flag: Test::Unit::Assertions module will not throw assertion failures
		# when true
		BLOCK_ASSERTIONS = false

		# Flag: tests that invoke non-existent macros or methods will NOT fail if
		# this flag is set true.
		ALLOW_MISSING_METHODS = false

		#
		# Test::System::Driver is a special derivative of TestCase designed to
		# contain user code written to support more macro-fied testing scripts.
		#
		class Driver < Test::Unit::TestCase
			include CatchallMethod

			def collect_assertion
				add_assertion
			end

			# == Description
			# Installs a back-reference from this Driver instance into the specified Helper
			# and returns a reference to that Helper.  Typically thie method is called
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

		#
		# TestRunner is the utility for launching system test scripts.
		#
		module Launcher

			# 
			# Find all the system test scripts, and add their contents
			# as new test methods on the main test class
			#
			def self.find_and_run_all_tests(test_class, dir='.')
				Find.find(dir) do |path|
					if File.basename(path) =~ /\.test$/
						import_test test_class,path
					end
				end

				Test::Unit::UI::Console::TestRunner.run(test_class.suite)
			end

			#
			# Run a specific test
			#
			def self.run_test(test_class, test_file)
				import_test test_class,test_file
				Test::Unit::UI::Console::TestRunner.run test_class.suite
			end

			#
			# Run a specific list of tests
			#
			def self.run_test_list(test_class, test_file_list)
				test_file_list.each do |path|
				  import_test test_class,path
				end
			end

			#
			# Read contents from_file, wrap text in 'def', 
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

		#
		# Helper module is a convenience module that includes
		# Test::Unit::Assertions and the CatchallMethod modules.
		# Designed to be mixed into helper classes
		# that a toolsmith may need to implement to provide domain-language-level
		# constructs.
		#
		module Helper
		  include Test::Unit::Assertions
			include CatchallMethod

			#
			# Ensures that assertions are counted by the main Driver
			#
			def add_assertion
				if driver
				  driver.collect_assertion
				else
					raise "assertion made outside the context of a Driver or TestCase"
				end
			end

			def driver
				unless @_driver
				  raise "helper has no back reference to the driver! The driver should have used hand_of_to()"
				end
			  return @_driver

			end
			def driver=(dr)
			  @_driver = dr
			end
		end
	end

end

# = Description
# CatchallMethod is a mix-in that allows undefined methods to be called
# safely.  The return from such calls is a Catchall instance, which 
# automatically has CatchallMethod mixed-in, so you can make chained
# calls on undefined methods, as well.
#
module CatchallMethod

	# Save a copy of the original method_missing functionality
	alias_method :old_method_missing, :method_missing

	#
	# Prints notification of an undefined call to stdout
	# 
	def method_missing(mname, *args)
		if Test::System::ALLOW_MISSING_METHODS
			# Fail softly
			(file,line) = caller[0].split(/:/)
			puts "No such macro: #{mname} (#{file}, line #{line})"

			# Return a semi-usable object
			return Catchall.new
		else
		  # Catchall not enabled; do normal method_missing behavior
			old_method_missing(mname,*args)
		end
	end

	# = Description
	# A dummy class that has CatchallMethod mixed in 
	# to allow the calling of methods that don't exist
	#
	class Catchall
		include CatchallMethod
	end
end


# = Description
# Modification to Test::Unit::Assertions
#
module Test 
  module Unit 
 
 	#
	# Modifies the standard Test::Unit::Assertions module to allow blocking of
	# assertions
	#
 	module Assertions
			#
			# Allow assertions to be blocked by the boolean constant
			# Test::System::BLOCK_ASSERTIONS
			#
      def assert_block(message="assert_block failed.") 
        if Test::System::BLOCK_ASSERTIONS 
					puts "(blocked assertion)"
				else
          _wrap_assertion do
            if (! yield)
              raise AssertionFailedError.new(message.to_s)
            end
          end
        end
      end
    end
  end
end


