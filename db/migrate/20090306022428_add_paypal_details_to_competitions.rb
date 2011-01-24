class AddPaypalDetailsToCompetitions < ActiveRecord::Migration
  def self.up
    change_table :competitions do |t|
      t.boolean       :transfered
      t.datetime      :transfered_at

      t.string        :inbound_paypal_account
      t.string        :inbound_paypal_transaction_number
      
      t.string        :outbound_paypal_account
      t.string        :outbound_paypal_transaction_number
    end
  end

  def self.down
    remove_column :competitions, :transfered
    remove_column :competitions, :transfered_at

    remove_column :competitions, :inbound_paypal_account
    remove_column :competitions, :inbound_paypal_transaction_number

    remove_column :competitions, :outbound_paypal_account
    remove_column :competitions, :outbound_paypal_transaction_number
  end
end
