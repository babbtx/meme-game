require 'test_helper'

class UserAnswersControllerTest < ActionDispatch::IntegrationTest

  setup do
    sign_in(FactoryBot.create(:user))
  end

  test "user can view another users answers" do
    answer = FactoryBot.create(:answer)
    another_users_answer = FactoryBot.create(:answer)

    get user_answers_url(answer.user.token_subject), as: :json
    assert_response :success

    d = JSON.parse(response.body).with_indifferent_access
    assert_equal 1, d[:data].length
    assert_equal answer.id.to_s, d[:data][0][:id]
  end
end
