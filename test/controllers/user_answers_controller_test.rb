require 'test_helper'

class UserAnswersControllerTest < ActionDispatch::IntegrationTest

  DEFAULT_ANSWERS_COUNT = User::DEFAULT_ANSWERS_ATTRIBUTES.length

  test "user can view another users answers" do
    sign_in(FactoryBot.create(:user)) # user 1
    user2_answer = FactoryBot.create(:answer)
    user3_answer = FactoryBot.create(:answer)
    assert_equal DEFAULT_ANSWERS_COUNT*3 + 2, Answer.count

    get user_answers_url(user2_answer.user.token_subject), as: :json
    assert_response :success

    d = JSON.parse(response.body).with_indifferent_access
    assert_equal DEFAULT_ANSWERS_COUNT+1, d[:data].length
    assert_equal user2_answer.id.to_s, d[:data].last[:id]
  end

  test "user can view another users specific answer" do
    sign_in(FactoryBot.create(:user)) # user 1
    user2_answer = FactoryBot.create(:answer)

    get user_answer_url(user2_answer.user.token_subject, user2_answer.id), as: :json
    assert_response :success

    d = JSON.parse(response.body).with_indifferent_access
    assert_equal user2_answer.id.to_s, d[:data][:id]
  end

  test "returns proper error if no token" do
    user = FactoryBot.build(:user)
    assert_no_changes ->{ User.count } do
      get user_answers_url(user.token_subject), as: :json
      assert_response :unauthorized
    end
  end

  test "works with client credentials" do
    sign_out
    user = FactoryBot.build(:user)
    @authz_header = {'Authorization': "Bearer #{JWT.encode({client_id: Faker::Internet.uuid}, 'password')}"}
    assert_no_changes ->{ User.count } do
      get user_answers_url(user.token_subject), as: :json
      assert_response :success
    end
  end
end
