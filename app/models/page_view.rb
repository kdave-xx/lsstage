class PageView < ActiveRecord::Base
  belongs_to :viewable, :polymorphic => true
  
  def self.hit?(ip_address)
    if exists?(['ip_address = ?', ip_address])
      false
    else
      create(:ip_address => ip_address)
    end
  end
  
  def self.clear
    delete_all(['created_at <= ?', 1.days.ago])
  end
end
