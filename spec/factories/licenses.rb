# == Schema Information
#
# Table name: licenses
#
#  id         :bigint(8)        not null, primary key
#  key        :string
#  platform   :integer
#  status     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  game_id    :bigint(8)        not null
#
# Indexes
#
#  index_licenses_on_game_id  (game_id)
#
# Foreign Keys
#
#  fk_rails_...  (game_id => games.id)
#
FactoryBot.define do
  factory :license do
    key { Faker::Lorem.characters(number: 15) }
    platform { :steam }
    status { :available }
    game
  end
end
