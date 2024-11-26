require "down"
require "fileutils"
require "net/http"

class Card < ApplicationRecord

  has_many :user_wanted_cards
  has_many :card_versions

  validates :scryfall_oracle_id, presence: true
  validates :name_fr, presence: true
  validates :name_en, presence: true

  def name(preferred_language = :en)
    case preferred_language
    when :en
      name_en
    when :fr
      name_fr
    else
      name_en
    end
  end
end
