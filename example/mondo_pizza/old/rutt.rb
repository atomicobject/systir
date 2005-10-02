
#
# Primitive template engine
#
module Rutt
  class Template
    def initialize(filename)
      @fname = filename
			@vars = {}
    end

    def [](key)
      @vars[key]
		end
    def []=(key,val)
      @vars[key] = val
		end

    def process
			@text = File.read(@fname)
			#@text.gsub!("\"", "\\\\""
			@vars.keys.each do |k|
        if !@vars[k] then
          @vars[k]=""
        end
			    @text.gsub!(/\$#{k}/, @vars[k])
         
			end
			return @text
    end
  end
end


