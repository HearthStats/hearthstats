require 'test_helper'

class ConstructedsControllerTest < ActionController::TestCase
  setup do
    @constructed = constructeds(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:constructeds)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create constructed" do
    assert_difference('Constructed.count') do
      post :create, constructed: {  }
    end

    assert_redirected_to constructed_path(assigns(:constructed))
  end

  test "should show constructed" do
    get :show, id: @constructed
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @constructed
    assert_response :success
  end

  test "should update constructed" do
    put :update, id: @constructed, constructed: {  }
    assert_redirected_to constructed_path(assigns(:constructed))
  end

  test "should destroy constructed" do
    assert_difference('Constructed.count', -1) do
      delete :destroy, id: @constructed
    end

    assert_redirected_to constructeds_path
  end
end
