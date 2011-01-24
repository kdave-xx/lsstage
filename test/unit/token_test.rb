require 'test_helper'

class TokenTest < ActiveSupport::TestCase
  def test_should_generate_token_for_person
    token = people(:ruitaosu).tokens.generate('127.0.0.1')
    token.reload
    
    assert token
    assert ! token.secret.nil?
    assert ! token.expired?
  end
end
