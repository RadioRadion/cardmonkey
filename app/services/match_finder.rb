# Single source of truth for the matching algorithm.
#
# Both directions (a new/updated UserCard, and a new/updated UserWantedCard)
# go through here, so the matching rules — same card, compatible language, and
# the owned condition meeting the wanted minimum condition — are applied
# identically on both sides (previously the UserWantedCard path skipped the
# condition filter, producing asymmetric matches).
class MatchFinder
  # Canonical condition ordering (worst -> best). Reused everywhere.
  CONDITION_ORDER = CardConditionManagement::CONDITION_ORDER

  UNIQUE_INDEX = :index_matches_on_user_card_and_wanted_card_unique

  # Ordinal value of a stored card condition, expressed in SQL.
  USER_CARD_CONDITION_SQL = <<~SQL.squish
    CASE user_cards.condition
      WHEN 'poor' THEN 0
      WHEN 'played' THEN 1
      WHEN 'light_played' THEN 2
      WHEN 'good' THEN 3
      WHEN 'excellent' THEN 4
      WHEN 'near_mint' THEN 5
      WHEN 'mint' THEN 6
      ELSE 0
    END
  SQL

  # Ordinal value of a wanted minimum condition, expressed in SQL.
  WANTED_MIN_CONDITION_SQL = <<~SQL.squish
    CASE COALESCE(user_wanted_cards.min_condition, 'poor')
      WHEN 'poor' THEN 0
      WHEN 'played' THEN 1
      WHEN 'light_played' THEN 2
      WHEN 'good' THEN 3
      WHEN 'excellent' THEN 4
      WHEN 'near_mint' THEN 5
      WHEN 'mint' THEN 6
      ELSE 0
    END
  SQL

  class << self
    # Idempotently (re)build matches for a UserCard, returns rows inserted.
    def create_for_user_card(user_card)
      insert(rows_for_user_card(user_card))
    end

    # Idempotently (re)build matches for a UserWantedCard, returns rows inserted.
    def create_for_user_wanted_card(user_wanted_card)
      insert(rows_for_user_wanted_card(user_wanted_card))
    end

    def rows_for_user_card(user_card)
      condition_value = CONDITION_ORDER.index(user_card.condition) || 0
      # enum reader returns the key ('french'); the column stores the value ('fr').
      language_value = UserCard.languages[user_card.language] || user_card.language

      wanted = UserWantedCard
               .where.not(user_id: user_card.user_id)
               .where(card_id: user_card.card_version.card_id)
               .where("user_wanted_cards.language = 'any' OR user_wanted_cards.language = ?", language_value)
               .where("user_wanted_cards.min_condition = 'unimportant' OR ? >= (#{WANTED_MIN_CONDITION_SQL})", condition_value)
               .select(:id, :user_id)

      timestamped(wanted.map do |w|
        { user_card_id: user_card.id, user_wanted_card_id: w.id,
          user_id: user_card.user_id, user_id_target: w.user_id }
      end)
    end

    def rows_for_user_wanted_card(user_wanted_card)
      scope = UserCard
              .joins(card_version: :card)
              .where.not(user_id: user_wanted_card.user_id)
              .where(cards: { id: user_wanted_card.card_id })

      scope = scope.where(language: user_wanted_card.language) unless user_wanted_card.language == 'any'

      unless user_wanted_card.min_condition == 'unimportant'
        min_value = CONDITION_ORDER.index(user_wanted_card.min_condition) || 0
        scope = scope.where("(#{USER_CARD_CONDITION_SQL}) >= ?", min_value)
      end

      cards = scope.select('user_cards.id, user_cards.user_id')

      timestamped(cards.map do |uc|
        { user_card_id: uc.id, user_wanted_card_id: user_wanted_card.id,
          user_id: uc.user_id, user_id_target: user_wanted_card.user_id }
      end)
    end

    private

    def timestamped(rows)
      now = Time.current
      rows.each { |row| row.merge!(created_at: now, updated_at: now) }
    end

    # Bulk insert, skipping rows that already exist (unique index), so the job
    # is idempotent and safe to retry / run concurrently from both sides.
    def insert(rows)
      return 0 if rows.empty?

      Match.insert_all(rows, unique_by: UNIQUE_INDEX)
      rows.size
    end
  end
end
