
#= DESCRIPTION
#The Bogus extension allows you partially mock a class or object
#by mocking specifc methods and leaving other functionality in place.
#
#Note that you perform bogification at the class or instance level.
#When possible you should bogify methods on a specific instance - this reduces
#the potential for test interaction.
#
#When you 'bogify' one or more methods, your object gets some new properties.
#You also get three method-specific add-ons.  These are for instrumenting return values,
#thrown symbols or raised errors.  For example, if you bogified +read+, you'll get:
#
#+_calls+        :: array which tracks the names of called methods
#+_args+         :: tracks arguments for each corresponding call in +_calls+. Each entry is an array.
#+_read_returns+ :: the return value for the +read+ method
#+_read_throws+  :: a symbol that +read+ will now throw
#+_read_raises+  :: an error that +read+ will now raise
#
#'throw' will override 'raise'; 'raise' will override 'return'
# 
#= EXAMPLES 
#
#== Class-level example:
#
#  class BogusTCPSocket
#    extend Bogus
#  
#    bogify :gethostbyname
#  end
#
#  sock = BogusTCPSocket.new("host",port)
#  sock._gethostbyname_return = "hi there"
#  h = sock.gethostbyname("findme")
#
#  assert_equal 1, sock._calls.size, 'Call count wrong'
#  assert_equal 'gethostbyname', sock._calls[0]
#  assert_equal ['findme'], sock._args[0]
#  assert_equal 'hi there', h
#
#== Instance-level example:
#
#  s = Socket.new
#  s.extend Bogus
#  s.bogify :read, :write
#
#
module Bogus
	#== Description
	#Bogify one or more methods.  Can be called on an instance that has extended Bogus
	#or within the body of a class declaration.
	#
	#== Arguments
	#+method_names+:: one or more symbols corresponding to method names
	#
  def bogify(*method_names)
    use_method = :class_eval
    unless self.kind_of? Class
      use_method = :instance_eval
    end

    method_names.each do |mname|
      new_code =<<-MARK
        def #{mname}(*args)
          @_calls ||= []
          @_args ||= []
          @_calls << :#{mname}
          @_args << args

          throw @_#{mname}_throws if @_#{mname}_throws
          raise @_#{mname}_raises if @_#{mname}_raises
          return @_#{mname}_return
        end

        def _#{mname}_return
          return @_#{mname}_return
        end

        def _#{mname}_return=(nv)
          return @_#{mname}_return = nv
        end

        def _#{mname}_throws=(sym)
          return @_#{mname}_throws = sym
        end

        def _#{mname}_raises=(err)
          return @_#{mname}_raises = err
        end
      MARK

      self.send(use_method, new_code)
    end

    trackers =<<-MARK
      def _calls
        @_calls
      end
      def _args
        @_args
      end
    MARK
    self.send(use_method, trackers)
  end

  #==Description
  #Replace the named instance method with the functionality 
  #of the given code block. 
	#If the given method doesn't exist, one will be created.
	#
  #If you're redefining a method that accepts blocks, the code block
  #you've written to represent the new functionality must accept 
  #as its first param an argument that represents a Proc instance.
  #(You can't use 'yield' in that circumstance.)
  #
	#==Example
  #To create a method called 'each_thing': 
  #
  #  obj = Object.new.extend Bogus
  #
  #  obj.rewrite(:each_thing) do |block|
  #    ['a','b','c'].each do |x|
  #      block.call x
  #    end
  #  end
  #
  #  str = ""
  #  obj.each_thing do |val|
  #    str << val
  #  end
  #  assert_equal "abc", str, "String improperly made"
  #
	#==Arguments
	#+method_name+:: name of the method to redefine
	#(block):: the functionality to use in the new definition
	#
  def rewrite(method_name)
    raise "rewrite() can only be used on instances" if self.kind_of? Class
    mname = method_name.to_s
    @_rewrites ||= {}
    @_rewrites[method_name.to_s] = Proc.new
     new_code =<<-MARK
      def #{mname}(*args)
        if block_given?
          @_rewrites['#{mname}'].call(Proc.new, *args) 
        else
          @_rewrites['#{mname}'].call(*args) 
        end
      end
    MARK
    self.instance_eval(new_code)
  end
end
