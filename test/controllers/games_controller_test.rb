require 'test_helper'

class GamesControllerTest < ActionDispatch::IntegrationTest

  setup do
    sign_in(FactoryBot.create(:user))
  end

  test "create a game works and adds the current user as a game player" do
    post games_url, as: :json
    assert_response :created

    j = JSON.parse(response.body).with_indifferent_access
    d = j[:data]
    assert_equal [@current_user], Game.find(d[:id]).players
  end

  test "create game with invitees" do
    Game.any_instance.expects(:send_invites).once
    body = {data: {type: 'game', attributes: {invitees: ['user@example.com']}}}
    post games_url, params: body, as: :json
    assert_response :created
  end

  test "reject game with bad invitees" do
    Game.any_instance.expects(:send_invites).never
    body = {data: {type: 'game', attributes: {invitees: ['not an email']}}}
    post games_url, params: body, as: :json
    assert_response :unprocessable_entity
  end

  test "requires user token" do
    sign_out
    @authz_header = {'Authorization': "Bearer #{JWT.encode({client_id: Faker::Internet.uuid}, 'password')}"}
    post games_url, as: :json
    assert_response :unauthorized
  end
end
