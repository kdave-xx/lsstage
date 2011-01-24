class AddNumberOfProjectWonToStatistic < ActiveRecord::Migration
  def self.up
    add_column :statistics, :number_of_projects, :integer
  end

  def self.down
    remove_column :statistics, :number_of_projects
  end
end
