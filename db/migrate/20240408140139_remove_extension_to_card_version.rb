class RemoveExtensionToCardVersion < ActiveRecord::Migration[7.1]
  def change
    change_table "card_versions", force: :cascade do |t|
      t.remove "extension"
    end
  end
end
