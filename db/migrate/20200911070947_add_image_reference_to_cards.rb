class AddImageReferenceToCards < ActiveRecord::Migration[6.0]
  def change
    add_reference :cards, :image, foreign_key: true
  end
end
