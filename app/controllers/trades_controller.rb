class TradesController < ApplicationController
#ce skip permet de forcer le fake formulaire à ce pas nécessité d'authencitytoker
  skip_before_action :verify_authenticity_token

  def create
    @userTarget = params[:user_id]
    @trade = Trade.new(status: "pending", user_id_invit: @userTarget)
    @trade.user = current_user

    @cardsOffer = params[:trade][:offer].split(",")
    @cardsTarget = params[:trade][:target].split(",")
    @cardsOfferNames = []
    @cardsTargetNames = []

    if @trade.save!
      save_card_trades;
      save_message;
      redirect_to user_path(current_user)
    else
      render 'users/show'
    end
  end

  def show
    @trade = Trade.find(params[:id])
    if current_user.id == @trade.user_id
      @cards = @trade.cards.joins(:user).where(user_id: current_user)
      @othercards = @trade.cards.joins(:user).where(user_id: @trade.user_id_invit)
    else
      @cards = @trade.cards.joins(:user).where(user_id: current_user)
      @othercards = @trade.cards.joins(:user).where(user_id: @trade.user_id)
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
      @cardsOfferNames << Card.find(card).name
      @cardtrade.save!
    end

    @cardsTarget.each do |card|
      @card = card.to_i
      @cardtrade = CardTrade.new(card_id: @card, trade_id: @trade.id)
      @cardsTargetNames << Card.find(card).name
      @cardtrade.save!
    end
  end

  def save_message
    @firstChat = Chatroom.where(user_id: current_user, user_id_invit: @userTarget).first
    @secondChat = Chatroom.where(user_id: @userTarget, user_id_invit: current_user).first
    @content = "Un nouveau trade est arrivé ! #{@trade.id}"

    if !@firstChat.nil?
      Message.new(content: @content, user_id: current_user.id, chatroom_id: @firstChat.id).save!
    elsif !@secondChat.nil?
      Message.new(content: @content, user_id: current_user.id, chatroom_id: @secondChat.id).save!
    else
      @chatroom = Chatroom.new(user_id: current_user.id, user_id_invit: @userTarget)
      @chatroom.save!
      Message.new(content: @content, user_id: current_user.id, chatroom_id: @chatroom.id).save!
    end

  end

end
