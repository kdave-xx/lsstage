class AddAutoExtendToCompetition < ActiveRecord::Migration
  def self.up
    add_column :competitions, :auto_extend, :boolean
  end

  def self.down
    remove_column :competitions, :auto_extend
  end
end
