class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update]
  before_action :ensure_current_user, only: [:edit, :update]

  def show
    @user = User.find(params[:id])
    @stats = @user.matching_stats if @user == current_user
    @editing = params[:field] == "info"
    @editing_preferences = params[:field] == "preferences"
  end

  def edit
    @stats = current_user.matching_stats
  end

  def update
    @user = User.find(params[:id])
    updating_avatar = user_params.key?(:avatar)
    
    if @user.update(user_params)
      respond_to do |format|
        format.turbo_stream do
          if updating_avatar
            render turbo_stream: turbo_stream.replace(
              "profile_avatar",
              partial: "users/avatar",
              locals: { user: @user }
            )
          else
            # Refresh the entire profile section for other updates
            render turbo_stream: [
              turbo_stream.replace(
                "profile_info",
                partial: "users/profile_info",
                locals: { user: @user, editing: false }
              ),
              turbo_stream.replace(
                "trading_preferences",
                partial: "users/trading_preferences",
                locals: { user: @user, editing_preferences: false }
              )
            ]
          end
        end
        format.html { redirect_to user_path(@user), notice: "Profile updated successfully." }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          if updating_avatar
            render turbo_stream: turbo_stream.update(
              "profile_avatar",
              partial: "users/avatar",
              locals: { user: @user }
            )
          else
            render :show, status: :unprocessable_entity
          end
        end
        format.html { render :show, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "User not found."
  end

  def ensure_current_user
    unless @user == current_user
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(
            "flash_messages",
            partial: "shared/flash",
            locals: { message: "You're not authorized to perform this action.", type: "error" }
          )
        end
        format.html { redirect_to root_path, alert: "You're not authorized to perform this action." }
      end
    end
  end

  def user_params
    params.require(:user).permit(:username, :email, :address, :area, :preference, :avatar)
  end
end
