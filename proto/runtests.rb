#!/usr/bin/ruby

require 'test/system'
require 'calc_driver'

one_script=nil

while arg = ARGV.shift
	case arg
		when '-p'
			Test::System::ALLOW_MISSING_methods = true
		  Test::System::BLOCK_ASSERTIONS = true
		when '-f'
		  one_script = ARGV.shift
		else 
			STDERR.puts "Unrecognized option: #{arg}"
	end
end

if one_script
  Test::System::Launcher.run_test(CalcDriver,one_script)
else
	Test::System::Launcher.find_and_run_all_tests(CalcDriver, '.')
end
