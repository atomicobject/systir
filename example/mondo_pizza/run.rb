#!/usr/bin/ruby
system "ruby mondo_server.rb&"
system "ruby systest/runtest.rb systest/toppings.test"

