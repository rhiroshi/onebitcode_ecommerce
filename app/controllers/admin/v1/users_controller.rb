module Admin::V1
  class UsersController < ApiController
    before_action :load_user, only: [:update, :destroy]

    def index
      @users = load_users
    end

    def update
      @user.attributes = user_params
      save_user!
    end

    def create
      @user = User.new
      @user.attributes = user_params
      save_user!
    end

    def destroy
      @user.destroy
    rescue
      render_error(fields: @user.errors.messages)
    end

    private

    def load_users
      permitted = params.permit({search: [:name, :email, :password, :password_confirmation, :profile]}, {order: {}}, :page, :length)
      Admin::ModelLoadingService.new(User.all, permitted).call
    end

    def load_user
      @user = User.find(params[:id])
    end

    def user_params
      return {} unless params.has_key?(:user)
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :profile)
    end

    def save_user!
      @user.save!
      render :show
    rescue
      render_error(fields: @user.errors.messages)
    end
  end
end
