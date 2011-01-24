class AddExtendedToCompetition < ActiveRecord::Migration
  def self.up
    add_column :competitions, :extended, :boolean
  end

  def self.down
    remove_column :competitions, :extended
  end
end
