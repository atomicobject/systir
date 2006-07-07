
require File.dirname(__FILE__) + '/helper'

context 'Running tests in a suite' do
	setup do
		def spec_dir
			File.dirname(__FILE__)
		end

		def test_dir
			spec_dir + "/testdir"
		end

		def test(path)
			test_dir + "/#{path}.test"
		end

		@launcher = Systir::Launcher.new :stdout => false
	end

	specify 'should run multiple tests specified in a suite' do
		result = @launcher.run_suite(ShaqDriver) do |suite|
			suite.add :test => test('pass')
			suite.add :test => test('fail')
			suite.add :test => test('error')
		end
		result.should_not_be_nil
		result.should_have(1).failures
		first_failure = result.failures.first
		first_failure.test_name.should_not_match /test_fail_/
		result.should_have(1).errors
		result.assertion_count.should_equal 13
		result.passed?.should_be false
	end

	specify 'should allow test name suffixes to execute a test multiple times' do
		result = @launcher.run_suite(ShaqDriver) do |suite|
			suite.add :test => test('fail'), :name_suffix => 'one'
			suite.add :test => test('fail'), :name_suffix => 'two'
			suite.add :test => test('error')
		end
		result.should_not_be_nil
		result.should_have(2).failures
		first_failure = result.failures.first
		first_failure.test_name.should_match /test_fail_one/
		second_failure = result.failures[1]
		second_failure.test_name.should_match /test_fail_two/
		result.should_have(1).errors
		result.assertion_count.should_equal 12
		result.passed?.should_be false
	end

	specify 'should allow individual parameterization of tests in a suite' do
		result = @launcher.run_suite(MultiParameterizedDriver) do |suite|
			suite.add :test => spec_dir + '/more/assist.test', :name_suffix => 'one', 
			  :params => {:carrottop => 'funny'}
			suite.add :test => spec_dir + '/more/assist.test', :name_suffix => 'two',
			  :params => {:carrottop => 'stupid'}
		end
		result.should_not_be_nil
		result.should_have(2).failures
		result.should_have(0).errors
		result.assertion_count.should_equal 2
		result.passed?.should_be false
		funny_failure = result.failures.shift
		funny_failure.message.should_equal 'carrottop=[funny].'
		stupid_failure = result.failures.shift
		stupid_failure.message.should_equal 'carrottop=[stupid].'
	end
end

class MultiParameterizedDriver < Systir::LanguageDriver
	def get_an_assist
		flunk "carrottop=[#{params[:carrottop]}]"
	end
end


