class CreateSupportedLanguages < ActiveRecord::Migration[7.1]
  def change
    create_table :supported_languages do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.boolean :active, default: true
      t.timestamps
      
      t.index :code, unique: true
    end
  end
end