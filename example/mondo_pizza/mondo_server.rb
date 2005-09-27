require 'mini_server'

class MondoPizzaServer < MiniServer

	def index
	end
	
	def login
		user = params['loginname']
		pass = params['password']
		if !user.nil? && Passwd.new[user] == pass then 
			@user = user
			render 'menu'
		end
	end

	def menu
	end
	
	def make
	end

	def queue
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