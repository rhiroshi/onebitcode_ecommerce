# == Schema Information
#
# Table name: licenses
#
#  id         :bigint(8)        not null, primary key
#  key        :string
#  platform   :integer
#  status     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  game_id    :bigint(8)        not null
#
# Indexes
#
#  index_licenses_on_game_id  (game_id)
#
# Foreign Keys
#
#  fk_rails_...  (game_id => games.id)
#
class License < ApplicationRecord
  include Paginatable
  include LikeSearchable

  belongs_to :game
  validates :key, presence: true, uniqueness: {case_sensitive: false, scope: :platform}
  validates :platform, presence: true
  validates :status, presence: true

  enum platform: { steam: 1, battle_net: 2, origin: 3 }
  enum status: { available: 1, in_use: 2, inactive: 3 }
end
