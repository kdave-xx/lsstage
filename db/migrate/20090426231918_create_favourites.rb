class CreateFavourites < ActiveRecord::Migration
  def self.up
    create_table :favourites do |t|
      t.integer         :rating
      
      t.references      :person
      t.references      :logo
      t.timestamps
    end
  end

  def self.down
    drop_table :favourites
  end
end
