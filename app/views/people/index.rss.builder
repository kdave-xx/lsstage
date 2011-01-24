xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "People"
    xml.description "People"
    xml.link formatted_people_url(:rss)
    
    for person in @people
      description = textilize person.profile.biography
      description += image_tag(person.avatar.url(:thumb))
      xml.item do
        xml.title person.nick_name
        xml.description description
        xml.pubDate person.created_at.to_s(:rfc822)
        xml.link formatted_person_url(person, :html)
        xml.guid formatted_person_url(person, :html)
      end
    end
  end
end
