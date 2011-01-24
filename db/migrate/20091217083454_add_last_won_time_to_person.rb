class AddLastWonTimeToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :last_won_at, :datetime
  end

  def self.down
    remove_column :people, :last_won_at
  end
end
