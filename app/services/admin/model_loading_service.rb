module Admin
  class ModelLoadingService
    attr_reader :records, :pagination

    def initialize(searchable_model, params = {})
      @searchable_model = searchable_model
      @params = params || {}
      @records = []
      @pagination = { page: @params[:page].to_i, length: @params[:length].to_i }
    end

    def call
      filtered = @searchable_model
      search = @params[:search] || {}
      search.each do |key, value|
        filtered = @searchable_model.like(key, value)
      end

=======
      fix_pagination_values
      @records = filtered.order(@params[:order].to_h).paginate(@pagination[:page], @pagination[:length])
      total_pages = (filtered.count / @pagination[:length].to_f).ceil
      @pagination.merge!(total: filtered.count, total_pages: total_pages)
    end

    def fix_pagination_values
      @pagination[:page] = @searchable_model.model::DEFAULT_PAGE if @pagination[:page].zero?
      @pagination[:length] = @searchable_model.model::MAX_PER_PAGE if @pagination[:length].zero?
ssw    end
  end
end
