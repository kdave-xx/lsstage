xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Posts"
    xml.description "Lots of posts"
    xml.link formatted_posts_url(:rss)
    
    for post in @posts
      xml.item do
        xml.title post.name
        xml.description post.excerpt
        xml.pubDate post.created_at.to_s(:rfc822)
        xml.link formatted_post_url(post, :html)
        xml.guid formatted_post_url(post, :html)
      end
    end
  end
end
