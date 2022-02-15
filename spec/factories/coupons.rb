# == Schema Information
#
# Table name: coupons
#
#  id             :bigint(8)        not null, primary key
#  code           :string
#  discount_value :decimal(5, 2)
#  due_date       :datetime
#  status         :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
FactoryBot.define do
  factory :coupon do
    code { Faker::Commerce.unique.promotion_code(digits: 6) }
    status { [:active, :inactive].sample }
    discount_value { rand(1..99.0) }
    due_date { Time.zone.now + 1.day }
  end
end
