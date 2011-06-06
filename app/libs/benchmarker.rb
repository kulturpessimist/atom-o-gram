require 'sinatra/base'
##
# module to implement all functions needed for benchmarker
# @version 0.7.304
# @author Alex Schedler <as@natureOffice.com>
module Sinatra
	module Benchmarker
    	module Helpers
		   	##
		    # returns the benchmark result in ms
		  	def bench 
    			return (((Time.now.to_f-@start_benchmarker)*1000*100).round.to_f/100).round
  			end
  			
  			def bench_head
				headers  "nb-bench" => bench.to_s
  			end
		end
		  
  		def self.registered(app)
	    	app.helpers Benchmarker::Helpers
			##
			# initialize benchmarker start time
			app.before do
				@start_benchmarker = Time.now.to_f
			end
		end
	end
  
  	register Benchmarker
end