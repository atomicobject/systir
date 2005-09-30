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
			redirect :menu
		end
	end

	def menu
	end
	
	def make
		session['toppings'] ||= [['ham']]
		@toppings = session['toppings']
		#if request.query['add_topping']
			#request.session['toppings'] += request
			
			#pizza = Pizza.new request.session['toppings'] += request.query['
			#YAML.dump pizza, pizza_file
		#end
	end

	def queue
		@pizzas = [Pizza.new]
	end
end

class Passwd
	def initialize
		@passwd = {}
		File.open("passwd").each do |pass|
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
	
	def initialize
		@toppings = []
	end
	
	def each_topping
		@toppings.each {|t| yield t}
	end
	
end