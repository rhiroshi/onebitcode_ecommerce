class Product < ApplicationRecord
  belongs_to :productable, polymorphic: true
  validates :name, uniqueness: { case_sensitive: false }
  validates :name, :price, :description, presence: true
  validates :price, numericality: { greater_than: 0 }
end
