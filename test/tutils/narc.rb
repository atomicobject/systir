
module Narc
	def __get(var)
		self.instance_eval("@#{var}")
	end

	def __set(var, val)
		self.instance_eval("@#{var}=val")
	end
end
