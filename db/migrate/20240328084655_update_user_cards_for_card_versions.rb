class UpdateUserCardsForCardVersions < ActiveRecord::Migration[7.1]
  def change
    # Supprimer la référence à card_id
    remove_reference :user_cards, :card, index: true, foreign_key: true
    
    # Ajouter une référence à card_version_id
    add_reference :user_cards, :card_version, null: false, index: true, foreign_key: true
  end
end
