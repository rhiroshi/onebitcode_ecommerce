class Product < ApplicationRecord
  belongs_to :productable, polymorphic: true
  validates :name, uniqueness: { case_sensitive: false }
  validates :image, :name, :price, :description, presence: true
  validates :price, numericality: { greater_than: 0 }

  has_many :product_categories, dependent: :destroy
  has_many :categories, through: :product_categories

  has_one_attached :image
  include NameSearchable
  include Paginatable
end
