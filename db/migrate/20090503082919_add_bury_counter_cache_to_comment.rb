class AddBuryCounterCacheToComment < ActiveRecord::Migration
  def self.up
    add_column :comments, :buries_count, :integer
  end

  def self.down
    remove_column :comments, :buries_count
  end
end
