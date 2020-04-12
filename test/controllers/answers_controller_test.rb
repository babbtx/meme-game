require 'test_helper'

class AnswersControllerTest < ActionDispatch::IntegrationTest

  setup do
    sign_in(FactoryBot.create(:user))
    @answer = FactoryBot.create(:answer, user: current_user)
  end

  test "only returns answers for the current user" do
    FactoryBot.create(:answer)
    assert_equal 2, Answer.count

    get answers_url, as: :json
    assert_response :success

    j = JSON.parse(response.body).with_indifferent_access
    assert_equal 1, j[:data].length
    d = j[:data]
    assert_equal @answer.id.to_s, d[0][:id]
  end

  test "update rating" do
    body = {data: {type: 'answers', id: @answer.id.to_s, attributes: {
        rating: 13
    }}}

    patch answer_url(@answer.id), params: body, as: :json
    assert_response :success

    assert_equal 13, @answer.reload.rating
  end

  test "cannot update caption" do
    body = {data: {type: 'answers', id: @answer.id.to_s, attributes: {
        caption: "new caption"
    }}}

    patch answer_url(@answer.id), params: body, as: :json
    assert_response :bad_request
  end
end
