class AddAdditionalFieldsToCompetition < ActiveRecord::Migration
  def self.up
    add_column :competitions, :sub_title, :string
    add_column :competitions, :target_audience, :text
    add_column :competitions, :requirement, :text
  end

  def self.down
    remove_column :competitions, :requirement
    remove_column :competitions, :target_audience
    remove_column :competitions, :sub_title
  end
end
