class Card < ApplicationRecord
  belongs_to :user
  belongs_to :image
  has_many :trades, through: :card_trades

  validates :name, presence: true
  validates :quantity, presence: true
  validates :extension, presence: true
  validates :foil, presence: true
end
