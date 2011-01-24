xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Logo"
    xml.description "Lots of logos"
    xml.description "Lots of logos"
    xml.link logos_url(:rss)
    
    for logo in @logos
      description = textilize logo.description
      description += image_tag(logo.image.url(:thumb))
      xml.item do
        xml.title logo.name
        xml.description description
        xml.pubDate logo.created_at.to_s(:rfc822)
        xml.link logo_url(logo, :html)
        xml.guid logo_url(logo, :html)
      end
    end
  end
end
