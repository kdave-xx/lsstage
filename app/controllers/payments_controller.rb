class PaymentsController < ApplicationController
  include ActiveMerchant::Billing::Integrations
  
  before_filter :require_admin
  before_filter :fetch_payable, :only => [:create]

  def create
    if @payable.payments.create
      message 'Payment Submitted', :kind => 'success'
    else
      message 'Payment Failed', :kind => 'error'
    end
    
    redirect_to @payable
  end
  
  def ipn
    notify = Paypal::Notification.new request.raw_post
    if notify.acknowledge and notify.complete?
      payment = Payment.find(notify)
      payment.success!
    else
      payment.failed!
    end
    
    render :nothing => true
  end
  
  protected
  
  def fetch_payable
    @payable = case
    when params[:competition_id]
      Competition.find params[:competition_id]
    when params[:logo_id]
      Logo.find params[:logo_id]
    else
      page_not_found
    end
  end
end
