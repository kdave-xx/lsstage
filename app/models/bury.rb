class Bury < ActiveRecord::Base
  belongs_to :comment, :counter_cache => true
  belongs_to :person
  
  validates_uniqueness_of :person_id, :scope => :comment_id
end
