require 'test_helper'

class AnswersControllerTest < ActionDispatch::IntegrationTest

  DEFAULT_ANSWERS_COUNT = User::DEFAULT_ANSWERS_ATTRIBUTES.length

  setup do
    sign_in(FactoryBot.create(:user))
    @answer = FactoryBot.create(:answer, user: current_user)
  end

  test "only returns answers for the current user" do
    another_users_answer = FactoryBot.create(:answer)
    assert_equal DEFAULT_ANSWERS_COUNT*2 + 2, Answer.count

    get answers_url, as: :json
    assert_response :success

    j = JSON.parse(response.body).with_indifferent_access
    assert_equal DEFAULT_ANSWERS_COUNT+1, j[:data].length
    d = j[:data]
    assert_equal @answer.id.to_s, d.last[:id]
  end

  test "creates user and data on the fly" do
    user = FactoryBot.build(:user)
    sign_in(user)
    assert_equal 1, User.count
    assert_changes ->{ User.count } do
      get answers_url, as: :json
      assert_response :success
    end
    j = JSON.parse(response.body).with_indifferent_access
    assert_equal DEFAULT_ANSWERS_COUNT, j[:data].length
  end

  test "creates user and data on the fly with a mock token" do
    user = FactoryBot.build(:user)
    @authz_header = {'Authorization': %[Bearer {"active": true, "sub": "#{user.token_subject}"}]}
    assert_equal 1, User.count
    assert_changes ->{ User.count } do
      get answers_url, as: :json
      assert_response :success
    end
    j = JSON.parse(response.body).with_indifferent_access
    assert_equal DEFAULT_ANSWERS_COUNT, j[:data].length
  end

  test "update rating" do
    body = {data: {type: 'answers', id: @answer.id.to_s, attributes: {
        rating: 13
    }}}

    patch answer_url(@answer.id), params: body, as: :json
    assert_response :success

    assert_equal 13, @answer.reload.rating
  end

  test "cannot update captions" do
    body = {data: {type: 'answers', id: @answer.id.to_s, attributes: {
        captions: ["joke goes here"]
    }}}

    patch answer_url(@answer.id), params: body, as: :json
    assert_response :bad_request
  end
end
