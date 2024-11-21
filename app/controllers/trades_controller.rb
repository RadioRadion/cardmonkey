class TradesController < ApplicationController
  before_action :set_trade, only: [:show, :edit, :update, :accept]  # Limite les actions
  before_action :set_trade_participants, only: [:show, :edit]
  before_action :set_partner, only: [:new_proposition, :update_trade_value]

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
    Rails.logger.debug "Trade params: #{params[:trade].inspect}"
    Rails.logger.debug "Current user: #{current_user.inspect}"
    
    @trade = current_user.trades.build(
      user_id_invit: params[:trade][:user_id_invit],
      status: "pending"
    )

    Rails.logger.debug "Created trade: #{@trade.inspect}"
    Rails.logger.debug "Trade errors: #{@trade.errors.full_messages}" if @trade.invalid?

    if @trade.save
      handle_trade_creation
      redirect_to user_path(current_user), notice: "Proposition de trade envoyée !"
    else
      Rails.logger.error("Trade creation failed: #{@trade.errors.full_messages}")
      redirect_back fallback_location: root_path, alert: "Erreur lors de la création du trade: #{@trade.errors.full_messages.join(', ')}"
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

    # Appliquer les filtres de recherche
    if params[:user_query].present?
      @user_cards = @user_cards.joins(card_version: :card)
        .where("cards.name_#{I18n.locale} ILIKE ?", "%#{params[:user_query]}%")
    end
  
    if params[:partner_query].present?
      @partner_cards = @partner_cards.joins(card_version: :card)
        .where("cards.name_#{I18n.locale} ILIKE ?", "%#{params[:partner_query]}%")
    end

    if params[:filter].present?
      apply_advanced_filters
    end
    
    # Récupérer l'historique des trades
    @trade_history = Trade.where(
      "(user_id = ? AND user_id_invit = ?) OR (user_id = ? AND user_id_invit = ?)",
      current_user.id, @partner.id, @partner.id, current_user.id
    ).order(created_at: :desc).limit(5)

    # Suggestions basées sur les wishlists
    @suggested_cards = find_suggested_cards

    @trade = Trade.new(
      user: current_user,
      user_id_invit: @partner.id
    )

    respond_to do |format|
      format.html
      format.turbo_stream if turbo_stream_request?
    end
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

  def apply_advanced_filters
    filter_params = params[:filter]
  
    @user_cards = @user_cards.where(language: filter_params[:language]) if filter_params[:language].present?
    @user_cards = @user_cards.where(condition: filter_params[:condition]) if filter_params[:condition].present?
    
    if filter_params[:rarity].present?
      @user_cards = @user_cards.where(card_versions: { rarity: filter_params[:rarity] })
    end
  
    if filter_params[:price_min].present? || filter_params[:price_max].present?
      @user_cards = @user_cards.where(
        price: filter_params[:price_min].to_f..filter_params[:price_max].to_f
      )
    end
  end

  def notify_trade_status_change(message, notification_text)
    other_user_id = @trade.other_user_id(current_user)
    Trade.save_message(current_user.id, other_user_id, message)
    Notification.create_notification(other_user_id, notification_text)
  end

  def turbo_stream_request?
    params[:user_query].present? || 
    params[:partner_query].present? || 
    params[:filter].present?
  end
end
