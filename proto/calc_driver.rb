require 'test/system'

#Test::System::BLOCK_ASSERTIONS = true

class DC
	DcProgram = `which dc`

	def initialize 
	  @dbg = nil
	end

	def start
		dbg 'Starting dc process (#{DcProgram}})...'
		@process = IO.popen(DcProgram,'w+')	
		dbg 'dc started ok.'
	end

	def stop
		dbg 'Stopping dc process'
		@process.close if @process
		dbg 'dc process stopped'
	end 

	def put_line(str)
	  @process.puts(str)
	end
	
	def get_line
	  @process.gets.chomp
	end

	def set_precision(dec)
		put_line "#{dec} k P"
	end

	def dbg(msg)
	  puts "#{msg}" if @dbg
	end
end

module DcTestMacros
	def use_precision(dec)
	  @decimal_places = dec
	end

	def verify_expression(expr)
		start_dc
		hand_off_to VerifyExpression.new(expr)
	end

	def assume_stack(as)
	  @assumed_stack = as
	end

	def verify_stack_is(str)
		assert_equal str.split(/\s+/).join(' '), get_stack_string, "Stack in dc not as expected"
	end

	def verify_stack_is(str)
		assert_equal str.split(/\s+/).join(' '), get_stack_string, "Stack in dc not as expected"
	end

end

class CalcDriver < Test::System::Driver
	include DcTestMacros

	def setup
		# Create a new process wrapper for our target dc instance
		@dc = DC.new

		# Bestow a 'should_give' method on String class:
		driver_ref = self
		String.class_eval do
			@@_dc_test_driver = driver_ref
		  def should_give(expect)
				@@_dc_test_driver.verify_expression(self).produces(expect)
			end
		end
	end

	def dc 
		raise "dc calculator not started" unless @dc
	  @dc
	end

	def start_dc
		dc.start
		dc.set_precision(@decimal_places) if @decimal_places
	end


	def send_and_recv(str)
		send str
		recv
	end 

	def send(str)
		begin
			dc.put_line str
		rescue => oops
			raise "Could not send string '#{str}' (#{oops})"
		end
	end

	def recv
		begin
			return dc.get_line.chomp
		rescue => oops
			raise "Could read from calculator (#{oops})"
		end
	end

end

#
# Second-half helper; this class services the second half of verification phrases.
# Instances of VerifyExpression are returned by CalcDriver.verify_expression 
# to provide semantic assistance.
#
class VerifyExpression
  include Test::System::Helper

	def initialize(expr)
	  @expr = expr
	end

	def gives(check_val)
		output = driver.send_and_recv("#{@expr} p")
		assert_equal check_val.to_f, output.to_f, 
		  "expression '#{@expr}' got wrong results"
		puts "Verified '#{@expr}' gives '#{check_val}'"
		driver.dc.stop
	end
	alias_method :produces, :gives

	def gives_assumed_stack
		expected_items = driver.assumed_stack.split(/\s+/)
		expect = expected_items.join(' ')

		driver.send @expr

		# Read lines of output
		arr = []
		expected_items.size.times do 
		  arr << driver.recv
		end
		result = stack.join(' ')
		assert_equal expect, result, "Stack reported by dc is not as expected"
	end

	def gives_nothing
		# TODO driver.recv needs to have a short timeout in a watchdog thread
		# before we can do this got = @driver.send_and_recv @expr
#		assert_nil got, "Should have gotten no output"
	end

end
