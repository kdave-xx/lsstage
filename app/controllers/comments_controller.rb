class CommentsController < ApplicationController
  before_filter :require_sign_in, :except => [:index]
  before_filter :fetch_commentable, :only => [:index, :create, :destroy]
  before_filter :require_admin, :only => [:destroy]

  before_filter :fetch_comment, :only => [:edit, :update]
  before_filter :security_check, :only => [:edit, :update]

  def new
  end
  
  def index
    @comments = @commentable.comments.paginate :page => params[:page]
    respond_to do |want|
      want.html
      want.rss
    end
  end
  
  def create
    @comment = current_user.comments.new params[:comment]
    @comment.commentable = @commentable
    
    respond_to do |want|
      if @comment.save
        want.js
        want.html { redirect_to @commentable }
      else
        want.js   { ajax_validation @comment }
        want.html { render :action => 'new' } 
      end
    end
  end
  
  def edit
  end
  
  def update
    if @comment.update_attributes params[:comment]
      message 'Done!'
      redirect_to @comment.commentable
    else
      render 'edit'
    end
  end
  
  def bury
    @comment = Comment.find params[:id]
    @comment.bury current_user
    
    respond_to do |want|
      want.js
    end
  end
  
  def unbury
    @comment = Comment.find params[:id]
    @comment.unbury current_user

    respond_to do |want|
      want.js
    end
  end
  
  def destroy
    Comment.find(params[:id]).destroy
    message 'Done!'
    redirect_to @commentable
  end
  
  protected
  
  def fetch_commentable
    @commentable = case
    when params[:logo_id]
      Logo.find params[:logo_id]
    when params[:competition_id]
      Competition.find params[:competition_id]
    when params[:post_id]
      Post.find params[:post_id]
    when (params[:project_id] and not params[:bid_id])
      Project.available(current_user).find params[:project_id]
    when (params[:project_id] and params[:bid_id])
      Bid.find params[:bid_id]
    else
      page_not_found
    end
    
  end
  
  def fetch_comment
    @comment = Comment.find params[:id]
  end
  
  def security_check
    forbidden unless can_edit?(@comment)
  end
end