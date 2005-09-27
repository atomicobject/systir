require 'test/unit'
require '../test_file_markup'

class TestTestFileMarkup < Test::Unit::TestCase

	def setup
		@test_file = 'test_markup'
	end

	def test_convert
		expected = open('expected_test').read
		testme = TestFileMarkup.new
		result = testme.convert @test_file
		
		assert_not_nil expected
		assert_equal expected, result, 'incorrect conversion' 
	end
end