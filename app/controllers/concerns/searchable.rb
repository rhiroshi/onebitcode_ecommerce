module Searchable
  extend ActiveSupport::Concern

  included do
    scope :search, -> (search_obj) do
      return self.all unless search_obj.present?
      self.where(search_obj)
    end
  end
end
