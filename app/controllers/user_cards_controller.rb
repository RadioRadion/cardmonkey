class UserCardsController < ApplicationController
  before_action :set_user, only: [:new, :index, :create]

  def index
    @user_cards = @user.user_cards
  end

  def new
    @user_card = UserCard.new
  end

  def create
    @user = User.find(params[:user_id])
    # Utiliser directement le scryfall_id reçu dans card_version_id
    scryfall_id = params[:user_card][:card_version_id]
    # Trouver la CardVersion basée sur le scryfall_id
    card_version = CardVersion.find_by(scryfall_id: scryfall_id)
  
    if card_version
      # Créer la nouvelle UserCard avec les paramètres reçus, à l'exception de card_version_id
      @user_card = @user.user_cards.new(user_card_params)
      # Associer la CardVersion trouvée à la UserCard
      @user_card.card_version = card_version
  
      if @user_card.save
        redirect_to user_user_cards_path(@user), notice: 'La carte a été ajoutée à votre collection.'
      else
        render :new, status: :unprocessable_entity
      end
    else
      @user_card = @user.user_cards.build(user_card_params)
      flash.now[:alert] = 'Version de carte invalide.'
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @user = User.find(params[:user_id])
    @user_card = @user.user_cards.find(params[:id])
    @card = @user_card.card_version.card
    # Récupérer toutes les versions basées sur le scryfall_oracle_id
    @versions = CardVersion.joins(:card).where(cards: { scryfall_oracle_id: @card.scryfall_oracle_id })
  end

  def update
    @user = User.find(params[:user_id])
    @user_card = @user.user_cards.find(params[:id])
  
    # Mise à jour de la UserCard avec les nouveaux paramètres, y compris la nouvelle CardVersion
    if @user_card.update(user_card_params)
      redirect_to user_user_cards_path(@user), notice: 'La carte a été mise à jour dans votre collection.'
    else
      # S'il y a des erreurs de validation ou autres, afficher à nouveau le formulaire avec les messages d'erreur.
      @card = @user_card.card_version.card
      @versions = CardVersion.joins(:card).where(cards: { scryfall_oracle_id: @card.scryfall_oracle_id })
      render :edit, status: :unprocessable_entity
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
  

  def search
    if params[:query].present?
      @cards = Card.where("name ILIKE ?", "%#{params[:query]}%").limit(5)
    else
      @cards = Card.none
    end
  
    render json: @cards.map{|card| { id: card.id, name: card.name }}
  end
  
  private

  def set_user
    @user = current_user
  end

  def user_card_params
    params.require(:user_card).permit(:card_version_id, :condition, :foil, :language, :quantity)
  end
  
end


# def new
#   @user_card = UserCard.new
#   @cards = Card
#             .pluck(:id, :name, :extension)
#             .sort_by { |a| a[1] }
#             .map { |a| ["#{a[1]} - #{a[2]}", a[0]]}
# end

# def suggestions
#   # Logique pour trouver des cartes correspondant à la saisie de l'utilisateur
#   @suggestions = Card.search(params[:query])
#   render partial: "suggestions", locals: { suggestions: @suggestions }
# end

# def create
#   @user_card = UserCard.new(user_cards_params)
#   @user_card.user = current_user
#   if @user_card.save!
#     redirect_to user_user_cards_path
#   else
#     render :new
#   end
# end

# def edit
#   @user_card = UserCard.find(params[:id])
# end

# def update
#   @user_card = UserCard.find(params[:id])
#   if @user_card.update(user_cards_params)
#     redirect_to user_user_cards_path
#   else
#     render :new
#   end
# end

# def destroy
#   @user_card = UserCard.find(params[:id])
#   @user_card.destroy
#   redirect_to user_user_cards_path(current_user)
# end

# private

# def user_cards_params
#   params.require(:user_card).permit(:condition, :foil, :language, :quantity, :card_id)
# endrails