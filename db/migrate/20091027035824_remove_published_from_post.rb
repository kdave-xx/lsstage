class RemovePublishedFromPost < ActiveRecord::Migration
  def self.up
    #remove_column :posts, :published
  end

  def self.down
    #add_column :posts, :published, :date_time
  end
end
