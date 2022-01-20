class Coupon < ApplicationRecord
  validates :code, :status, :discount_value, :due_date, presence: true
  validates :code, uniqueness: {case_sensitive: false}
  validates :discount_value, numericality: {greater_than: 0}
  validates :due_date, presence: true, future_date: true

  enum status: {active: 1, inactive: 2}
  include NameSearchable
  include Paginatable
end
