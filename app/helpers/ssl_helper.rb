require 'sinatra/base'
##
# Helper module for enforcing and checking for ssl connections
# @version 0.6.211
# @author Alex Schedler <as@natureOffice.com>
module Sinatra
  module SSLHelper
    
    ## 
    # redirects the user to browsed page via ssl 
    def secure!
		redirect "https://"+request.env["HTTP_HOST"]+request.env["PATH_INFO"]
  	end

	##
	# checks if the "force_ssl" option is set.
	# @return [boolean] value of options.force_ssl
  	def require_ssl?
	  	# change later to request.secure?
		if !( (@env['HTTP_X_FORWARDED_PROTO'] || @env['rack.url_scheme']) == 'https' )
			if options.force_ssl
				p "ssl is required!"
				return true
			end
		end
		return false
  	end
  end

  helpers SSLHelper
end