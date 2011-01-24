class AddBitMaskToCompetition < ActiveRecord::Migration
  def self.up
    add_column :competitions, :logo_format, :integer
    add_column :competitions, :logo_use, :integer
  end

  def self.down
    remove_column :competitions, :logo_use
    remove_column :competitions, :logo_format
  end
end
