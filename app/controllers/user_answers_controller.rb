class UserAnswersController < ApplicationController
  def index
    answers = AnswerResource.all(params, Answer.by_user_uuid(params[:user_uuid]))
    render jsonapi: answers
  end

end
