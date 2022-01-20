module Admin::V1
  class CouponsController < ApiController
    before_action :load_coupon, only: [:update, :destroy]

    def index
      @coupons = Coupon.all
    end

    def update
      @coupon.attributes = coupons_params
      save_category!
    end

    def create
      @coupon = Coupon.new
      @coupon.attributes = coupons_params
      save_category!
    end

    def destroy
      @coupon.destroy
    rescue
      render_error(fields: @coupon.errors.messages)
    end

    private

    def load_coupon
      @coupon = Coupon.find(params[:id])
    end

    def coupons_params
      return {} unless params.has_key?(:coupon)
      params.require(:coupon).permit(:code, :status, :discount_value, :due_date)
    end

    def save_category!
      @coupon.save!
      render :show
    rescue
      render_error(fields: @coupon.errors.messages)
    end
  end
end
