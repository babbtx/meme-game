require 'test_helper'

class GameAnswersControllerTest < ActionDispatch::IntegrationTest

  setup do
    sign_in(FactoryBot.create(:user))
  end

  test "answering creates a game on the fly" do
    answer_params = FactoryBot.build(:answer, user: current_user, game: nil)
    game_id = Faker::Number.number(digits: 4)
    body = {data: {type: 'answers', attributes: {
        url: answer_params.url,
        caption: answer_params.caption
    }}}

    assert_changes ->{ Game.count } do
      post game_answers_url(game_id), params: body, as: :json
      assert_response :created
    end
  end

  test "answering links user and game to answer" do
    answer_params = FactoryBot.build(:answer, user: current_user, game: nil)
    game_id = Faker::Number.number(digits: 4)
    body = {data: {type: 'answers', attributes: {
        url: answer_params.url,
        caption: answer_params.caption
    }}}

    post game_answers_url(game_id), params: body, as: :json
    assert_response :created

    d = JSON.parse(response.body).with_indifferent_access[:data]
    answer_id = d[:id]
    answer = Answer.find(answer_id)
    assert_equal current_user, answer.user
    assert_equal game_id, answer.game.id
  end

  test "answer sets attributes" do
    game = FactoryBot.create(:game)
    answer_params = FactoryBot.build(:answer, user: current_user, game: game, rating: Faker::Number.number(digits: 2))
    body = {data: {type: 'answers', attributes: {
        url: answer_params.url,
        caption: answer_params.caption,
        rating: answer_params.rating
    }}}

    post game_answers_url(game.id), params: body, as: :json
    assert_response :created

    d = JSON.parse(response.body).with_indifferent_access[:data]
    answer_id = d[:id]
    answer = Answer.find(answer_id)
    assert_equal answer_params.url, answer.url
    assert_equal answer_params.caption, answer.caption
    assert_equal answer_params.rating, answer.rating
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
end
