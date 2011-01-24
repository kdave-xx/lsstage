class ArtworksController < ApplicationController
  before_filter :require_sign_in
  before_filter :fetch_attachable
  
  def create
    @artwork      = @attachable.artwork || Artwork.new
    
    @artwork.attributes = params[:artwork]
    @artwork.person     = current_user
    @artwork.attachable = @attachable
    
    @artwork.save
    Notifier.deliver_logo_artwork_uploaded(current_user, @attachable)
    message 'Thank you, artwork uploaded', :kind => 'success'
    redirect_to @attachable
  end
  
  def show
    send_file @attachable.artwork.document.path
  end
  
  def fetch_attachable
    @attachable = case
    when params[:logo_id]
      Logo.find params[:logo_id]
    when params[:competition_id]
      Competition.find params[:competition_id]
    else
      page_not_found
    end
  end
  
end
