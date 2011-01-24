class AddCompetitionFlagToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :competition_winner, :boolean
  end

  def self.down
    remove_column :people, :competition_winner
  end
end
