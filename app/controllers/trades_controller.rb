class TradesController < ApplicationController
#ce skip permet de forcer le fake formulaire à ne pas nécessité d'authencitytoker
  skip_before_action :verify_authenticity_token

  def index
    @trades = Trade.where(user_id: current_user)
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

    if @trade.save!
      save_card_trades
      Notification.create_notification(@trade.user_id_invit, "Nouveau trade !")
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

    @cards = @trade.user_cards.joins(:user).where(user_id: current_user)
    if current_user.id == @trade.user_id
      @other_cards = @trade.user_cards.joins(:user).where(user_id: @trade.user_id_invit)
    else
      @other_cards = @trade.user_cards.joins(:user).where(user_id: @trade.user_id)
    end
    @total_price = calculate_total_price(@cards).round(2)
    @other_total_price = calculate_total_price(@other_cards).round(2)
  end

  def edit
    @user = User.find(params[:user_id])
    @trade = Trade.find(params[:id])
    @path = "/users/#{@user.id}/trades/#{@trade.id}"

    @trade_user_cards = @trade.user_cards.joins(:user).where(user_id: current_user).uniq
    if current_user.id == @trade.user_id
      other_user = User.find(@trade.user_id_invit)
      @trade_user_wanted_cards = @trade.user_cards.joins(:user).where(user_id: @trade.user_id_invit).uniq
    else
      other_user = User.find(@trade.user_id)
      @trade_user_wanted_cards = @trade.user_cards.joins(:user).where(user_id: @trade.user_id).uniq
    end
    cards_other_wants_ids = other_user.user_wanted_cards.map(&:card_id)
    @cards_other_wants = UserCard.where(user_id: current_user).where(card_id: cards_other_wants_ids) - @trade_user_cards
    cards_i_wants_ids = current_user.user_wanted_cards.map(&:card_id)
    @cards_i_wants = UserCard.where(user_id: other_user).where(card_id: cards_i_wants_ids) - @trade_user_wanted_cards

    @my_cards = current_user.user_cards.where.not(id: @trade_user_cards.map(&:id) + @cards_other_wants.map(&:id))
    @other_cards = other_user.user_cards.where.not(id: @trade_user_wanted_cards.map(&:id) + @cards_i_wants.map(&:id))
  end

  def update
    @trade = Trade.find(params[:id])
    current_user.id == @trade.user_id ? other_user_id = @trade.user_id_invit : other_user_id = @trade.user_id
    if params[:status] == "accepted"
      change_status_trade("Trade accepté ! Discutez-ici pour vous donner rendez-vous et procéder à l'échange.
      Une fois le trade terminé, n'oubliez pas de de valider !", "Trade validé !", "accepted")
      Notification.create_notification(other_user_id, "Trade accepté !")
    elsif params[:status] == "done"
      change_status_trade("Trade terminé bon jeu !", "Trade terminé !", "done")
      Notification.create_notification(other_user_id, "Trade réalisé !")
    elsif @trade.pending?
      @trade.trade_user_cards.destroy_all
      user_card_ids = params[:trade][:offer].split(",") + params[:trade][:target].split(",")
      user_card_ids.each { |user_card_id| @trade.trade_user_cards.create(user_card_id: user_card_id) }
      content = "Trade modifié ! #{@trade.id}"
      change_status_trade(content, "Trade modifié !", "pending")
      Notification.create_notification(other_user_id, "Trade modifié !")
    end
    redirect_to user_trade_path(@trade.user_id, @trade)
  end

  private

  def change_status_trade(content, flash, status)
    @trade.update(status: status) if status != "pending"
    @trade.user_id == current_user.id ? other_user_id = @trade.user_id_invit : other_user_id = @trade.user_id
    Trade.save_message(current_user.id, other_user_id, content)
    flash[flash] = flash
  end

  def trade_params
    params.require(:trade).permit(:offer, :target)
  end

  def save_card_trades
    @cards_offer.each do |user_card_id|
      TradeUserCard.create!(user_card_id: user_card_id.to_i, trade_id: @trade.id)
    end

    @cards_target.each do |user_card_id|
      TradeUserCard.create!(user_card_id: user_card_id.to_i, trade_id: @trade.id)
    end
  end

  def calculate_total_price(cards)
    total_price = 0
    cards.each { |card| total_price += card.price.to_f }
    total_price
  end
end
