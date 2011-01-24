class CreateLogos < ActiveRecord::Migration
  def self.up
    create_table :logos do |t|
      t.integer         :kind
      
      t.string          :name
      t.string          :strapline
      t.text            :description
      
      t.string          :brand
      t.string          :brand_owner
      t.string          :brand_owner_website

      t.string          :access
      t.string          :access_website
      
      t.integer         :year_first_used
      
      t.references      :person
      
      t.timestamps
    end
  end

  def self.down
    drop_table :logos
  end
end
