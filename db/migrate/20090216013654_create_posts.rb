class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.string          :name
      t.text            :excerpt
      t.text            :body
              
      t.string          :rewrite
      
      t.datetime        :publish_at
      t.datetime        :expires_at
      
      t.references      :person
      
      t.timestamps
    end
  end

  def self.down
    drop_table :posts
  end
end
