class UserCardsController < ApplicationController
  before_action :set_user, only: [:new, :index, :create]

  def index
    @user_cards = @user.user_cards.includes(card_version: [:card, :extension])
  end

  def new
    @user_card = UserCard.new
  end

  def create
    @user = User.find(params[:user_id])
    # Récupérer le scryfall_id à partir des nouveaux paramètres
    scryfall_id = params[:user_card][:scryfall_id]
    # Trouver la CardVersion basée sur le scryfall_id
    card_version = CardVersion.find_by(scryfall_id: scryfall_id)
  
    if card_version
      # Initialiser la nouvelle UserCard avec les paramètres reçus, mais sans scryfall_id
      @user_card = @user.user_cards.new(user_card_params.except(:scryfall_id).merge(card_version_id: card_version.id))
      set_foil_automatically
    
      if @user_card.save
        redirect_to user_user_cards_path(@user), notice: 'La carte a été ajoutée à votre collection.'
      else
        render :new, status: :unprocessable_entity
      end
    else
      @user_card = @user.user_cards.build(user_card_params.except(:scryfall_id))
      flash.now[:alert] = 'Version de carte invalide.'
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @user = User.find(params[:user_id])
    @user_card = @user.user_cards.find(params[:id])
    @card = @user_card.card_version.card
    # Récupérer toutes les versions basées sur le scryfall_oracle_id et trier par le nom de l'extension
    @versions = CardVersion.joins(:card, :extension)
                           .where(cards: { scryfall_oracle_id: @card.scryfall_oracle_id })
                           .order('extensions.name ASC')
  end
  
  def update
    @user = User.find(params[:user_id])
    @user_card = @user.user_cards.find(params[:id])
    set_foil_automatically
  
    if @user_card.update(user_card_params)
      if request.xhr?
        # Traitement pour une requête AJAX
        render json: { message: 'La carte a été mise à jour dans votre collection.', quantity: @user_card.quantity }, status: :ok
      else
        # Traitement pour une requête HTTP classique
        redirect_to user_user_cards_path(@user), notice: 'La carte a été mise à jour dans votre collection.'
      end
    else
      if request.xhr?
        # Traitement d'erreur pour une requête AJAX
        render json: { errors: @user_card.errors.full_messages }, status: :unprocessable_entity
      else
        # Traitement d'erreur pour une requête HTTP classique
        @card = @user_card.card_version.card
        @versions = CardVersion.joins(:card).where(cards: { scryfall_oracle_id: @card.scryfall_oracle_id })
        flash.now[:alert] = 'Une erreur est survenue lors de la mise à jour de la carte.'  # Ajout d'un message flash d'erreur
        render :edit, status: :unprocessable_entity
      end
    end
  end

  def destroy
    @user_card = current_user.user_cards.find(params[:id])
    if @user_card.destroy
      respond_to do |format|
        format.html { redirect_to user_user_cards_url(current_user), notice: 'La carte a été supprimée avec succès.' }
        format.json { head :no_content } # Pour AJAX, renvoie un statut 204 sans contenu.
      end
    else
      # Gérer le cas où la suppression échoue, par exemple, en renvoyant un statut d'erreur.
    end
  rescue ActiveRecord::RecordNotFound => e
    respond_to do |format|
      format.html { redirect_to user_user_cards_url(current_user), alert: 'La carte n\'a pas été trouvée.' }
      format.json { render json: { error: e.message }, status: :not_found }
    end
  end

  private

  def set_user
    @user = current_user
  end

  def user_card_params
    params.require(:user_card).permit(:condition, :foil, :language, :quantity, :card_version_id)
  end
  
  def set_foil_automatically
    if @user_card.card_version.eur_price.nil? && @user_card.card_version.eur_foil_price.present?
      @user_card.foil = true
      @user_card.save
    end
  end
  
end
