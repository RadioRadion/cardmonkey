class CardsController < ApplicationController

  def index
    @cards = current_user.cards
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

  private

  def cards_params
    params.require(:card).permit(:name, :quantity, :extension, :foil, :condition, :language)
  end
end
