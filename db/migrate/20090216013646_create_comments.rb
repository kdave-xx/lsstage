class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer         :rating
      t.text            :body
      
      t.references      :person
      t.references      :commentable, :polymorphic => { :default => 'Logo' }
      
      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
