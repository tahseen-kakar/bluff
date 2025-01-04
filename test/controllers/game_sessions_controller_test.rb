require "test_helper"

class GameSessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get game_sessions_show_url
    assert_response :success
  end

  test "should get select_format" do
    get game_sessions_select_format_url
    assert_response :success
  end

  test "should get select_players" do
    get game_sessions_select_players_url
    assert_response :success
  end

  test "should get record_chips" do
    get game_sessions_record_chips_url
    assert_response :success
  end
end
