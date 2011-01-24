module EntriesHelper
  def rating_stars(competition, entry)
    [1, 2, 3].map do |rating|
      link_to_remote "&nbsp;", :url => rate_competition_entry_path(competition, entry, :rating => rating), :method => :post, :html => {:class => "star_#{rating}"}
    end
  end
  
  def rating_stars_static(competition, entry)
    [1, 2, 3].map do |rating|
      content_tag :span, '&nbsp;', :class => "star_#{rating}"
    end
  end
  
end
