class ChangeCompPaymentColumns < ActiveRecord::Migration
  def self.up
    remove_column :competitions, :inbound_paypal_account
    remove_column :competitions, :inbound_paypal_transaction_number

    remove_column :competitions, :outbound_paypal_account
    remove_column :competitions, :outbound_paypal_transaction_number
    
    add_column :competitions, :winner_chosen, :boolean
    add_column :competitions, :artwork_submitted, :boolean
  end

  def self.down
    change_table :competitions do |t|
      t.string        :inbound_paypal_account
      t.string        :inbound_paypal_transaction_number
      
      t.string        :outbound_paypal_account
      t.string        :outbound_paypal_transaction_number
    end
    
    remove_column :competitions, :winner_chosen
    remove_column :competitions, :artwork_submitted
  end
end
