module Admin
  class ModelLoadingService
    def initialize(searchable_model, params = {})
      @searchable_model = searchable_model
      @params = params
      @params ||= {}
    end

    def call
      @searchable_model.search(@params[:search])
                       .order(@params[:order].to_h)
                       .paginate((@params[:page] || 1).to_i, (@params[:length] || 10).to_i)
    end
  end
end
