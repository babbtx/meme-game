class AnswerResource < ApplicationResource
  self.primary_endpoint '/answers', [:index, :show, :update]
  self.validate_endpoints = false

  attribute :url, :string, writable: :creating?
  attribute :caption, :string, writable: :creating?
  attribute :rating, :integer, writable: true
  attribute :created_at, :datetime

end
