class BlogImagesController < ApplicationController
  before_filter :require_admin, :except => [:show]
  
  def index
    @blog_images = BlogImage.paginate :page => params[:page]
  end
  
  def new
    @blog_image = BlogImage.new
  end
  
  def show
    @blog_image = BlogImage.find(params[:id])
    send_file @blog_image.document.path, :filename => @blog_image.document.original_filename, :disposition => 'inline'
  end
  
  def create
    @blog_image = BlogImage.new(params[:blog_image])
    if @blog_image.save
      redirect_to blog_images_path
    else
      render 'new'
    end
  end
  
  
end

