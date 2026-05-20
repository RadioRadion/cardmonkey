class CreateCardLegalities < ActiveRecord::Migration[7.1]
  def change
    create_table :card_legalities do |t|
      t.references :card, null: false, foreign_key: true
      t.string :format, null: false
      t.string :status, null: false
      t.timestamps

      t.index [:card_id, :format], unique: true
    end

    add_check_constraint :card_legalities,
      "status IN ('legal', 'not_legal', 'restricted', 'banned')",
      name: 'check_legality_status'
  end
end