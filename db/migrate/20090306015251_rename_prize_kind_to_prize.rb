class RenamePrizeKindToPrize < ActiveRecord::Migration
  def self.up
    rename_column :competitions, :prize_kind, :prize
  end

  def self.down
    rename_column :competitions, :prize, :prize_kind
  end
end
