require 'watir'
require 'watir/watir_simple'
require 'soap/rpc/standaloneServer'
$LOAD_PATH << File.dirname(__FILE__) + '/lib'
require 'systir'

class PizzaHelper
  include Watir::Simple
	include Test::Unit::Assertions

	def initialize(watir)
	  @watir = watir
		assert_shown if self.respond_to?('assert_shown')
	end
end

class PizzaDriver < Systir::LanguageDriver
	
  SITE_URL = 'http://localhost:4444/'

  include Watir::Simple
  
	def setup
    #hide_browsers
    new_browser_at SITE_URL
		@watir = @ie
	end

	def helper(helper_sym)
		return self.class.const_get(helper_sym.to_s).new(@watir) 
	end
	
	def teardown
		close_browser
	end

  def goto_login_page
    click_link_with_id 'login_link'
  end
  
  def login
    goto_login_page
    login_page = helper :LoginPage
    login_page.login_as 'karlin'
		@menu_page = helper :MenuPage
  end

  def username_should_be(name)
    @menu_page.assert_username_shown name
  end
  
  def click_on_make_a_pizza   
    @menu_page.make_a_pizza
  end
  
  def add_topping(topping)
    @maker_page = helper :MakePizzaHelper
		@maker_page.add_topping topping
  end

	def go_back
		@watir.back
	end
end

class LoginPage < PizzaHelper

	# The user must login to access Mondo Pizza
  def login_as(user)
    fill_text_field 'login', 'karlin'
    fill_text_field 'password', 'fox'		
    click_button_with_id 'login_button_id'
  end
end

class MenuPage < PizzaHelper

	# Successful login shows the Menu page.
	def assert_shown
		assert_text_in_body 'Welcome'
	end

	# The user name should be shown on the Menu page.
	def assert_username_shown(name)
		assert_text_in_body name
	end

	# The user can select Make a Pizza from the Menu page.
  def make_a_pizza
    click_link_with_id 'make_pizza_link_id'
  end
end

class MakePizzaHelper < PizzaHelper

	# The Make a Pizza link shows a page where the user can make pizzas
	def assert_shown
		assert_text_in_body 'make a pizza'
	end

	def add_topping(topping)
		fill_text_field 'topping_name', topping
    click_button_with_id "add_topping_id"
    assert_text_in_body topping
	end
end

