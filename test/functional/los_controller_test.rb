require 'test_helper'

class LosControllerTest < ActionController::TestCase
  setup do
    @lo = los(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:los)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create lo" do
    assert_difference('Lo.count') do
      post :create, lo: { callback: @lo.callback, category: @lo.category, description: @lo.description, hasQuizzes: @lo.hasQuizzes, name: @lo.name, repository: @lo.repository, technology: @lo.technology, type: @lo.type, url: @lo.url }
    end

    assert_redirected_to lo_path(assigns(:lo))
  end

  test "should show lo" do
    get :show, id: @lo
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @lo
    assert_response :success
  end

  test "should update lo" do
    put :update, id: @lo, lo: { callback: @lo.callback, category: @lo.category, description: @lo.description, hasQuizzes: @lo.hasQuizzes, name: @lo.name, repository: @lo.repository, technology: @lo.technology, type: @lo.type, url: @lo.url }
    assert_redirected_to lo_path(assigns(:lo))
  end

  test "should destroy lo" do
    assert_difference('Lo.count', -1) do
      delete :destroy, id: @lo
    end

    assert_redirected_to los_path
  end
end
