require File.dirname(__FILE__) + '/test_helper'

class LauncherTest < Test::Unit::TestCase
	def setup
		@launcher = Systir::Launcher.new
		assert @launcher.respond_to?(:execute), "Launcher instance has no execute method"
		@launcher.extend Bogus
		@launcher.bogify :execute
	end

	# For testing the runner methods:
	class MyDriver 
		def self.suite
			# return a reference to this class for testing
			return self 
		end
	end

	# See that run_test creates and executes the test suite
	# based on the given file
  def test_run_test
		test_script = relfile('resource/launcher/wonder.test')
		@launcher.run_test(MyDriver, test_script)

		suite = @launcher._args[0][0]
		assert_include suite.instance_methods, 'test_wonder'
  end

	# See that run_test_list creates and executes the test suite
	# based on a list of files
  def test_run_test_list
		wonder = relfile('resource/launcher/wonder.test')
		other = relfile('resource/launcher/other.test')
		@launcher.run_test_list(MyDriver, [wonder,other])

		assert_not_nil @launcher._args
		assert_not_nil @launcher._args[0]
		suite = @launcher._args[0][0]
		assert_include suite.instance_methods, 'test_wonder'
		assert_include suite.instance_methods, 'test_other'
  end

	# See that find_and_run_all_tests finds tests
	# recursively and puts them in the suite
  def test_run_test_list
		dir = relfile('resource/launcher/')
		@launcher.find_and_run_all_tests(MyDriver, dir)

		assert_not_nil @launcher._args
		assert_not_nil @launcher._args[0]
		suite = @launcher._args[0][0]
		assert_include suite.instance_methods, 'test_wonder'
		assert_include suite.instance_methods, 'test_other'
		assert_include suite.instance_methods, 'test_funky'
		assert_include suite.instance_methods, 'test_bunny'
  end

end
