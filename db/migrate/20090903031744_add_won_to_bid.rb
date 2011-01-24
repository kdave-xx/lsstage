class AddWonToBid < ActiveRecord::Migration
  def self.up
    add_column :bids, :won, :boolean
  end

  def self.down
    remove_column :bids, :won
  end
end
