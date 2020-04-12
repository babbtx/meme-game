# == Schema Information
#
# Table name: answers
#
#  id         :bigint           not null, primary key
#  url        :string           not null
#  captions   :json
#  rating     :integer
#  user_id    :bigint           not null
#  game_id    :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Answer < ApplicationRecord
  belongs_to :user
  belongs_to :game

  validate :captions_format, if: :captions_changed?

  scope :by_user, ->(user) {
    where(user: user)
  }
  scope :by_user_token_subject, ->(sub) {
    joins(:user).where({users: {token_subject: sub}})
  }
  scope :for_game, ->(game) {
    game_id = Integer === game ? game.id : game
    where(game_id: game_id)
  }

  private

  def captions_format
    unless captions.blank? || Array === captions
      errors.add(:captions, message: 'must be an array')
    end
  end
end
