class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update]
  before_action :ensure_current_user, only: [:edit, :update]

  def show
    if @user != current_user
      @path = "/users/#{@user.id}/trades/"
      @trade = Trade.new
      cards_other_wants_ids = @user.user_wanted_cards.map(&:card_id)
      @cards_other_wants = UserCard.where(user_id: current_user).where(card_id: cards_other_wants_ids)
      cards_i_wants_ids = current_user.user_wanted_cards.map(&:card_id)
      @cards_i_wants = UserCard.where(user_id: @user).where(card_id: cards_i_wants_ids)
      @my_cards = UserCard.where(user_id: current_user).where.not(card_id: cards_other_wants_ids)
      @other_cards = UserCard.where(user_id: @user).where.not(card_id: cards_i_wants_ids)
    else
      @cards = current_user.user_cards
      @wants = current_user.user_wanted_cards
      @stats = current_user.matching_stats
      users = User.near(current_user.address, current_user.area)
    end
  end

  def edit
    @stats = current_user.matching_stats
  end

  def update
    if @user.update(user_params)
      redirect_to edit_user_path(@user), notice: 'Profile updated successfully!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def ensure_current_user
    unless @user == current_user
      redirect_to root_path, alert: "You're not authorized to perform this action."
    end
  end

  def user_params
    params.require(:user).permit(:username, :email, :address, :area, :preference)
  end
end
