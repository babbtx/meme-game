class AnswerResource < ApplicationResource
  self.primary_endpoint '/answers', [:index, :show, :update]
  self.validate_endpoints = false

  attribute :url, :string, writable: :creating?
  attribute :captions, :array, writable: :creating?
  attribute :rating, :integer, writable: true
  attribute :created_at, :datetime

  extra_attribute :user_token_subject, :string do
    # the if checks that it's been eager loaded
    # which means that this really only works where we expect (in GameAnswersController#index)
    @object.user.token_subject if @object.association(:user).loaded?
  end

  attr_accessor :user, :game
  before_save :set_private_attributes

  private

  def set_private_attributes(model)
    model.user = user if user
    model.game = game if game
  end
end
