xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Comments"
    xml.description "Comments"
    xml.link url_for(@commentable)
    
    for comment in @comments
      xml.item do
        xml.title comment.person.nick_name
        xml.description textilize comment.body
        xml.pubDate comment.created_at.to_s(:rfc822)
        xml.link "http://www.logosauce.com#{url_for(@commentable)}"
        xml.guid comment.id
      end
    end
  end
end
