class CreateBuries < ActiveRecord::Migration
  def self.up
    create_table :buries do |t|
      t.references :person
      t.references :comment
      t.timestamps
    end
  end

  def self.down
    drop_table :buries
  end
end
