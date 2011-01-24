class PasswordResetCoupon < ActiveRecord::Base
  belongs_to :person
  
  before_create :generate_code
  before_create :set_expire_date
  
  after_create :send_email
  
  # Instance Methods
  def generate_code
    self.code = "ABCDEFGHJKMNPQRSTUVWXYZ23456789".split(//).sort { rand <=> rand }.join('')[0..9]
  end
  
  def set_expire_date
    self.expire_at = 30.days.from_now
  end
  
  def send_email
    Notifier.deliver_forget_password(self)
  end
  
end
