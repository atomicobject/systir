require 'webrick'
require 'erb'
require 'logger'
$log = Logger.new("log.txt")

#
# mini_server.rb
#
# Quick-n-dirty framework for writing standalone webapps in the fastest
# possible way.
# 
# 

class Framework
  def initialize(server_factory)
    @server_factory = server_factory
		@global_session = { :flash => Flash.new }
  end

  def launch
    @s = WEBrick::HTTPServer.new( :Port => 4444 )
		@s.mount_proc "/favicon.ico" do end
    @s.mount_proc '/' do |req,res|
      @mini_server = @server_factory.create_instance
			@global_session[:flash].tick # age and purge 
      res['content-type'] = nil
      res.body = nil

      path_elements = req.path.split(/\//)
      path_elements.shift
      entry = path_elements.shift
      unless entry and @mini_server.respond_to?(entry)
        entry = "index"
      end

      @mini_server.setup
      @mini_server.request = req
      @mini_server.response = res
      @mini_server.session = @global_session
      @mini_server.path_elements = path_elements

      catch :done do 
				@mini_server.class.before_filters.each do |bf|
					unless bf.except?(entry)
						eval "@mini_server.#{bf.method}"
					end
				end
        eval "@mini_server.#{entry}"
      end
      unless @mini_server.output
        catch :done do
          @mini_server.render(entry)
        end
      end

      res['content-type'] ||= "text/html"
			puts res['content-type']
      res.body ||= @mini_server.output
      @mini_server.reset
    end
    @s.start
  end

  def shutdown
    @s.shutdown
  end

	class Flash
		Entry = Struct.new('Entry',:key,:value,:age)

		def initialize
			@vars = {}
		end

		def []=(k,v)
			@vars[k] = Entry.new(k,v,0)
		end

		def [](k)
			@vars[k].value if @vars[k]
		end

		def tick
			@vars.values.each do |ent|
				if ent.age >= 1
					@vars.delete ent.key
				else
					ent.age += 1
				end
			end
		end
	end

end

class MiniServer
  attr_accessor :request, :response, :session, :path_elements
  attr_accessor :output

  @@layout_sym = :layout
	@@user_class = nil
	@@user_src_file = nil

  def self.inherited(c)
    @@user_class = c
		file = ''
    pieces = caller[0].split(/:/)
		pieces.each_index do |i|
			case i
				when pieces.size - 2
					file += pieces[i]
				when pieces.size - 1
				else
					file += pieces[i] + ":"
			end
		end
    @@user_src_file = file
  end

  def self.create_instance
		
    load @@user_src_file if @@user_src_file
		if @@user_class
			return @@user_class.new 
		else
			return MiniServer.new
		end
  end

  def self.layout(sym=nil)
    @@layout_sym = sym unless sym.nil?
    @@layout_sym
  end

	class BeforeFilter
		attr_reader :method
		def initialize(mname,options={})
			@method = mname.to_s
			@options = options
		end
		# Is the given action excepted from the filtering?
		def except?(action)
			setting = @options[:except]
			item = action.to_sym
			setting == action.to_sym or (setting and setting.kind_of?(Array) and setting.member?(:action.to_sym))
		end
	end

	def self.before_filter(mname, options={})
		@@before_filters ||= []
		@@before_filters << BeforeFilter.new(mname,options)
	end

	def self.before_filters
		@@before_filters ||= []
	end

  def initialize
  end

  def setup
    @layout_name = self.class.layout.to_s
  end

  def reset
    @@layout_sym = :layout
  end

  def layout(sym)
    @layout_name = sym.to_s
  end

  def layout_template
    unless @layout_name.nil?
      tname = template_filename(@layout_name)
      if File.exist?(tname)
        return ERB.new(File.read(tname))
      else
        puts "MiniServer layout FAILED: no such file '#{tname}'"
      end
    end
    return ERB.new(%|<html><body><%= @main_content %></body></html>|)
  end

  def template_filename(str)
    str += '.rhtml' unless str =~ /\.[^\.]+$/
    str
  end

  def render(filename)
    filename = template_filename(filename)
    if File.exist?(filename)
      erb = ERB.new(File.read(filename))
      @main_content = erb.result(binding)
    else
      @main_content = %|<h1>Error: No template '#{filename}'</h1>|
    end
    @output = layout_template.result(binding)
    throw :done
  end

  def send(txt)
    @output = txt
    throw :done
  end

	def redirect(action)
		response.set_redirect WEBrick::HTTPStatus::Found, "/#{action.to_s}"
	end
  	
	def params
		@request.query
	end

	def cookies
		CookieWrapper.new(request,response)
	end

	class CookieWrapper
		def initialize(req,res)
			@request = req
			@response = res
		end
		def []=(k,v)
			@response.cookies << WEBrick::Cookie.new(k.to_s,v)
		end

		def [](k)
			ck = @request.cookies.find do |c| c.name == k.to_s end
			if ck
				return ck.value
			else
				return nil
			end
		end
	end

	def flash
		session[:flash]
	end

	def log(msg)
		puts "[#{Time.now}] #{msg}"
	end

  def index 
    miniserver_help
  end

  def miniserver_help
    send %|<html><head><title>Welcome to MiniServer</title></head>
    <body><h1>Welcome to MiniServer</h1>
    <p>
    <code>mini_server.rb<code> is a mini-framework for chucking together the
    quickest, dirtiest webapps ever.
    <p>
<pre>
require 'mini_server'

class RealQuickServer &lt; MiniServer
  def index
  end

  def another_url
  end
end
</pre>
    <p>
    That's all; magic <code>at_exit</code> will detect your class and launch it 
    in the framework on port 4444.
    <p>
    By default, the framework will invoke the method that corresponds to the first
    step in the request path.  Output is generated by invoking ERB against the 
    template file that matches the name of the method.  Eg, <code>index.rhtml</code>
    or <code>another_url.rhtml</code>.  The template is invoked with a binding to the
    current instance of your class so you get all your instance vars.
    <p>
    You can select a different template by invoking <code>render :some_other_file</code>.
    <p>
    Furthermore, you get a layout.
    The layout template is <code>layout.rhtml</code> by default but this can be 
    configured at the class and method levels using <code>layout :some_layout</code>.
    <p>
    Hitting <code>http://localhost:4444/index</code> and
    <code>http://localhost:4444/anoter_url</code> will invoke the respective
    instance methods in your server class.  
    </body></html>
    |
  end
end

at_exit do 
  $FW = Framework.new(MiniServer)
  trap("INT") do 
    $FW.shutdown 
  end
  $FW.launch
end
  

