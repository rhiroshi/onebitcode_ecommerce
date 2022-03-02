# == Schema Information
#
# Table name: products
#
#  id               :bigint(8)        not null, primary key
#  description      :text
#  name             :string
#  price            :decimal(10, 2)
#  productable_type :string           not null
#  status           :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  productable_id   :bigint(8)        not null
#
# Indexes
#
#  index_products_on_productable  (productable_type,productable_id)
#
FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Product #{n}" }
    description { Faker::Lorem.paragraph }
    price { Faker::Commerce.price(range: 100.0..400.0) }
    image { Rack::Test::UploadedFile.new(Rails.root.join("spec/support/images/product_image.png")) }
    status { :available }

    after :build do |product|
      product.productable ||= create(:game)
    end
  end
end
