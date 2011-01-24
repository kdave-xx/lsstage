class FavouritesController < ApplicationController
  before_filter :require_sign_in, :except => [:index]
  
  def index
    @person = Person.find(params[:person_id])
    @favourites = @person.favourites.paginate :page => params[:page]
  end

  def create
    current_user.favourites.create :logo_id => params[:logo_id]
    redirect_to person_favourites_path current_user
  end
  
  def destroy
    current_user.favourites.find(params[:id]).destroy
    redirect_to person_favourites_path current_user
  end
end
