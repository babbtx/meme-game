class AnswerResource < ApplicationResource
  self.primary_endpoint '/answers', [:index, :show, :update]
  self.validate_endpoints = false

  attribute :url, :string, writable: :creating?
  attribute :caption, :string, writable: :creating?
  attribute :rating, :integer, writable: true
  attribute :created_at, :datetime

  attr_accessor :user, :game
  before_save :set_private_attributes

  private

  def set_private_attributes(model)
    model.user = user if user
    model.game = game if game
  end
end
