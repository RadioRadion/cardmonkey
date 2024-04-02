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

    # Récupérer toutes les versions de cette carte
    versions = card.card_versions.select(:id, :extension, :scryfall_id, :img_uri, :price).map do |version|
      {
        id: version.id,
        scryfall_id: version.scryfall_id,
        extension: version.extension,
        img_uri: version.img_uri,
        price: version.price
      }
    end

    render json: versions
  rescue => e
    render json: { error: e.message }, status: :not_found
  end
  
  private

  def cards_params
    params.require(:card).permit(:name, :quantity, :extension, :foil, :condition, :language)
  end

end
