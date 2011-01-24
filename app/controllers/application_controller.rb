# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  helper_method :signed_in?, :current_user, :current_token, :admin?, :can_edit?
  
  include SimpleCaptcha::ControllerHelpers

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'f7ca0e20b9de6861d2a99b2f9a6f9d4a'
  
  before_filter :authenticate_token
  
  protected
  
  def message(message, options = {})
    options.reverse_merge!({:kind => :message})
    
    flash[:notice] = message
    flash[:kind] = options[:kind]
  end
  
  def current_user
    if signed_in?
      @current_user ||= Person.find_by_id session[SESSION_USER]
    end
  end
  
  def current_token
    if signed_in?
      @current_token ||= Token.find_by_secret cookies[SESSION_TOKEN]
    end
  end
  
  def require_sign_in
    unless signed_in?
      message t('session.sign_in_required')
      session[:return_path] = request.path
      redirect_to new_session_path
    end
  end
  
  
  def require_admin
    unless signed_in? and current_user.admin?
      message t('session.admin_required')
      redirect_to new_session_path
    end
  end
  
  def authenticate_token
    if not signed_in? and has_token?
      token = Token.find :first, :conditions => {:secret => cookies[SESSION_TOKEN]}
      if token
        if token.expired?
          revoke_token token
        else
          sign_in token.person
        end
      else
        revoke_client_token
      end
    end
  end
  
  def sign_in(person, options = {})
    issue_token person if options[:issue_token]
    session[SESSION_USER] = person.id
  end
  
  def signed_in?
    not session[SESSION_USER].blank?
  end
  
  def sign_out
    if has_token?
      token = current_user.tokens.find :first, :conditions => {:secret => cookies[SESSION_TOKEN]}
      if token
        revoke_token token
      else
        revoke_client_token
      end
    end
    revoke_client_session
  end
  
  def has_token?
    not cookies[SESSION_TOKEN].blank?
  end
  
  def issue_token(person)
    token = person.tokens.generate request.remote_ip
    cookies[SESSION_TOKEN] = {:value => token.secret, :expires => token.expire}
  end
  
  def revoke_token(token)
    revoke_server_token token
    revoke_client_token
  end
  
  def revoke_server_token(token)
    token.destroy
  end
  
  def revoke_client_token
    cookies.delete SESSION_TOKEN
  end
  
  def revoke_client_session
    session[SESSION_USER] = nil
  end
  
  def forbidden
    render :file => "#{RAILS_ROOT}/public/403.html", :status	=> 403
  end

  def page_not_found
	  render :file => "#{RAILS_ROOT}/public/404.html", :status	=> 404
  end
  
  def internal_server_error
    render :file => "#{RAILS_ROOT}/public/500.html", :status	=> 500
  end
  
  def ajax_validation(record)
    render :partial => 'shared/ajax_validation', :locals => {:record => record}
  end
  
  def admin?
    current_user and current_user.admin?
  end
  
  def can_see?(record)
    return true if admin?
    
    case
    when record.is_a?(Project)
      if record.private?
        current_user and current_user.pro?
      else
        true
      end
    end
  end
  
  def can_edit?(record)
    return true if admin?
    
    case
    when record.is_a?(Logo)
      record.person == current_user and record.editable?(current_user)
    when record.is_a?(Competition)
      record.person == current_user and not record.approved?
    when record.is_a?(Person)
      record == current_user
    when record.is_a?(Comment)
      record.person == current_user
    when record.is_a?(Project)
      record.person == current_user and not record.approved?
    else
      false
    end
  end

  
end
