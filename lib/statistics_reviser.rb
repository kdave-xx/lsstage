class StatisticsReviser
  PRO_MULTIPLIER = 3
  CLIENT_MULTIPLIER = 3
  PRO_THRESHOLD = 2
  BURY_THRESHOLD = 3
  WON_PROJECT_SCORE = 100
  
  def self.promote_users
    Person.all.each do |person|
      if person.entries.winner.size >= PRO_THRESHOLD and not person.pro?
        person.kind = Person::KIND[:pro_designer]
        person.save false
      end
      
      if person.entries.winner.size < PRO_THRESHOLD and (person.kind == Person::KIND[:pro_designer])
        person.kind = Person::KIND[:designer]
        person.save false
      end
    end
  end
  
  def self.revise_people
    Person.all.each do |person| 
      puts "Working #{person.id}" if (person.id % 10 == 0)
      revise_person person 
    end
  end
  
  def self.revise_logos
    Logo.all.each do |logo|
      puts "Working #{logo.id}" if (logo.id % 10 == 0)
      revise_logo logo 
    end
  end
  
  def self.revise_person(person)
    return if person.admin?
    person.statistic.score = person.logos.map { |logo| logo.statistic.score }.sum + (person.bids.won.count * WON_PROJECT_SCORE)
    person.statistic.number_of_views = person.logos.map { |logo| logo.statistic.number_of_views }.sum
    person.statistic.number_of_projects = person.bids.won.count
    person.statistic.number_of_gold_medals = person.entries.winner.count
    
    person.statistic.save
  end
  
  def self.revise_logo(logo)
    logo.statistic.number_of_comments = logo.comments.size
    logo.statistic.number_of_favourites = logo.favourites.size
    logo.statistic.score = logo.comments.has_rating.find(:all, :select => 'DISTINCT(person_id), commentable_id, commentable_type, rating').map(&:weighted_score).sum
    
    logo.statistic.save
    
    revise_person logo.person if logo.person
  end
end