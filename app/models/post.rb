class Post < ActiveRecord::Base
  # Associations
  acts_as_solr :fields => [:name, :body, :person_id]
  belongs_to :person
  has_many :comments, :as => :commentable, :dependent => :destroy 
  
  # Validations
  validates_presence_of :name, :body
  
  # Tag
  acts_as_taggable
  
  #Sphinx
#  define_index do
#    indexes :name
#    indexes excerpt
#    indexes body
#    indexes :person_id
#
#    indexes tags.name, :as => :tag
#    has created_at, :sortable => true
#
#    set_property :delta => true
#  end
  
  # Instance Methods
  def to_param
    "#{id}-#{name.gsub(/[^a-z1-9]+/i, '-')}"
  end
end
