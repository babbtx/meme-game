require 'test_helper'

class UserAnswersControllerTest < ActionDispatch::IntegrationTest

  test "user can view another users answers" do
    sign_in(FactoryBot.create(:user))
    answer = FactoryBot.create(:answer)
    another_users_answer = FactoryBot.create(:answer)

    get user_answers_url(answer.user.token_subject), as: :json
    assert_response :success

    d = JSON.parse(response.body).with_indifferent_access
    assert_equal 1, d[:data].length
    assert_equal answer.id.to_s, d[:data][0][:id]
  end

  test "creates user on the fly" do
    user = FactoryBot.build(:user)
    sign_in(user)
    assert_equal 0, User.count
    assert_changes ->{ User.count } do
      get user_answers_url(user.token_subject), as: :json
      assert_response :success
    end
  end

  test "returns proper error if no token" do
    user = FactoryBot.build(:user)
    get user_answers_url(user.token_subject), as: :json
    assert_response :unauthorized
  end

  test "returns proper error if token has no subject" do
    user = FactoryBot.build(:user)
    authz_header = {'Authorization': "Bearer #{JWT.encode({email: "foo@example.com"}, 'password')}"}
    get user_answers_url(user.token_subject), headers: authz_header, as: :json
    assert_response :unauthorized
  end
end
