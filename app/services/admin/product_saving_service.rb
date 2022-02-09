module Admin
  class ProductSavingService
    class NotSavedProductError < StandardError; end

    attr_reader :product, :errors

    def initialize(params, product=nil)
      
    end
  end
end
