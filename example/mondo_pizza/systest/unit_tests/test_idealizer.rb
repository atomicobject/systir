require 'test/unit'
require '../idealizer'

class TestIdealizer < Test::Unit::TestCase

	def setup
		@test_file = 'test_markup'
	end

	def test_convert
		expected = open('expected_test').read
		testme = Idealizer.new
		result = testme.convert @test_file
		
		assert_not_nil expected
		assert_equal expected, result, 'incorrect conversion' 
	end

	def test_remove_sentence_punctuation
		sentences = [
			'Hello there you.',
			'....,',
			'Blah, blah,',
			'.Blah.,blah.,'
		]

		exp = [
			'Hello there you',
			'....',
			'Blah, blah',
			'.Blah.,blah.'
		]

		testme = Idealizer.new
		got = []
		sentences.each do | s |
			got << testme.remove_sentence_punctuation(s)
		end

		assert_equal exp, got, "remove punctuation failed"
	end

	def test_spaces_to_underlines
		sentences = [
			' this is here',
			'that is there ',
			't t'
		]

		exp = [
			'_this_is_here',
			'that_is_there',
			't_t'
		]

		testme = Idealizer.new
		got = []
		sentences.each do | s |
			got << testme.spaces_to_underlines(s)
		end

		assert_equal exp, got, "spaces->underlines failed"
	end

	def test_de_sentence
    sentences = [
			'This is here.',
			' that iS There . ',
			'T t,'
		]

		exp = [
			'this is here',
			'that is there ',
			't t'
		]

		testme = Idealizer.new
		got = []
		sentences.each do | s |
			got << testme.de_sentence(s)
		end

		assert_equal exp, got, "de-sentence failed"

	end
end
