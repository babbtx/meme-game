# == Schema Information
#
# Table name: users
#
#  id            :bigint           not null, primary key
#  token_subject :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class User < ApplicationRecord
  after_create :create_default_game_and_answers

  private

  DEFAULT_ANSWERS_ATTRIBUTES = [
      {url: 'https://i.imgflip.com/2fm6x.jpg', captions: ["Still waiting for the bus to Jennie’s"]},
      {url: 'https://i.imgflip.com/23ls.jpg', captions: ["There was a spider", "it's gone now"], rating: 13},
      {url: 'https://i.imgflip.com/26am.jpg', captions: ["It was the aliens who stole my weed"], rating: 13},
      {url: 'https://i.imgflip.com/1bip.jpg', captions: ["Elected as class president", "Gets assassinated"], rating: 13},
      {url: 'https://i.imgflip.com/1bhw.jpg', captions: ["Password needs what kind of characters?"]},
      {url: 'https://i.imgflip.com/c2qn.jpg', captions: ["If you could go out and buy some more TP", "That'd be great"]},
      {url: 'https://i.imgflip.com/39t1o.jpg', captions: ["First day of school for kids", "No kids for me"]}
  ].freeze

  def create_default_game_and_answers
    game = Game.create!
    game.players << self
    DEFAULT_ANSWERS_ATTRIBUTES.each do |attributes|
      Answer.create!(attributes.merge(game: game, user: self))
    end
  end
end
