# == Schema Information
#
# Table name: games
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Game < ApplicationRecord
  has_many :game_players
  has_many :players, class_name: 'User', through: :game_players

  # because clients can indirectly create games via the game answers API
  validates :id, numericality: {:greater_than => 0}, allow_nil: true, on: :create
end
