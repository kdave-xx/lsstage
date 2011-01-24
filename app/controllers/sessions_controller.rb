class SessionsController < ApplicationController
  before_filter :require_sign_in, :only => [:show, :destroy]

  def new
  end
  
  def show
  end
  
  def create
    user = Person.sign_in(params[:email], params[:password])
    if user
      sign_in(user, :issue_token => params[:remember_me])
      if session[:return_path]
        return_path = session[:return_path].dup
        session.delete :return_path
        redirect_to return_path
      else
        redirect_to root_path
      end
    else
      message t('session.sign_in_failed'), :kind => :error
      render :action => 'new'
    end
  end
  
  def destroy
    sign_out
    redirect_to root_path
  end
  
  def forget_password
  end

  def forget_password_commit
    person = Person.find_by_email params[:email]
    if person
      person.create_password_reset_coupon
      message "Done, please check your email."
      redirect_to new_session_path
    else
      message "Unknow email", :kind => :error
      redirect_to forget_password_session_path
    end
  end
  
  def reset_password
    @password_reset_coupon = PasswordResetCoupon.find_by_code(params[:code]) || raise(ActiveRecord::RecordNotFound)
    @person = @password_reset_coupon.person
  end
  
  def reset_password_commit
    @password_reset_coupon = PasswordResetCoupon.find_by_code(params[:code]) || raise(ActiveRecord::RecordNotFound)
    @person = @password_reset_coupon.person
    
    @person.password_reset = params[:person][:password_reset]
    @person.password_reset_confirmation = params[:person][:password_reset_confirmation]
    
    if @person.save
      @password_reset_coupon.destroy
      
      message 'Your password has successfully been reset.'
      sign_in @person
      redirect_to root_path
    else
      render :action => 'reset_password'
    end
  end
  
  
end
