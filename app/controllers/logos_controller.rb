class LogosController < ApplicationController
  before_filter :require_sign_in,   :except   => [:index, :show, :preview, :tags]
  before_filter :require_admin,     :only     => [:sales]
  before_filter :fetch_logo,        :only     => [:show, :edit, :update, :preview, :destroy, :pay, :process_express_payment, :sold]
  
  before_filter :permission_check,  :only     => [:show]
  before_filter :security_check,    :only     => [:edit, :update, :destroy]
  before_filter :trader_check,      :only     => [:sold]
  
  def index
    @keyword = params[:query]
    @show_private = false

    case params[:sort]
    when 'date', 'score', 'views'
      @sort = params[:sort]
    else
      @sort = 'date'
    end

    case params[:kind]
    when 'all', 'portfolio', 'competition_entries', 'competition_winners', 'for_sale', 'search_result'
      @kind = params[:kind]
    else
      @kind = 'all'
    end

    order = case @sort
    when 'score'
      :score
    when 'views'
      :view
    else
      :created_at
    end






    if params[:person_id]
      @person = Person.find params[:person_id]
      @show_private = true
      if params[:entry]
        @kind = "#{@person.nick_name}'s competition"
        if params[:won]
          @logos = Person.find(params[:person_id]).logos.winners.paginate(:page => params[:page], :per_page => Logo::PER_PAGE)
        else
          @logos = Person.find(params[:person_id]).logos.entry.paginate(:page => params[:page], :per_page => Logo::PER_PAGE)
        end
      else
        @kind = "#{@person.nick_name}'s portfolio"
        @logos = Person.find(params[:person_id]).logos.portfolio.paginate(:page => params[:page], :per_page => Logo::PER_PAGE)
      end
    end

      conditions = {}
     unless params[:query].blank?
      @logos = Logo.find_by_solr(params[:query]).docs
      else
        case @kind
    when 'all', 'search_result'
      conditions[:kind] = {}
    when 'portfolio'
      conditions[:kind] = Logo::KIND[:profile]
    when 'competition_winners'
      {:entry_status => Entry::STATUS[:winner]}
    when 'competition_entries'
      conditions[:kind] = Logo::KIND[:competition_entry]
    when 'for_sale'
      conditions[:for_sale] = true
    end
     @logos = Logo.find(:all, :conditions => conditions)
    
      end
    @logos = @logos.paginate :page => params[:page]
    respond_to do |want|
      want.html
      want.rss
    end
  end
  
  def tags
    @tags = Logo.tag_counts(:order => 'tags.name ASC')
  end
  
  def sales
    @logos = Logo.for_sale.paginate(:page => params[:page], :per_page => Logo::PER_PAGE)
  end

  def new
    @logo = current_user.logos.new
    if params[:competition_id]
      @logo.competition_id = params[:competition_id]
      @logo.kind = Logo::KIND[:competition_entry]
    end
  end
    
  def create
    @logo = current_user.logos.new params[:logo]
    if @logo.save
      message t('logo.flash.new')
      redirect_to @logo
    else
      render :action => 'new'
    end
  end
  
  def update
    if @logo.update_attributes params[:logo]
      message t('logo.flash.edit')
      redirect_to @logo
    else
      render :action => 'edit'
    end
  end
  
  def show
    @logo.hit! request.ip
  end
  
  def edit
    @logo.build_artwork unless @logo.artwork
  end
  
  def update
    if @logo.update_attributes params[:logo]
      message t('logo.flash.update')
      redirect_to @logo
    else
      render 'edit'
    end
  end
  
  def preview
    render :layout => false
  end
  
  def destroy
    if @logo.destroy
      message t('logo.flash.destroy')
      redirect_to logos_path
    else
      redirect_to @logo
    end
  end
  
  def pay
    if @logo.purchasable?
      if request.put?
        response = PAYPAL_EXPRESS_GATEWAY.setup_purchase(
          @logo.total_fee_in_cents,
          :ip                => request.remote_ip,
          :return_url        => process_express_payment_logo_url(@logo),
          :cancel_return_url => logo_url(@logo)
        )
        redirect_to PAYPAL_EXPRESS_GATEWAY.redirect_url_for(response.token)
      else
        render
      end
      
    else
      message t('logo.flash.cannot_purchase')
      redirect_to @logo
    end
  end
  
  def process_express_payment
    if not @logo.purchasable?
      message 'This logo is not for sale', :kind => 'error'
      redirect_to @logo
    else
      if @logo.process_express_payment(params[:token], request.remote_ip, current_user)
        Notifier.deliver_logo_sold @logo
        message 'Payment received, thank you!', :kind => 'success'
        redirect_to sold_logo_path(@logo)
      else
        message 'Payment decliend, please try again.', :kind => 'error'
        redirect_to @logo
      end
    end
  end
  
  def sold
  end
  
  private
  
  def fetch_logo
    @logo = Logo.find params[:id]
  end
  
  def permission_check
    forbidden unless @logo.viewable?(current_user)
  end
  
  def security_check
    forbidden unless can_edit?(@logo)
  end
  
  def trader_check
    forbidden unless [@logo.person, @logo.buyer].include?(current_user)
  end
end
