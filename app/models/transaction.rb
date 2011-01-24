class Transaction < ActiveRecord::Base
  # Constants
  KIND = {
    :inward => 1,
    :outward => 2
  }
  
  # Serialization
  serialize :references
  
  # Associations
  belongs_to :loggable, :polymorphic => true
  
  # Callbacks
  after_create :notify_admin
  
  # Record Callbacks
  def notify_admin
    Notifier.deliver_new_transaction self
  end
  
  # Instance Methods
  def amount_in_dollar
    amount / 100.0
  end
  
  
end
