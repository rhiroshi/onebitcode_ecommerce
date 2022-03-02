# == Schema Information
#
# Table name: games
#
#  id                    :bigint(8)        not null, primary key
#  developer             :string
#  mode                  :integer
#  release_date          :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  system_requirement_id :bigint(8)        not null
#
# Indexes
#
#  index_games_on_system_requirement_id  (system_requirement_id)
#
# Foreign Keys
#
#  fk_rails_...  (system_requirement_id => system_requirements.id)
#
FactoryBot.define do
  factory :game do
    mode { [:pvp, :pve, :both].sample }
    release_date { "2021-12-21 00:44:48" }
    developer { Faker::Company.name }
    system_requirement
  end
end
