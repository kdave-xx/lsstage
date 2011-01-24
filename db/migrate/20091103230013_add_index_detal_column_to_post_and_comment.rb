class AddIndexDetalColumnToPostAndComment < ActiveRecord::Migration
  def self.up
    [:posts, :comments].each do |table|
      add_column table, :delta, :boolean, :default => true, :null => false
    end
  end

  def self.down
    [:posts, :comments].each do |table|
      remove_column table, :delta
    end
  end
end
