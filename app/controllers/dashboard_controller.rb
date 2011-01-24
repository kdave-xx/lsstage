class DashboardController < ApplicationController
  before_filter :require_sign_in
  
  def index
    @comments = current_user.comments.first 10
    @comments_on_my_logos = current_user
  end
end
