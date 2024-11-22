class TradesController < ApplicationController
  before_action :set_trade, only: [:show, :edit, :update, :accept]
  before_action :set_trade_participants, only: [:show, :edit]
  before_action :set_partner, only: [:new_proposition, :update_trade_value, :search_cards]

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
    @trade = current_user.trades.build(
      user_id_invit: params[:trade][:user_id_invit],
      status: "pending"
    )

    if @trade.save
      handle_trade_creation
      redirect_to user_path(current_user), notice: "Proposition de trade envoyée !"
    else
      redirect_back fallback_location: root_path, 
                    alert: "Erreur lors de la création du trade: #{@trade.errors.full_messages.join(', ')}"
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

  def new_proposition
    @user_cards = current_user.user_cards
      .includes(card_version: [:card, :extension])
      .order("cards.name_#{I18n.locale}")
  
    @partner_cards = @partner.user_cards
      .includes(card_version: [:card, :extension])
      .order("cards.name_#{I18n.locale}")

    @trade_history = Trade.where(
      "(user_id = ? AND user_id_invit = ?) OR (user_id = ? AND user_id_invit = ?)",
      current_user.id, @partner.id, @partner.id, current_user.id
    ).order(created_at: :desc).limit(5)

    @suggested_cards = find_suggested_cards

    @trade = Trade.new(
      user: current_user,
      user_id_invit: @partner.id
    )
  end

  def search_cards
    query = params[:query].to_s.strip
    side = params[:side]

    cards = if side == 'user'
      current_user.user_cards
    else
      @partner.user_cards
    end

    @filtered_cards = cards
      .includes(card_version: [:card, :extension])
      .joins(card_version: :card)

    # Si la requête est vide, on retourne toutes les cartes
    if query.blank?
      @filtered_cards = @filtered_cards.order("cards.name_#{I18n.locale}")
    else
      @filtered_cards = @filtered_cards
        .where("cards.name_fr ILIKE :query OR cards.name_en ILIKE :query", query: "%#{query}%")
        .order("cards.name_#{I18n.locale}")
        .limit(20)
    end

    render partial: "trades/card", 
           collection: @filtered_cards, 
           locals: { side: side }
  end

  def update_trade_value
    @selected_cards = {
      user: parse_card_quantities(params[:user_cards]),
      partner: parse_card_quantities(params[:partner_cards])
    }

    @values = calculate_trade_values(@selected_cards)
    @trade_balance = @values[:user_total] - @values[:partner_total]

    respond_to do |format|
      format.turbo_stream
      format.json { render json: @values }
    end
  end

  private

  def set_trade
    @trade = Trade.find(params[:id])
  end

  def set_partner
    @partner = User.find(params[:partner_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Utilisateur non trouvé"
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

  def find_suggested_cards
    wanted_cards = @partner.user_wanted_cards.pluck(:card_id)
    my_wanted_cards = current_user.user_wanted_cards.pluck(:card_id)

    {
      for_partner: current_user.user_cards
        .includes(card_version: :card)
        .where(cards: { id: wanted_cards })
        .limit(6),
      for_me: @partner.user_cards
        .includes(card_version: :card)
        .where(cards: { id: my_wanted_cards })
        .limit(6)
    }
  end

  def parse_card_quantities(cards_param)
    return [] if cards_param.blank?

    cards_param.to_h.map do |card_id, quantity|
      {
        card: UserCard.find(card_id),
        quantity: quantity.to_i
      }
    end
  end

  def calculate_trade_values(selected_cards)
    {
      user_total: calculate_side_value(selected_cards[:user]),
      partner_total: calculate_side_value(selected_cards[:partner])
    }
  end

  def calculate_side_value(cards)
    cards.sum { |item| item[:card].card_version.eur_price.to_f * item[:quantity] }
  end

  def handle_trade_creation
    process_trade_cards
    notify_trade_creation
  end

  def process_trade_cards
    offer_cards = params.dig(:trade, :offer).to_s.split(",").reject(&:blank?)
    target_cards = params.dig(:trade, :target).to_s.split(",").reject(&:blank?)
    
    (offer_cards + target_cards).each do |card_id|
      next if card_id.blank?
      @trade.trade_user_cards.create!(user_card_id: card_id.to_i)
    end
  end

  def notify_trade_creation
    Notification.create_notification(@trade.user_id_invit, "Nouveau trade proposé !")
    Trade.save_message(
      current_user.id, 
      @trade.user_id_invit, 
      "trade_id:#{@trade.id}"
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
    Trade.save_message(current_user.id, other_user_id, "trade_id:#{@trade.id}")
    Notification.create_notification(other_user_id, notification_text)
  end
end
