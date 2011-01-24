class AddApprovedToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :approved, :boolean
  end

  def self.down
    remove_column :projects, :approved
  end
end
