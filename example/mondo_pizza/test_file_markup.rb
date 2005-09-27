class TestFileMarkup

	def convert(file)
		lines = File.open(file).readlines
		out = ""
		lines.each do |line|
			unless line =~ /^\s*$/
				pieces = split_params remove_sentence_punctuation(line)
				out += spaces_to_underlines(de_sentence(pieces[0]))
				params = unify_quoting(pieces[1])
				out += ' ' + params if params != ''
			end
			out += "\n"
		end
		puts out
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