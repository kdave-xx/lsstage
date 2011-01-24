class AddDeltaToModels < ActiveRecord::Migration
  def self.up
    [:logos, :competitions, :people, :projects].each do |table|
      add_column table, :delta, :boolean, :default => true, :null => false
    end
  end

  def self.down
    [:logos, :competitions, :people, :projects].each do |table|
      remove_column table, :delta
    end
  end
end
