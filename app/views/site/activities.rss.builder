xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Logo"
    xml.description "Lots of logos"
    xml.link root_url
    
    for activity in @activities
      xml.item do
        xml.title activity_status(activity)
        xml.description activity_status(activity)
        xml.pubDate activity.created_at.to_s(:rfc822)
      end
    end
  end
end
