
# = DESCRIPTION
#
# A mixin module for quick system sketches.
# A class can include Catchall in order to answer all as-yet undefined
# method calls.  Catchall::AutoObject instances, which also have the Catchall mixin, are
# returned from undefined methods, so a faked-out object automatically has all
# the depth it needs.
#
module Catchall

	def method_missing(mname=nil, *args)
		args.map! do |x| x.inspect end
		arglist = args ? args.join(', ') : ""
		blocktext = block_given? ? " {__block__}" : ""
	  puts "Catchall<#{self.class.name}>.#{mname}(#{arglist})#{blocktext} from #{caller[0]}" 
		return AutoObject.new( self.class.name, mname, args, caller[0])
	end

	# = DESCRIPTION
	# An object that has Catchall mixed in.  Used by Catchall as a return value for
	# undefined methods.
	# 
	class AutoObject
		include Catchall
		def initialize(pSrc_classname=nil, pMethod_name=nil, pArgs=nil, pCall_orig=nil)
		  @src_classname = pSrc_classname
			@method_name = pMethod_name
			@args = pArgs
			@call_orig = pCall_orig
		end
		
		def to_s
			"<AutoObject,#{@src_classname}, from #{@call_orig}>"
		end
	end
end

#class Dave
#  include Catchall
#end

#d = Dave.new
#clist = d.courses
#clist.each do |x|
#  puts "Course: #{x.inspect}"
#end
#d.this.is.a.long("series", "of").chained{ |method| }.calls

