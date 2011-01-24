class CreateTransactions < ActiveRecord::Migration
  def self.up
    create_table :transactions do |t|
      t.integer     :kind
      t.decimal     :amount,  :precision => 9, :scale => 2
      t.string      :references
      t.references  :loggable, :polymorphic => { :default => 'Competition' }
      t.timestamps
    end
  end

  def self.down
    drop_table :transactions
  end
end
