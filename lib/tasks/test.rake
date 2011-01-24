namespace :db do
  desc "update_delta according to images for logo"
  task :update => :environment do
    puts "Starting"
    logo = Logo.find_by_id(10050)
#    s3 = AmazonS3Asset.new
#    logos.each do |c|
#      raise logo.image.path(:original).inspect
        raise AmazonS3Asset.new.exists?("logosauce-live", "system/images/10050/original/10050.jpg").inspect
      if AmazonS3Asset.new.exists?("logosauce-live", logo.image.path(:original))
        logo.flag = true
        logo.save!
        puts "Image exists"
      else
       puts "Leave"
      end
#    end
    puts "Finished"
  end
end



