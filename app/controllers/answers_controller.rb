class AnswersController < ApplicationController
  def index
    answers = AnswerResource.all(params, scope_for_user)
    render jsonapi: answers
  end

  def show
    answer = AnswerResource.find(params, scope_for_user)
    render jsonapi: answer
  end

  def update
    answer = AnswerResource.find(params, scope_for_user)

    if answer.update_attributes
      render jsonapi: answer
    else
      render jsonapi_errors: answer
    end
  end

  protected

  def scope_for_user
    Answer.by_user(current_user)
  end
end
