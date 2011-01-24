class Competition < ActiveRecord::Base
  # Constants
  acts_as_solr :fields => [:name, :description, :person_id, :open_on, :close_on, :prize_value]
  ORGANIZATION = {
    :commercial => 1,
    :non_profit => 2
  }
  
  PRIZE = {
    :cash => 1,
    :non_cash => 2
  }

  MIN_PRIZE_PUBLIC = 200
  MIN_PRIZE_PRIVATE = 200
  
  AUTO_EXTEND_MIN_PRIZE = 500
  AUTO_EXTEND_HASH = {
    (0...200) => 0,
    (200...300) => 25,
    (300...500) => 50,
    (500...750) => 75,
    (750...100000) => 100
  }
  
  bitmask :logo_format, :as => [:wordmark, :pictorial_mark, :abstract_mark, :emblem, :mascot, :web_2]
  bitmask :logo_use, :as => [:web, :print, :tv_film, :branded_product, :promo_item]
  
  # Defaults
  default_scope :order => 'close_on DESC'
  
  # Associations
  belongs_to :person
  
  has_many :comments, :as => :commentable, :dependent => :destroy  
  has_many :entries, :as => :enterable, :dependent => :destroy

  has_many :transactions, :as => :loggable
  has_one :success_transaction, :class_name => "Transaction", :conditions => ['transactions.success = ?', true], :as => :loggable

  has_many :payments, :as => :payable
  has_one :success_payment, :class_name => "Payment", :conditions => ['payments.status = ?', 'SUCCESS'], :as => :payable
  
  has_one :won, :as => :enterable, :conditions => ['entries.status = ?', Entry::STATUS[:winner]], :class_name => "Entry"
  has_one :artwork, :as => :attachable

  with_options :through => :entries do |competition|
    competition.has_many :logos, :order => 'entries.created_at DESC'
    competition.has_many :current_logos, :conditions => ['entries.status = ?', Entry::STATUS[:entry]], :order => 'entries.created_at DESC', :source => :logo
    competition.has_many :people, :order => 'entries.created_at DESC', :uniq => true
  end
  
  # Named Scopes
  named_scope :paid,          :conditions => {:paid => true}
  named_scope :unpaid,        :conditions => {:paid => false}

  named_scope :approved,      :conditions => {:approved => true}
  named_scope :unapproved,    :conditions => {:approved => false}
  named_scope :paid_approved, :conditions => {:paid => true, :approved => true}
  named_scope :transferred,   :conditions => {:transferred => true}
  named_scope :has_winner,    :conditions => {:winner_chosen => true}
  named_scope :has_no_winner, :conditions => 'winner_chosen <> 1 AND expired <> 1'
  
  named_scope :client_unpaid, :conditions => {:winner_chosen => true, :artwork_submitted => true}  
  
  named_scope :auto_extend,   :conditions => {:auto_extend => true}

  named_scope :open,    lambda { {:conditions => ['open_on <= :today AND close_on >= :today AND paid = :paid AND approved = :approved', {:today => Date.current, :paid => true, :approved => true}]} }
  named_scope :closed,  lambda { {:conditions => ['close_on < :today AND paid = :paid AND approved = :approved',{:today => Date.current, :paid => true, :approved => true}]} }
  named_scope :by,      lambda { |person| {:conditions => ['person_id = ?', person.id]} }  

  # Search
#  define_index do
#    indexes :name
#    indexes :description
#    indexes :person_id
#
#    indexes open_on, :as => :open_on, :sortable => true
#    indexes close_on, :as => :close_on, :sortable => true
#    indexes prize_value, :as => :prize_value, :sortable => true
#
#    set_property :delta => true
#  end
  
  # Valdiations
  validates_presence_of :name, :description, :target_audience, :open_on, :close_on, :prize_value
  
  validates_numericality_of :prize_value
  
  validate :must_exceed_mininum_prize
  
  # validate_on_create :must_open_on_future
  # validate_on_create :must_close_on_future
  
  # Protection
  # TODO Change this to attr_accessible
  attr_protected  :expired, :auto_extend, :extended, :person_id, :approved, :approved_at, :paid, :paid_at, :fee, :transfered_at, :transfered, :comment_ids
  
  # Callbacks
  before_save :calculate_fee
  before_create :set_default_attributes
  
  after_create :notify_admin
  
  # Class Methods

  def self.process_pending_winner
    Competition.approved.closed.has_no_winner.each do |pending|
      if pending.expiry_date <= Date.current
        pending.expired!
      else
        Notifier.deliever_choose_winner(pending)
      end
    end
  end
  
  def self.process_auto_extend
    Competition.open.each do |open|
      if open.should_extend?
        open.extend!
      end
    end
  end
  
  def self.current
    Competition.approved.paid.open
  end
  
  def self.search(keyword, options = {})
    super(keyword, options)
  end
  
  # Validation Callbacks
  def must_open_on_future
    #if self.open_on and self.open_on < Date.current
    #  errors.add :open_on, 'must open in future'
    #end
  end
  
  def must_close_on_future
    if self.close_on and self.close_on < Date.current
      errors.add :close_on, 'must close in future'
    end
  end
  
  def must_exceed_mininum_prize
    return unless self.errors.empty?
    if self.private?
      errors.add(:prize_value, "must exceed $#{MIN_PRIZE_PRIVATE}") if self.prize_value < MIN_PRIZE_PRIVATE
    else
      errors.add(:prize_value, "must exceed $#{MIN_PRIZE_PUBLIC}") if self.prize_value < MIN_PRIZE_PUBLIC
    end
  end
  
  # Record Callbacks
  def set_default_attributes
    self.paid       ||= false
    self.transferred ||= false
    self.approved   ||= false
    
    if self.prize_value >= AUTO_EXTEND_MIN_PRIZE
      self.auto_extend = true
    else
      self.auto_extend = false
    end

    return true
  end
  
  def calculate_fee
    commision_percent = private? ? 0.2 : 0.1
    self.fee = prize_value * commision_percent
  end
  
  def notify_admin
    Notifier.deliver_new_activity "Competition", self
  end
  
  # Instance Method
  def total_fee
    prize == PRIZE[:non_cash] ? fee : prize_value + fee
  end
  
  def total_fee_in_cents
    total_fee * 100
  end
  
  def prize_value_in_cents
    prize_value * 100
  end
  
  def expiry_date
    self.close_on + 7.days
  end
  
  def should_extend?
    auto_extend_range = AUTO_EXTEND_HASH.detect { |key, value| key.include?(self.prize_value) }
    if auto_extend_range
      self.entries.size < auto_extend_range.last
    else
      false
    end
  end
  
  def extend!
    self.close_on = close_on + 1.day
    self.extended = true
    self.save
  end
  
  def approve!
    self.approved = true
    self.approved_at = Date.current
    self.save
  end
  
  def paid!
    self.paid = true
    self.paid_at = Date.current
    self.save
  end
  
  def expired!
    self.expired = true
    self.save
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
  
  def viewable?(user)
    if self.private? and self.closed?
      if user
        user.admin? or self.person == user or self.entries.by_person(user).any?
      else
        false
      end
    else
      true
    end
  end
  
  def open?
    not closed?
  end
  def closed?
    self.close_on < Date.current
  end
  
  def winner
    won.person
  end
  
  def favorite_entries
    entries.all :conditions => ['favourites.person_id = ?', self.person.id], :include => {:logo => :favourites}
  end
  
  def payable?
    paid? and closed? and not success_payment
  end
  
end

