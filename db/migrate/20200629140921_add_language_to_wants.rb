class AddLanguageToWants < ActiveRecord::Migration[6.0]
  def change
    add_column :wants, :language, :string
  end
end
