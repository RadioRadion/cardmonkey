class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: :index

  def index
    if user_signed_in?
      @recent_trades = current_user.trades
        .includes(:user, :user_invit, user_cards: [:card_version])
        .limit(5)
      @potential_matches = current_user.matches
        .includes(:user_card, :user_wanted_card)
        .limit(10)
      @notifications = current_user.notifications.unread.limit(5)
      @user_cards = current_user.user_cards
        .includes(card_version: :card)
        .limit(4)
      render 'index'
    else
      render 'landing'
    end
  end
end
