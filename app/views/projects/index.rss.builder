xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Projects"
    xml.description "Projects"
    xml.link projects_url(:rss)

    for project in @projects
      xml.item do
        xml.title project.name
        xml.description textilize project.brief
        xml.pubDate project.created_at.to_s(:rfc822)
        xml.link project_url(project, :html)
        xml.guid project_url(project, :html)
      end
    end
  end
end
