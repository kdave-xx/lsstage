class Token < ActiveRecord::Base
  belongs_to :person
  
  def self.generate(ip)
    Token.create :secret => Token.token_hash, :ip => ip, :expire => 1.year.from_now
  end
  
  def self.token_hash
    Digest::SHA512.hexdigest "#{rand.to_s}#{Time.now.to_s}:TOKEN_SLAT"
  end
  
  def expired?
    self.expire and (self.expire < Date.today)
  end
end
