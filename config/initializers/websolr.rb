if RAILS_ENV == "production"
  load "websolr-acts_as_solr.rb"
  ENV["WEBSOLR_URL"] = "http://index.websolr.com/solr/e2aa91439d2"
  ENV["WEBSOLR_PWD"]  = "763046f1a4"
  ENV["WEBSOLR_USER"] = "heroku-763046f1a4"
end
