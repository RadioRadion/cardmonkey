class UserCardsController < ApplicationController
  def index
    @user_cards = current_user.user_cards
  end

  def new
    @user_card = UserCard.new
    @cards = Card
              .pluck(:id, :name, :extension)
              .sort_by { |a| a[1] }
              .map { |a| ["#{a[1]} - #{a[2]}", a[0]]}
  end

  def create
    @user_card = UserCard.new(user_cards_params)
    @user_card.user = current_user
    if @user_card.save!
      redirect_to user_user_cards_path
    else
      render :new
    end
  end

  def edit
    @user_card = UserCard.find(params[:id])
  end

  def update
    @user_card = UserCard.find(params[:id])
    if @user_card.update(user_cards_params)
      redirect_to user_user_cards_path
    else
      render :new
    end
  end

  def destroy
    @user_card = UserCard.find(params[:id])
    @user_card.destroy
    redirect_to user_user_cards_path(current_user)
  end

  private

  def user_cards_params
    params.require(:user_card).permit(:condition, :foil, :language, :quantity, :card_id)
  end
end
