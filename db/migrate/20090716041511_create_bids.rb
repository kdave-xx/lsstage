class CreateBids < ActiveRecord::Migration
  def self.up
    create_table :bids do |t|
      t.string      :name
      t.decimal     :price, :precision => 9, :scale => 2
      
      t.text        :brief
      t.text        :capabilities
      t.text        :offered_services
      t.text        :terms_of_service
      t.text        :warranties
      
      t.references  :person
      t.references  :project
      
      t.string      :image_file_name
      t.string      :image_content_type
      t.integer     :image_file_size
      t.datetime    :image_updated_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :bids
  end
end
