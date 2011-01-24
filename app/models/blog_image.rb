class BlogImage < ActiveRecord::Base
  has_attached_file :document, 
                    :storage => :s3,
                    :s3_credentials => "#{RAILS_ROOT}/config/amazon_s3.yml",
                    :bucket => BUCKET_NAME,
                    :styles => {:thumb => "100x100>" },
                    :path => "/system/documents/:id/:style/:id.:extension",
                    :url  => "/system/documents/:id/:style/:id.:extension"
  
  validates_attachment_presence :document
  validates_attachment_size :document, :less_than => 10.megabyte
end
