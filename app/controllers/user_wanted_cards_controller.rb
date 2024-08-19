class UserWantedCardsController < ApplicationController
  before_action :set_user, only: [:new, :index, :create, :update]

  def index
    # Assurez-vous que @user est l'utilisateur actuellement connecté ou un utilisateur dont vous avez le droit de voir les cartes recherchées
    @user_wanted_cards = @user.user_wanted_cards.includes(:card)
  end

  def new
    @user_wanted_card = @user.user_wanted_cards.build
  end

  def create
  @user_wanted_card = @user.user_wanted_cards.new(user_wanted_card_params)

  # Récupérer toujours la carte générale basée sur l'oracle_id
  card = Card.find_by(scryfall_oracle_id: params[:user_wanted_card][:scryfall_oracle_id])
  if card
    @user_wanted_card.card = card

    # Associer la version spécifique de la carte si une est choisie
    if params[:user_wanted_card][:card_version_id].present?
      card_version = CardVersion.find_by(scryfall_id: params[:user_wanted_card][:card_version_id])
      @user_wanted_card.card_version = card_version if card_version
    end

    if @user_wanted_card.save
      redirect_to user_user_wanted_cards_path(@user), notice: 'Wanted card was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  else
    flash.now[:alert] = 'Card not found.'
    render :new, status: :unprocessable_entity
  end
  rescue ActiveRecord::RecordNotFound
    flash.now[:alert] = 'Card version not found.'
    render :new, status: :unprocessable_entity
  end

  
  def edit
    @user_wanted_card = UserWantedCard.find(params[:id])
    @card = @user_wanted_card.card || (@user_wanted_card.card_version&.card if @user_wanted_card.card_version_id.present?)
  
    # Récupérer toutes les versions de cette carte et trier par le nom de l'extension, si la carte existe
    @versions = CardVersion.joins(:extension)
                           .where(card_id: @card&.id)
                           .order('extensions.name ASC') if @card
  end  

  def update
    @user_wanted_card = UserWantedCard.find(params[:id])
    
    if params[:user_wanted_card][:card_version_id].present?
      card_version = CardVersion.find_by(id: params[:user_wanted_card][:card_version_id])
      if card_version
        update_params = user_wanted_card_params.merge(card_version_id: card_version.id)
      else
        flash[:alert] = "Specific card version not found."
        render :edit and return
      end
    else
      update_params = user_wanted_card_params.merge(card_version_id: nil)
    end
  
    if @user_wanted_card.update(update_params)
      redirect_to user_user_wanted_cards_path(@user), notice: 'Wanted card was successfully updated.'
    else
      flash.now[:alert] = 'Failed to update the wanted card.'  # Ajout d'un message d'alerte pour échec de validation
      render :edit, status: :unprocessable_entity
    end
  end  

  def destroy
    @user_wanted_card = current_user.user_wanted_cards.find(params[:id])
    if @user_wanted_card.destroy
      respond_to do |format|
        format.html { redirect_to user_user_wanted_cards_path(current_user), notice: 'La carte recherchée a été supprimée avec succès.' }
        format.json { head :no_content } # Pour AJAX, renvoie un statut 204 sans contenu.
      end
    else
      # Gérer le cas où la suppression échoue, par exemple, en renvoyant un statut d'erreur.
    end
  rescue ActiveRecord::RecordNotFound => e
    respond_to do |format|
      format.html { redirect_to user_user_wanted_cards_path(current_user), alert: 'La carte n\'a pas été trouvée.' }
      format.json { render json: { error: e.message }, status: :not_found }
    end
  end

  private

  def user_wanted_card_params
    params.require(:user_wanted_card).permit(:min_condition, :foil, :language, :quantity, :card_id, :scryfall_id)
  end  

  def set_user
    @user = current_user
  end
end
