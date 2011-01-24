class ConvertDecimalOnCompetition < ActiveRecord::Migration
  def self.up
    change_column :competitions, :prize_value, :float
    change_column :competitions, :fee, :float
  end

  def self.down
    change_column :competitions, :prize_value, :float
    change_column :competitions, :fee, :float
  end
end
