class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :trades
  has_many :messages
  has_many :chatrooms, through: :messages

  has_many :user_cards
  has_many :cards, through: :user_cards

  has_many :user_wanted_cards
  has_many :wanted_cards, through: :user_wanted_cards, class_name: "Card", source: :card

  def want_cards_by_user
    matches = {}
    result = []
    users = User.near(self.address, self.area)
    self.wants.each do |want|
      want.cards.each do |card|
        if users.include?(card.user)
          matches[card.user.id] ? matches[card.user.id] << card.id : matches[card.user.id] = [card.id]
        end
      end
    end
    matches.each do |user_id, total_cards|
      result << {
        username: User.find(user_id).username,
        user_id: user_id,
        cards: total_cards
      }
    end
    result
  end
end
