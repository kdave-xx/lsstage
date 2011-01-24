class ConvertDecimalIntoFloat < ActiveRecord::Migration
  def self.up
    change_column :competitions, :prize_value, :float
    change_column :competitions, :fee, :float
    change_column :payments, :amount, :float
    change_column :projects, :prize_value, :float
    change_column :logos, :price, :float
  end

  def self.down
    change_column :competitions, :prize_value, :decimal
    change_column :competitions, :fee, :decimal
    change_column :payments, :amount, :decimal
    change_column :projects, :prize_value, :decimal
    change_column :logos, :price, :decimal
  end
end
