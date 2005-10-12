$LOAD_PATH << File.dirname(__FILE__) + '/lib'
require 'watir'
require 'watir/watir_simple'
require 'soap/rpc/standaloneServer'
require 'fileutils'
require 'systir'

class PizzaHelper
  include Systir::Helper
  include Watir::Simple
	include Test::Unit::Assertions
  
	def initialize(driver)
    super
		assert_shown if self.respond_to?('assert_shown')
    @watir = @@browser
	end
end

class PizzaDriver < Systir::LanguageDriver

  SITE_URL = 'http://localhost:4444/'

  include Watir::Simple

	def setup
    delete_pizza_queue
    new_browser_at SITE_URL
		@watir = @@browser
    @watir.defaultSleepTime = 0.5
		@watir.typingspeed = 0.1
	end

	def helper(helper_sym)
		return self.class.const_get(helper_sym.to_s).new(self)
	end

	def teardown
		close_browser
	end
end

require 'pizza_demo'