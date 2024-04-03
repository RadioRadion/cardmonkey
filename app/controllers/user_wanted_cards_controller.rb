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
    
    # Trouver la version de la carte basée sur l'identifiant Scryfall reçu
    card_version = CardVersion.find_by(scryfall_id: params[:user_wanted_card][:scryfall_id])
  
    if card_version
      # Préparer les paramètres en incluant card_version_id
      wanted_card_params = user_wanted_card_params.except(:scryfall_id).merge(card_version_id: card_version.id, card_id: card_version.card.id)
      @user_wanted_card = @user.user_wanted_cards.new(wanted_card_params)
    
      if @user_wanted_card.save!
        redirect_to user_user_wanted_cards_path(@user), notice: 'Wanted card was successfully created.'
      else
        render :new, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = 'Card version not found.'
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
    params.require(:user_wanted_card).permit(:min_condition, :foil, :language, :quantity, :card_id, :scryfall_id)
  end

  def set_user
    @user = current_user
  end
end
