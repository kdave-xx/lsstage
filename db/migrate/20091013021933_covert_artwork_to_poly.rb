class CovertArtworkToPoly < ActiveRecord::Migration
  def self.up
    rename_column :artworks, :competition_id, :attachable_id
    add_column :artworks, :attachable_type, :string, :default => 'Competition'
  end

  def self.down
    rename_column :artworks, :attachable_id, :competition_id
    remove_column :artworks, :attachable_type
  end
end
