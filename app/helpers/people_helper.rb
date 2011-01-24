module PeopleHelper
  def person_kind_options
    options_for_select([
      ['All', 'all'],
      ['Designer', 'designer'],
      ['Pro Designer', 'pro'],
      ['Client/Fan', 'client']
    ], :selected => params[:kind])
  end
  
  def winning_cup_images(person)
    cup = case person.total_wins
    when 0
      nil
    when 1..9
      'red'
    when 10..19
      'silver'
    else
      'gold'
    end
    unless cup.blank?
      %Q{<p align="center"><img src="/images/#{cup}cup_medium.gif" title="#{cup} cup"/></p>}
    else
      ''
    end
  end
end
