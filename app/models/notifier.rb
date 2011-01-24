class Notifier < ActionMailer::Base
  default_url_options[:host] = 'www.logosauce.com'
  FROM = 'notifier@logosauce.com'
  TO = 'admin@logosauce.com'
  
  # --------
  # To User
  # --------
  def welcome(person)
    from        FROM
    recipients  person.email
    subject     "Welcome"
    body        :person => person
  end
  
  def user_message(sender, recipient, message)
    from        FROM
    recipients  recipient.email
    subject     "Message from Logosauce"
    body        :sender => sender, :recipient => recipient, :message => message
    
    @headers["reply-to"] = sender.email
  end
  
  def choose_winner(competition)
    from        FROM
    recipients  competition.person.email
    subject     "Message from Logosauce"
    body        :competition => competition
  end
  
  def request_artwork(entry)
    from        FROM
    recipients  entry.person.email
    subject     "Message from Logosauce"
    body        :entry => entry
  end
  
  def logo_sold(logo)
    from        FROM
    recipients  logo.person.email
    subject     "Logo Sold!"
    body        :logo => logo
  end
  
  def logo_artwork_uploaded(buyer, logo)
    from        FROM
    recipients  buyer.email
    subject     "Logo Artwork uploaded!"
    body        :logo => logo, :buyer => buyer
  end
  
  def comment_placed(commenter, commentable)
    from        FROM
    recipients  commentable.person.email
    subject     "Comment placed"
    body        :commenter => commenter, :commentable => commentable
  end

  def competition_comment_placed(commenter, commentable)
    from        FROM
    recipients  commentable.person.email
    subject     "Comment placed"
    body        :commenter => commenter, :commentable => commentable
  end
  
  def forget_password(password_reset_coupon)
    from        FROM
    recipients  password_reset_coupon.person.email
    subject     "Password reset link"
    body        :password_reset_coupon => password_reset_coupon
  end
  
  # --------
  # To Site Admin
  # --------
  
  def new_activity(kind, activity)
    from        FROM
    recipients  TO
    subject     "[Logosauce] New Activity: #{kind}"
    body        :kind => kind, :activity => activity
  end
  
  def new_transaction(transaction)
    from        FROM
    recipients  TO
    subject     '[Logosauce] New Transaction'
    body        :transaction => transaction
  end

  def generate_compitition_invoices(activity)
    from        FROM
    recipients  activity.person.email
    subject     '[Logosauce] Approved Compitition'
    body        :competition => activity
  end

  def generate_project_invoices(activity)
    from        FROM
    recipients  activity.person.email
    subject     '[Logosauce] Approved Project'
    body        :activity => activity
  end

  def project_declined_info(activity)
    from        FROM
    recipients  activity.person.email
    subject     '[Logosauce] Declined Project'
    body        :activity => activity
  end

  def competition_declined_info(activity)
    from        FROM
    recipients  activity.person.email
    subject     '[Logosauce] Declined Project'
    body        :activity => activity
  end
  
end
