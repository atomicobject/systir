class PizzaDriver < Systir::LanguageDriver

  def goto_login_page
    click_link_with_id 'login_link'
		@login_page = helper :LoginPage
  end

  def login
    goto_login_page
    @login_page.login_as 'karlin', 'secret'
		@menu_page = helper :MenuPage
  end
	
	def login_as_invalid_user
		goto_login_page
		@login_page.login_as 'nobody', 'nothin'
	end
	
	def expect_an_invalid_login_error
		@login_page.expect_error(/invalid login/i)
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

class PizzaHelper
	def get_error_span
		return @watir.span(:id, 'error')
	end
end

class LoginPage < PizzaHelper

	# The user must login to access Mondo Pizza
  def login_as(user, pass)
    fill_text_field 'login', user
    fill_text_field 'password', pass
    click_button_with_id 'login_button_id'
  end
	
	def expect_error(message)
		error_span = get_error_span
		assert message.match(error_span.text),
			"could not find error message #{message.to_s}"
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
    span = get_error_span
    assert message.match(span.text)
  end
    
end

class QueuePage < PizzaHelper
  
  # The user can see which pizzas are in the queue
  def number_of_pizzas_should_be(number)
    pizza_divs = @watir.divs.select do |div|
			div.id == 'pizza_name'
		end
		
		assert_equal number, pizza_divs.length, "wrong number of pizzas in queue."
		
		sleep 2
  end
  
  # The user can delete queued pizzas
  def delete_pizza(index)
		find_delete_button_for(index).click
		assert_text
  end
	
  # The user can see the toppings for each pizza
  def toppings_should_be(list)    
    list.each do |topping|
      assert_text_in_body topping
    end
  end
  
end
