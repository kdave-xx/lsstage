class PeopleController < ApplicationController
  before_filter :require_sign_in, :except => [:index, :new, :show, :create]
  
  before_filter :fetch, :only => [:show, :edit, :update, :email, :pay, :process_express_payment, :admin, :reset_avatar]
  before_filter :security_check, :only => [:edit, :update, :pay, :process_express_payment, :reset_avatar]
  
  before_filter :require_admin, :only => [:admin]
  
  def index
    @keyword = params[:query]
    case params[:kind]
    when 'everyone', 'designers', 'pro_designers', 'clients', 'top_designers_last_30_days', 'top_designers_all_time', 'competition_winners', 'search_result'
      @kind = params[:kind]
    else
      @kind = 'everyone'
    end

    @location = params[:location] || 'everywhere'

    @order = case params[:order]
    when 'score'
      :score
    when 'view'
      :view
    else
      :created_at
    end

    conditions = {}

    unless params[:query].blank?
      @people = Person.find_by_solr(params[:query]).docs
    else
      case @kind
      when 'designers'
        conditions[:kind] = Person::KIND[:designer]
      when 'pro_designers'
        conditions[:kind] = [Person::KIND[:pro_designer], Person::KIND[:paid_designer]]
      when 'top_designers_last_30_days'
        conditions[:created_at] = (Time.now..3.month.ago)
        conditions[:kind] = [Person::KIND[:designer], Person::KIND[:pro_designer], Person::KIND[:paid_designer]]
        @order = :score
      when 'top_designers_all_time'
        conditions[:kind] = [Person::KIND[:designer], Person::KIND[:pro_designer], Person::KIND[:paid_designer]]
        @order = :score
      when 'competition_winners'
        conditions[:competition_winner] = true
        @order = :last_won_at
      when 'clients'
        conditions[:kind] = Person::KIND[:client]
      end
      
      @people = Person.find(:all, :conditions => conditions, :order => "created_at DESC")
    end

    if @location != 'everywhere'
        conditions[:country] = @location
        @profiles = Profile.find(:all, :conditions => conditions)
        @people = []
        @profiles.each do |profile| @people << profile.person end
    end
     
  
 
      @people = @people.paginate :page => params[:page]
    respond_to do |want|
      want.html
      want.rss
    end
  end
  
  def new
    @person   = Person.new
    @profile  = @person.build_profile
  end
  
  def create
    @person   = Person.new params[:person]
    @profile  = @person.build_profile params[:profile]
    
    if @person.valid_with_captcha? and @profile.valid?
      @person.save
      @profile.person_id = @person.id
      @profile.save
      
      sign_in @person
      render 'thank'
    else
      render 'new'
    end
  end
  
  def show
    @person = Person.find params[:id]
    projects = Project.find(:all, :conditions => {:person_id => @person.id}, :order => 'created_at DESC', :limit => 8)
    logos = Logo.find(:all, :conditions => {:person_id => @person.id}, :order => 'created_at DESC', :limit => 8)
    compititions = Competition.find(:all, :conditions => {:person_id => @person.id}, :order => 'created_at DESC', :limit => 8)
    @activities = projects + logos + compititions
#    @activities = ThinkingSphinx.search(:order => 'created_at DESC', :conditions => {:person_id => @person.id}, :limit => 8)
    
    respond_to do |want|
      want.html
      want.rss
    end
  end
 
  
  def edit
  end
  
  def update
    @person.attributes  = params[:person]
    @profile.attributes = params[:profile]
    @profile.person_id = @person.id
    if @person.valid? and @profile.valid?
      @person.save
      @profile.save
      
      redirect_to @person
    else
      render :action => 'edit'
    end
  end
  
  def email
    if request.put?
      Notifier.deliver_user_message current_user, @person, params[:message]
      
      message 'Email sent.'
      redirect_to @person
    end
  end
  
  def pay
    if request.put?
      if @person.pro?
        message 'You are already a pro', :kind => 'error'
        redirect_to @person
      else
        response = PAYPAL_EXPRESS_GATEWAY.setup_purchase(
          @person.pro_fee_in_cents,
          :ip                => request.remote_ip,
          :return_url        => process_express_payment_person_url(@person),
          :cancel_return_url => person_url(@person)
        )
        redirect_to PAYPAL_EXPRESS_GATEWAY.redirect_url_for(response.token)
      end
    end
  end
  
  def process_express_payment
    if @person.pro?
      message 'You are already a pro', :kind => 'error'
    else
      if @person.process_express_payment(params[:token], request.remote_ip)
        message 'Now you are a pro, thank you!', :kind => 'success'
      else
        message 'Payment declined, please try again.', :kind => 'error'
      end
    end
    
    redirect_to @person
  end
  
  def admin
    if request.put?
      if @person.unprotected_update_attributes(params[:person])
        message 'Done!'
        redirect_to @person
      else
        render 'admin'
      end
    end
  end
  
  def reset_avatar
    @person.reset_avatar!
    message 'Done!'
    redirect_to @person
  end

  def deactivate
    @user = Person.find(params[:id])
     @user.update_attribute(:active, false)
     sign_out
     redirect_to root_path
  end

  def create_message
    @announcement = Announcement.new(params[:announcement])
#    @announcement.message  = params[:message]
       @announcement.save
       
    redirect_to :action => :show, :id => params[:id]
  end

  def announcement
    
     @announcement = Announcement.find(params[:id])
     @person = current_user
     @announcement.people << @person

    render :nothing => true

  end
  
  protected
  
  def fetch
    @person = Person.find params[:id]
    @profile = @person.profile
  end
  
  def security_check
    forbidden unless can_edit?(@person)
  end
end
