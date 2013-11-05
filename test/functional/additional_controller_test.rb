require 'test_helper'

class AdditionalControllerTest < ActionController::TestCase
  test "should get contactus" do
    get :contactus
    assert_response :success
  end

  test "should get aboutus" do
    get :aboutus
    assert_response :success
  end

  test "should get help" do
    get :help
    assert_response :success
  end

end
