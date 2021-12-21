FactoryBot.define do
  factory :coupon do
    code { Faker::Commerce.unique.promotion_code(digits: 6) }
    status { [:active, :inactive].sample }
    discount_value { rand(1..99.0) }
    due_date { "2021-12-21 16:31:14" }
  end
end
