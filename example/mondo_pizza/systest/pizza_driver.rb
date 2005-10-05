require 'watir'
require 'watir/watir_simple'
require 'soap/rpc/standaloneServer'
require 'fileutils'
$LOAD_PATH << File.dirname(__FILE__) + '/lib'
require 'systir'

class PizzaHelper
  include Watir::Simple
	include Test::Unit::Assertions

	def initialize
		assert_shown if self.respond_to?('assert_shown')
    @watir = @@browser
	end
end

class PizzaDriver < Systir::LanguageDriver

  SITE_URL = 'http://localhost:4444/'

  include Watir::Simple

	def setup
    #hide_browsers
    delete_pizza_queue
    new_browser_at SITE_URL
		@watir = @@browser
    @watir.set_slow_speed
	end

	def helper(helper_sym)
		return self.class.const_get(helper_sym.to_s).new
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
    @maker_page = helper :MakePizzaPage
  end

  def add_a_topping(topping)
		@maker_page.add_topping topping
  end

  def name_the_pizza(name)
    @maker_page.name_the_pizza name
  end
  
  def make_the_pizza
    @maker_page.make_the_pizza
  end
  
  def expect_pizza_needs_a_name_error
    @maker_page.expect_error(/You must choose/)
  end
  
  def click_on_view_queue
    @menu_page.view_the_queue
    @queue_page = helper :QueuePage
  end
  
  def number_of_pizzas_should_be(count)
    @queue_page.number_of_pizzas_should_be count
  end
  
  def toppings_should_be(*list)
    @queue_page.toppings_should_be list
  end
  
  def delete_pizza_queue
    Dir['../pizzas/*.pizza'].each do |pizza|
      FileUtils.rm_rf pizza
    end
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
  
  # The user can select to view queued pizzas from the Menu page. 
  def view_the_queue
    click_link_with_id 'view_queue_link_id'
  end
end

class MakePizzaPage < PizzaHelper

	# The Make a Pizza link shows a page where the user can make pizzas
	def assert_shown
		assert_text_in_body 'make a pizza'
	end

  # The user can add toppings by entering a topping name and clicking Add
	def add_topping(topping)
		fill_text_field 'topping_name', topping
    click_button_with_id 'add_topping_id'
    assert_text_in_body topping
	end

  # The user will name their pizza
  def name_the_pizza(name)
    fill_text_field 'pizza_name', name
  end
  
  # The user can click a button to make a completed pizza
  def make_the_pizza
    click_button_with_id 'make_pizza_id'
  end
  
  # The user will get an error message when they fail to name a pizza
  def expect_error(message)
    span = @watir.span(:id, 'error')
    assert message.match(span.text)
  end
    
end

class QueuePage < PizzaHelper
  
  # The user can see which pizzas are in the queue
  def number_of_pizzas_should_be(number)
    assert_equal number, @watir.divs.select {|d| d.id == 'pizza_name'}.length,
      "wrong number of pizzas in queue."
  end
  
  # The user can delete queued pizzas
  def delete_pizza(index)
    #TODO
  end
  
  # The user can see the toppings for each pizza
  def toppings_should_be(list)
    #@watir.div(:xpath, "//div[@id='pizza_name']/")
    #names = @watir.divs(:id, 'pizza_name').collect {|d| d.text}
    
    list.each do |topping|
      #assert names.include?(topping)
      assert_text_in_body topping
    end
  end
  
end
