class CreateArtworks < ActiveRecord::Migration
  def self.up
    create_table :artworks do |t|
      t.string      :document_file_name
      t.string      :document_content_type
      t.integer     :document_file_size
      t.datetime    :document_updated_at
      t.references  :person
      t.references  :competition
      t.timestamps
    end
  end

  def self.down
    drop_table :artworks
  end
end
