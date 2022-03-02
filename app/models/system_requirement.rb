# == Schema Information
#
# Table name: system_requirements
#
#  id                 :bigint(8)        not null, primary key
#  memory             :string
#  name               :string
#  operational_system :string
#  processor          :string
#  storage            :string
#  video_board        :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
class SystemRequirement < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :operational_system, :storage, :processor, :memory, :video_board, presence: true
  has_many :games, dependent: :restrict_with_error
  include LikeSearchable
  include Paginatable
end
