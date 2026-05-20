# app/controllers/matches_controller.rb
class MatchesController < ApplicationController
  include Pagy::Backend

  def index
    # Get paginated list of users with match counts (efficient query)
    matched_users_data = Match.where(user_id: current_user.id)
      .group(:user_id_target)
      .select('user_id_target, COUNT(*) as match_count')
      .order('match_count DESC')

    # Paginate the matched users (10 per page)
    @pagy, @matched_users_page = pagy_array(
      matched_users_data.to_a,
      items: 10,
      page: params[:page] || 1
    )

    # Batch load users for this page
    user_ids_on_page = @matched_users_page.map(&:user_id_target)
    users_by_id = User.where(id: user_ids_on_page).index_by(&:id)

    # Load matches only for users on this page
    matches_for_page = current_user.matches
      .where(user_id_target: user_ids_on_page)
      .includes(user_card: { card_version: :card }, user_wanted_card: :card)

    # Group matches by user (already limited to this page's users)
    @matches_by_user = {}
    @matched_users_page.each do |data|
      user = users_by_id[data.user_id_target]
      next unless user
      user_matches = matches_for_page.select { |m| m.user_id_target == user.id }
      @matches_by_user[user] = user_matches.take(20) # Limit matches per user displayed
    end

    # Statistiques (count queries, not full loads)
    @matches_count = current_user.matches.count
    @matched_users_count = matched_users_data.length
    @active_trades_count = current_user.trades.active.count rescue 0
  end

  def show
    @match = Match.find(params[:id])
    render json: {
      match: @match,
      user_card: @match.user_card.as_json(include: { card_version: { include: :card } }),
      user_wanted_card: @match.user_wanted_card.as_json(include: :card)
    }
  end

  def matches
    @stats = {
      total_matches: current_user.matches.count,
      matches_by_condition: current_user.matches
                                     .joins(user_card: :card_version)
                                     .group('user_cards.condition')
                                     .count,
      matches_by_language: current_user.matches
                                     .joins(user_card: :card_version)
                                     .group('user_cards.language')
                                     .count,
      top_matched_users: current_user.top_matching_users(5),
      recent_matches: current_user.matches
                                .includes(user_card: { card_version: :card }, user_wanted_card: :card)
                                .order(created_at: :desc)
                                .limit(5),
      pending_trades: current_user.trades.pending.count,
      completed_trades: current_user.trades.completed.count
    }
  end
end