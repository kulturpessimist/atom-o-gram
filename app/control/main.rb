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
		@me = request.scheme+"://"+request.host_with_port
		@rc4 = RubyRc4.new( options.secret )
	end
	
	get "/" do
		crypt = @rc4.encrypt_url_safe('Kno brings textbooks to iPad, millions of children now dread getting Apple tablet for Christmas')
		decrypt = "jeferj7d1ekmskxtya60beuf3nvcwxj7xv2wtj33w9rip0c8es7mg6a9zlmwq656dcqqn2z93skxqg7hiyweofc96nsvgbmw558h1e7iugcwtynbxscpdpcfnalhttcx9zqa3ec9t0etif3temb"
	
	  	html = '<a href="/oauth/connect">Connect with Instagram</a><br/>'
		html += @rc4.encrypt('Kno brings textbooks to iPad, millions of children now dread getting Apple tablet for Christmas')+"<br/>"
		html += crypt+"<br/>"
		html += ('%024x' % crypt.to_i(36))+"<br/>"
		
		html += @rc4.decrypt_url_safe(decrypt)+"<br/>"
		
		html
	end
	
	get "/oauth/connect" do
	  	redirect Instagram.authorize_url(:redirect_uri => @me+options.instagram[:callback])
	end
	
	get "/oauth/callback" do
	  	response = Instagram.get_access_token(params[:code], :redirect_uri => options.instagram["callback"])
	  	session[:access_token] = response.access_token
	  	# access token wird rc4 verschlüsselt in die URL codiert...
	  	redirect "/feed"
	end
	
	get "/feed" do
	  	client = Instagram.client(:access_token => session[:access_token])
	  	user = client.user
	
	  	html = "<h1>#{user.username}'s recent photos</h1>"
	  	for media_item in client.user_recent_media
	  		html << "<img src='#{media_item.images.thumbnail.url}'>"
	  	end
	  	
	  	html
	end
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	def cached_loockup id
		begin 
			result = @CACHE.get(id.to_s) || ''
			return result
		rescue Exception=>e
			p "** no cached version of "+id+" available **"
			result = @db.get(id)
			if result["_id"].length > 0
 				@CACHE.set(id, result)
 				return result
			else
				return {}
			end	
		end
	end

	
end