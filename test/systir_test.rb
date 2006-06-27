
require File.dirname(__FILE__) + '/helper'

module JustForMe
	def test_dir
		File.dirname(__FILE__) + "/testdir"
	end

	def test(path)
		test_dir + "/#{path}.test"
	end
end
include JustForMe

class ShaqDriver < Systir::LanguageDriver
	def setup
		assert true
	end

	def teardown
		assert true
	end
end

#def test_dir
#	File.dirname(__FILE__) + "/testdir"
#end
#
#def test(path)
#	test_dir + "/#{path}.test"
#end

context 'Accessing test results' do
	setup do
		@launcher = Systir::Launcher.new
	end

	specify 'should be able to get at failures, errors, and assertion_count from TestResult' do
		result = @launcher.run_test_list(ShaqDriver, [test('pass'),test('error'),test('fail')])
		result.should_not_be_nil
		result.should_respond_to :failures
		result.should_respond_to :errors
		result.should_respond_to :assertion_count
		result.should_have(1).failures
		result.should_have(1).errors
		result.assertion_count.should_equal 13
	end
end
	
context 'Running single test cases' do
	setup do
		@launcher = Systir::Launcher.new
	end

  specify 'should report single passing test as passing' do
		result = @launcher.run_test(ShaqDriver, test('pass'))
		result.should_not_be_nil
		result.errors.should_be_empty
		result.failures.should_be_empty
		result.passed?.should_be true
  end

	specify 'should report failure when a test fails' do
		result = @launcher.run_test(ShaqDriver, test('fail'))
		result.should_not_be_nil
		result.errors.should_be_empty
		result.should_have(1).failures
		result.passed?.should_be false
		result.failures.first.test_name.should_equal 'test_fail(ShaqDriver)'
		result.failures.first.location.first.should_match /fail\.test:3:/
	end

	specify 'should report error when a test raises an error' do
		result = @launcher.run_test(ShaqDriver, test('error'))
		result.should_not_be_nil
		result.should.have(1).errors
		result.failures.should_be_empty
		result.passed?.should_be false
		result.errors.first.test_name.should_equal 'test_error(ShaqDriver)'
	end

	specify 'should raise error if nil test filename given' do
		lambda { @launcher.run_test(ShaqDriver, nil) }.should_raise RuntimeError
	end

	specify 'should raise error if non existent test filename given' do
		lambda { @launcher.run_test(ShaqDriver, '/nothere/noway') }.should_raise RuntimeError
	end
end

context 'Running multiple test cases' do
	setup do
		@launcher = Systir::Launcher.new
	end

	specify 'should only run two tests for the same file once' do
		result = @launcher.run_test_list(ShaqDriver, [test('pass'),test('fail'),test('fail')])
		result.should_not_be_nil
		result.should.have(1).failures
		result.should.have(0).errors
		result.passed?.should_be false
	end

	specify 'should raise error if no tests given' do
		lambda { @launcher.run_test_list(ShaqDriver, []) }.should_raise RuntimeError
	end

	specify 'should raise error if nil test list given' do
		lambda { @launcher.run_test_list(ShaqDriver, nil) }.should_raise RuntimeError
	end

	specify 'should run all tests in a directory as well as those in subdirectories' do
		result = @launcher.find_and_run_all_tests(ShaqDriver, test_dir)
		result.should_not_be_nil
		result.should.have(1).failures
		result.should.have(1).errors
		result.assertion_count.should_equal 19
		result.passed?.should_be false
	end

	specify 'should raise error if nil directory given' do
		lambda { @launcher.find_and_run_all_tests(ShaqDriver, nil) }.should_raise RuntimeError
	end

	specify 'should raise error if non existent directory given' do
		lambda { @launcher.find_and_run_all_tests(ShaqDriver, '/howhere/nohow') }.should_raise RuntimeError
	end
end

