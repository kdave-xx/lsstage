# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include TagsHelper
  
  # Layout
  def javascript(js)
    content_for :head do
      javascript_include_tag js
    end
  end
  
  def stylesheet(css)
    content_for :head do
      stylesheet_link_tag css
    end
  end
  
  # Flash
  def message
    if flash[:notice]
      content_tag :div, :class => flash[:kind].to_s do
        h flash[:notice]
      end
    end
  end
  
  # Link
  def link_to_person(person)
    link_to(h(person.nick_name), person) if person
  end
  
  def edit(&block)
    concat(capture(&block))
  end
  
  # Common
  def state_status(tab)
    if tab == 'people' and controller.controller_name == tab
      if current_user and not params[:id] == current_user.id.to_s
        {:class => 'active'}
      elsif not current_user
        {:class => 'active'}
      end
    else
      if tab == 'my_profile'
        if controller.controller_name == 'people' and params[:id] == current_user.id.to_s
          {:class => 'profile active', :title => 'Click to view your profile page where you can edit your details and more'}
        else
          {:class => 'profile', :title => 'Click to view your profile page where you can edit your details and more'}
        end
      else
        {:class => 'active'} if controller.controller_name == tab
      end
    end
  end
  
  def person_kind(person)
    case person.kind
    when Person::KIND[:regular]
      'Regular'
    when Person::KIND[:designer], Person::KIND[:pro_designer], Person::KIND[:paid_designer]
      'Designer'
    when Person::KIND[:client]
      'Client'
    when Person::KIND[:admin]
      'Administrator'
    end
  end
  
  def link_to_twitter(label, status)
    link_to label, "http://twitter.com/home?status=#{status}", :id => 'tweet_link', :title => 'Tweet this logo'
  end
  
  def activity_status(activity)
    case
    when activity.is_a?(Person)
      "#{h activity.full_name} joined logosauce."
    when activity.is_a?(Logo)
      "#{h activity.person.full_name} uploaded a logo #{h activity.name}."
    when activity.is_a?(Competition)
      "#{h activity.person.full_name} started a competition #{h activity.name}."
    when activity.is_a?(Project)
      "#{h activity.person.full_name} started a project: #{h activity.name}."
    when activity.is_a?(Comment)
      "#{h activity.person.full_name} placed a comment."
    when activity.is_a?(Post)
      "#{h activity.person.full_name} posted a blog article logo #{h activity.name}."
    end
  end
  
  def link_to_title_menu(type, title)
    link_to h(type.titleize), '#', :title => title, :class => 'menu_link'
  end
  
  def link_to_toggle_help 
    link_to_function 'Help', "Effect.toggle('help_slide_down', 'blind')", :title => 'click to reveal slide down help about this page'
  end
  def link_to_toggle_about 
    link_to_function '?', "Effect.toggle('about_slide_down', 'blind')", :title => 'click to reveal slide down info about BrandFM'
  end

  
end
