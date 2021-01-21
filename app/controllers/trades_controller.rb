class TradesController < ApplicationController
#ce skip permet de forcer le fake formulaire à ce pas nécessité d'authencitytoker
  skip_before_action :verify_authenticity_token

  def index
    @trades = Trade.where(user_id: current_user)
    @trades_pending = Trade.where(statut: "pending")
    @trades_done = Trade.where(statut: "done")
  end

  def create
    other_user_id = params[:user_id]
    @trade = Trade.new(status: "pending", user_id_invit: other_user_id)
    @trade.user = current_user

    @cards_offer = params[:trade][:offer].split(",")
    @cards_target = params[:trade][:target].split(",")
    @cards_offer_names = []
    @cards_target_names = []

    if @trade.save!
      save_card_trades
      content = "Un nouveau trade est arrivé ! #{@trade.id}"
      Trade.save_message(current_user.id, other_user_id, content)

      flash[:alert] = "Proposition de trade envoyée !"
      redirect_to user_path(current_user)
    else
      render 'users/show'
    end
  end

  def show
    @trade = Trade.find(params[:id])
    @cards = @trade.cards.joins(:user).where(user_id: current_user)
    if current_user.id == @trade.user_id
      @other_cards = @trade.cards.joins(:user).where(user_id: @trade.user_id_invit)
    else
      @other_cards = @trade.cards.joins(:user).where(user_id: @trade.user_id)
    end
    calcultate_total_price
    calculate_other_total_price
  end

  def edit
    @trade = Trade.find(params[:id])
    if current_user.id == @trade.user_id
      @cards_trade = @trade.cards.joins(:user).where(user_id: current_user)
      @other_cards_trade = @trade.cards.joins(:user).where(user_id: @trade.user_id_invit)
    else
      @cards_trade = @trade.cards.joins(:user).where(user_id: current_user)
      @other_cards_trade = @trade.cards.joins(:user).where(user_id: @trade.user_id)
    end
  end

  def update
    @trade = Trade.find(params[:id])
    if params[:accept]
      @trade.update(status: "accepted")
      @trade.user_id == current_user.id ? other_user_id = @trade.user_id_invit : other_user_id = @trade.user_id
      content = "Trade accepté ! Discutez-ici pour vous donner rendez-vous et procéder à l'échange.
      Une fois le trade terminé, n'oubliez pas de de valider !"
      Trade.save_message(current_user.id, other_user_id, content)
      flash[:alert] = "Trade validé !"
      redirect_to user_trade_path(@trade.user_id, @trade)
    end
  end

  private

  def trade_params
    params.require(:trade).permit(:offer, :target)
  end

  def save_card_trades
    @cards_offer.each do |card|
      @card = card.to_i
      @card_trade = CardTrade.new(card_id: @card, trade_id: @trade.id)
      @cards_offer_names << Card.find(card).name
      @card_trade.save!
    end

    @cards_target.each do |card|
      @card = card.to_i
      @card_trade = CardTrade.new(card_id: @card, trade_id: @trade.id)
      @cards_target_names << Card.find(card).name
      @card_trade.save!
    end
  end

  def calcultate_total_price
    @total_price = 0
    @cards.each { |card| @total_price += card.image.price.to_f }
    @total_price
  end

  def calculate_other_total_price
    @other_total_price = 0
    @other_cards.each { |card| @other_total_price += card.image.price.to_f }
    @other_total_price
  end
end
