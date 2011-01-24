class AddRatingToEntry < ActiveRecord::Migration
  def self.up
    add_column :entries, :rating, :integer
  end

  def self.down
    remove_column :entries, :rating
  end
end
