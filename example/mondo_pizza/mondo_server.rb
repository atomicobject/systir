require 'mini_server'
require 'yaml'
require 'webrick/httputils'
require 'logger'

$log = Logger.new("log.txt")

class MondoPizzaServer < MiniServer
	def index		
	end
	
	def login
		@login_error = nil
		if params['login']
			user = params['loginname']
			pass = params['password']
			if !user.nil? && Passwd.new[user] == pass 
				@user = user
				name = user[0...1].upcase + user[1..user.size]
				session[:user_sess] = {:name => name}
				$log.info "User #{name} logged on."
				redirect :menu
			else
				@login_error = "Couldn't log you in.  Please try again."
				redirect :login
			end
		end
	end

	def menu
		if session[:user_sess].nil?
			redirect :login
		end

		@name = session[:user_sess][:name]
	end
	
	def images
		response['content-type'] = 'image/png'
		send File.open('images/'+path_elements[0], 'rb').read
  end

	def make
		if session[:user_sess].nil?
			redirect :login
		end
		
		@error_text = nil
		session[:user_sess][:toppings] ||= []
		@toppings = session[:user_sess][:toppings]
		if params['add_topping'] && params['topping_name'] != ''
			topping = request.query['topping_name'].to_s
			session[:user_sess][:toppings] << topping
			$log.info "Adding topping: #{topping}"
			redirect :make
		elsif request.query['make_pizza']
			if request.query['pizza_name'] == ''
				@error_text = 'You must choose a title for your new pizza creation!'
				$log.info 'Pizza with blank name was attempted.'
				render 'make'
			end
			pizza = Pizza.new(session[:user_sess][:toppings])
			session[:user_sess][:toppings] = []
			pizza.name = request.query['pizza_name'].to_s
			pizza.make
			redirect :menu
		end
	end

	def queue
		@pizzas = []
		Dir['pizzas/*.pizza'].each do |pizza_file|
			next if pizza_file.nil?
			@pizzas << YAML.load_file(pizza_file)
		end
		$log.info "Found #{@pizzas.inspect}"
	end

	def delete
		pizza_file = Pizza.generate_path(path_elements[0])
		$log.info "Deleting  pizza #{pizza_file} from disk."
		if File.exists?(pizza_file)
			success = File.delete pizza_file
			$log.info "Success" if success
		end
		redirect :queue
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
	
	attr_accessor :name, :toppings, :pizza_id
	
	def initialize(list)
		if list then
			@toppings = list
		else
			@toppings = []
		end
	end
	
	def each_topping
		@toppings.each {|t| yield t}
	end

	def generate_path
		"pizzas/#{@pizza_id}.pizza"
	end

	def Pizza.generate_path(obj_id)
		"pizzas/#{obj_id}.pizza"
	end
	
	def make
		@pizza_id = self.object_id
		pizza_file = File.new(self.generate_path, File::CREAT|File::TRUNC|File::RDWR)
		$log.info "Making #{@pizza_id}.pizza..."
		YAML.dump self, pizza_file
		$log.info "Wrote new pizza file #{pizza_file.path} with:\n#{self.inspect}\n"
		pizza_file.close
	end
end