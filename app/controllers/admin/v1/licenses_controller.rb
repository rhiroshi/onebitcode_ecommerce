module Admin::V1
  class LicensesController < ApiController
    before_action :load_license, only: [:update, :destroy, :show]

    def index
      searchable = License.where(game_id: params[:game_id])
      @licenses = load_licenses(searchable)
    end

    def show
    end

    def update
      @license.attributes = license_params
      save_license!
    end

    def create
      @license = License.new(game_id: params[:game_id])
      @license.attributes = license_params
      save_license!
    end

    def destroy
      @license.destroy
    rescue
      render_error(fields: @license.errors.messages)
    end

    private

    def load_license
      @license = License.find(params[:id])
    end

    def load_licenses(searchable)
      permitted = params.permit({search: :key}, {order: {}}, :page, :length)
      Admin::ModelLoadingService.new(searchable, permitted).call
    end

    def license_params
      return {} unless params.has_key?(:license)
      params.require(:license).permit(:id, :key, :status, :platform)
    end

    def save_license!
      @license.save!
      render :show
    rescue
      render_error(fields: @license.errors.messages)
    end
  end
end
