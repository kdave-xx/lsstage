class PeopleAnnouncements < ActiveRecord::Migration
  def self.up
    create_table :people_announcements do |t|
      t.integer :person_id
      t.integer :announcement_id

      t.timestamps
    end
  end

  def self.down
    drop_table :people_announcements
  end
end
