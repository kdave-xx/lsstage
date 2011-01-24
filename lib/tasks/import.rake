namespace :ls do
  BASE_PATH = "/home/logosauce/production.logosauce.com/current/public/images"
  
  desc 'Import old previous data'
  task :import_logos => :environment do
    class PreviousUser < ActiveRecord::Base
      default_scope :conditions => ['deleted_at IS NULL']
      establish_connection 'previous'
      set_table_name 'users'
      set_inheritance_column nil
      
      def avatar
        path = "#{BASE_PATH}/profiles/original/#{self.id}.#{self.image_extension}"
        puts "Avatar Path #{path}"
        if File.exists? path
          puts "Avatar exist"
          File.new path
        end
      end
    end

    class PreviousLogo < ActiveRecord::Base
      default_scope :conditions => ['deleted_at IS NULL']
      establish_connection 'previous'
      set_table_name 'logos'

      def original_file
        path = "#{BASE_PATH}/logos/original/#{self.id}.#{self.image_extension}"
        puts "Logo Path #{path}"
        if File.exists? path
          puts "Logo exist"
          File.new path
        end
      end
      
      def tags
        PreviousTag.find_by_sql(
          ["SELECT tags.* FROM logos_tags JOIN tags ON tags.id = logos_tags.tag_id WHERE logos_tags.logo_id = ?", self.id]
        ).collect{ |tag| tag.name }
      end
    end

    class PreviousComment < ActiveRecord::Base
      default_scope :conditions => ['deleted_at IS NULL']
      establish_connection 'previous'
      set_table_name 'logo_comments'
    end

    class PreviousCountryCode < ActiveRecord::Base
      establish_connection 'previous'
      set_table_name 'countries'
    end

    class PreviousTag < ActiveRecord::Base
      establish_connection 'previous'
      set_table_name 'tags'
    end

    def find_or_import_user(id)
      person = Person.find_by_id(id) || Person.new

      if person.new_record?
        user  = PreviousUser.find_by_id(id)
        if user
          person.id                     = user.id
          person.nick_name              = user.nickname
          person.first_name             = user.first_name
          person.last_name              = user.last_name
          person.email                  = user.email
          person.paypal_account         = user.paypal_email
          person.last_login_at          = user.last_login_at
          person.last_login_ip_address  = user.last_login_ip_address
          person.password               = user.password
          person.password_confirmation  = user.password
          person.created_at             = user.created_at
          person.updated_at             = user.updated_at
          person.old_user_id            = user.id
          if user.avatar
            person.avatar = user.avatar
          end

          unless person.save(false)
            puts "** Error importing user #{user.id}: #{person.errors.full_messages}"
          else
            puts "Imported user #{user.id}"
          end

          profile                 = person.build_profile
          profile.job_title       = user.job_title
          profile.company         = user.company
          profile.company_website = user.company_website
          profile.location        = user.location
          profile.country         = PreviousCountryCode.find_by_code2(user.country_code).try :name
          profile.biography       = user.biography
          profile.created_at      = user.created_at
          profile.updated_at      = user.updated_at

          unless profile.save(false)
            puts "** Error importing user profile #{user.id}: #{profile.errors.full_messages}"
          else
            puts "Imported profile #{profile.id}"
          end

        else
          puts "** Error user with email #{email} does not exist"
        end
      end

      person
    end
    

    PreviousLogo.find(:all, :conditions => ['id > 78767']).each do |previous_logo|
      user                      = PreviousUser.find_by_id(previous_logo.user_id)
      existing_logo = Logo.find_by_id(previous_logo.id)
      if user and not existing_logo
        person                    = find_or_import_user(user.id)
        logo                      = person.logos.new
        logo.id                   = previous_logo.id
        logo.kind                 = previous_logo.competition_id.nil? ? Logo::KIND[:profile] : Logo::KIND[:competition_entry]
        logo.name                 = previous_logo.name
        logo.strapline            = previous_logo.strapline
        logo.description          = previous_logo.description
        logo.brand_name           = previous_logo.brand
        logo.brand_owner          = previous_logo.brand_owner
        logo.brand_owner_website  = previous_logo.brand_owner_website
        logo.access               = previous_logo.access
        logo.access_website       = previous_logo.access_website
        logo.year_first_used      = previous_logo.year_first_used
        logo.tag_list             = previous_logo.tags.join(',')
        logo.created_at           = previous_logo.created_at
        logo.updated_at           = previous_logo.updated_at
        logo.old_logo_id          = previous_logo.id
        logo.for_sale             = (previous_logo.status == 'for_sale')
        if previous_logo.original_file
          logo.image = previous_logo.original_file
        end
          

        unless logo.save(false)
          puts "** Error importing logo #{previous_logo.id}: #{logo.errors.full_messages}"
        end

        logo.statistic.number_of_views = previous_logo.num_views

        PreviousComment.find(:all, :conditions => {:logo_id => previous_logo.id}).each do |previous_comment|
          user = PreviousUser.find_by_id(previous_comment.user_id)
          if user
            person              = find_or_import_user(user.id)

            comment             = logo.comments.new
            comment.commentable = logo
            comment.person      = person
            comment.rating      = (previous_comment.rating + 2)
            comment.body        = previous_comment.comment
            comment.created_at  = previous_comment.created_at
            comment.updated_at  = previous_comment.updated_at

            unless comment.save(false)
              puts "** Error importing comment #{previous_comment.id}: #{comment.errors.full_messages}"
            end
          else
            puts "** Error comment owner #{previous_comment.id} does not exist"
          end
        end
        
      else
        puts "** Error logo owner #{previous_logo.id} does not exist"
      end
    end
    
  end

  desc 'Import old previous data'
  task :import_competitions => :environment do
    class PreviousUser < ActiveRecord::Base
      default_scope :conditions => ['deleted_at IS NULL']
      establish_connection 'previous'
      set_table_name 'users'
      set_inheritance_column nil
      
      def avatar
        path = "#{BASE_PATH}/profiles/original/#{self.id}.#{self.image_extension}"
        puts "Avatar Path #{path}"
        if File.exists? path
          puts "Avatar exist"
          File.new path
        end
      end
    end

    class PreviousLogo < ActiveRecord::Base
      default_scope :conditions => ['deleted_at IS NULL']
      establish_connection 'previous'
      set_table_name 'logos'

      def original_file
        path = "#{BASE_PATH}/logos/original/#{self.id}.#{self.image_extension}"
        puts "Logo Path #{path}"
        if File.exists? path
          puts "Logo exist"
          File.new path
        end
      end
      
      def tags
        PreviousTag.find_by_sql(
          ["SELECT tags.* FROM logos_tags JOIN tags ON tags.id = logos_tags.tag_id AND tags.category IS NULL WHERE logos_tags.logo_id = ?", self.id]
        ).collect{ |tag| tag.name }
      end
    end

    class PreviousComment < ActiveRecord::Base
      default_scope :conditions => ['deleted_at IS NULL']
      establish_connection 'previous'
      set_table_name 'logo_comments'
    end

    class PreviousCountryCode < ActiveRecord::Base
      establish_connection 'previous'
      set_table_name 'countries'
    end

    class PreviousTag < ActiveRecord::Base
      establish_connection 'previous'
      set_table_name 'tags'
    end
    
    class PreviousCompetition < ActiveRecord::Base
      default_scope :conditions => ['deleted_at IS NULL']
      establish_connection 'previous'
      set_table_name 'competitions'
    end

    class PreviousCompetitionComment < ActiveRecord::Base
      default_scope :conditions => ['deleted_at IS NULL']
      establish_connection 'previous'
      set_table_name 'competition_comments'
    end
    

    def find_or_import_user(email)
      person = Person.find_by_email(email) || Person.new

      if person.new_record?
        user  = PreviousUser.find_by_email(email)
        if user
          person.nick_name              = user.nickname
          person.first_name             = user.first_name
          person.last_name              = user.last_name
          person.email                  = user.email
          person.paypal_account         = user.paypal_email
          person.last_login_at          = user.last_login_at
          person.last_login_ip_address  = user.last_login_ip_address
          person.password               = user.password
          person.password_confirmation  = user.password
          person.created_at             = user.created_at
          person.updated_at             = user.updated_at
          person.old_user_id            = user.id
          if user.avatar
            person.avatar = user.avatar
          end

          unless person.save(false)
            puts "** Error importing user #{user.id}: #{person.errors.full_messages}"
          else
            puts "Imported user #{user.id}"
          end

          profile                 = person.build_profile
          profile.job_title       = user.job_title
          profile.company         = user.company
          profile.company_website = user.company_website
          profile.location        = user.location
          profile.country         = PreviousCountryCode.find_by_code2(user.country_code).try :name
          profile.biography       = user.biography
          profile.created_at      = user.created_at
          profile.updated_at      = user.updated_at

          unless profile.save(false)
            puts "** Error importing user profile #{user.id}: #{profile.errors.full_messages}"
          else
            puts "Imported profile #{profile.id}"
          end

        else
          puts "** Error user with email #{email} does not exist"
        end
      end

      person
    end
    
    
    PreviousCompetition.find(:all).each do |previous_competition|
      competition = Competition.new
      new_record = true

      if Competition.find_by_id(previous_competition.id)
        puts "HIT"
        competition = Competition.find_by_id(previous_competition.id)
        new_record = false
      end

      if new_record
        competition.id = previous_competition.id
      end
      competition.person_id = previous_competition.user_id
      competition.name = previous_competition.name
      competition.description = previous_competition.description
      competition.organization = previous_competition.organization == 'nonprofit' ? Competition::ORGANIZATION[:non_profit] : Competition::ORGANIZATION[:commercial]
      competition.private = previous_competition.private
      competition.prize = previous_competition.cash_prize? ? Competition::PRIZE[:cash] : Competition::PRIZE[:non_cash]
      competition.prize_value = previous_competition.prize_value
      competition.created_at = previous_competition.created_at
      competition.updated_at = previous_competition.updated_at
      competition.open_on = previous_competition.opens_at.to_date
      competition.close_on = previous_competition.closes_at.to_date
      competition.approved_at = previous_competition.approved_at
      competition.approved = (not previous_competition.approved_at.nil?)
      competition.paid_at = previous_competition.fee_paid_at
      competition.paid = true unless competition.paid_at.nil?
      
      competition.winner_chosen = (not previous_competition.winning_logo_id.nil?)
      competition.save(false)
      
      if new_record
        competition_comments = PreviousCompetitionComment.find(:all, :conditions => {:competition_id => previous_competition.id})
      
        competition_comments.each do |previous_comment|
          comment = Comment.new
          previous_commentter = Person.find_by_old_user_id previous_comment.user_id
          if not previous_commentter
            previous_commentter = find_or_import_user(PreviousUser.find_by_id(previous_comment.user_id).email)
          end
          comment.person = previous_commentter
          comment.body = previous_comment.comment
          comment.created_at = previous_comment.created_at
          comment.updated_at = previous_comment.updated_at
          comment.commentable = competition
          comment.save(false)
        end
      
        competition_logos = PreviousLogo.find(:all, :conditions => {:competition_id => previous_competition.id})
        competition_logos.each do |previous_logo|
          logo = Logo.find_by_old_logo_id previous_logo.id
          if logo
            entry = Entry.new
            entry.logo_id   = logo.id
            entry.person_id = logo.person.id
            entry.enterable = competition
            entry.kind      = previous_logo.visible ? Entry::KIND[:public] : Entry::KIND[:private]
            entry.status    = previous_logo.id == previous_competition.winning_logo_id ? Entry::STATUS[:winner] : Entry::STATUS[:entry]
            entry.save(false)
          end
        end
    end
    end
  end
  
  task :import_views => :environment do
    class PreviousLogoView < ActiveRecord::Base
      establish_connection 'previous'
      set_table_name 'logo_views'
    end
    
    #Logo.all.each do |logo|
    #  puts "Working on logo: #{logo.id}" if logo.id % 10 == 0
    #  logo.statistic.number_of_views = PreviousLogoView.count(:conditions => {:logo_id => logo.old_logo_id})
    #  logo.statistic.save
    #end
    
    Person.all.each do |person|
      puts "Working on person #{person.id}" if person.id % 10 == 0
      person.statistic.number_of_views = person.logos.map { |logo| logo.statistic.number_of_views }.sum
      person.statistic.save
    end
  end

  task :import_blogs => :environment do 
    class PreviousUser < ActiveRecord::Base
      default_scope :conditions => ['deleted_at IS NULL']
      establish_connection 'previous'
      set_table_name 'users'
      set_inheritance_column nil
      
      def avatar
        path = "#{BASE_PATH}/profiles/original/#{self.id}.#{self.image_extension}"
        puts "Avatar Path #{path}"
        if File.exists? path
          puts "Avatar exist"
          File.new path
        end
      end
    end
    
    class PreviousTag < ActiveRecord::Base
      establish_connection 'previous'
      set_table_name 'tags'
    end

    class PreviousCountryCode < ActiveRecord::Base
      establish_connection 'previous'
      set_table_name 'countries'
    end

    class PreviousPost < ActiveRecord::Base
      default_scope :conditions => ['deleted_at IS NULL']
      establish_connection 'previous'
      set_table_name 'posts'
      
      def tags
        PreviousTag.find_by_sql(
          ["SELECT tags.* FROM posts_tags JOIN tags ON tags.id = posts_tags.tag_id AND tags.category IS NULL WHERE posts_tags.post_id = ?", self.id]
        ).collect{ |tag| tag.name }
      end
    end
    
    class PreviousComment < ActiveRecord::Base
      default_scope :conditions => ['deleted_at IS NULL']
      establish_connection 'previous'
      set_table_name 'post_comments'
    end
    
    def find_or_import_user(email)
      person = Person.find_by_email(email) || Person.new

      if person.new_record?
        user  = PreviousUser.find_by_email(email)
        if user
          person.nick_name              = user.nickname
          person.first_name             = user.first_name
          person.last_name              = user.last_name
          person.email                  = user.email
          person.paypal_account         = user.paypal_email
          person.last_login_at          = user.last_login_at
          person.last_login_ip_address  = user.last_login_ip_address
          person.password               = user.password
          person.password_confirmation  = user.password
          person.created_at             = user.created_at
          person.updated_at             = user.updated_at
          person.old_user_id            = user.id
          if user.avatar
            person.avatar = user.avatar
          end

          unless person.save(false)
            puts "** Error importing user #{user.id}: #{person.errors.full_messages}"
          else
            puts "Imported user #{user.id}"
          end

          profile                 = person.build_profile
          profile.job_title       = user.job_title
          profile.company         = user.company
          profile.company_website = user.company_website
          profile.location        = user.location
          profile.country         = PreviousCountryCode.find_by_code2(user.country_code).try :name
          profile.biography       = user.biography
          profile.created_at      = user.created_at
          profile.updated_at      = user.updated_at

          unless profile.save(false)
            puts "** Error importing user profile #{user.id}: #{profile.errors.full_messages}"
          else
            puts "Imported profile #{profile.id}"
          end

        else
          puts "** Error user with email #{email} does not exist"
        end
      end

      person
    end
    
    
    PreviousPost.find(:all).each do |previous_post|
      post = Post.new
      post.name = previous_post.name
      post.excerpt = previous_post.excerpt
      post.body = previous_post.body
      post.tag_list = previous_post.tags.join(',')
      post.publish_at = previous_post.publish_at
      post.created_at = previous_post.created_at
      post.updated_at = previous_post.updated_at
      
      PreviousComment.find(:all, :conditions => {:post_id => previous_post.id}).each do |previous_comment|
        user = PreviousUser.find_by_id(previous_comment.user_id)
        if user
          person              = find_or_import_user(user.email)

          comment             = post.comments.new
          comment.commentable = post
          comment.person      = person
          comment.rating      = 0
          comment.body        = previous_comment.comment
          comment.created_at  = previous_comment.created_at
          comment.updated_at  = previous_comment.updated_at

          unless comment.save(false)
            puts "** Error importing comment #{previous_comment.id}: #{comment.errors.full_messages}"
          end
        else
          puts "** Error comment owner #{previous_comment.id} does not exist"
        end
      end
      
    end
    
  end

  task :import_fav_logos => :environment do
    class PreviousFavouriteLogo < ActiveRecord::Base
      establish_connection 'previous'
      set_table_name 'favourite_logos'
    end
    PreviousFavouriteLogo.all.each do |fav|
      person = Person.find_by_id(fav.user_id)
      logo = Logo.find_by_id(fav.logo_id)
      puts "F: #{fav.id}"
      
      if person and logo
        puts "P: #{person.id} L:#{logo.id}"
        person.favourites.create(:logo_id => logo.id)
      end
    end
    
  end
  
  task :promo_client => :environment do
    Person.all.each do |person|
      if person.competitions.any?
        person.kind = Person::KIND[:client]
        person.save
      end
    end
  end
  
  task :import_winners => :environment do
    class PreviousCompetition < ActiveRecord::Base
      default_scope :conditions => ['deleted_at IS NULL']
      establish_connection 'previous'
      set_table_name 'competitions'
    end

    PreviousCompetition.all.each do |previous_competition|
      puts "C: #{previous_competition.id}"
      unless previous_competition.winning_logo_id.blank?
        competition = Competition.find(previous_competition.id)
        if competition
          entry = competition.entries.first(:conditions => {:logo_id => previous_competition.winning_logo_id})
          if entry
            puts "E: #{entry.id}"
            entry.status = Entry::STATUS[:winner]
            entry.save
  
            entry.person.competition_winner = true
            entry.person.last_won_at = previous_competition.updated_at
            entry.person.save
  
            entry.enterable.winner_chosen = true
            entry.enterable.save 
          end
        end
      end
    end   
  end

  task :import_tags => :environment do 
    ActiveRecord::Base.record_timestamps = false
    class PreviousLogo < ActiveRecord::Base
      default_scope :conditions => ['deleted_at IS NULL']
      establish_connection 'previous'
      set_table_name 'logos'

      def original_file
        path = "#{BASE_PATH}/logos/original/#{self.id}.#{self.image_extension}"
        puts "Logo Path #{path}"
        if File.exists? path
          puts "Logo exist"
          File.new path
        end
      end
      
      def tags
        PreviousTag.find_by_sql(
          ["SELECT tags.* FROM logos_tags JOIN tags ON tags.id = logos_tags.tag_id WHERE logos_tags.logo_id = ?", self.id]
        ).collect{ |tag| tag.name }
      end
    end
    class PreviousTag < ActiveRecord::Base
      establish_connection 'previous'
      set_table_name 'tags'
    end
    
    PreviousLogo.all.each do |previous_logo|
      logo = Logo.find_by_id(previous_logo.id)
      if logo
        puts "L: #{logo.id} | Tag: #{previous_logo.tags.join(', ')}"
        logo.tag_list             = previous_logo.tags.join(',')
        logo.save
      end
    end
  end
  
  task :import_entries => :environment do
    class PreviousCompetition < ActiveRecord::Base
      default_scope :conditions => ['deleted_at IS NULL']
      establish_connection 'previous'
      set_table_name 'competitions'
    end
    
    class PreviousLogo < ActiveRecord::Base
      default_scope :conditions => ['deleted_at IS NULL']
      establish_connection 'previous'
      set_table_name 'logos'

      def original_file
        path = "#{BASE_PATH}/logos/original/#{self.id}.#{self.image_extension}"
        puts "Logo Path #{path}"
        if File.exists? path
          puts "Logo exist"
          File.new path
        end
      end
      
      def tags
        PreviousTag.find_by_sql(
          ["SELECT tags.* FROM logos_tags JOIN tags ON tags.id = logos_tags.tag_id WHERE logos_tags.logo_id = ?", self.id]
        ).collect{ |tag| tag.name }
      end
    end
    
    
    Entry.delete_all
    Competition.all.each do |competition|
      competition_logos = PreviousLogo.find(:all, :conditions => {:competition_id => competition.id})
      puts "C: #{competition.id} LC: #{competition_logos.size}"
      competition_logos.each do |previous_logo|
        logo = Logo.find_by_id previous_logo.id
        if logo
          entry = Entry.new
          entry.logo_id   = logo.id
          entry.person_id = logo.person.id
          entry.enterable = competition
          entry.kind      = previous_logo.visible ? Entry::KIND[:public] : Entry::KIND[:private]
          entry.status    = Entry::STATUS[:entry]
          entry.save(false)
        end
      end
      
    end
  end

  task :import_users => :environment do
    class PreviousUser < ActiveRecord::Base
      default_scope :conditions => ['deleted_at IS NULL']
      establish_connection 'previous'
      set_table_name 'users'
      set_inheritance_column nil
      
      def avatar
        path = "#{BASE_PATH}/profiles/original/#{self.id}.#{self.image_extension}"
        puts "Avatar Path #{path}"
        if File.exists? path
          puts "Avatar exist"
          File.new path
        end
      end
    end
    
    class PreviousCountryCode < ActiveRecord::Base
      establish_connection 'previous'
      set_table_name 'countries'
    end
    
    PreviousUser.all.each do |user|
      puts "U: #{user.id}"
      p = Person.find_by_id(user.id)
      if p.nil?
        puts "HIT!"
        person = Person.new
        
        person.id                     = user.id
        person.nick_name              = user.nickname
        person.first_name             = user.first_name
        person.last_name              = user.last_name
        person.email                  = user.email
        person.paypal_account         = user.paypal_email
        person.last_login_at          = user.last_login_at
        person.last_login_ip_address  = user.last_login_ip_address
        person.password               = user.password
        person.password_confirmation  = user.password
        person.created_at             = user.created_at
        person.updated_at             = user.updated_at
        person.old_user_id            = user.id
        if user.avatar
          person.avatar = user.avatar
        end

        unless person.save(false)
          puts "** Error importing user #{user.id}: #{person.errors.full_messages}"
        else
          puts "Imported user #{user.id}"
        end

        profile                 = person.build_profile
        profile.job_title       = user.job_title
        profile.company         = user.company
        profile.company_website = user.company_website
        profile.location        = user.location
        profile.country         = PreviousCountryCode.find_by_code2(user.country_code).try :name
        profile.biography       = user.biography
        profile.created_at      = user.created_at
        profile.updated_at      = user.updated_at

        unless profile.save(false)
          puts "** Error importing user profile #{user.id}: #{profile.errors.full_messages}"
        else
          puts "Imported profile #{profile.id}"
        end
        
      end
    end
    
  end

  task :import_for_sale => :environment do 
    class PreviousLogo < ActiveRecord::Base
      default_scope :conditions => ['deleted_at IS NULL AND status = ?', 'for_sale']
      establish_connection 'previous'
      set_table_name 'logos'
    end

    PreviousLogo.all.each do |previous_logo|
      logo = Logo.find_by_id(previous_logo.id)
      if logo
        logo.for_sale = true
        logo.save false
      end
    end
  end
end
