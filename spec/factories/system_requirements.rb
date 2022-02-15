# == Schema Information
#
# Table name: system_requirements
#
#  id                 :bigint(8)        not null, primary key
#  memory             :string
#  name               :string
#  operational_system :string
#  processor          :string
#  storage            :string
#  video_board        :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
FactoryBot.define do
  factory :system_requirement do
    sequence(:name) { |n|  "Basic #{n}" }
    sequence(:operational_system) { |n|  Faker::Computer.os }
    sequence(:storage) { |n|  "500GB" }
    sequence(:processor) { |n|  "AMD Ryzen 7" }
    sequence(:memory) { |n|  "2GB" }
    sequence(:video_board) { |n|  "GeForce RTX 3060" }
  end
end
