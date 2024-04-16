class CardsController < ApplicationController

  def index
  end

  def edit
    @card = Card.find(params[:id])
  end

  def update
    @card = Card.find(params[:id])

    if @card.update(cards_params)
      redirect_to user_cards_path
    else
      render :new
    end
  end

  def destroy
    @card = Card.find(params[:id])
    @card.destroy
    redirect_to user_cards_path(current_user)
  end

  def search
    query = params[:query]
    cards = Card.where('name_fr ILIKE :query OR name_en ILIKE :query', query: "%#{query}%")
                .select(:scryfall_oracle_id, :name_fr, :name_en)
                .limit(5)
    cards = cards.map do |card|
      {
        oracle_id: card.scryfall_oracle_id,
        name_fr: card.name_fr,
        name_en: card.name_en
      }
    end
    render json: cards
  end

  def versions
    oracle_id = params[:oracle_id]
  
    # Trouver la carte par oracle_id
    card = Card.find_by(scryfall_oracle_id: oracle_id)
  
    if card
      # Récupérer toutes les versions de cette carte, incluant les informations de l'extension
      versions = card.card_versions.includes(:extension).select(:id, :scryfall_id, :img_uri, :eur_price, :eur_foil_price, :extension_id).map do |version|
        {
          id: version.id,
          scryfall_id: version.scryfall_id,
          extension: {
            code: version.extension.code,
            name: version.extension.name,
            icon_uri: version.extension.icon_uri
          },
          img_uri: version.img_uri,
          eur_price: version.eur_price,
          eur_foil_price: version.eur_foil_price
        }
      end
  
      # Tri par le nom de l'extension
      sorted_versions = versions.sort_by { |version| version[:extension][:name] }
  
      render json: sorted_versions
    else
      render json: { error: "Card not found" }, status: :not_found
    end
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end  
  
  private

  def cards_params
    params.require(:card).permit(:name, :quantity, :extension, :foil, :condition, :language)
  end

end
