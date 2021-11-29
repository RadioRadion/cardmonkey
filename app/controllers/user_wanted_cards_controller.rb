class UserWantedCardsController < ApplicationController
  def index
    @user_wanted_cards = current_user.user_wanted_cards
  end

  def new
    @user_wanted_card = UserWantedCard.new
    @cards = Card
              .pluck(:id, :name, :extension)
              .sort_by { |a| a[1] }
              .map { |a| ["#{a[1]} - #{a[2]}", a[0]]}
  end

  def create
    @user_wanted_card = UserWantedCard.new(user_wanted_cards_params)
    @user_wanted_card.user = current_user
    if @user_wanted_card.save!
      redirect_to user_user_wanted_cards_path
    else
      render :new
    end
  end

  def edit
    @user_wanted_card = UserWantedCard.find(params[:id])
  end

  def update
    @user_wanted_card = UserWantedCard.find(params[:id])
    if @user_wanted_card.update(user_wanted_cards_params)
      redirect_to user_user_wanted_cards_path
    else
      render :new
    end
  end

  def destroy
    @user_wanted_card = UserWantedCard.find(params[:id])
    @user_wanted_card.destroy
    redirect_to user_user_wanted_cards_path(current_user)
  end

  private

  def user_wanted_cards_params
    params.require(:user_wanted_card).permit(:min_condition, :foil, :language, :quantity, :card_id)
  end
end
