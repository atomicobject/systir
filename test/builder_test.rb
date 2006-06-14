
require File.dirname(__FILE__) + '/test_helper'

class BuilderTest < Test::Unit::TestCase
  
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


