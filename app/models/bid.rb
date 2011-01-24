class Bid < ActiveRecord::Base
  # Associations
  belongs_to :person
  belongs_to :project
  
  with_options :dependent => :destroy do |bid|
    bid.has_many :comments, :as => :commentable
  end
  
  # Validations
  validates_presence_of :name
  validates_presence_of :brief
  validates_presence_of :price
  validates_numericality_of :price, :greater_than => 0
  #validate_on_create :bidder_must_be_pro_designer
  
  # Named Scope
  named_scope :won, :conditions => {:won => true}
  # Attachments
  has_attached_file :image,
                    :storage => :s3,
                    :s3_credentials => "#{RAILS_ROOT}/config/amazon_s3.yml",
                    :bucket => BUCKET_NAME,
                    :url  => "/system/data/:id/:basename.:extension",
                    :path => "/system/data/:id/:basename.:extension"
                    
  
  
  validates_attachment_size :image, :less_than => 10.megabyte
  validates_attachment_content_type :image, :content_type => ['application/pdf', 'application/x-pdf', 'application/acrobat', 'applications/vnd.pdf', 'text/pdf', 'text/x-pdf']
  
  
  # Validation Callbacks
  def bidder_must_be_pro_designer
    unless self.person and self.person.pro?
      self.errors.add_to_base 'You must be a pro designer in order to bid in a project'
    end
  end
  
  # Instance Methods
  def lost!
    self.won = false
    self.save
  end
  
  def won!
    if self.project.winning_bid 
      self.project.winning_bid.lost!
    end
    
    self.won = true
    self.project.won!
    self.save
  end

end
