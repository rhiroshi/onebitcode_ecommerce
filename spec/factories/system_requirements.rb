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
