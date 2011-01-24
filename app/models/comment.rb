class Comment < ActiveRecord::Base
  # Defaults
  acts_as_solr :fields => [:body, :person_id]
  default_scope :order => 'comments.created_at ASC'
  
  # Associations
  belongs_to :person
  belongs_to :commentable, :polymorphic => true
  
  with_options :dependent => :destroy do |comment|
    comment.has_many :buries
  end
  
  # Validations
  validates_presence_of :body
  validates_presence_of :person_id
  validates_numericality_of :rating, :only_integer => true, :less_than_or_equal_to => 3, :greater_than_or_equal_to => 0, :allow_nil => true
  
  # Named Scopes
  named_scope :has_rating, :conditions => ['rating IS NOT NULL OR rating = 0']
  
  # Callbacks
  after_create :notify_user
  after_save :change_previous_votes
  after_save :revise_statistics
  
  # Class Methods
  def self.on_person(person)
  end
  
  # Sphinx
#  define_index do
#    indexes :body
#    indexes :person_id
#
#    has rating
#    has created_at, :sortable => true
#
#    set_property :delta => true
#  end
  
  # Record Callbacks
  def revise_statistics
    if self.commentable.is_a?(Logo)
      StatisticsReviser.revise_logo(self.commentable)
    end
  end
  
  def change_previous_votes
    if self.rating and not self.rating.zero?
      self.person.comments.update_all(
        "rating = #{self.rating}",
        "commentable_id = #{self.commentable.id} AND commentable_type = '#{self.commentable_type}'"
      )
    end
  end
  
  def notify_user
    if self.commentable.is_a? Logo
      Notifier.deliver_comment_placed(self.person, self.commentable)
    else
      if self.commentable.is_a? Competition
        Notifier.deliver_competition_comment_placed(self.person, self.commentable)
      end
    end
    true
  end
  
  # Instance Method
  def weighted_score
    if self.buried? or self.has_no_rating?
      0
    else
      if self.person.pro?
        StatisticsReviser::PRO_MULTIPLIER * self.rating
      else
        if self.commentable.competition
          if self.commentable.competition.person == self.person
            StatisticsReviser::CLIENT_MULTIPLIER * self.rating
          else
            self.rating
          end
        else
          self.rating
        end
      end
    end
  end
  
  def highlight?
    if self.commentable.is_a? Logo
      if self.commentable.person == self.person
        true
      end
    end
  end
  
  def has_no_rating?
    self.rating.blank? or self.rating == 0
  end
  
  def buried?
    self.buries.size >= StatisticsReviser::BURY_THRESHOLD
  end
  
  def buried_by?(person)
    self.buries.exists?(['person_id = ?', person.id])
  end
  
  def bury(person)
    self.buries.create(:person => person)
    self.reload
    self.revise_statistics
  end
  
  def unbury(person)
    self.buries.first(:conditions => {:person_id => person.id}).destroy
    self.reload
    self.revise_statistics
  end
  
  def subsequent?
    not self.rating.zero? and commentable.comments.exists?(['person_id = ? AND id < ?', self.person_id, self.id])
  end
end
