#!/usr/local/bin/ruby
require 'webrick'
require 'rutt'

class BaseServlet < WEBrick::HTTPServlet::AbstractServlet
	OK = 200
  #
	# Bootstrap
	#
  def do_GET(request, response)
    status, body = handle request
    response.status = status
    response['Content-Type'] = 'text/html'
    response.body = body
  end
	alias_method :do_POST, :do_GET
  
	#
	# request dispatcher
	#
  def handle(request)
		pi = request.path_info
		if pi =~ /\/(.+)/
			fname = "handle_#{$1}"
			if self.respond_to?(fname) then
			  return eval("handle_#{$1} request")
			else
				return 404,"#{fname} not supported."
			end
		else 
			return handle_default request
		end
  end
	
	#
	# Default redirect page
	#
	def handle_default(request)
    return 200, "<html><body><a href='/app/login' id='login_page_id'>Login Page</a></body></html>"
	end

	#
	# Home page
	#
	def handle_home(request)
	  page = Rutt::Template.new("welcome.html")
		page['username'] = 'Karlin'

		return OK, page.process
	end

	#
	# Login page
	#
	def handle_login(request)
		login_page = Rutt::Template.new("login.html")
		case request.query['loginname']
		  when 'karlin'
				return handle_home(request)
			when nil
				login_page['error_field'] = ''
			else
				login_page['error_field'] = "Access Denied!"
		end	

		return OK, login_page.process
	end
  
  #
  # Pizza Page
  #
  def handle_pizza(request)
    pizza_page = Rutt::Template.new("pizza.html")
    if request.query['make_pizza'] then
      #process pizza form
      toppings = request.query['toppings']
      #assign form vars
      pizza_page['toppings'] = toppings
    end
    pizza_page['toppings'] = toppings
    return OK, pizza_page.process
  end
  
  #
  # Contact Page
  #
  def handle_contact(request)
    return OK, "<html>Please do not contact us.<br>We will contact you.</html>"
  end
end


if $0 == __FILE__ then
  server = WEBrick::HTTPServer.new(:Port => 12000)
  server.mount "/app", BaseServlet
  trap "INT" do 
		pid = $$
#		puts "AAAAAAYYYYYYEEEEEEEEEE!!!!"
		`kill -9 #{pid}`
	end
  server.start
end

