module ProjectsHelper
  def can_see_bid?(bid)
    if current_user
      current_user == bid.person or current_user.admin? or current_user == bid.project.person
    else
      false
    end
  end
  
  def can_bid?(project)
    if current_user
      not project.closed?
    else
      false
    end
  end
  
  def can_pick_bid?(bid)
    if current_user
      if bid.project.winning_bid
        false
      else
        current_user == bid.project.person or current_user.admin?
      end
    else
      false
    end
  end
  
  def can_repick_bid?(bid)
    if current_user
      if bid.project.winning_bid and bid != bid.project.winning_bid and (current_user == bid.project.person or current_user.admin?)
        true
      else
        false
      end
    else
      false
    end
  end
  
end
