require 'watir'
require 'watir_simple'
require 'soap/rpc/standaloneServer'
$LOAD_PATH << File.dirname(__FILE__) + "/lib"
require 'systir'

$siteUrl = "http://localhost:12000/app"

class PizzaDriver < Systir::LanguageDriver
  
  include Watir::Simple
  
	def setup
    #hide_browsers
    new_browser_at $siteUrl
	end

	def teardown
		close_browser
	end

  def goto_login_page
    click_link_with_id "login_page_id"
  end
  
  def login
    goto_login_page
    loginPage = LoginPage.new(@ie)
    loginPage.login_as "karlin"
  end

  def assert_username(name)
    assert_text_in_body name
  end
  
  def click_on_make_a_pizza
    wp = WelcomePage.new(@ie)
    wp.make_a_pizza    
  end
  
  def add_topping(topping)
    fill_text_field "toppings", topping
    click_button_with_id "add_topping_id"
    assert_text_in_body topping
  end
end

class PizzaHelper
  include Watir::Simple
	include Test::Unit::Assertions

	def initialize(ie)
	  @ie = ie
	end
end

class LoginPage < PizzaHelper
  def login_as(user)
    fill_text_field "loginname", "karlin"
    click_button_with_id "login"
  end
end

class WelcomePage < PizzaHelper
  def make_a_pizza
    click_link_with_id "make_pizza_id"
    assert_text_in_body "Just one"
  end
end
