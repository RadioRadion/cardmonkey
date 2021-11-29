class UsersController < ApplicationController

  def show
      @user = User.find(params[:id])
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
        users = User.near(current_user.address, current_user.area)
      end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    @user.update!(user_params)
    redirect_to user_path(@user)
  end

  private

  def user_params
    params.require(:user).permit(:area, :address)
  end

end
