require 'rails_helper'

RSpec.describe Coupon, type: :model do
  it { is_expected.to validate_presence_of(:code) }
  it { is_expected.to validate_uniqueness_of(:code).case_insensitive }

  it { is_expected.to validate_presence_of(:status) }
  it { is_expected.to define_enum_for(:status).with_values({ active: 1, inactive: 2}) }

  it { is_expected.to validate_presence_of(:due_date) }
  it { is_expected.to validate_presence_of(:discount_value) }

  it { is_expected.to validate_numericality_of(:discount_value).is_greater_than(0) }

  it "can't have past date due_date" do
    subject.due_date = Date.yesterday
    subject.valid?
    expect(subject.errors.attribute_names).to include :due_date
  end
  it "is valid with future date due_date" do
    subject.due_date = Time.zone.now + 1.hour
    subject.valid?
    expect(subject.errors.attribute_names).to_not include :due_date
  end

  it_has_behavior_of "like searchable concern", :coupon, :code
  it_behaves_like "paginatable concern", :coupon
end
