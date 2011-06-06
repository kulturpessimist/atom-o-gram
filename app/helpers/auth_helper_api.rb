require 'sinatra/base'
##
# helper module for authorizations based on http basic auth
# @version 1.0
# @author Alex Schedler <as@natureOffice.com>
module Sinatra
  module AuthorizationHelper
    
    ##
    # protects the calling route and shows a login dialog.
    # the execution of the calling route is halted until user is authenticated.
    def protected!
    	response['WWW-Authenticate'] = %(Basic realm="#{options.name}") and \
    	throw(:halt, [401, "Not authorized\n"]) and \
    	return unless authorized?
  	end
	
	##
	# checks if the provided credentials are fitting on the config values
	# @return (boolean) authorized or not authorized
  	def authorized?
    	@auth ||=  Rack::Auth::Basic::Request.new(request.env)
    	@auth.provided? && @auth.basic? && @auth.credentials && session_authorized_nc?(@auth.credentials)
  	end
  	
	##
	# checks if the provided credentials are fitting to a pair in couchdb
	# @param [string] cookie (credentials eg. foo:bar)
	# @param [boolean] log auto log for usage statistic
	# @return [boolean] authorized or not authorized
	def session_authorized?( credentials, log2db=true )
		return false if credentials==[]
		
		begin 
			@couch_client = @CACHE.get(credentials.to_s) || ''
		rescue Exception=>e
			params = { :key => credentials }
			result = @db.view('login/api',params)
			if result["rows"].length > 0
 				@couch_client = result["rows"][0]["value"]
 				@CACHE.set(credentials.to_s, @couch_client)
 				return true
			else
				return false
			end	
		end

		if @couch_client == ''
			return false
		else
			return true
		end
	end
  
  	##
	# checks if the provided credentials are fitting to a pair in couchdb
	# @param [string] cookie (credentials eg. foo:bar)
	# @param [boolean] log auto log for usage statistic
	# @return [boolean] authorized or not authorized
	def session_authorized_nc?( credentials, log2db=true )
		return false if credentials==[]
		
		params = { :key => credentials }
		result = @db.view('login/api',params)
		if result["rows"].length > 0
			@couch_client = result["rows"][0]["value"]
			return true
		end	

		return false
	end
  end

  helpers AuthorizationHelper
end