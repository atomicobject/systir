#!/usr/bin/ruby

require 'systir'
require 'test/unit'
require 'tutils/bogus'
require 'tutils/ext_assertions'

# = DESCRIPTION
# This is the unit test suite for the Systir modules and classes.
#

###########################################################################
# UTILS

# Use the directory of this test file to prepend to fname
def relfile(fname)
  File.dirname(__FILE__) + "/#{fname}"
end

###########################################################################

class Systir::LanguageDriver
  # Since a LanguageDriver is a kind of TestCase,
  # and you must have at least one test method if you
  # are a TestCase, we must add a bogus filler method here:
  def test_BOGUS
		puts "!!!!!!!!!!!!!!!"
		puts caller
		puts "!!!!!!!!!!!!!!!"

    raise "SHOULDN'T BE CALLED"
  end
end


class TestLanguageDriver < Test::Unit::TestCase
  class BogusHelper
    attr_accessor :driver
  end

  def setup
    @driver = Systir::LanguageDriver.new('test_BOGUS')
    @helper = BogusHelper.new
  end

  #
  # See that associate_helper causes the driver to set a self-reference
  # on the given helper and returns the helper
  #
  def test_associate_helper
    assert_nil @helper.driver
    got = @driver.associate_helper(@helper)
    assert_equal @driver, @helper.driver
    assert_equal @helper, got, "wrong return"
  end
  # (return_helper is an alias of associate_helper)
  def test_return_helper
    assert_nil @helper.driver
    got = @driver.return_helper(@helper)
    assert_equal @driver, @helper.driver
    assert_equal @helper, got, "wrong return"
  end
  # (return_helper is an alias of associate_helper)
  def test_hand_off_to
    assert_nil @helper.driver
    got = @driver.hand_off_to(@helper)
    assert_equal @driver, @helper.driver
    assert_equal @helper, got, "wrong return"
  end

  # See that collect_assertion calls add_assertion
  def collect_assertion
    @driver.extend Bogus
    @driver.bogify :add_assertion

    assert_nil @driver._calls
    @driver.collect_assertion
    assert_equal [:add_assertion], @driver._calls
  end

end

###########################################################################
class TestLauncher < Test::Unit::TestCase
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

###########################################################################
class TestBuilder < Test::Unit::TestCase
  
  
  # See that suite() gets a suite from the driver class
  def test_suite
    cl = Object.new
    cl.extend Bogus
    cl.bogify :suite
    the_suite = Object.new
    cl._suite_return = the_suite

    b = Systir::Builder.new(cl)
    assert_equal the_suite, cl.suite
  end

  # Target class fot testing import_test:
  class MyClass1
  end

  # See that import_test successfully loads the contents of 
  # a text file as the source of a new method on the driver class.
  def test_import_test
    b = Systir::Builder.new(MyClass1)
    b.import_test relfile('resource/builder1.test')
    
    # MyClass should now have a method called test_builder1
    obj = MyClass1.new
    assert obj.respond_to?(:test_builder1)

    assert_equal "This is the test script!", obj.test_builder1
  end

  # Target class fot testing import_test's context:
  class MyClass2
  end

  # See that import_test uses eval in such a way as to preserve
  # source code context, ie, file name and line number
  def test_import_test_context
    b = Systir::Builder.new(MyClass2)
    b.import_test relfile('resource/builder2.test')
    
    # MyClass should now have a method called test_builder1
    obj = MyClass2.new
    #puts obj.methods.sort # XXX
    assert obj.respond_to?(:test_builder2)

    # The loaded code is instrumented to raise an error
    begin 
      obj.test_builder2
      fail "expected an error to be thrown"
    rescue => gotcha
      assert_equal "the error", gotcha.message
      trace_item = gotcha.backtrace[0]
      assert_match(/builder2\.test:4:/, trace_item, "wrong traceback item")
    end
  end


  # For testing the suite_for_* methods:
  class MyClass3; end

  
  # See that suite_for_directory scans the given directory for files
  # with .test extension then imports them into the target,
  # returning the test suite
  def test_suite_for_directory
    b = Systir::Builder.new(MyClass3)
    b.extend Bogus
    b.bogify :import_test, :suite
    b._suite_return = "the suite"

    got = b.suite_for_directory(relfile('resource/sfdtest'))
    assert_equal [:import_test, :import_test, :import_test, :import_test, :suite], b._calls
		assert_include b._args, [relfile("resource/sfdtest/sub/sub2/one.test")]
		assert_include b._args, [relfile("resource/sfdtest/sub/two.test")]
		assert_include b._args, [relfile("resource/sfdtest/red.test")]
		assert_include b._args, [relfile("resource/sfdtest/blue.test")]
		assert_equal "the suite", got
  end

  #
  # See that suite_for_file imports the test script and returns the suite
  #
  def test_suite_for_file
    b = Systir::Builder.new(MyClass3)
    b.extend Bogus
    b.bogify :import_test, :suite
    b._suite_return = "the suite"

    got = b.suite_for_file("my file")
    assert_equal [:import_test,:suite], b._calls
    assert_equal [ ["my file"], [] ], b._args
    assert_equal "the suite", got  
  end

  #
  # See that suite_for_list imports the list of test script and returns the
  # suite
  #
  def test_suite_for_list
    b = Systir::Builder.new(MyClass3)
    b.extend Bogus
    b.bogify :import_test, :suite
    b._suite_return = "the suite"

    got = b.suite_for_list(["file1","file2","file3"])
    assert_equal [:import_test, :import_test, :import_test, :suite], b._calls
    assert_equal [ ["file1"], ["file2"], ["file3"], [] ], b._args
    assert_equal "the suite", got  
  end
