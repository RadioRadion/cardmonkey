class TradesController < ApplicationController
#ce skip permet de forcer le fake formulaire à ne pas nécessité d'authencitytoker
  skip_before_action :verify_authenticity_token

  def index
    @trades = Trade.where(user_id: current_user).or(Trade.where(user_id: current_user)).uniq
    @trades_pending = Trade.pending.where(user_id: current_user).or(Trade.pending.where(user_id_invit: current_user)).uniq
    @trades_done = Trade.done.where(user_id: current_user).or(Trade.done.where(user_id_invit: current_user)).uniq
    @trades_accepted = Trade.accepted.where(user_id: current_user).or(Trade.accepted.where(user_id_invit: current_user)).uniq
  end

  def create
    other_user_id = params[:user_id]
    @trade = Trade.new(status: "pending", user_id_invit: other_user_id)
    @trade.user = current_user
    @cards_offer = params[:trade][:offer].split(",")
    @cards_target = params[:trade][:target].split(",")
    # cards_offer_names = []
    # cards_target_names = []

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
    @total_price = calcultate_total_price(@cards).round(2)
    @other_total_price = calcultate_total_price(@other_cards).round(2)
  end

  def edit
    @user = User.find(params[:user_id])
    @trade = Trade.find(params[:id])
    @path = "/users/#{@user.id}/trades/#{@trade.id}"

    @cards_trade = @trade.cards.joins(:user).where(user_id: current_user)
    if current_user.id == @trade.user_id
      @other_cards_trade = @trade.cards.joins(:user).where(user_id: @trade.user_id_invit)
    else
      @other_cards_trade = @trade.cards.joins(:user).where(user_id: @trade.user_id)
    end
    users = User.near(current_user.address, current_user.area)
    @trade.user_id == current_user.id ? @other_user = User.find(@trade.user_id_invit) : @other_user = User.find(@trade.user_id)
    cards_id_wants = want_cards_id_by_user(current_user, @other_user, users)
    # On prend les instances de ces cartes
    @cards_i_wants = Card.find(cards_id_wants - @other_cards_trade.ids)
    # les autres cards
    @other_cards = @other_user.cards.where.not(id: cards_id_wants + @other_cards_trade.ids)

    # Inversement
    cards_id_other_wants = want_cards_id_by_user(@other_user, current_user, users)
    # cards_id_other_wants.reject { |id| @cards_trade.ids.include?(id) }
    @cards_other_wants = Card.find(cards_id_other_wants - @cards_trade.ids)
    @my_cards = current_user.cards.where.not(id: cards_id_other_wants + @cards_trade.ids)
  end

  def update
    @trade = Trade.find(params[:id])
    if params[:status] == "accepted"
      change_status_trade("Trade accepté ! Discutez-ici pour vous donner rendez-vous et procéder à l'échange.
      Une fois le trade terminé, n'oubliez pas de de valider !", "Trade validé !", "accepted")
    elsif params[:status] == "done"
      change_status_trade("Trade terminé bon jeu !", "Trade terminé !", "done")
    end
  end

  private

  def change_status_trade(content, flash, status)
    @trade.update(status: status)
    @trade.user_id == current_user.id ? other_user_id = @trade.user_id_invit : other_user_id = @trade.user_id
    Trade.save_message(current_user.id, other_user_id, content)
    flash[flash] = flash
    redirect_to user_trade_path(@trade.user_id, @trade)
  end

  def trade_params
    params.require(:trade).permit(:offer, :target)
  end

  def save_card_trades
    @cards_offer.each do |card|
      CardTrade.new(card_id: card.to_i, trade_id: @trade.id).save!
      # cards_offer_names << Card.find(card).name
    end

    @cards_target.each do |card|
      CardTrade.new(card_id: card.to_i, trade_id: @trade.id).save!
      # cards_target_names << Card.find(card).name
    end
  end

  def calcultate_total_price(cards)
    total_price = 0
    cards.each { |card| total_price += card.image.price.to_f }
    total_price
  end

  def want_cards_id_by_user(user, other_user, users)
    # format avant {user_id: [card_id, card_id], user_id: ......}
    user.want_cards_by_user(users).select { |user_cards| user_cards[:user_id] == other_user.id }[0][:cards]
    # format apres [card_id, card_id]
  end
end
