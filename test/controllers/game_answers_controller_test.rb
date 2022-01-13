require 'test_helper'

class GameAnswersControllerTest < ActionDispatch::IntegrationTest

  setup do
    sign_in(FactoryBot.create(:user))
  end

  test "answering creates a user on the fly" do
    user = FactoryBot.build(:user)
    sign_in(user)
    assert_equal 1, User.count

    answer_params = FactoryBot.build(:answer, user: nil, game: nil)
    body = {data: {type: 'answers', attributes: {
      url: answer_params.url,
      captions: answer_params.captions
    }}}

    game = FactoryBot.create(:game)

    assert_changes ->{ User.count } do
      post game_answers_url(game.id), params: body, as: :json
      assert_response :created
    end
  end

  test "answering creates a user on the fly with a mock token" do
    sign_out
    user = FactoryBot.build(:user)
    @authz_header = {'Authorization': %[Bearer {"active": true, "sub": "#{user.token_subject}"}]}
    assert_equal 1, User.count

    answer_params = FactoryBot.build(:answer, user: nil, game: nil)
    body = {data: {type: 'answers', attributes: {
      url: answer_params.url,
      captions: answer_params.captions
    }}}

    game = FactoryBot.create(:game)

    assert_changes ->{ User.count } do
      post game_answers_url(game.id), params: body, as: :json
      assert_response :created
    end
  end

  test "answering creates a game on the fly" do
    answer_params = FactoryBot.build(:answer, user: nil, game: nil)
    body = {data: {type: 'answers', attributes: {
        url: answer_params.url,
        captions: answer_params.captions
    }}}

    game_id = Faker::Number.number(digits: 4)
    assert_changes ->{ Game.count } do
      post game_answers_url(game_id), params: body, as: :json
      assert_response :created
    end
  end

  test "answering links user and game to answer" do
    answer_params = FactoryBot.build(:answer, user: nil, game: nil)
    body = {data: {type: 'answers', attributes: {
        url: answer_params.url,
        captions: answer_params.captions
    }}}

    game_id = Faker::Number.number(digits: 4)
    post game_answers_url(game_id), params: body, as: :json
    assert_response :created

    d = JSON.parse(response.body).with_indifferent_access[:data]
    answer_id = d[:id]
    answer = Answer.find(answer_id)
    assert_equal current_user, answer.user
    assert_equal game_id, answer.game.id
  end

  test "answer sets attributes" do
    answer_params = FactoryBot.build(:answer, user: nil, game: nil, rating: Faker::Number.number(digits: 2))
    body = {data: {type: 'answers', attributes: {
        url: answer_params.url,
        captions: answer_params.captions,
        rating: answer_params.rating
    }}}

    game = FactoryBot.create(:game)
    post game_answers_url(game.id), params: body, as: :json
    assert_response :created

    d = JSON.parse(response.body).with_indifferent_access[:data]
    answer_id = d[:id]
    answer = Answer.find(answer_id)
    assert_equal answer_params.url, answer.url
    assert_equal answer_params.captions, answer.captions
    assert_equal answer_params.rating, answer.rating
  end

  test "answer by user doesn't render user token attribute" do
    answer_params = FactoryBot.build(:answer, user: nil, game: nil)
    body = {data: {type: 'answers', attributes: {
      url: answer_params.url,
      captions: answer_params.captions
    }}}

    game_id = Faker::Number.number(digits: 4)
    post game_answers_url(game_id), params: body, as: :json
    assert_response :created

    d = JSON.parse(response.body).with_indifferent_access[:data]
    assert_equal 'answers', d[:type]
    assert_nil d[:user_token_subject]
  end

  test "answer requires captions array" do
    answer_params = FactoryBot.build(:answer, user: nil, game: nil)
    body = {data: {type: 'answers', attributes: {
        url: answer_params.url,
        captions: 'this is not an array',
        rating: answer_params.rating
    }}}

    game = FactoryBot.create(:game)
    post game_answers_url(game.id), params: body, as: :json
    assert_response :bad_request
  end

  test "returns answers for game including those submitted by others" do
    game = FactoryBot.create(:game)
    answer1 = FactoryBot.create(:answer, game: game)
    answer2 = FactoryBot.create(:answer, game: game)
    answer_for_another_game = FactoryBot.create(:answer)

    get game_answers_url(game.id), as: :json
    assert_response :success

    d = JSON.parse(response.body).with_indifferent_access[:data]
    assert_equal 2, d.length
    assert_equal [answer1.id.to_s, answer2.id.to_s], d.collect {|dd| dd[:id] }
  end

  test "returns answers for game including the token subjects of the other players" do
    game = FactoryBot.create(:game)
    answer1 = FactoryBot.create(:answer, game: game)
    answer2 = FactoryBot.create(:answer, game: game)

    get game_answers_url(game.id), as: :json
    assert_response :success

    d = JSON.parse(response.body).with_indifferent_access[:data]
    assert_equal [answer1.user.token_subject, answer2.user.token_subject], d.collect{|dd| dd[:attributes][:user_token_subject]}
  end

  test "proper error if getting answers for invalid game identifier" do
    get game_answers_url('foo'), as: :json
    assert_response :bad_request
  end

  test "answering requires user token" do
    sign_out
    @authz_header = {'Authorization': "Bearer #{JWT.encode({client_id: Faker::Internet.uuid}, 'password')}"}

    answer_params = FactoryBot.build(:answer, user: nil, game: nil, rating: Faker::Number.number(digits: 2))
    body = {data: {type: 'answers', attributes: {
      url: answer_params.url,
      captions: answer_params.captions,
      rating: answer_params.rating
    }}}

    game = FactoryBot.create(:game)
    post game_answers_url(game.id), params: body, as: :json
    assert_response :unauthorized
  end

  test "getting game answers works for client credentials" do
    sign_out
    @authz_header = {'Authorization': "Bearer #{JWT.encode({client_id: Faker::Internet.uuid}, 'password')}"}

    answer = FactoryBot.create(:answer)
    get game_answers_url(answer.game.id), as: :json
    assert_response :success
  end
end
