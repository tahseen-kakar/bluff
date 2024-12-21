require "test_helper"

class GameFormatsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get game_formats_index_url
    assert_response :success
  end

  test "should get new" do
    get game_formats_new_url
    assert_response :success
  end

  test "should get create" do
    get game_formats_create_url
    assert_response :success
  end

  test "should get edit" do
    get game_formats_edit_url
    assert_response :success
  end

  test "should get update" do
    get game_formats_update_url
    assert_response :success
  end

  test "should get destroy" do
    get game_formats_destroy_url
    assert_response :success
  end
end
