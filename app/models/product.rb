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
class Product < ApplicationRecord
  belongs_to :productable, polymorphic: true
  validates :name, uniqueness: { case_sensitive: false }
  validates :name, :price, :description, presence: true
  validates :price, numericality: { greater_than: 0 }

  has_many :product_categories, dependent: :destroy
  has_many :categories, through: :product_categories

  enum status: {available: 1, unavailable: 2}

  has_one_attached :image
  include LikeSearchable
  include Paginatable
end
