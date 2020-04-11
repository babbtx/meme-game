# == Schema Information
#
# Table name: users
#
#  id         :bigint           not null, primary key
#  uuid       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :user do
    token_subject { Faker::Internet.uuid }
  end
end
