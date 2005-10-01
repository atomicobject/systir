require 'mini_server'
require 'yaml'

class MondoPizzaServer < MiniServer
	def index
		
	end
	
	def login
		user = params['loginname']
		pass = params['password']
		if !user.nil? && Passwd.new[user] == pass 
			@user = user
			name = user[0...1].upcase + user[1..user.size]
			flash[:username] = name
			redirect :menu
		end
	end

	def menu
		@name = flash[:username]
	end
	
	def images
    @response.content_type = 'image/jpeg'
		file = path_elements[0]
		puts "Image file: #{file}"
		if File.exist?(file)
			send File.read(file)
		end
  end

	def make
		session[:toppings] ||= [['ham']]
		@toppings = session[:toppings]
		if request.query['add_topping'] && request.query['topping_name'] != ''
			session[:toppings] << request.query['topping_name'].to_s
			redirect :make
		elsif request.query['make_pizza']
			pizza = Pizza.new session[:toppings]
			pizza_file = File.open "pizzas/#{pizza.object_id}.pizza", 'w', File::CREAT
			YAML.dump pizza, pizza_file
			redirect :menu
		end
	end

	def queue
		@pizzas = []
		Dir['pizzas/*'].each do |pizza_file|
			@pizzas << YAML.load_file(pizza_file)
		end
	end
end

class Passwd
	def initialize
		@passwd = {}
		passwd_file = File.open "passwd"
		passwd_file.each do |pass|
			l, p = pass.split
			@passwd[l] = p
		end
	end

	def [](login)
		@passwd[login]
	end
end

class Pizza
	
	attr_accessor :toppings, :crust_flavor
	
	def initialize(list)
		@toppings = list or []
	end
	
	def each_topping
		@toppings.each {|t| yield t}
	end
	
end