class AddOldLogoIdToLogo < ActiveRecord::Migration
  def self.up
    add_column :logos, :old_logo_id, :integer
  end

  def self.down
    remove_column :logos, :old_logo_id
  end
end
