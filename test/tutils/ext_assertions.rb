
#
# Added assertions.
# See "test_ext_assertions.rb"
#
module ExtAssertions

	#
	# Given an array, assert that the given item
	# is included in the list (using the include? method).
	# Fails if the item is not in the array, or if the 
	# given list instance doesn't support 'include?'
	#
	def assert_include(list,item,msg=nil)
		assert_respond_to list, :include?
		assert_block("#{list.inspect} doesn't include #{item.inspect}") do 
		  list.include? item
		end
	end
end

require 'test/unit'
class Test::Unit::TestCase
  include ExtAssertions
end
