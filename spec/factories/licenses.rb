# == Schema Information
#
# Table name: licenses
#
#  id         :bigint(8)        not null, primary key
#  key        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  game_id    :bigint(8)
#  user_id    :bigint(8)
#
# Indexes
#
#  index_licenses_on_game_id  (game_id)
#  index_licenses_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (game_id => games.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :license do
    key { "MyString" }
    game { "" }
    user { "" }
  end
end
