ActionController::Routing::Routes.draw do |map|
  map.resource :session, :member => {:forget_password => :get, :forget_password_commit => :post, :reset_password => :get, :reset_password_commit => :put}

  map.resources :blog_images
  map.resources :posts, :collection => {:tags => :get} do |post|
    post.resources :comments
  end
  
  map.resources :people, :member => {:email => [:get, :put], :pay => [:get, :put], :process_express_payment => :get, :admin => [:get, :put], :reset_avatar => [:put]} do |person|
    person.resources :logos
    person.resources :favourites
    person.resources :transactions
    person.resources :competitions, :collection => {:won => :get}
    person.resources :projects, :collection => {:won => :get}
  end
  
  map.resources :competitions, 
                :member => {:pay => [:get, :put], :process_express_payment => :get, :approve => :post, :wall => :get, :admin => [:get, :put]},
                :collection => {:unapproved => :get, :unpaid => :get, :client_unpaid => :get, :client_paid => :get} do |competition|
                  competition.resources :comments
                  competition.resources :logos
                  competition.resources :people
                  competition.resources :entries, :member => {:rate => :post, :withdraw => :delete, :pick => :post}
                  competition.resources :transactions
                  competition.resources :payments
                  competition.resource  :artwork
                end
  
  map.resources :logos, :member => {:image => :get, :preview => :get, :pay => [:get, :put], :process_express_payment => :get, :sold => :get}, :collection => {:tags => :get, :sales => :get} do |logo|
    logo.resources :comments
    logo.resources :transactions
    logo.resources :payments
    logo.resource :artwork
  end
  
  map.resources :projects,
    :member => {:pay => [:get, :put], :process_express_payment => :get, :admin => [:get, :put]},
    :collection => {:winners => :get, :unapproved => :get, :unpaid => :get, :closed => :get, :mine => :get} do |project|
    project.resources :comments
    project.resources :bids, :member => {:won => :put, :lost => :put, :file => :get} do |bid|
      bid.resources :comments
    end
    project.resources :transactions
  end
  
  map.resources :payments, :collection => {:ipn => :post}
  map.resources :comments, :member => {:bury => :post, :unbury => :post}
  map.create_message '/people/:id/create_message', :controller => 'people', :action => 'create_message'
  map.dashboard '/dashboard', :controller => 'dashboard', :action => 'index'
  map.deactivate '/deactivate/:id', :controller => 'people', :action => 'deactivate'
  map.root :controller => 'site', :action => 'home'
  map.findadesigner '/findadesigner', :controller => 'site', :action => 'findadesigner'
  map.getalogo '/getalogo', :controller => 'site', :action => 'getalogo'
  map.findaclient '/findaclient', :controller => 'site', :action => 'findaclient'
  map.oozing '/oozing', :controller => 'site', :action => 'oozing'
  map.faq '/faq', :controller => 'site', :action => 'help'
  map.blog '/blog', :controller => 'posts', :action => 'index'
  map.contact '/contact', :controller => 'site', :action => 'contact'
  map.announcement '/announcement', :controller => 'people', :action => 'announcement'
  map.tour '/tour', :controller => 'site', :action => 'tour'
  map.pricing '/pricing', :controller => 'site', :action => 'pricing'
  map.about '/about', :controller => 'site', :action => 'about'
  map.terms '/terms', :controller => 'site', :action => 'terms'
  map.privacy '/privacy', :controller => 'site', :action => 'privacy'
  map.help '/help', :controller => 'site', :action => 'help'
  map.thebook '/thebook', :controller => 'site', :action => 'thebook'
  map.thebottle '/thebottle', :controller => 'site', :action => 'thebottle'
  map.getnews '/getnews', :controller => 'site', :action => 'getnews'
  map.advertising '/advertising', :controller => 'site', :action => 'advertising'
  
  map.activities_feed '/feeds/activities.rss', :controller => 'site', :action => 'activities', :format => 'rss'
  map.simple_captcha '/simple_captcha/:action', :controller => 'simple_captcha'

  map.map '/javascripts/:action.:format', :controller => 'javascripts'
end