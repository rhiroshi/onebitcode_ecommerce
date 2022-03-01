module Admin
  class ModelLoadingService
    def initialize(searchable_model, params = {})
      @searchable_model = searchable_model
      @params = params
      @params ||= {}
    end

    def call
      search = @params[:search] || {}
      search.each do |key, value|
        @searchable_model = @searchable_model.like(key, value)
      end

      @searchable_model.order(@params[:order].to_h)
                       .paginate((@params[:page] || 1).to_i, (@params[:length] || 10).to_i)
    end
  end
end
