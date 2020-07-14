class UserAnswersController < ApplicationController
  def index
    answers = AnswerResource.all(params, scope_for_user_token_subject)
    render jsonapi: answers
  end

  def show
    answer = AnswerResource.find(params, scope_for_user_token_subject)
    render jsonapi: answer
  end

  protected

  def scope_for_user_token_subject
    Answer.by_user_token_subject(params[:user_token_subject])
  end
end
