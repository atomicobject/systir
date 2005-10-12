Thread.new do
  system "ruby mondo_server.rb"
end	
system "cd systest && ruby all_tests.rb"

