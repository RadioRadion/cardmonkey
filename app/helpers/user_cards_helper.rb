module UserCardsHelper
    def rarity_color(rarity)
      case rarity
      when 'common'
        'bg-black' # Noir pour commun
      when 'uncommon'
        'bg-gray-400' # Gris (argenté) pour peu commun
      when 'rare'
        'bg-yellow-500' # Jaune pour rare
      when 'mythic'
        'bg-orange-500' # Orange pour mythique
      else
        'bg-gray-300' # Gris clair pour tout ce qui n'est pas classifié
      end
    end
  end