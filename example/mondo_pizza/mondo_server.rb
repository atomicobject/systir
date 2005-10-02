require 'mini_server'
require 'yaml'
require 'webrick/httputils'
require 'logger'

$log = Logger.new("log.txt")

class MondoPizzaServer < MiniServer
	def index		
	end
	
	def login
		user = params['loginname']
		pass = params['password']
		if !user.nil? && Passwd.new[user] == pass 
			@user = user
			name = user[0...1].upcase + user[1..user.size]
			session[:user_sess] = {:name => name}
			$log.info "User #{name} logged on."
			redirect :menu
		end
	end

	def menu
		@name = session[:user_sess][:name]
	end
	
	def images
		response['content-type'] = 'image/png'
		send File.open('images/'+path_elements[0], 'rb').read
  end

	def make
		session[:user_sess][:toppings] ||= []
		@toppings = session[:user_sess][:toppings]
		if request.query['add_topping'] && request.query['topping_name'] != ''
			topping = request.query['topping_name'].to_s
			session[:user_sess][:toppings] << topping
			$log.info "Adding topping: #{topping}"
			redirect :make
		elsif request.query['make_pizza']
			if !request.query['pizza_name']
				@error_text = 'You must choose a title for your new pizza creation!'
				redirect :make
			end
			pizza = Pizza.new session[:user_sess][:toppings]
			pizza.name = request.query['pizza_name']
			pizza_file = File.open "pizzas/#{pizza.object_id}.pizza", 'w', File::CREAT
			YAML.dump pizza, pizza_file
			pizza_file.close
			$log.info "Wrote new pizza file #{pizza_file.path} with:\n#{pizza.inspect}\n"
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
	
	attr_accessor :name, :toppings, :crust_flavor
	
	def initialize(list)
		@toppings = list or []
	end
	
	def each_topping
		@toppings.each {|t| yield t}
	end
	
end