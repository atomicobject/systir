
# A simple english-to-test-script converter
#
# Example:
#  >ruby test_file_markup.rb 
class Idealizer
	def convert(file)
		lines = File.open(file).readlines
		out = ""
		@in_block = false
		lines.each_with_index do |line, i|
			line.chomp!
			if line =~ /^\s*$/
				out += "\n"
				next
			end


		
			# Detect input indentation before we horse this line:
			indented = line =~ /^\s+/
			end_block out  if @in_block and !indented

			pieces = split_params remove_sentence_punctuation(line)
			block_starter = pieces[-1] =~ /do\s*$/

			newline = spaces_to_underlines(de_sentence(pieces[0]))

			# Dig the params
			params = unify_quoting(pieces[1])
			newline += ' ' + params if params != ''

			# Indentation
			indent = @in_block ? "  " : ""

			# Append new line to output
			out += "#{indent}#{newline}\n";

			# Was that a block starter line?
			if block_starter
				@in_block = true
			end
		end
		end_block(out) if @in_block
		return out
	end
	
	def remove_sentence_punctuation(str)
		str.gsub!(/[:]$/, ' do')
		str.gsub!(/[,\.]$/, '')
		str.gsub!(/[:]/, '')
		str
	end
	
	def spaces_to_underlines(str)
		str.rstrip.gsub /\s/, '_'
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

	def end_block(str)
		str.chop!
		str << "; end\n"
		@in_block = false
	end

end

if __FILE__ == $0
  converter = Idealizer.new
	
  if !ARGV[0]
	  raise "You must supply a filename to convert."
	end
  
	output = ARGV[1] ? File.new(ARGV[1], 'w', 0644) : STDOUT
	
  output.puts converter.convert(ARGV[0])

	output.close
end	
	
