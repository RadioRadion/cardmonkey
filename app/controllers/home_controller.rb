class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: :index

  def index
    if user_signed_in?
      load_dashboard_data(current_user)
      render 'dashboard_app'
    else
      render 'landing'
    end
  end

  private

  def load_dashboard_data(user)
    @recent_trades = user.all_trades
                         .includes(:user, :user_invit, user_cards: [:card_version])
                         .order(updated_at: :desc)
                         .limit(5)
    @potential_matches = Match.where("(user_id = :user_id AND user_id_target != :user_id) OR (user_id_target = :user_id AND user_id != :user_id)", user_id: user.id)
                              .includes(
                                user_card: { card_version: %i[card extension], user: {} },
                                user_wanted_card: { card_version: %i[card extension] }
                              )
                              .limit(10)
    # Preload partner users to avoid N+1 in the dashboard match list
    partner_ids = @potential_matches.flat_map { |m| [m.user_id, m.user_id_target] }.uniq - [user.id]
    @match_users_by_id = User.where(id: partner_ids).index_by(&:id)
    @notifications = user.notifications.unread.limit(5)
    @user_cards = user.user_cards.includes(card_version: :card).limit(4)
    @user_wanted_cards = user.user_wanted_cards.includes(:card).limit(4)
    @onboarding = {
      address: user.address.present?,
      cards: user.user_cards.exists?,
      wishlist: user.user_wanted_cards.exists?
    }
  end
end