end



###########################################################################
class TestHelper < Test::Unit::TestCase
  # Helper is a mixin; let's make something concrete:
  class MyHelper 
    include Systir::Helper

    # Because add_assertion is private...
    def _call_add_assertion
      add_assertion
    end
  end

  def setup 
    # Bogus driver
    @driver = Object.new
    @driver.extend Bogus
    @driver.bogify :collect_assertion
  end

  # See the constructor stores a driver ref
  def test_constructor
    h = MyHelper.new(@driver)
    assert_not_nil h, "failed to construct"
    assert_equal @driver, h.driver, "driver ref not set"
  end
  
  # See the constructor considers driver to be optional 
  def test_constructor_no_driver
    h = MyHelper.new
    assert_not_nil h, "failed to construct"
  end

  # See that we can set and get the driver
  def test_driver_accessor
    h = MyHelper.new
    h.driver = @driver
    assert_equal @driver, h.driver, "driver not gotten"
  end

  # See that the driver getter explodes if driver is unset
  def test_driver_getter_nil
    h = MyHelper.new
    err = assert_raise RuntimeError  do
      h.driver
    end
    assert_match(/reference.*driver/i, err.message) 
  end

  # See that add_assertion() calls collect_assertion on the driver
  def test_add_assertion
    h = MyHelper.new(@driver)
    assert_nil @driver._calls, 'Expected no calls yet'
    h._call_add_assertion
    assert_equal [:collect_assertion], @driver._calls
  end

  # See that add_assertion() raises err if driver is unset
  def test_add_assertion_no_driver
    h = MyHelper.new
    err = assert_raise RuntimeError  do
      h._call_add_assertion
    end
    assert_match(/helper.*no.*reference.*driver/, err.message)
  end

  # See that add_assertion() raises err if driver hasn't got collect_assertion
  def test_add_assertion_bad_driver
    h = MyHelper.new(Object.new)
    err = assert_raise RuntimeError  do
      h._call_add_assertion
    end
    assert_match(/collect_assertion/, err.message)
  end

end

###########################################################################
# Standalone console runner:
if $0 == __FILE__
  require 'test/unit/ui/console/testrunner'
  suite = Test::Unit::TestSuite.new
  suite << TestBuilder.suite
  suite << TestLauncher.suite
  suite << TestLanguageDriver.suite
  suite << TestHelper.suite
  Test::Unit::UI::Console::TestRunner.run suite
end

Test::Unit.run=true
