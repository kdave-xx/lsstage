class Artwork < ActiveRecord::Base
  belongs_to :person
  belongs_to :attachable, :polymorphic => true
  
  has_attached_file :document
  
  validates_attachment_presence :document
  validates_attachment_size :document, :less_than => 10.megabyte
  
  after_create :assign_ownership
  
  def assign_ownership
    if self.person_id.blank?
      self.person_id = self.attachable.person.id
    end
    true
  end
end
