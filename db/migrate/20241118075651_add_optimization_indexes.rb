class AddOptimizationIndexes < ActiveRecord::Migration[7.1]
  def change
    # Indexes pour card_versions
    add_index :card_versions, [:card_id, :extension_id], 
      name: 'index_card_versions_on_card_and_extension'
    add_index :card_versions, :scryfall_id, 
      name: 'index_card_versions_on_scryfall_id'
    
    # Indexes pour user_cards
    add_index :user_cards, [:user_id, :card_version_id], 
      name: 'index_user_cards_on_user_and_card_version'
    
    # Indexes pour user_wanted_cards
    add_index :user_wanted_cards, [:user_id, :card_id, :card_version_id], 
      name: 'index_user_wanted_cards_on_user_card_and_version'
    
    # Indexes pour matches
    add_index :matches, [:user_id, :user_id_target], 
      name: 'index_matches_on_user_and_target'
    add_index :matches, [:user_id_target, :user_id], 
      name: 'index_matches_on_target_and_user'
    
    # Index pour trades
    add_index :trades, [:user_id, :user_id_invit], 
      name: 'index_trades_on_user_and_invit'
    
    # Index simple pour la géolocalisation
    add_index :users, [:latitude, :longitude], 
      name: 'index_users_on_coordinates'
  end
end