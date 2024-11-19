# app/controllers/matches_controller.rb
class MatchesController < ApplicationController
  def index
    # Récupérer tous les matches de l'utilisateur actuel
    all_matches = current_user.matches
                            .includes(user_card: { card_version: :card }, 
                                    user_wanted_card: :card)

    # Créer un Hash des matches groupés par utilisateur
    @matches_by_user = all_matches.each_with_object({}) do |match, hash|
      # Déterminer l'autre utilisateur dans le match
      other_user = if match.user_id == current_user.id
                    User.find(match.user_id_target)
                  else
                    User.find(match.user_id)
                  end

      # Initialiser ou ajouter au tableau de matches pour cet utilisateur
      hash[other_user] ||= []
      hash[other_user] << match
    end

    # Trier le hash par nombre de matches (du plus grand au plus petit)
    @matches_by_user = @matches_by_user.sort_by { |_, matches| -matches.size }.to_h

    # Statistiques
    @matches_count = all_matches.count
    @matched_users_count = @matches_by_user.keys.count
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