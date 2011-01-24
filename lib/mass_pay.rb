module MassPay
  class Processor
    require 'net/https'
    require 'uri'
    
    SANDBOX_SERVER = 'https://api-3t.sandbox.paypal.com/nvp'
    LIVE_SERVER = 'https://api-3t.paypal.com/nvp'
    
    attr_accessor :login
    attr_accessor :password
    attr_accessor :signature
    attr_accessor :receivers
    attr_accessor :currency
    
    def initialize(options = {})
      @login = options[:login]
      @password = options[:password]
      @signature = options[:signature]
      @currency = options[:currency] || 'USD'
      
      @receivers = []
    end
    
    def commit
      if @receivers.any?
        post = {
          "USER" => @login,
          "PWD" => @password,
          "SIGNATURE" => @signature,
          "VERSION" => "2.3",
          "METHOD" => "MassPay",
          "RECEIVERTYPE" => "EmailAddress"
        }
        
        receivers.each_with_index do |receiver, index|
          post.merge!({
            "L_EMAIL#{index}" => receiver.email,
            "L_AMT#{index}" => receiver.amount.to_s,
            "L_UNIQUEID#{index}" => receiver.unique_id,
            "L_NOTE#{index}" => receiver.note
          })
        end
        
        post.merge! "CURRENCYCODE" => @currency

        url = URI.parse(SANDBOX_SERVER)
        
        https = Net::HTTP.new(url.host, 443)
        https.use_ssl = true
        
        request = Net::HTTP::Post.new(url.path)
        request.set_form_data(post)
        
        response = https.start { |http| http.request(request) }
        
        case response
        when Net::HTTPSuccess
          result = response.body.split('&').map { |r| r.split('=') }.detect { |r| r.first == 'ACK' }
          if result.any? and result.last == 'Success'
            return true
          else
            return false
          end
        else
          return false
        end
      end
    end
  end
  
  class Receiver
    attr_accessor :email
    attr_accessor :amount
    attr_accessor :unique_id
    attr_accessor :note
  end
end
