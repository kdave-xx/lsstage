class Favourite < ActiveRecord::Base
  default_scope :order => 'favourites.created_at DESC'
  # Associations
  belongs_to :person
  belongs_to :logo
  
  # Validations
  validates_presence_of :person_id
  validates_presence_of :logo_id
  
  after_save :revise_statistics
  after_destroy :revise_statistics
  
  def self.favoured?(logo)
    exists?(['logo_id = ?', logo.id])
  end
  
  def revise_statistics
    StatisticsReviser.revise_logo(self.logo)
  end
end
