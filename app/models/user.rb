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
end
