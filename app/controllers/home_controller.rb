class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: :index

  def index
    if user_signed_in?
      @recent_trades = current_user.all_trades
        .includes(:user, :user_invit, user_cards: [:card_version])
        .order(updated_at: :desc)
        .limit(5)
      @potential_matches = Match.where("(user_id = :user_id AND user_id_target != :user_id) OR (user_id_target = :user_id AND user_id != :user_id)", user_id: current_user.id)
        .includes(
          user_card: { card_version: [:card, :extension], user: {} },
          user_wanted_card: { card_version: [:card, :extension] }
        )
        .limit(10)
      @notifications = current_user.notifications.unread.limit(5)
      @user_cards = current_user.user_cards
        .includes(card_version: :card)
        .limit(4)
      @user_wanted_cards = current_user.user_wanted_cards
        .includes(:card)
        .limit(4)
      render 'index'
    else
      render 'landing'
    end
  end
end
