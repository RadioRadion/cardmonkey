class AddReleaseDateToCards < ActiveRecord::Migration[7.0]
  def change
    add_column :cards, :release_date, :date
  end
end
