# == Schema Information
#
# Table name: game_players
#
#  id         :bigint           not null, primary key
#  game_id    :bigint           not null
#  player_id  :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class GamePlayer < ApplicationRecord
  belongs_to :game
  belongs_to :player, class_name: 'User'
end
