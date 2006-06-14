require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

task :default => [ :testall ]

desc "Run the unit tests in test/unit"
Rake::TestTask.new("testall") do |t|
	t.libs << "test"
	t.pattern = 'test/**/*_test.rb'
	t.verbose = true
end

Rake::RDocTask.new do |rdoc|
	rdoc.rdoc_dir = 'doc'
	rdoc.title    = "CMock: Expectation-based mock object library " 
	rdoc.options << '--line-numbers' << '--inline-source' << '-A cattr_accessor=object'
	rdoc.rdoc_files.include('lib/**/*.rb')
end

desc "Set version number"
task :set_version do
	version = ENV['version']
	raise "Please specify version" unless version

	proj_root = File.expand_path(File.dirname(__FILE__))

	systir_file = proj_root + "/lib/systir.rb"
	systir_source = File.read(systir_file) 
	File.open(systir_file,"w") do |f|
		f.write systir_source.sub(/VERSION\s*=\s*'.*?'/, "VERSION = '#{version.strip}'")
		puts "Wrote #{systir_file}"
	end
	sh %|svn ci #{systir_file} -m "Setting version to #{version}"|
end

desc "Create a release tar.gz file."
task :release => [:set_version, :testall] do
	version = ENV['version'].strip
	raise "Please specify version" unless version
	proj_root = File.expand_path(File.dirname(__FILE__))
	require proj_root + '/lib/systir'
	raise "Wrong VERSION written to systir.rb" unless version == Systir::VERSION

	require 'fileutils'
	include FileUtils::Verbose
	begin 
		cd proj_root

		sh 'svn up'
		status = `svn status` 
		raise "Please clean up before releasing.\n#{status}" unless status.empty?

		sh "svn cp . https://bear.atomicobject.com/svn/systir/tags/release-#{version} -m 'Releasing version #{version}'"

		rm_rf 'release'
		mkdir 'release'
		sh "svn export . release/systir-#{version}"
		cd 'release'
		sh "tar cvzf ../systir-#{version}.tar.gz systir-#{version}"
	ensure
		cd proj_root
		rm_rf 'release'
	end
end

