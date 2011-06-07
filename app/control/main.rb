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
		require_ssl?
		Instagram.configure do |config|
			config.client_id = options.instagram[:client_id]
		  	config.client_secret = options.instagram[:client_secret]
		end
		@name = options.name
		@google_analytics = options.google_analytics
		@ayb = AllYourBase::Are.new
	end
	
	get "/" do	
		erb :main
	end
	
	get "/oauth/connect" do
		# go on...
	  	redirect Instagram.authorize_url(:redirect_uri => options.instagram[:callback])
	end
	
	get "/oauth/callback" do
		#load the objects...
		encryptor = RubyRc4.new( options.secret )
	  	response = Instagram.get_access_token(params[:code], :redirect_uri => options.instagram[:callback])
		# crypt token with rc4 and place it in URL...
		crypt = encryptor.encrypt_hex( response.access_token )
		crypt.upcase!
	  	access_token = crypt.from_base_16.to_base_62
	  	# go on...
	  	redirect "/feed/#{access_token}"
	end
	
	get "/feed/:token" do
		content_type :xml
		
		# access token decrypt
		decryptor = RubyRc4.new( options.secret )
		@token = params[:token]
		@access_token = decryptor.decrypt_hex( params[:token].from_base_62.to_base_16.downcase! )
		# initiate the client
	  	client = Instagram.client(:access_token => @access_token)
	  	# gather some user infos
	  	user = client.user
	  	@username = user.username
	  	@profile = user.profile_picture
	  	#load the feed
	  	@feed = client.user_media_feed
		# render the atom
		erb :atom		
	end
	
end