class AddCompanySizeToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :company_size, :integer
  end

  def self.down
    remove_column :profiles, :company_size
  end
end
