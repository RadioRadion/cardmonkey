class CreateMatches < ActiveRecord::Migration[6.0]
  def change
    create_table :matches do |t|
      t.references :card, null: false, foreign_key: true
      t.references :want, null: false, foreign_key: true

      t.timestamps
    end
  end
end
