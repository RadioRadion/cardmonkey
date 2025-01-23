class TradesController < ApplicationController
  before_action :set_trade, only: [:show, :edit, :update, :accept, :validate]
  before_action :set_trade_participants, only: [:show, :edit]
  before_action :set_partner, only: [:new_proposition, :update_trade_value, :search_cards]

  def index
    @trades = current_user.all_trades
      .includes(:user_cards, :trade_user_cards, user_cards: { card_version: [:card, :extension] })
      .group_by(&:status)

    # Load matches in both directions - where current user has cards others want
    # and where current user wants cards others have
    @matches = Match.where("(user_id = :user_id AND user_id_target != :user_id) OR (user_id_target = :user_id AND user_id != :user_id)", user_id: current_user.id)
      .includes(
        user_card: { card_version: [:card, :extension], user: {} },
        user_wanted_card: { card_version: [:card, :extension] }
      )
      .limit(5)

    # Get users with most matches
    @top_matching_users = Match.where(user: current_user)
      .group(:user_id_target)
      .select('user_id_target, COUNT(*) as match_count')
      .order('match_count DESC')
      .limit(4)
      .map { |m| [User.find(m.user_id_target), m.match_count] }

    @stats = {
      trades_completed: current_user.trades.done.count,
      cards_available: current_user.user_cards.count,
      cards_wanted: current_user.user_wanted_cards.count,
      potential_matches: current_user.matches.count
    }
  end

  def show
    @cards_by_user = @trade.user_cards
      .includes(card_version: [:card, :extension])
      .group_by(&:user_id)
      .transform_values { |cards| calculate_cards_info(cards) }
  end

  def edit
    @trade_data = TradeCardCollector.new(@trade, current_user).collect
  end

  def create
    if params[:trade][:user_id_invit].to_i == current_user.id
      redirect_back fallback_location: root_path, alert: "Vous ne pouvez pas échanger avec vous-même"
      return
    end

    @trade = Trade.new(
      user: current_user,
      user_id_invit: params[:trade][:user_id_invit],
      status: :pending
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
    result = case params.dig(:trade, :status) || params[:status]
    when "accepted"
      handle_trade_acceptance
    when "done"
      handle_trade_completion
    when "validated"
      handle_trade_validation
    when "modified"
      handle_trade_modification
    else
      if params[:trade].present? && (params[:trade][:offer].present? || params[:trade][:target].present?)
        handle_trade_modification
      else
        redirect_to trade_path(@trade), alert: "Action non valide."
        return
      end
    end

    # Si la méthode a retourné false, c'est qu'elle a déjà fait un redirect
    unless result == false
      respond_to do |format|
        format.html { redirect_to trade_path(@trade) }
        format.json { head :ok }
      end
    end
  end

  def validate
    if @trade.can_be_validated?(current_user)
      @trade.update!(status: :accepted)
      notify_trade_validation
      redirect_to trade_path(@trade), notice: "Modification validée !"
    else
      redirect_to trade_path(@trade), alert: "Vous ne pouvez pas valider cette modification."
    end
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
      user_id_invit: @partner.id,
      status: :pending
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
      format.html { head :ok }
      format.json { render json: @values }
    end
  end

  private

  def set_trade
    @trade = Trade.find(params[:id])
  end

  def set_partner
    @partner = User.find(params[:partner_id])
    if @partner.id == current_user.id
      redirect_to root_path, alert: "Vous ne pouvez pas échanger avec vous-même"
      return
    end
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
      total_price: cards.sum { |card| card.card_version.eur_price.to_f }.round(2)
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
    
    Rails.logger.info "Processing trade cards for trade ##{@trade.id}"
    Rails.logger.info "Offer cards: #{offer_cards.inspect}"
    Rails.logger.info "Target cards: #{target_cards.inspect}"
    
    @trade.trade_user_cards.destroy_all
    
    (offer_cards + target_cards).each do |card_id|
      next if card_id.blank?
      @trade.trade_user_cards.create!(user_card_id: card_id.to_i)
    end

    Rails.logger.info "After processing, trade has #{@trade.trade_user_cards.count} cards"
  end

  def notify_trade_creation
    begin
      Notification.create_trade_notification(
        @trade.user_id_invit,
        @trade.id,
        I18n.t('notifications.trade.new_trade', id: @trade.id)
      )
      chatroom = Trade.find_or_create_chatroom(current_user.id, @trade.user_id_invit)
    Message.create!(
      content: "#{current_user.username} a proposé un échange",
      user_id: current_user.id,
      chatroom_id: chatroom.id,
      metadata: { 'type' => 'trade', 'trade_id' => @trade.id }
    )
    rescue => e
      Rails.logger.error "Error in notify_trade_creation: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      raise e
    end
  end

  def handle_trade_acceptance
    unless @trade.can_be_accepted_by?(current_user)
      redirect_to trade_path(@trade), alert: "Vous ne pouvez pas accepter ce trade."
      return false
    end

    Trade.transaction do
      @trade.update!(status: :accepted)
      notify_trade_status_change(
        "Trade accepté ! Discutez-ici pour vous donner rendez-vous.",
        I18n.t('notifications.trade.trade_accepted', id: @trade.id)
      )
    end
    true
  end

  def handle_trade_completion
    unless @trade.accepted?
      redirect_to trade_path(@trade), alert: "Seul un trade accepté peut être marqué comme terminé."
      return false
    end

    Trade.transaction do
      @trade.completed_by_user_ids = (@trade.completed_by_user_ids || []) + [current_user.id]
      
      if @trade.completed_by_user_ids.sort == [@trade.user_id, @trade.user_id_invit].sort
        @trade.status = :done
        notify_trade_status_change(
          "Les deux participants ont confirmé que l'échange physique a été réalisé. Trade terminé, bon jeu !",
          I18n.t('notifications.trade.trade_completed', id: @trade.id)
        )
      else
        other_user = @trade.other_user(current_user)
        notify_trade_status_change(
          "#{current_user.username} confirme avoir réalisé l'échange physiquement. En attente de la confirmation de #{other_user.username}.",
          I18n.t('notifications.trade.trade_completion_pending', id: @trade.id, username: current_user.username)
        )
      end
      
      @trade.save!
    end
    true
  end

  def handle_trade_modification
    unless @trade.can_be_modified_by?(current_user)
      redirect_to trade_path(@trade), alert: "Vous ne pouvez pas modifier ce trade."
      return false
    end

    Rails.logger.info "Starting trade modification for trade ##{@trade.id}"
    Rails.logger.info "Current user: #{current_user.id}"
    Rails.logger.info "Params: #{params.inspect}"

    Trade.transaction do
      process_trade_cards
      @trade.update!(status: :modified, last_modifier_id: current_user.id)
      notify_trade_status_change(
        "Une modification a été proposée pour le trade #{@trade.id}",
        I18n.t('notifications.trade.trade_modified', id: @trade.id)
      )
    end

    Rails.logger.info "Trade modification completed for trade ##{@trade.id}"
    Rails.logger.info "New card count: #{@trade.trade_user_cards.count}"
    true
  end

  def handle_trade_validation
    unless @trade.can_be_validated?(current_user)
      redirect_to trade_path(@trade), alert: "Vous ne pouvez pas valider ce trade."
      return false
    end

    @trade.update!(status: :accepted)
    notify_trade_validation
    true
  end

  def notify_trade_validation
    other_user = @trade.other_user(current_user)
    chatroom = Trade.find_or_create_chatroom(current_user.id, other_user.id)
    Message.create!(
      content: "✅ La modification de l'échange a été validée ! Vous pouvez maintenant organiser la rencontre.",
      user_id: current_user.id,
      chatroom_id: chatroom.id,
      metadata: { 'type' => 'trade', 'trade_id' => @trade.id }
    )
    Notification.create_trade_notification(
      other_user.id,
      @trade.id,
      I18n.t('notifications.trade.trade_validated', id: @trade.id)
    )
  end

  def notify_trade_status_change(message, notification_text)
    other_user = @trade.other_user(current_user)
    chatroom = Trade.find_or_create_chatroom(current_user.id, other_user.id)
    Message.create!(
      content: message,
      user_id: current_user.id,
      chatroom_id: chatroom.id,
      metadata: { 'type' => 'trade', 'trade_id' => @trade.id }
    )
    Notification.create_trade_notification(other_user.id, @trade.id, notification_text)
  end
end
