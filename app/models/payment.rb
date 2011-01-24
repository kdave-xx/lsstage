class Payment < ActiveRecord::Base
  # Contants
  STATUS = ['SUBMITTED', 'SUCCESS', 'FAILED']
  
  # Assocations
  belongs_to :person
  belongs_to :payable, :polymorphic => true
  
  has_many :transactions, :as => :loggable
  
  # Callbacks
  before_create :process_payment
  before_create :submit_mass_pay
  after_create :log_payable
  
  def amount_in_cents
    self.amount * 100
  end
  
  def log_payable
    if payable and payable.is_a?(Competition)
      payable.transferred = true
      payable.transferred_at = Time.now
    end
    
    true
  end
  
  def process_payment
    if payable and payable.is_a?(Competition)
      self.email = payable.winner.paypal_account
      self.person = payable.winner
      self.amount = payable.prize_value
      self.status = "SUBMITTED"
      self.note = "Prize money for competition #{payable.id}"
      
      true
    elsif payable and payable.is_a?(Logo)
      self.email = payable.person.paypal_account
      self.person = payable.person
      self.amount = payable.payable_amount
      self.status = "SUBMITTED"
      self.note = "Payment money for logo #{payable.id}"

      true
    else
      false
    end
  end
  
  def submit_mass_pay
    gateway = MassPay::Processor.new PAYPAL_CONFIG
    receiver = MassPay::Receiver.new
    
    receiver.email = self.email
    receiver.amount = self.amount
    receiver.unique_id = self.id
    receiver.note = "Prize"
    
    gateway.receivers << receiver
    gateway.commit
  end
  
  def success!(response)
    self.status = 'SUCCESS'
    self.save
    
    self.payable.transactions.create!(
      :amount => self.amount_in_cents, 
      :kind => Transaction::KIND[:outward],
      :action => "PURCHASE",
      :success => true,
      :references => response
    )
    
  end
  
  def failed!
    self.status = 'FAILED'
    self.save
  end
end
