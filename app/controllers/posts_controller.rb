class PostsController < ApplicationController
  before_filter :require_admin, :except => [:index, :show, :tags]
  
  def index
    unless params[:query].blank?
      @posts = Post.find_by_solr(params[:query]).docs
    else
      @posts = Post.find(:all, :order => 'created_at DESC')
     end
     @posts = @posts.paginate :page => params[:page]
    respond_to do |want|
      want.html
      want.rss
    end
  end
  
  def new
    @post = Post.new
  end
  
  def create
    @post = current_user.posts.new params[:post]
    if @post.save
      redirect_to @post
    else
      render :new
    end
  end
  
  def show
    @post = Post.find params[:id]
    @comments = @post.comments.paginate :page => 1
  end
  
  def edit
    @post = Post.find params[:id]
  end
  
  def update
    @post = Post.find params[:id]
    if @post.update_attributes(params[:post])
      redirect_to @post
    else
      render :new
    end
  end
  
  def destroy
    Post.find(params[:id]).destroy
    redirect_to posts_path
  end
  
  def tags
    @tags = Post.tag_counts(:order => 'tags.name ASC')
  end
end
