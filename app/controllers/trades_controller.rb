class TradesController < ApplicationController
  before_action :set_trade, only: [:show, :edit, :update, :accept]
  before_action :set_trade_participants, only: [:show, :edit]

  def index
    @trades = current_user.all_trades.includes(:user_cards, :trade_user_cards)
      .group_by(&:status)
  end

  def show
    @cards_by_user = @trade.user_cards
      .includes(:card_version)
      .group_by(&:user_id)
      .transform_values { |cards| calculate_cards_info(cards) }
  end

  def edit
    @trade_data = TradeCardCollector.new(@trade, current_user).collect
  end

  def create
    @trade = Trade.new(
      user: current_user,
      user_id_invit: params[:user_id],
      status: "pending"
    )

    if @trade.save
      handle_trade_creation
      redirect_to user_path(current_user), notice: "Proposition de trade envoyée !"
    else
      redirect_back fallback_location: root_path, alert: "Erreur lors de la création du trade"
    end
  end

  def update
    case params[:status]
    when "accepted"
      handle_trade_acceptance
    when "done"
      handle_trade_completion
    else
      handle_trade_modification
    end

    redirect_to user_trade_path(@trade.user_id, @trade)
  end

  private

  def set_trade
    @trade = Trade.find(params[:id])
  end

  def set_trade_participants
    @other_user = current_user.id == @trade.user_id ? 
      User.find(@trade.user_id_invit) : 
      User.find(@trade.user_id)
  end

  def calculate_cards_info(cards)
    {
      cards: cards,
      total_price: cards.sum { |card| card.price.to_f }.round(2)
    }
  end

  def handle_trade_creation
    process_trade_cards
    notify_trade_creation
  end

  def process_trade_cards
    offer_cards = params[:trade][:offer].to_s.split(",")
    target_cards = params[:trade][:target].to_s.split(",")
    
    (offer_cards + target_cards).each do |card_id|
      @trade.trade_user_cards.create!(user_card_id: card_id.to_i)
    end
  end

  def notify_trade_creation
    Notification.create_notification(@trade.user_id_invit, "Nouveau trade !")
    Trade.save_message(
      current_user.id, 
      @trade.user_id_invit, 
      "Un nouveau trade est arrivé ! #{@trade.id}"
    )
  end

  def handle_trade_acceptance
    @trade.update!(status: "accepted")
    notify_trade_status_change(
      "Trade accepté ! Discutez-ici pour vous donner rendez-vous.",
      "Trade accepté !"
    )
  end

  def handle_trade_completion
    @trade.update!(status: "done")
    notify_trade_status_change(
      "Trade terminé, bon jeu !",
      "Trade réalisé !"
    )
  end

  def handle_trade_modification
    return unless @trade.pending?

    Trade.transaction do
      @trade.trade_user_cards.destroy_all
      process_trade_cards
      notify_trade_status_change(
        "Trade modifié ! #{@trade.id}",
        "Trade modifié !"
      )
    end
  end

  def notify_trade_status_change(message, notification_text)
    other_user_id = @trade.other_user_id(current_user)
    Trade.save_message(current_user.id, other_user_id, message)
    Notification.create_notification(other_user_id, notification_text)
  end
end