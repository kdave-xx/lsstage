class Entry < ActiveRecord::Base
  # Constants
  KIND = {
    :public => 1,
    :private => 2
  }
  
  STATUS = {
    :entry => 1,
    :winner => 2,
    :preferred => 3,
    :withdrawn => 11
  }
  
  # Associations
  belongs_to :person
  belongs_to :logo
  belongs_to :enterable, :polymorphic => true
  
  # Named Scope
  named_scope :winner, :conditions => {:status => STATUS[:winner]}
  named_scope :by_person, lambda { |person| { :conditions => { :person_id => person.id } } }
  
  # Instance Methods
  def private?
    self.kind == KIND[:private]
  end
  def rate!(supplied_rating)
    self.rating = supplied_rating
    self.save
  end

  def winner?
    self.status == STATUS[:winner]
  end

  def withdrawn?
    self.status == STATUS[:withdrawn]
  end
  
  def withdraw!
    if self.status == STATUS[:winner] or self.enterable.closed?
      false
    else
      self.status = STATUS[:withdrawn]
      self.save
    end
  end
  
  def won!
    self.status = STATUS[:winner]
    self.save

    self.person.competition_winner = true
    self.person.last_won_at = Time.now
    self.person.save
    
    self.enterable.winner_chosen = true
    self.enterable.save
    
    Notifier.deliver_request_artwork(self)
  end
  
  def viewable?(user)
    if self.private?
      if user
        user.admin? or entry.enterable.person == user or entry.person = user
      else
        false
      end
    else
      true
    end
  end
end
