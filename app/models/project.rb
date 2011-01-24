class Project < ActiveRecord::Base
  # Constants
  acts_as_solr :fields => [:name, :location, :brief, :person_id, :deadline, :prize_value, :created_at]
  MIN_PRIZE = 200
  LISTING_FEE = 50
  
  ALLOWED_CURRENCY = ['USD', 'NZD']
  PERMISSION = {
    :public => 1,
    :private => 2
  }
  
  STATUS = {
    :unpaid => 1,
    :paid => 2,
    :winner_chosen => 3
  }
  
  default_scope :order => 'deadline DESC'
  
  # Associations
  belongs_to :person
  
  with_options :dependent => :destroy do |project|
    project.has_many :comments, :as => :commentable
    project.has_many :bids
  end

  has_one :success_transaction, :class_name => "Transaction", :conditions => ['transactions.success = ?', true], :as => :loggable
  has_one :winning_bid, :class_name => "Bid", :conditions => ['bids.won = ?', true]
  has_many :transactions, :as => :loggable
  
  # Named Scope
  named_scope :all
  named_scope :approved, :conditions => {:approved => true}
  named_scope :unapproved, :conditions => {:approved => false}

  named_scope :paid, :conditions => {:status => STATUS[:paid]}
  named_scope :unpaid, :conditions => {:status => STATUS[:unpaid]}
  named_scope :has_winner, :conditions => {:status => STATUS[:winner_chosen]}
  
  named_scope :public, :conditions => {:permission => PERMISSION[:public]}
  named_scope :private, :conditions => {:permission => PERMISSION[:private]}

  named_scope :open,    lambda { {:conditions => ['deadline >= :today AND status <> :won', {:today => Date.current, :won => STATUS[:winner_chosen]}]} }
  named_scope :closed,  lambda { {:conditions => ['deadline < :today OR status = :won',{:today => Date.current, :won => STATUS[:winner_chosen]}]} }
  named_scope :by,      lambda { |person| {:conditions => ['person_id = ?', person.id]} }
  

  # Validations
  validates_presence_of :name
  validates_presence_of :brief
  
#  validates_inclusion_of :permission, :in => PERMISSION.values
  
  # Callbacks
  before_create :set_default_attributes
  
  # Sphinx
#  define_index do
#    indexes :name
#    indexes :location
#    indexes :brief
#    indexes :person_id
#
#    indexes deadline, :sortable => true
#    indexes prize_value, :sortable => true
#    indexes created_at, :sortable => true
#    has     kind
#    has     approved
#
#    set_property :delta => true
#  end
  
  # Class Methods
  def self.available(user = nil)
    if user
      if user.designer?
        Project.approved.open
      elsif user.admin?
        Project.approved.open
      else
        Project.approved.public.open
      end
    else
      Project.approved.public.open
    end
  end
  
  # Record Callbacks
  def set_default_attributes
    self.status     ||= STATUS[:unpaid]
    return true
  end
  
  # Instance Methods
  def total_fee_in_cents
    LISTING_FEE * 100
  end
  
  def private?
    self.permission == PERMISSION[:private]
  end
  
  def closed?
    self.deadline < Date.current or self.status == STATUS[:winner_chosen]
  end
  
  def paid?
    self.status == STATUS[:paid]
  end
  
  def paid!
    self.status = STATUS[:paid]
    self.save
  end
  
  def won!
    self.status = STATUS[:winner_chosen]
    self.save
  end
  
  def viewable?(user)
    if self.private?
      if user
        user.admin? or self.person == user or user.pro?
      else
        false
      end
    else
      true
    end
  end
  
  def process_express_payment(token, ip_address)
    if not token.blank?
      payment_details = PAYPAL_EXPRESS_GATEWAY.details_for(token)
      
      payment_result = PAYPAL_EXPRESS_GATEWAY.purchase(
        self.total_fee_in_cents, 
        {
          :ip => ip_address,
          :token => token,
          :payer_id => payment_details.payer_id
        }
      )
      
      transactions.create!(
        :amount => self.total_fee_in_cents, 
        :kind => Transaction::KIND[:inward],
        :action => "PURCHASE",
        :token => token,
        :ip_address => ip_address,
        :payer_id => payment_details.payer_id,
        :success => payment_result.success?,
        :authorization => payment_result.authorization,
        :message => payment_result.message,
        :references => payment_result.params
      )
      
      self.paid! if payment_result.success?
      
      payment_result.success?
    end
  end
  
end
