class TransactionsController < ApplicationController
  before_filter :require_admin
  before_filter :fetch_loggable
  
  def index
    @transactions = @loggable.transactions
  end
  
  protected
  
  def fetch_loggable
    @loggable = case
    when params[:competition_id]
      Competition.find params[:competition_id]
    when params[:project_id] 
      Project.find params[:project_id]
    when params[:person_id]
      Person.find params[:person_id]
    when params[:logo_id]
      Logo.find params[:logo_id]
    else
      page_not_found
    end
  end
  
end
