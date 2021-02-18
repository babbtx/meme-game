class GameAnswersController < ApplicationController
  before_action :find_or_create_game, :add_user_to_game

  def index
    params.merge!(extra_fields: {answers: 'user_token_subject'})
    answers = AnswerResource.all(params, Answer.includes(:user).for_game(params[:game_id]))
    render jsonapi: answers
  end

  def create
    answer = AnswerResource.build(params)
    answer.resource.user = current_user
    answer.resource.game = @game

    if answer.save
      render jsonapi: answer, status: 201
    else
      render jsonapi_errors: answer
    end
  end

  private

  # normally you wouldn't create a game on the fly
  # but we're trying to simplify demonstrating APIs
  def find_or_create_game
    @game = Game.find_or_create_by!(id: params[:game_id])
  rescue ActiveRecord::RecordInvalid => ex
    render_invalid_request(ex)
  end

  def add_user_to_game
    unless @game.players.exists?(id: current_user.id)
      @game.players << current_user
    end
  end
end
