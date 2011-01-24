class RenameColumnTypo < ActiveRecord::Migration
  def self.up
    rename_column :competitions, :transfered, :transferred
    rename_column :competitions, :transfered_at, :transferred_at
  end

  def self.down
    rename_column :competitions, :transferred, :transfered
    rename_column :competitions, :transferred_at, :transfered_at
  end
end
