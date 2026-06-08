# app/controllers/matches_controller.rb
class MatchesController < ApplicationController
  include Pagy::Backend

  def index
    # Both directions of matching involving the current user.
    matches = Match.where("matches.user_id = :id OR matches.user_id_target = :id", id: current_user.id)
                   .includes(user_card: { card_version: %i[card extension] })

    # Per partner: what I can GIVE (cards I own they want) and RECEIVE (cards they own I want).
    partners = Hash.new { |hash, key| hash[key] = { give: [], receive: [] } }
    matches.each do |match|
      if match.user_id == current_user.id
        partners[match.user_id_target][:give] << match
      elsif match.user_id_target == current_user.id
        partners[match.user_id][:receive] << match
      end
    end

    @partner_users = User.where(id: partners.keys).index_by(&:id)
    sorted = partners.sort_by { |_id, lists| -(lists[:give].size + lists[:receive].size) }
    @pagy, @partner_pairs = pagy_array(sorted, limit: 10, page: params[:page] || 1)

    @stats = {
      matches: matches.size,
      partners: partners.size,
      active_trades: current_user.trades.active.count
    }
  end

  def show
    # Security: only matches the current user is part of (owner or target).
    @match = Match.where("user_id = :id OR user_id_target = :id", id: current_user.id)
                  .find(params[:id])
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
