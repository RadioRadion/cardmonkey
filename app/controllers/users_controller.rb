class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update]
  before_action :ensure_current_user, only: [:edit, :update]

  def show
    @stats = @user.matching_stats if @user == current_user
    @editing = params[:field] == "info"
    @editing_preferences = params[:field] == "preferences"
  end

  def search
    query = params[:query].to_s.strip.downcase
    @users = User.where("LOWER(username) LIKE ?", "%#{query}%")
      .where.not(id: current_user.id)
      .limit(5)
      .includes(:user_cards, :user_wanted_cards)

    render turbo_stream: turbo_stream.update(
      "search_results",
      partial: "users/search_results",
      locals: { users: @users }
    )
  end

  def edit
    @stats = current_user.matching_stats
    @editing = params[:field] == "info"
    @editing_preferences = params[:field] == "preferences"
    
    respond_to do |format|
      format.html { render :edit }
      format.turbo_stream do
        if params[:field] == "info"
          render turbo_stream: turbo_stream.replace(
            "profile_info",
            partial: "users/profile_info",
            locals: { user: @user, editing: true }
          )
        elsif params[:field] == "preferences"
          render turbo_stream: turbo_stream.replace(
            "trading_preferences",
            partial: "users/trading_preferences",
            locals: { user: @user, editing_preferences: true }
          )
        end
      end
    end
  end

  def update
    @user = User.find(params[:id])
    updating_preferences = user_params.keys.any? { |k| %w[address area preference].include?(k) }
    updating_avatar = user_params.key?(:avatar)
    
    if @user.update(user_params)
      respond_to do |format|
        format.turbo_stream do
          streams = []
          
          if updating_avatar
            streams << turbo_stream.replace("profile_avatar",
              partial: "users/avatar",
              locals: { user: @user }
            )
            # Also update the navbar avatar
            streams << turbo_stream.replace("navbar_avatar",
              partial: "shared/navbar_avatar",
              locals: { user: @user }
            )
          elsif updating_preferences
            streams << turbo_stream.replace("trading_preferences",
              partial: "users/trading_preferences",
              locals: { user: @user, editing_preferences: false }
            )
          else
            streams << turbo_stream.replace("profile_info",
              partial: "users/profile_info",
              locals: { user: @user, editing: false }
            )
          end

          render turbo_stream: streams
        end
        format.html { redirect_to user_path(@user), notice: t('.update_success') }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          if updating_avatar
            render turbo_stream: [
              turbo_stream.replace("profile_avatar",
                partial: "users/avatar",
                locals: { user: @user }
              ),
              turbo_stream.update("flash_messages",
                partial: "shared/flash_messages",
                locals: { messages: @user.errors.full_messages }
              )
            ]
          elsif updating_preferences
            render turbo_stream: [
              turbo_stream.replace("trading_preferences",
                partial: "users/trading_preferences",
                locals: { user: @user, editing_preferences: true }
              ),
              turbo_stream.update("flash_messages",
                partial: "shared/flash_messages",
                locals: { messages: @user.errors.full_messages }
              )
            ]
          else
            render turbo_stream: [
              turbo_stream.replace("profile_info",
                partial: "users/profile_info",
                locals: { user: @user, editing: true }
              ),
              turbo_stream.update("flash_messages",
                partial: "shared/flash_messages",
                locals: { messages: @user.errors.full_messages }
              )
            ]
          end
        end
        format.html { render :edit }
      end
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: t('.user_not_found')
  end

  def ensure_current_user
    unless @user == current_user
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(
            "flash_messages",
            partial: "shared/flash_messages",
            locals: { messages: [t('.unauthorized')] }
          ), status: :forbidden
        end
        format.html { redirect_to root_path, alert: t('.unauthorized') }
      end
    end
  end

  def user_params
    params.require(:user).permit(:username, :email, :address, :area, :preference, :avatar)
  end
end
