class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
      t.string      :job_title
      t.string      :company
      t.string      :company_website
      t.string      :location
      t.string      :country
      t.text        :biography
      
      t.references  :person
      
      t.timestamps
    end
    
    add_index :profiles, :person_id
  end

  def self.down
    drop_table :profiles
  end
end
