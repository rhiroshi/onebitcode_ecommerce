FactoryBot.define do
  factory :game do
    mode { [:pvp, :pve, :both].sample }
    release_date { "2021-12-21 00:44:48" }
    developer { Faker::Company.name }
    system_requirement
  end
end
