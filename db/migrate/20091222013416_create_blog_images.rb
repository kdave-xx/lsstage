class CreateBlogImages < ActiveRecord::Migration
  def self.up
    create_table :blog_images do |t|
      t.string      :document_file_name
      t.string      :document_content_type
      t.integer     :document_file_size
      t.datetime    :document_updated_at

      t.timestamps
    end
  end

  def self.down
    drop_table :blog_images
  end
end
