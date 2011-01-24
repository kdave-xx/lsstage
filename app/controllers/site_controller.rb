class SiteController < ApplicationController
  def home
    @logos = Logo.image.latest
    @competitions = Competition.open.paid.approved.find(:all, :limit => 4)
    @projects = Project.open.paid.approved.find(:all, :limit => 4)
    @message = Announcement.find(:last)
    
#    @activities = ThinkingSphinx.search(:order => 'created_at DESC', :limit => 12)
    logos = Logo.image.find(:all, :conditions => ["created_at >= ?", 3.days.ago], :order => "created_at DESC", :limit => 5)
    compititions = Competition.find(:all, :conditions => ["created_at >= ?", 3.days.ago], :order => "created_at DESC", :limit => 5)
    projects = Project.find(:all, :conditions => ["created_at >= ?", 3.days.ago], :order => "created_at DESC", :limit => 5)
    comments = Comment.find(:all, :conditions => ["created_at >= ?", 3.days.ago], :order => "created_at DESC", :limit => 5)
    @activities = logos + compititions + projects + comments
    
  end
  
  def activities
#    @activities = ThinkingSphinx.search(:order => 'created_at DESC', :limit => 100)
    logos = Logo.image.find(:all, :conditions => ["created_at >= ?", 3.days.ago], :order => "created_at DESC", :limit => 50)
    compititions = Competition.find(:all, :conditions => ["created_at >= ?", 3.days.ago], :order => "created_at DESC", :limit => 50)
    projects = Project.find(:all, :conditions => ["created_at >= ?", 3.days.ago], :order => "created_at DESC", :limit => 50)
    comments = Comment.find(:all, :conditions => ["created_at >= ?", 3.days.ago], :order => "created_at DESC", :limit => 50)
    @activities = logos + compititions + projects + comments
  end
end

