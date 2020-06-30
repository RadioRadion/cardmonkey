class TradesController < ApplicationController
#ce skip permet de forcer le fake formulaire à ce pas nécessité d'authencitytoker
  skip_before_action :verify_authenticity_token

  def create
    @userTarget = params[:user_id]
    @trade = Trade.new(status: "pending", user_id_invit: @userTarget)
    @trade.user = current_user

    @cardsOffer = params[:trade][:offer].split(",")
    @cardsTarget = params[:trade][:target].split(",")

    if @trade.save!
      save_card_trades;
      redirect_to user_path(current_user)
    else
      render 'users/show'
    end
  end

  private

  def trade_params
    params.require(:trade).permit(:offer, :target)
  end

  def save_card_trades
    @cardsOffer.each do |card|
      @card = card.to_i
      @cardtrade = CardTrade.new(card_id: @card, trade_id: @trade.id)
      @cardtrade.save!
    end

    @cardsTarget.each do |card|
      @card = card.to_i
      @cardtrade = CardTrade.new(card_id: @card, trade_id: @trade.id)
      @cardtrade.save!
    end
  end

end
