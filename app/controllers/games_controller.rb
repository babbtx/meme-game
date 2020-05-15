class GamesController < ApplicationController

  def create
    game = GameResource.build(params)
    game.resource.creator = current_user

    if game.save
      render jsonapi: game, status: 201
    else
      render jsonapi_errors: game
    end
  end

end
