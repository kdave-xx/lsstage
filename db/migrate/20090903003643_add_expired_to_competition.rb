class AddExpiredToCompetition < ActiveRecord::Migration
  def self.up
    add_column :competitions, :expired, :boolean
  end

  def self.down
    remove_column :competitions, :expired
  end
end
