class AddFacebookAndTwitterToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :facebook, :string
    add_column :profiles, :twitter, :string
  end

  def self.down
    remove_column :profiles, :twitter
    remove_column :profiles, :facebook
  end
end
