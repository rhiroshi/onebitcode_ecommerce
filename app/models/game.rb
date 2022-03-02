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
class Game < ApplicationRecord
  belongs_to :system_requirement
  has_one :product, as: :productable
  validates :mode, :release_date, :developer, presence: true

  enum mode: {pvp: 1, pve: 2, both: 3}
end
