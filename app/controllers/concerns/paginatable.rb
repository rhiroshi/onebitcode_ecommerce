module Paginatable
  extend ActiveSupport::Concern

  MAX_PER_PAGE = 10
  DEFAULT_PAGE = 1

  included do
    scope :paginate, -> (page, length) do
      page = page.nil? || page < 0 ? DEFAULT_PAGE : page
      length = length.nil? || length < 0 ? MAX_PER_PAGE : length
      starts_at = (page - 1) * length
      limit(length).offset(starts_at)
    end
  end
end
