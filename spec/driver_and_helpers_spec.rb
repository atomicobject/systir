
require File.dirname(__FILE__) + '/helper'

class BirdDriver < Systir::LanguageDriver
	def setup
		assert true
	end

	def make_a_3_pointer
		assert true
		assert true
		assert true
	end

	def get_an_assist
		pippen = PippenHelper.new
		associate_helper pippen
		pippen.alleyoop
	end

	def teardown
		assert true
	end
end

class PippenHelper 
	include Systir::Helper

	def alleyoop
		assert true
	end
end

context 'Using drivers and helpers' do
	setup do
		@launcher = Systir::Launcher.new

		def test_dir
			File.dirname(__FILE__) + "/more"
		end

		def test(path)
			test_dir + "/#{path}.test"
		end
	end

	specify 'tests should execute within the context of the driver' do
		result = @launcher.run_test(BirdDriver, test('just_sit_there'))
		result.should_not_be_nil
		result.should_have(0).failures
		result.should_have(0).errors
		result.assertion_count.should_be 2
		result.passed?.should_be true

		result = @launcher.run_test(BirdDriver, test('3_pointer'))
		result.should_not_be_nil
		result.should_have(0).failures
		result.should_have(0).errors
		result.assertion_count.should_be 5
		result.passed?.should_be true
	end

	specify 'assertions in associated helpers should be tracked in main assertion count' do
		result = @launcher.run_test(BirdDriver, test('assist'))
		result.should_not_be_nil
		result.should_have(0).failures
		result.should_have(0).errors
		result.assertion_count.should_be 3
		result.passed?.should_be true
	end
	
end

