class EntriesController < ApplicationController
  before_filter :require_sign_in
  
  def rate
    @competition  = current_user.competitions.find params[:competition_id]
    @entry        = @competition.entries.find params[:id]
    
    @entry.rate! params[:rating]
  end
  
  def withdraw
    @competition  = Competition.find params[:competition_id]
    @entry        = current_user.entries.find params[:id]
    
    if @entry.withdraw!
      message t('entry.flash.withdraw')
    else
      message t('entry.flash.error')
    end
    
    redirect_to @competition
  end
  
  def pick
    @competition  = current_user.competitions.closed.find params[:id]
    @entry        = @competition.entries.find params[:competition_id]
    
    @entry.won!
    Notifier.deliver_choose_winner(@competition)
    message t('entry.flash.won')
    
    redirect_to @competition
  end
end
