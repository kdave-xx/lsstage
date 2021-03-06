class CompetitionsController < ApplicationController
  include ActiveMerchant::Billing::Integrations
  
  before_filter :fetch_competition, :only => [:edit, :update, :approve, :show, :wall, :admin]
  
  before_filter :require_sign_in, :only => [:new, :edit, :create, :update, :mine]  
  before_filter :permission_check,:only => [:show, :wall]
  before_filter :security_check,  :only => [:edit, :update]
  before_filter :require_admin,   :only => [:unpaid, :unapproved, :approve, :admin]
  
  def index
   case params[:kind]
    when 'all', 'open', 'closed', 'my', 'winners', 'search_result'
      @kind = params[:kind]
    else
      @kind = 'open'
    end

    case params[:sort]
    when 'open_date', 'close_date', 'prize_value'
      @sort = params[:sort]
    else
      @sort = 'open_date'
    end

    order = case @sort
    when 'open_date'
      'open_on DESC'
    when 'close_date'
      'close_on DESC'
    else
      'prize_value DESC'
    end

    if params[:person_id]
      @competitions = Person.find(params[:person_id]).competitions.paginate(:page => params[:page])
    else
      unless params[:query].blank?
          @competitions = Competition.find_by_solr(params[:query]).docs
        else
          case @kind
      when 'open'
        @competitions = Competition.open.paginate :order => order, :page => params[:page]
      when 'closed'
        @competitions = Competition.closed.paginate :order => order, :page => params[:page]
      when 'my'
        @competitions = Competition.by(current_user).paginate :order => order, :page => params[:page]
      when 'winners'
        @competitions = Competition.has_winner.paginate :order => order, :page => params[:page]
      else
        @competitions = Competition.paid_approved.all
      end
        end
    end
      @competitions = @competitions.paginate :page => params[:page]
    respond_to do |want|
      want.html
      want.rss
    end
  end
  
  def new
    @competition = Competition.new
    @competition.open_on = Time.now
  end
  
  def unpaid
    @kind = 'unpaid'
    @sort = 'close_date'
    @competitions = Competition.unpaid.paginate :page => params[:page]
    render 'index'
  end
  
  def unapproved
    @kind = 'unapproved'
    @sort = 'close_date'
    @competitions = Competition.paid.unapproved.paginate :page => params[:page]
    render 'index'
  end
  
  def client_unpaid
    @kind = 'client_unpaid'
    @sort = 'close_date'
    @competitions = Competition.client_unpaid.paginate :page => params[:page]
    render 'index'
  end
  
  def client_paid
    @kind = 'client_paid'
    @sort = 'close_date'
    @competitions = Competition.transferred.paginate :page => params[:page]
    render 'index'
  end
  
      
  def create
    @competition = current_user.competitions.new params[:competition]
    if @competition.save
      redirect_to pay_competition_path(@competition)
    else
      render :action => 'new'
    end
  end
  
  def show
    @entries      = @competition.entries.paginate :page => params[:page]
  end
  
  def pay
    @competition = current_user.competitions.find params[:id]
    
    if request.put?
      if @competition.paid?
        message 'This invoice is already paid', :kind => 'error'
        redirect_to @competition
      else
        response = PAYPAL_EXPRESS_GATEWAY.setup_purchase(
          @competition.total_fee_in_cents,
          :ip                => request.remote_ip,
          :return_url        => process_express_payment_competition_url(@competition),
          :cancel_return_url => competition_url(@competition)
        )
        redirect_to PAYPAL_EXPRESS_GATEWAY.redirect_url_for(response.token)
      end
    end
  end
  
  def process_express_payment
    @competition = current_user.competitions.find params[:id]
    
    if @competition.paid?
      message 'This competition is already paid', :kind => 'error'
    else
      if @competition.process_express_payment(params[:token], request.remote_ip)
        message 'Payment received, thank you!', :kind => 'success'
      else
        message 'Payment declined, please try again.', :kind => 'error'
      end
    end
    
    redirect_to @competition
  end
  
  def edit
  end
  
  def update
    if @competition.update_attributes params[:competition]
      message t('competition.flash.edit')
      redirect_to @competition
    else
      render 'edit'
    end
  end

  def approve
    @competition.approve!
    Notifier.deliver_generate_compitition_invoices @competition
    message t('competition.flash.approve')
    redirect_to @competition
  end
  
  def admin
    if request.put?
      if @competition.unprotected_update_attributes(params[:competition])
         if @competition.approved?
          Notifier.deliver_generate_compitition_invoices @competition
        else
          Notifier.deliver_competition_declined_info @competition
        end
        message 'Done!'
        redirect_to @competition
      else
        render 'admin'
      end
    end
  end
  
  def wall
    render :layout => 'wallview'
  end
  
  protected
  
  def fetch_competition
    @competition  = Competition.find(params[:id])
  end
  
  def permission_check
    forbidden unless @competition.viewable?(current_user)
  end
  
  def security_check
    forbidden unless can_edit?(@competition)
  end
end
