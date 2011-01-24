class CreatePageViews < ActiveRecord::Migration
  def self.up
    create_table :page_views do |t|
      t.string    :ip_address
      t.references  :viewable, :polymorphic => true
      
      t.timestamps
    end
  end

  def self.down
    drop_table :page_views
  end
end
