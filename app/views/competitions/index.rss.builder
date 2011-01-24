xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Competitions"
    xml.description "Competitions"
    xml.link competitions_url(:rss)
    
    for competition in @competitions
      xml.item do
        xml.title competition.name
        xml.description textilize competition.description
        xml.pubDate competition.created_at.to_s(:rfc822)
        xml.link competition_url(competition, :html)
        xml.guid competition_url(competition, :html)
      end
      for entry in competition.entries
        description = textilize entry.logo.description
        description += image_tag(entry.logo.image.url(:thumb))
        xml.item do
        xml.title entry.logo.name
        xml.description description
        xml.pubDate entry.logo.created_at.to_s(:rfc822)
        xml.link logo_url(entry.logo, :html)
        xml.guid logo_url(entry.logo, :html)
      end
      for comment in competition.comments
        description = textilize comment.body
        description += image_tag(comment.person.avatar.url(:thumb))
        xml.item do
        xml.title comment.person.full_name
        xml.description description
        xml.pubDate entry.logo.created_at.to_s(:rfc822)
      end
      end
    end
  end
end
end
