class Statistic < ActiveRecord::Base
  # Associations
  belongs_to :analyzable, :polymorphic => true
  
  # Record Callbacks
  before_create :set_defaults
  
  # Record Callbacks
  def set_defaults
    self.score                    ||= 0
    self.number_of_comments       ||= 0
    self.number_of_views          ||= 0
    self.number_of_gold_medals    ||= 0
    self.number_of_silver_medals  ||= 0
    self.number_of_bronze_medals  ||= 0
    self.number_of_projects       ||= 0
  end
  
  def hit!
    increment!(:number_of_views)
  end
end