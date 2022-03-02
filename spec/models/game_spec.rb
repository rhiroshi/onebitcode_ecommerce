# == Schema Information
#
# Table name: games
#
#  id                    :bigint(8)        not null, primary key
#  developer             :string
#  mode                  :integer
#  release_date          :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  system_requirement_id :bigint(8)        not null
#
# Indexes
#
#  index_games_on_system_requirement_id  (system_requirement_id)
#
# Foreign Keys
#
#  fk_rails_...  (system_requirement_id => system_requirements.id)
#
require 'rails_helper'

RSpec.describe Game, type: :model do
  it { is_expected.to validate_presence_of(:mode) }
  it { is_expected.to validate_presence_of(:developer) }
  it { is_expected.to validate_presence_of(:release_date) }
  it { is_expected.to belong_to(:system_requirement) }
  it { is_expected.to define_enum_for(:mode).with_values({ pvp: 1, pve: 2, both: 3}) }
  it { is_expected.to have_one(:product) }
end
