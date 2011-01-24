class AddNumberOfFavouritesToStatistic < ActiveRecord::Migration
  def self.up
    add_column :statistics, :number_of_favourites, :integer
  end

  def self.down
    remove_column :statistics, :number_of_favourites
  end
end
