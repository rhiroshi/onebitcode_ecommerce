class Coupon < ApplicationRecord
  validates :code, :status, :discount_value, :due_date, presence: true
  validates :code, uniqueness: {case_sensitive: false}
  validates :discount_value, numericality: {greater_than: 0}

  enum status: {active: 1, inactive: 2}
end
