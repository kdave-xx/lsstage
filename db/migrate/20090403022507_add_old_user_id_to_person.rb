class AddOldUserIdToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :old_user_id, :integer
  end

  def self.down
    remove_column :people, :old_user_id
  end
end
