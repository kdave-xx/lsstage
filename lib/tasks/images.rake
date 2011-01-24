namespace :db do
  desc "update delta according to images for logo"
  task :update_delta => :environment do
    puts "Starting"
    logos = Logo.all
    s3 = AmazonS3Asset.new
    logos.each do |c|
      path = c.image.path(:original)
      key = path.sub(/^./,"")
      puts key
      if s3.exists?("logosauce-live", key)
        c.flag = true
        c.save
        puts "Image exists"
      end
    end
    puts "Finished"
  end
end



