class RenameBrandToBrandName < ActiveRecord::Migration
  def self.up
    rename_column :logos, :brand, :brand_name
  end

  def self.down
    rename_column :logos, :brand_name, :brand
  end
end
