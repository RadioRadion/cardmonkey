class AddEnglishAndFrenchNamesToCards < ActiveRecord::Migration[6.0]
  def change
    add_column :cards, :name_en, :string
    add_column :cards, :name_fr, :string
  end
end
