
# A simple english-to-test-script converter
#
# Example:
#  >ruby test_file_markup.rb 
class TestFileMarkup
	def convert(file)
		lines = File.open(file).readlines
		out = ""
		lines.each_with_index do |line, i|
			line.chomp!
			if line =~ /^\s*$/
				out += "\n"
				next
			end
		
			pieces = split_params remove_sentence_punctuation(line)
			out += spaces_to_underlines(de_sentence(pieces[0]))
			params = unify_quoting(pieces[1])
			out += ' ' + params if params != ''
      
      #TODO:  Try to detect blocks
      #if line =~ /^\s+/ && lines[i+1] =~ /^[^\s]/
      #  out += "\nend\n"
      #elsif line =~ /^[^\s]/ && lines[i+1] =~ /^\s+/
      #  out += " do\n"
      #else      
        out += "\n"
      #end
      
		end
		return out
	end
	
	def remove_sentence_punctuation(str)
		str.sub(/[,\.]$/, '')
	end
	
	def spaces_to_underlines(str)
		str.rstrip.gsub /\s/, '_'
    #str.gsub /^_*/, ' '
	end
	
	# remove caps	
	def de_sentence(str)
		remove_sentence_punctuation(str.downcase.rstrip.lstrip)
	end
	
	def split_params(str)
		m = Regexp.new("[0-9\"':]").match(str)
		if !m.nil? then 
			i = m.offset(0)[0]
			return str[0...i], str[i..str.size]
		else
			return str, ''
		end
	end

	def unify_quoting(str)
		str.gsub '"', '\''
	end

end

if __FILE__ == $0
  converter = TestFileMarkup.new
	
  if !ARGV[0]
	  raise "You must supply a filename to convert."
	end
  
	output = ARGV[1] ? File.new(ARGV[1], 'w', 0644) : STDOUT
	
  output.puts converter.convert(ARGV[0])
	output.close
end	
	
