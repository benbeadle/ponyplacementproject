require 'test_helper'

class EvaluateControllerTest < ActionController::TestCase
  test "should get do" do
    get :do
    assert_response :success
  end

end
