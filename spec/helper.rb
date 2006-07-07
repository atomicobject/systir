
require File.dirname(__FILE__) + '/../config/environment'
require 'systir'
require 'spec'

class ShaqDriver < Systir::LanguageDriver
	def setup
		assert true
	end

	def teardown
		assert true
	end
end

