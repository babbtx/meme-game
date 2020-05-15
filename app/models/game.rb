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

  # invites aren't remembered. They're not game players until they join.
  attr_writer :invitees

  # because clients can indirectly create games via the game answers API
  validates :id, numericality: {:greater_than => 0}, allow_nil: true, on: :create
  validate :invitees_must_be_emails

  after_commit :send_invites, if: ->(model) { model.instance_variable_get(:@invitees).present? }

  private

  attr_reader :invitees

  def invitees_must_be_emails
    if invitees.present?
      regex = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      if Enumerable === invitees && invitees.all?{|invitee| String === invitee && regex =~ invitee}
        # good
      else
        errors.add(:invitees, :invalid, message: 'must be a list of valid email addresses')
      end
    end
  end

  def send_invites
    # we're not going to invite people for real
  end
end
