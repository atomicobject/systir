
require File.dirname(__FILE__) + '/helper'

class ParameterizedShaqDriver < Systir::LanguageDriver

	def get_an_assist
		assert_equal 'cosmo', params[:kramer]
		assert_equal 'george', params[:castanza]
	end
end

context 'Running tests with parameters passed to driver instances' do
	setup do
		def test_dir
			File.dirname(__FILE__) + "/more"
		end

		def test(path)
			test_dir + "/#{path}.test"
		end

		@launcher = Systir::Launcher.new :stdout => false
	end

	specify 'should pass parameters to driver if specified via launcher' do
		result = @launcher.run_test(ParameterizedShaqDriver, test('assist'), 
			:kramer => 'cosmo', :castanza => 'george')
		result.should_not_be_nil
		result.should_have(0).failures
		result.should_have(0).errors
		result.assertion_count.should_be 2
		result.passed?.should_be true
	end
end

