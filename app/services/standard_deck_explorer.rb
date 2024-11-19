# app/services/standard_deck_explorer.rb
class StandardDeckExplorer
  STANDARD_SETS = [
    'woe', # Wilds of Eldraine
    'lci', # Lost Caverns of Ixalan
    'mom', # March of the Machine
    'one', # Phyrexia: All Will Be One
    'bro', # The Brothers' War
    'dmu', # Dominaria United
    'snc', # Streets of New Capenna
    'neo', # Kamigawa: Neon Dynasty
    'vow', # Innistrad: Crimson Vow
    'mid'  # Innistrad: Midnight Hunt
  ]

  def initialize
    @cards = Card.where(set_code: STANDARD_SETS)
                 .includes(:card_types, :keywords)
    build_card_cache
  end

  def explore_unique_strategies
    @potential_strategies = []
    
    explore_uncommon_tribal_synergies
    explore_mechanic_based_strategies
    explore_cross_set_synergies
    explore_alternate_win_conditions
    
    @potential_strategies
  end

  private

  def build_card_cache
    @card_cache = {
      by_type: @cards.group_by { |c| c.card_types.map(&:name) },
      by_keyword: @cards.group_by { |c| c.keywords.map(&:name) },
      by_cmc: @cards.group_by { |c| c.cmc },
      by_color: @cards.group_by { |c| c.colors }
    }
    
    # Cache pour les cartes par mot-clé dans le texte
    @text_cache = build_text_cache
  end

  def build_text_cache
    cache = {}
    @cards.each do |card|
      text = card.oracle_text.downcase
      # Cherche des mots-clés stratégiques dans le texte
      cache[:sacrifice] ||= [] << card if text.include?('sacrifice')
      cache[:counter] ||= [] << card if text.match?(/put.*counter|remove.*counter/)
      cache[:copy] ||= [] << card if text.include?('copy')
      cache[:trigger] ||= [] << card if text.match?(/when|whenever|at the beginning/)
      # Ajoute plus de catégories selon les mécaniques à explorer
    end
    cache
  end

  def explore_uncommon_tribal_synergies
    # Cherche des tribus peu exploitées avec suffisamment de support
    creature_types = @cards.flat_map { |c| c.subtypes }.uniq
    
    creature_types.each do |tribe|
      tribal_cards = @cards.select { |c| c.subtypes.include?(tribe) }
      tribal_support = find_tribal_support(tribe)
      
      if tribal_cards.size >= 8 && tribal_support.size >= 4
        strategy = build_tribal_strategy(tribal_cards, tribal_support)
        @potential_strategies << strategy if viable_strategy?(strategy)
      end
    end
  end

  def explore_mechanic_based_strategies
    # Cherche des combinaisons de mécaniques intéressantes
    mechanics = extract_unique_mechanics
    
    mechanics.combination(2).each do |mech1, mech2|
      cards_with_mech1 = find_cards_with_mechanic(mech1)
      cards_with_mech2 = find_cards_with_mechanic(mech2)
      
      if mechanics_synergize?(mech1, mech2)
        strategy = build_mechanic_strategy(cards_with_mech1, cards_with_mech2)
        @potential_strategies << strategy if viable_strategy?(strategy)
      end
    end
  end

  def explore_cross_set_synergies
    # Cherche des synergies entre cartes de différents sets
    STANDARD_SETS.combination(2).each do |set1, set2|
      set1_cards = @cards.select { |c| c.set_code == set1 }
      set2_cards = @cards.select { |c| c.set_code == set2 }
      
      synergies = find_cross_set_synergies(set1_cards, set2_cards)
      synergies.each do |synergy|
        strategy = build_cross_set_strategy(synergy)
        @potential_strategies << strategy if viable_strategy?(strategy)
      end
    end
  end

  def explore_alternate_win_conditions
    # Cherche des win conditions non-conventionnelles
    win_conditions = find_alternate_win_conditions
    
    win_conditions.each do |win_con|
      support_cards = find_win_condition_support(win_con)
      if support_cards.size >= 12  # Assez de support pour construire autour
        strategy = build_alternate_win_strategy(win_con, support_cards)
        @potential_strategies << strategy if viable_strategy?(strategy)
      end
    end
  end

  def find_tribal_support(tribe)
    @cards.select do |card|
      text = card.oracle_text.downcase
      text.include?(tribe.downcase) || 
      text.match?(/creatures you control|each creature/)
    end
  end

  def mechanics_synergize?(mech1, mech2)
    # Définit des paires de mécaniques qui fonctionnent bien ensemble
    synergy_pairs = {
      'sacrifice' => ['token', 'treasure', 'death trigger'],
      'counter' => ['proliferate', 'shield', 'modify'],
      'copy' => ['spell', 'token', 'trigger'],
      # Ajouter d'autres paires synergiques
    }
    
    synergy_pairs[mech1]&.include?(mech2) || 
    synergy_pairs[mech2]&.include?(mech1)
  end

  def find_alternate_win_conditions
    @cards.select do |card|
      text = card.oracle_text.downcase
      text.include?('win the game') || 
      text.include?('can\'t lose the game') ||
      (card.power.to_i >= 7 && card.keywords.include?('Trample')) ||
      text.match?(/deals.*damage.*each opponent/)
    end
  end

  def viable_strategy?(strategy)
    return false unless strategy[:cards].size >= 20
    
    has_early_game = strategy[:cards].any? { |c| c.cmc <= 2 }
    has_card_advantage = strategy[:cards].any? { |c| provides_card_advantage?(c) }
    has_interaction = strategy[:cards].any? { |c| provides_interaction?(c) }
    
    has_early_game && has_card_advantage && has_interaction
  end

  def provides_card_advantage?(card)
    text = card.oracle_text.downcase
    text.match?(/draw.*card|return.*to.*hand|create.*token|investigate|scry 2/)
  end

  def provides_interaction?(card)
    text = card.oracle_text.downcase
    text.match?(/destroy|exile|counter|return.*to.*library|damage|reduce/)
  end

  def build_decklist(strategy)
    {
      main_deck: suggest_main_deck(strategy),
      sideboard: suggest_sideboard(strategy),
      mana_base: suggest_mana_base(strategy),
      key_cards: identify_key_cards(strategy),
      synergy_packages: identify_synergy_packages(strategy),
      strategy_guide: {
        game_plan: describe_game_plan(strategy),
        key_synergies: describe_key_synergies(strategy),
        mulligan_guide: create_mulligan_guide(strategy)
      }
    }
  end
end