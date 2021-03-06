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

FactoryBot.define do
  factory :answer do
    association :user, factory: :user
    association :game, factory: :game
    url { Faker::Internet.url }
    captions { [Faker::ChuckNorris.fact] }
  end
end
