class AddForSaleAttributesToLogo < ActiveRecord::Migration
  def self.up
    add_column :logos, :for_sale, :boolean
    add_column :logos, :price, :decimal, :precision => 9, :scale => 2
    add_column :logos, :sold, :boolean
    add_column :logos, :buyer_id, :integer
    add_column :logos, :sale_description, :text
  end

  def self.down
    remove_column :logos, :sale_description
    remove_column :logos, :for_sale
    remove_column :logos, :sold
    remove_column :logos, :price
    remove_column :logos, :buyer_id
  end
end
