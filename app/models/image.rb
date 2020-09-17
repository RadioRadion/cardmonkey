class Image < ApplicationRecord
  has_many :cards
  has_many :wants
end
