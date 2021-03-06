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

  test "creates user on the fly" do
    user = FactoryBot.build(:user)
    sign_in(user)
    assert_equal 0, User.count
    assert_changes ->{ User.count } do
      get user_answers_url(user.token_subject), as: :json
      assert_response :success
    end
  end

  test "creates user on the fly with a mock token" do
    user = FactoryBot.build(:user)
    @authz_header = {'Authorization': %[Bearer {"active": true, "sub": "#{user.token_subject}"}]}
    assert_equal 0, User.count
    assert_changes ->{ User.count } do
      get user_answers_url('user.0'), as: :json
      assert_response :success
    end
  end

  test "returns proper error if no token" do
    user = FactoryBot.build(:user)
    assert_no_changes ->{ User.count } do
      get user_answers_url(user.token_subject), as: :json
      assert_response :unauthorized
    end
  end

  test "returns proper error if token has no subject" do
    user = FactoryBot.build(:user)
    authz_header = {'Authorization': "Bearer #{JWT.encode({email: "foo@example.com"}, 'password')}"}
    assert_no_changes ->{ User.count } do
      get user_answers_url(user.token_subject), headers: authz_header, as: :json
      assert_response :unauthorized
    end
  end
end
