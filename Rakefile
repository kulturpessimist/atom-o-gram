require 'rubygems'
require 'memcached'
require 'jsdoc'
Dir["#{File.dirname(__FILE__)}/lib/tasks/**/*.rake"].sort.each { |ext| load ext }

desc 'Start a development server'
task :server do
	if system "which shotgun"
		exec 'shotgun config.ru -o 10.0.1.30 -O'
	else
		warn 'warn: shotgun not installed; reloading is disabled.'
		exec 'ruby -rubygems docs.rb -p 9393'
	end
end

namespace :dev do
	
	task :version do
  		f = File.read('config/config.yml')
  		@version = f.match(/VERSION: \&version ([\d\w\.]+)/)[1]
  		puts "VERSION: " + @version
	end
	
	desc 'update the current version # in the pages'
	task :update_version => :version do
		Dir['app/**/*.*'].each do |file|
		    File.open(file, 'r+') do |f|
		    	contents = f.read
		    	contents.gsub!(/# @version ([\w\d\.]+)/, "# @version #{@version}")
		    	f.truncate(0)
		    	f.rewind
		    	f << contents
		    end
		end
	end

	desc 'Tag with the current version'
	task :tag => :version do
  		sh "git add ."
  		sh "git commit -a -m'Pushing version #{@version}'"
  		sh "git tag v#{@version}"
  		sh "git push --tags"
	end
	
	desc "generate documentation with jsdoc"
	task :jsdoc do
		system 'jsdoc ./jsdoc public/js/apps/*'
	end
	
	desc "bundle javascript"
	task :jim do
		system 'jim bundle'
		system 'jim compress'
	end
	
	desc "generate docs"
	task :docs do
		system 'yardoc -o doc/ app/**/*'
		system 'open doc/index.html'
		p "ok! rtfm!"
	end

	task :build => [:version, :update_version, :jim]
	
end

namespace :naturebalance do
	
	desc "default task"
	task :default do
		p "rake runs"
	end

	desc "flush memcache"
	task :flush do
		cache = Memcached.new
		cache.flush
		p "everything is flushed."
	end
	
end