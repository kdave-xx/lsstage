class Profile < ActiveRecord::Base
  # Associations
  belongs_to :person

  # Protections
  attr_protected :person_id
end
