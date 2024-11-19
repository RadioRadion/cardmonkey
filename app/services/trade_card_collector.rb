# app/services/trade_card_collector.rb
class TradeCardCollector
  def initialize(trade, current_user)
    @trade = trade
    @current_user = current_user
    @other_user = @trade.other_user(@current_user)
  end

  def collect
    {
      trade_cards: collect_trade_cards,
      wanted_cards: collect_wanted_cards,
      collection_cards: collect_collection_cards
    }
  end

  private

  def collect_trade_cards
    {
      mine: @trade.user_cards.where(user: @current_user),
      theirs: @trade.user_cards.where(user: @other_user)
    }
  end

  def collect_wanted_cards
    {
      they_want: find_wanted_cards(@other_user, @current_user),
      i_want: find_wanted_cards(@current_user, @other_user)
    }
  end

  def collect_collection_cards
    {
      mine: find_remaining_collection(@current_user),
      theirs: find_remaining_collection(@other_user)
    }
  end

  def find_wanted_cards(wanting_user, having_user)
    wanted_card_ids = wanting_user.user_wanted_cards.pluck(:card_id)
    having_user.user_cards
              .where(card_id: wanted_card_ids)
              .where.not(id: @trade.user_cards.pluck(:id))
  end

  def find_remaining_collection(user)
    user.user_cards
        .where.not(id: @trade.user_cards.pluck(:id))
        .where.not(id: all_wanted_cards_ids(user))
  end

  def all_wanted_cards_ids(user)
    if user == @current_user
      find_wanted_cards(@other_user, user).pluck(:id)
    else
      find_wanted_cards(@current_user, user).pluck(:id)
    end
  end
end