class BidsController < ApplicationController
  before_filter :require_sign_in
  
  before_filter :fetch_project
  before_filter :fetch_bid, :only => [:show, :won, :lost, :file]
  before_filter :permission_check, :except => [:file]
  
  def new
    @bid = @project.bids.new
  end
  
  def create
    @bid = @project.bids.new params[:bid]
    @bid.person = current_user
    
    if @bid.valid?
      @bid.save
      message t('bid.create.flash.done')
      redirect_to @project
    else
      render 'new'
    end
  end

  def edit
    @bid = @project.bids.find(params[:id])
  end

  def update
    @bid = @project.bids.find(params[:id])
    if @bid.update_attributes params[:bid]
      message 'Done!'
      redirect_to project_bid_url(@project, @bid)
    else
      render 'edit'
    end
  end
  
  def show
    forbidden unless can_edit?(@project) or @bid.person == current_user
  end
  
  def won
    
    forbidden unless can_edit?(@project)
    @bid.won!
    message t('bid.won.flash.done')
    redirect_to @project
  end
  
  def lost
    forbidden unless can_edit?(@project)
    @bid.lost!
    message t('bid.lost.flash.done')
    redirect_to @project
  end

  def file    
    send_file @bid.image.path, :type => "application/pdf"
  end
  

  private
  
  def fetch_project
    @project = Project.approved.find params[:project_id]
  end
  
  def fetch_bid
    @bid = @project.bids.find params[:id]
  end
    
  def permission_check
    forbidden unless @project.viewable?(current_user)
  end
end

