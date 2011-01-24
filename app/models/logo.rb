class Logo < ActiveRecord::Base
  # Meta
  acts_as_solr :field => [:name, :description, :strapline, :brand_name, :brand_owner, :person_id]
  attr_accessor :competition_id, :hide_in_competition

  # Tag
  acts_as_taggable
  
  # Constants
  KIND = {
    :profile => 1,
    :competition_entry => 2,
    :project_entry => 3
  }
  PER_PAGE = 60
  
  EARLY_YEAR_OPTIONS = (1900...1980).select { |y| (y % 10).zero? }.map { |y| ["#{y}'s", y] }
  CURRENT_YEAR_OTPIONS = (1980..Date.current.year).map { |y| [y, y] }
  YEAR_OPTIONS = EARLY_YEAR_OPTIONS + CURRENT_YEAR_OTPIONS
  COMMISSION_PERCENTAGE = 0.1
  
  # Paperclip
  has_attached_file :image,
                    :storage => :s3,
                    :s3_credentials => "#{RAILS_ROOT}/config/amazon_s3.yml",
                    :bucket => BUCKET_NAME,
                    :styles => {
                      :large => "640x640>",
                      :medium => "320x320>", 
                      :thumb => "100x100>"
                    },
                    :path => "/system/images/:id/:style/:id.:extension",
                    :url  => "/system/images/:id_partition/:style/:id.:extension"
                    
  
  # Associations
  belongs_to :person
  belongs_to :buyer, :class_name => 'Person', :foreign_key => 'buyer_id'
  
  with_options :dependent => :destroy do |logo|
    logo.has_many :comments, :as => :commentable
    logo.has_many :page_views, :as => :viewable
    logo.has_many :favourites
  
    logo.has_one :entry
    logo.has_one :statistic, :as => :analyzable
    logo.has_one :artwork, :as => :attachable
  end
  
  accepts_nested_attributes_for :artwork
  
  has_many :transactions, :as => :loggable
  has_one :success_transaction, :class_name => "Transaction", :conditions => ['transactions.success = ?', true], :as => :loggable
  
  has_many :payments, :as => :payable
  has_one :success_payment, :class_name => "Payment", :conditions => ['payments.status = ?', 'SUCCESS'], :as => :payable
  
  # Sphinx
#  define_index do
#    indexes :name
#    indexes strapline
#    indexes description
#    indexes brand_name
#    indexes brand_owner
#    indexes :person_id
#
#    indexes tags.name, :as => :tag
#
#    indexes person.nick_name, :as => :person_nick_name
#    indexes [person.first_name, person.last_name], :as => :person_full_name
#    indexes entry.status, :as => :entry_status
#
#    has :kind
#    has created_at, :sortable => true
#    has statistic.score, :as => :score, :sortable => true
#    has statistic.number_of_views, :as => :view, :sortable => true
#    has for_sale
#
#    set_property :delta => true
#  end
  
  # Named Scope
  named_scope :for_sale, :conditions => {:for_sale => true}, :order => 'created_at DESC'
  named_scope :in_competition, lambda { |competition| {:conditions => ['entries.enterable_id = ?', competition.id], :joins => :entry} }
  named_scope :entry, :conditions => {:kind => KIND[:competition_entry]}
  named_scope :portfolio, :conditions => {:kind => KIND[:profile]}
  named_scope :winners, lambda { |competition| {:conditions => ['entries.status = ?', Entry::STATUS[:winner]], :joins => :entry} }
