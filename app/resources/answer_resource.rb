class AnswerResource < ApplicationResource
  attribute :url, :string, writable: :creating?
  attribute :caption, :string, writable: :creating?
  attribute :rating, :integer, writable: true
  attribute :created_at, :datetime

end
