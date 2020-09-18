class AddImageReferenceToWants < ActiveRecord::Migration[6.0]
  def change
    add_reference :wants, :image, foreign_key: true
  end
end
