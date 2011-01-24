class AddDetailsToTransaction < ActiveRecord::Migration
  def self.up
    add_column :transactions, :action, :string
    add_column :transactions, :token, :string
    add_column :transactions, :ip_address, :string
    add_column :transactions, :payer_id, :string
    add_column :transactions, :success, :boolean
    add_column :transactions, :authorization, :string
    add_column :transactions, :message, :string
    change_column :transactions, :references, :text
    change_column :transactions, :amount, :integer
  end

  def self.down
    remove_column :transactions, :action
    remove_column :transactions, :token
    remove_column :transactions, :ip_address
    remove_column :transactions, :payer_id
    remove_column :transactions, :success
    remove_column :transactions, :authorization
    remove_column :transactions, :message
    change_column :transactions, :references, :string
    change_column :transactions, :amount, :decimal, :precision => 9, :scale => 2
  end
end
