require File.dirname(__FILE__) + '/config/environment'
require 'rake'
require 'rake/rdoctask'
require 'spec/rake/spectask'

task :default => [ :spec ]

desc "Run all specifications"
Spec::Rake::SpecTask.new('spec') do |s|
	s.spec_files = FileList['spec/*_spec.rb']
	s.spec_opts = %w{ -f s }
end

desc "Generate code coverage statistics from specifications"
Spec::Rake::SpecTask.new('coverage') do |s|
	s.spec_files = FileList['spec/*_spec.rb']
	s.rcov = true
	s.ruby_opts = %w{--exclude ".*vendor\/.*" --exclude ".*config\/.*" --exclude ".*spec\/.*"}
end

Rake::RDocTask.new do |rdoc|
	rdoc.rdoc_dir = 'doc'
	rdoc.title    = 'Systir: System Testing in Ruby'
	rdoc.options << '--line-numbers' << '--inline-source' << '-A cattr_accessor=object'
	rdoc.rdoc_files.include('lib/**/*.rb')
end

desc "Set version number"
task :set_version => :spec do
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

desc "Generate and upload api docs to rubyforge"
task :upload_doc => :rerdoc do
	sh "scp -r doc/* rubyforge.org:/var/www/gforge-projects/systir/"
end

def make_archives
	begin
		proj_root = File.expand_path(File.dirname(__FILE__))
		version = ENV['version'].strip

		cd proj_root
		rm FileList["systir-#{version}.*"]
		rm_rf 'release'
		mkdir 'release'
		sh "svn export . release/systir-#{version}"
		cd 'release'
		sh "tar cvzf ../systir-#{version}.tar.gz systir-#{version}"
		sh "tar cvjf ../systir-#{version}.tar.bz2 systir-#{version}"
		sh "zip -r ../systir-#{version}.zip systir-#{version}"
	ensure
		cd proj_root
		rm_rf 'release'
	end
end

desc "Create release archives"
task :create_archives do
	make_archives
end

desc "Create release files, upload docs to rubyforge, update the version number and tag the release."
task :release => [:set_version, :upload_doc, :spec] do
	version = ENV['version'].strip
	raise "Please specify version" unless version
	proj_root = File.expand_path(File.dirname(__FILE__))
	require proj_root + '/lib/systir'
	raise "Wrong VERSION written to systir.rb" unless version == Systir::VERSION

	require 'fileutils'
	include FileUtils::Verbose
	cd proj_root

	sh 'svn up'
	status = `svn status` 
	raise "Please clean up before releasing.\n#{status}" unless status.empty?

	sh "svn cp . https://bear.atomicobject.com/svn/systir/tags/release-#{version} -m 'Releasing version #{version}'"

	make_archives
end

