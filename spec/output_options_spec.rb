
require File.dirname(__FILE__) + '/helper'
require 'rexml/document'
include REXML

context 'Various output options' do
	setup do
		def test_dir
			File.dirname(__FILE__) + "/testdir"
		end

		def test(path)
			test_dir + "/#{path}.test"
		end

		@output_file = test_dir + 'output.dat'
		@old_stdout = $stdout.dup
		$stdout.reopen(@output_file)
	end

	teardown do
		$stdout.reopen(@old_stdout)
		File.delete(@output_file) if File.exists?(@output_file)
	end

	specify 'should allow disabling of output to stdout' do
		@launcher = Systir::Launcher.new :stdout => false
		result = @launcher.run_test_list(ShaqDriver, 
		  [test('pass'),test('error'),test('fail')])
		result.should_not_be_nil
		result.should_have(1).failures
		result.should_have(1).errors
		result.assertion_count.should_equal 13
		result.output.should_match /3 tests, 13 assertions, 1 failures, 1 errors/m
		File.read(@output_file).should_be_empty
	end

	specify 'should send output to stdout by default' do
		@launcher = Systir::Launcher.new 
		result = @launcher.run_test_list(ShaqDriver, 
		  [test('pass'),test('error'),test('fail')])
		result.should_not_be_nil
		result.should_have(1).failures
		result.should_have(1).errors
		result.assertion_count.should_equal 13
		result.output.should_match /3 tests, 13 assertions, 1 failures, 1 errors/m
		File.read(@output_file).should_match /3 tests, 13 assertions, 1 failures, 1 errors/m
	end

	specify 'should allow outputting in xml format' do
		@launcher = Systir::Launcher.new :stdout => false, :format => :xml
		result = @launcher.run_test_list(ShaqDriver, 
		  [test('pass'),test('error'),test('fail')])
		result.should_not_be_nil
		result.should_have(1).failures
		result.should_have(1).errors
		result.assertion_count.should_equal 13
		File.read(@output_file).should_be_empty
		result.output.should_not_be_nil
		doc = Document.new(result.output)
		doc.should_not_be_nil
		XPath.first(doc, "/testsuite").should_not_be_nil
		XPath.match(doc, "/testsuite/test").size.should_be 3
		result_el = XPath.first(doc, "/testsuite/result")
		result_el.should_not_be_nil
		result_el.attributes['testcount'].should_equal '3'
		result_el.attributes['assertcount'].should_equal '13'
		result_el.attributes['errors'].should_equal '1'
		result_el.attributes['failures'].should_equal '1'
		result_el.attributes['passed'].should_equal 'false'
		XPath.first(doc, "/testsuite/elapsed-time").should_not_be_nil
	end

	specify 'should raise error if invalid format given' do
		@launcher = Systir::Launcher.new :stdout => false, :format => :junk
		lambda {
			@launcher.run_test_list(ShaqDriver, [test('pass'),test('error'),test('fail')])
		}.should_raise
	end
end

