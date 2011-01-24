class CreateTokens < ActiveRecord::Migration
  def self.up
    create_table :tokens do |t|
      t.string      :secret
      t.string      :ip
      t.string      :location
      t.date        :expire
      
      t.references  :person

      t.timestamps
    end
  end

  def self.down
    drop_table :tokens
  end
end
