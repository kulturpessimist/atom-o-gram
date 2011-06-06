class RubyRc4
  
  def initialize(str)
    @q1, @q2 = 0, 0
    @key = []
    str.each_byte {|elem| @key << elem} while @key.size < 256
    @key.slice!(256..@key.size-1) if @key.size >= 256
    @s = (0..255).to_a
    j = 0 
    0.upto(255) do |i| 
      j = (j + @s[i] + @key[i] )%256
      @s[i], @s[j] = @s[j], @s[i]
    end    
  end
    
  def encrypt!(text)
    process text
  end  
  
  def encrypt(text)
    process text.dup
  end 

  def encrypt_url_safe(text)
    (string_to_hex ( process text.dup )).hex.to_s(36)
  end 

  def decrypt_url_safe(text)
    process hex_to_string( '%024x' % text.to_i(36) ) 
  end 
  
  alias_method :decrypt, :encrypt
  
  private

  def process(text)
    0.upto(text.length-1) {|i| text[i] = text[i] ^ round}
    text
  end
  
  def round
    @q1 = (@q1 + 1)%256
    @q2 = (@q2 + @s[@q1])%256
    @s[@q1], @s[@q2] = @s[@q2], @s[@q1]
    @s[(@s[@q1]+@s[@q2])%256]  
  end
  
  # hex_to_string("486578546f537472") returns "HexToStr"
  def hex_to_string(str)
	returned = ''
  	for i in (0..str.length).step(2)
      unless str[i].nil?
		hex_chr = str[i].chr + str[i+1].chr
    	returned += hex_chr.hex.chr
      end
    end
  	returned
  end
  
  # string_to_hex("StrToHex") returns "537472546f486578"
  def string_to_hex(str)
	returned = ''
	for i in (0..str.length)
      unless str[i].nil?
        returned += str[i].to_s(16).rjust(2, '0')
      end
  	end
    returned
  end
  
end