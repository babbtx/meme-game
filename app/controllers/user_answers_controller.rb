class UserAnswersController < ApplicationController
  def index
    answers = AnswerResource.all(params, Answer.by_user_token_subject(params[:user_token_subject]))
    render jsonapi: answers
  end
end
