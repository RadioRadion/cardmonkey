class UserWantedCardsController < ApplicationController
  before_action :set_user, only: [:new, :index, :create]

  def index
    # Assurez-vous que @user est l'utilisateur actuellement connecté ou un utilisateur dont vous avez le droit de voir les cartes recherchées
    @user_wanted_cards = @user.user_wanted_cards.includes(:card)
  end

  def new
    @user_wanted_card = @user.user_wanted_cards.build
  end

  def create
    @user = User.find(params[:user_id])
    # Plus besoin de trouver la carte par oracle_id, car l'oracle_id est directement associé à UserWantedCard
    @user_wanted_card = @user.user_wanted_cards.new(user_wanted_card_params)
  
    if @user_wanted_card.save
      redirect_to user_user_wanted_cards_path(@user), notice: 'Wanted card was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  

  def edit
    @user_wanted_card = UserWantedCard.find(params[:id])
  end

  def update
    @user_wanted_card = UserWantedCard.find(params[:id])
    if @user_wanted_card.update(user_wanted_card_params)
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

  def user_wanted_card_params
    params.require(:user_wanted_card).permit(:min_condition, :foil, :language, :quantity, :card_id, :scryfall_oracle_id)
  end

  def set_user
    @user = current_user
  end
end
