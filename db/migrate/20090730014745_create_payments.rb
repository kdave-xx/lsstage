class CreatePayments < ActiveRecord::Migration
  def self.up
    create_table :payments do |t|
      t.string      :email
      t.decimal     :amount, :precision => 9, :scale => 2
      t.string      :status
      t.text        :note
      
      t.references  :payable, :polymorphic => { :default => 'Competition' }
      t.references  :person
      
      t.timestamps
    end
  end

  def self.down
    drop_table :payments
  end
end
