require 'config/deps'
require File.expand_path(File.dirname(__FILE__) + '/../helpers/auth_helper_api')
require File.expand_path(File.dirname(__FILE__) + '/../helpers/ssl_helper')
require File.expand_path(File.dirname(__FILE__) + '/../libs/rc4')

class AoGMain < Sinatra::Base
	
	helpers Sinatra::AuthorizationHelper
	helpers Sinatra::SSLHelper
	
	config = YAML.load_file("config/config.yml")
		
	configure :development do
		config['development'].each { |key, value| 
			set :"#{key}", value
		}
	end

	configure :production do		
		config['production'].each { |key, value| 
			set :"#{key}", value
		}
	end
	
	set :root, 		File.expand_path(File.dirname(__FILE__) + "/../")
  	set :views, 	File.expand_path(File.dirname(__FILE__) + "/../views")
	set :public, 	File.expand_path(File.dirname(__FILE__) + '/../../public')
	set :default_locale, 'de'
	enable :static, :sessions, :method_override
	##
	before do
		#@CACHE = Memcached.new
		#@bp = BoxcarAPI::Provider.new(options.boxcar[:provider_key], options.boxcar[:provider_secret])
		Instagram.configure do |config|
			config.client_id = options.instagram[:client_id]
		  	config.client_secret = options.instagram[:client_secret]
		end
		@name = options.name
		@me = request.scheme+"://"+request.host_with_port
		@ayb = AllYourBase::Are.new
	end
	
	get "/" do
		
	  	html = '<a href="/oauth/connect">Connect with Instagram</a><br/><br/>'
		
		html
	end
	
	get "/oauth/connect" do
	  	redirect Instagram.authorize_url(:redirect_uri => @me+options.instagram[:callback])
	end
	
	get "/oauth/callback" do
		encryptor = RubyRc4.new( options.secret )

	  	response = Instagram.get_access_token(params[:code], :redirect_uri => @me+options.instagram[:callback])
		
		# access token wird rc4 verschlüsselt in die URL codiert...
		crypt = encryptor.encrypt_hex( response.access_token )
		crypt.upcase!
	  	access_token = crypt.from_base_16.to_base_62
	  	
	  	redirect "/feed/#{access_token}"
	end
	
	get "/feed/:token" do
		content_type :xml
		
		# access token decrypt
		decryptor = RubyRc4.new( options.secret )
		@token = params[:token]
		@access_token = decryptor.decrypt_hex( params[:token].from_base_62.to_base_16.downcase! )
			
	  	client = Instagram.client(:access_token => @access_token)
	  	@feed = client.user_media_feed
		
		#y @feed
				
		erb :atom		
				
	  	#html = "<h1>your media feed!</h1>"
	  	#for media_item in feed#.user_recent_media
	  		#html << "<img src='#{media_item.images.thumbnail.url}'>"
	  	#	html << "<img src='#{media_item.images.low_resolution.url}'>"
	  	#end
	  	
	  	#html
	end
	
end