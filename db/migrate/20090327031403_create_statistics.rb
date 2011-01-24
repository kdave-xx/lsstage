class CreateStatistics < ActiveRecord::Migration
  def self.up
    create_table :statistics do |t|
      t.integer   :score
      t.integer   :rank
      
      t.integer   :number_of_comments
      t.integer   :number_of_views
      t.integer   :number_of_gold_medals
      t.integer   :number_of_silver_medals
      t.integer   :number_of_bronze_medals
      
      t.references :analyzable, :polymorphic => true
    end
    
    add_index :statistics, :analyzable_id
    add_index :statistics, :score
  end

  def self.down
    drop_table :statistics
  end
end
