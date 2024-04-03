class AddCardVersionToUserWantedCards < ActiveRecord::Migration[7.1]
  def change
    add_reference :user_wanted_cards, :card_version, foreign_key: true, null: true
  end
end
