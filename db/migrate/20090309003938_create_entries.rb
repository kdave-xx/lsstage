class CreateEntries < ActiveRecord::Migration
  def self.up
    create_table :entries do |t|
      t.integer         :kind
      t.integer         :status

      t.references      :person
      t.references      :logo
      t.references      :enterable, :polymorphic => { :default => 'Competition' }

      t.timestamps
    end
  end

  def self.down
    drop_table :entries
  end
end