#  named_scope :image, :conditions => {:flag => true}
  
  # Validations
  validates_presence_of :name, :description
  validates_inclusion_of :kind, :in => KIND.values
  
  validates_attachment_size :image, :less_than => 10.megabyte
  
  # validates_attachment_content_type :image, :content_type => ['image/jpeg', 'image/pjpeg', 'image/x-png', 'image/png', 'image/gif']
  validates_attachment_presence :image
  
  validate_on_create :presence_of_competition, :if => :competition_entry?

  validate :has_enough_tag
  validate :permission_to_enter_competition, :if => :competition_entry?
  
  # Protections
  attr_protected :person_id
  
  # Callbacks
  after_create :create_statistic
  after_create :assign_to_competition, :if => :competition_entry?
  after_create :promote_user
  
  # Validation Callbacks
  def presence_of_competition
    unless Competition.current.exists?(self.competition_id)
      errors.add :competition_id, "can't be blank"
    end
  end
  
  def permission_to_enter_competition
    if self.errors.empty?
      if not self.person.designer?
        self.errors.add_to_base 'Permission denied, you must be a designer to enter a competition'
      end
    
      if self.person.paypal_account.blank?
        self.errors.add_to_base 'Permission denied, you must record your Paypal email in your profile to enter a competition'
      end
    
      if self.person.created_at > Competition.find(self.competition_id).created_at
        self.errors.add_to_base 'Permission denied, your account is too new to enter this competition'
      end
    end
  end
  
  def has_enough_tag
    unless self.tag_list.size >= 3
      self.errors.add :tag_list, 'must include 3 or more tags'
    end
  end
  
  # Record Callbacks
  def assign_to_competition
    entry = self.entry || self.build_entry
    entry.logo_id   = self.id
    entry.person_id = self.person.id
    entry.enterable = self.enterable
    entry.kind      = self.hide_in_competition ? Entry::KIND[:public] : Entry::KIND[:private]
    entry.status    = Entry::STATUS[:entry]
    entry.save
  end
  
  def permission_to_delete
    if self.manager.nil?
      true
    else
      self.deletable? self.manager
    end
  end
  
  def promote_user
    if not self.person.designer? and not self.person.admin?
      self.person.kind = Person::KIND[:designer]
      self.person.save
    end
    
    true
  end
  
  # Paperclip
  LAST_ASSET_ID = 46210
  def id_partition(attachment, style)
     if attachment.instance.id > LAST_ASSET_ID
       ("%09d" % attachment.instance.id).scan(/\d{3}/).join("/")
     else
       "images/#{attachment.instance.id.to_s}"
     end
  end
  
  # Class Methods
  def self.search(keyword, options = {})
    options.reverse_merge!({
      :field_weights => {
        :name => 20,
        :person_nick_name => 10,
        :person_full_name => 5
      },
      :sort_mode => :desc
    })
    super(keyword, options)
  end  
  
  def self.latest
    Logo.find :all, :order => 'created_at DESC', :limit => 21
  end
    
  # Instance Methods
  def hit!(ip_address)
    self.statistic.hit! if page_views.hit?(ip_address)
  end
  
  def competition_entry?
    self.kind == KIND[:competition_entry]
  end
  
  def enterable
    if self.competition_id
      Competition.current.find(self.competition_id)
    end
  end
  
  def year
    if self.year_first_used
      option = YEAR_OPTIONS.detect { |y| y.last == self.year_first_used }
      option.first if option
    end
  end
  
  def competition_id=(value)
    @competition_id = value.to_i
  end
  
  def competition_id
    @competition_id or (self.competition and self.competition.id)
  end
  
  def competition
    self.entry.enterable if (self.competition_entry? and self.entry)
  end
  
  def average_rating
    if self.comments.has_rating.any?
      self.comments.has_rating.average(:rating).round.to_i
    else
      2
    end
  end
  
  def editable?(user)
    if user
      user.admin? or (user.id == self.person_id and self.comments.empty?)
    end
  end
  
  def deletable?(user)
    return false if not user
    if competition_entry?
      user.admin?
    else
      user.admin? or user.id == person_id
    end
  end
  
  def withdrawable?(user)
    return false if not user
    if user.admin? 
      competition_entry? and not entry.withdrawn?
    else
      competition_entry? and not entry.withdrawn? and self.person == user
    end
  end
  
  def withdrawn?
    competition_entry? and entry.withdrawn?
  end
  
  def purchasable?
    self.for_sale and self.price and self.price > 0 and not self.sold?
  end
  
  def process_express_payment(token, ip_address, buyer)
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
      
      self.sold!(buyer) if payment_result.success?
      
      payment_result.success?
    end
  end
    
  def sold!(buyer)
    self.sold = true
    self.buyer_id = buyer.id
    self.save
    
    Notifier.deliver_logo_sold(self)
  end
  
  def total_fee
    self.price
  end
  
  def total_fee_in_cents
    total_fee * 100
  end
  
  def payable_amount
    total_fee * (1 - COMMISSION_PERCENTAGE)
  end
  
  def payable?
    self.sold? and not success_payment
  end
  
  def viewable?(user)
    if self.competition and self.competition.private? and self.competition.closed?
      if user
        user.admin? or self.person == user or self.competition.person == user
      else
        false
      end
    else
      true
    end
  end
end
