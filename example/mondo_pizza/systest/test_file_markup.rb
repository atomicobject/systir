class TestFileMarkup

	def convert(file)
		lines = File.open(file).readlines
		out = ""
		lines.each do |line|
			line.chomp!
			if line =~ /^\s*$/
				out += "\n"
				next
			end
		
			pieces = split_params remove_sentence_punctuation(line)
			out += spaces_to_underlines(de_sentence(pieces[0]))
			params = unify_quoting(pieces[1])
			out += ' ' + params if params != ''
			out += "\n"
		end
		return out
	end
	
	def remove_sentence_punctuation(str)
		str.sub(/[,\.]$/, '')
	end
	
	def spaces_to_underlines(str)
		str.rstrip.gsub ' ', '_'
	end
	
	# remove caps	
	def de_sentence(str)
		remove_sentence_punctuation(str.downcase.rstrip.lstrip)
	end
	
	def split_params(str)
		m = /[0-9"':]/.match(str)
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
  t = TestFileMarkup.new
	if !ARGV[0]
	  raise "You must supply a filename to convert."
	end

	io = nil
	if ARGV[1]
	  io = File.new(ARGV[1], 'w', File::CREAT)
	else
	  io = STDOUT
	end	
	io.puts t.convert(ARGV[0])
	
end	
	
