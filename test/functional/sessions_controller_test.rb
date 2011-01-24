require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  def test_should_show_sign_in_page
    get :new
    assert_response :success
  end
  
  def test_should_not_allow_invalid_person_to_sign_in
    post :create, :email => 'hacker', :password => 'hacker'
    
    assert_response :success
    assert flash[:notice]
  end
  
  def test_should_allow_valid_person_to_sign_in_without_remember
    post :create, :email => people(:ruitaosu).email, :password => 'password'
    
    assert_response :redirect
    assert_equal people(:ruitaosu).id, session[SESSION_USER]
  end
  
  def test_should_allow_valid_person_sign_on_with_remember
    post :create, :email => people(:ruitaosu).email, :password => 'password', :remember_me => true
    
    assert_response :redirect
    
    #should have session assigned
    assert_equal people(:ruitaosu).id, session[SESSION_USER]
    
    #should have token generated and cookies assigned
    token = people(:ruitaosu).tokens[0]
    
    assert token
    assert_equal token.secret, cookies[SESSION_TOKEN].to_s
  end
  
  def test_should_allow_valid_token_sign_on
    @request.cookies[SESSION_TOKEN] = CGI::Cookie.new(SESSION_TOKEN, tokens(:locke_token).secret)
    get :show
    
    assert_response :success
    assert_equal people(:locke).id, session[SESSION_USER]
  end
  
  def test_should_not_allow_invalid_token_sign_on
    @request.cookies[SESSION_TOKEN] = CGI::Cookie.new(SESSION_TOKEN, 'hacker')
    get :show
    
    assert_response :redirect
    assert_redirected_to new_session_path
    
    assert session[SESSION_USER].blank?

    #should revoke invalid client token
    assert cookies[SESSION_TOKEN].blank?
  end
  
  def test_should_not_allow_expired_token_sign_on
    @request.cookies[SESSION_TOKEN] = CGI::Cookie.new(SESSION_TOKEN, tokens(:jack_token).secret)
    get :show
    
    assert_response :redirect
    assert_redirected_to new_session_path
    
    
    #should revoke expired server token
    assert ! Token.find_by_secret(tokens(:jack_token).secret)
    
    #should revoke expired client token    
    assert session[SESSION_USER].blank?
    assert cookies[SESSION_TOKEN].blank?
  end
  
  def test_should_allow_to_sign_out
    post :create, :email => people(:ruitaosu).email, :password => 'password', :remember_me => true
    
    assert_equal 1, people(:ruitaosu).tokens.size
    
    @request.cookies[SESSION_TOKEN] = CGI::Cookie.new(SESSION_TOKEN, people(:ruitaosu).tokens.first.secret)
    
    delete :destroy
    
    assert_redirected_to root_path
        
    assert session[SESSION_USER].blank?
    assert people(:ruitaosu).tokens.empty?
  end
end
