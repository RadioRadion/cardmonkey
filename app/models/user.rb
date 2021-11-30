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
  has_many :matches

  accepts_nested_attributes_for :user_cards

  def group_matches
    users = User.near(address, area)
      results = []
      users.each do |user|
        matches = Match
                    .where(user_id: id, user_id_target: user.id)
                    .or(Match.where(user_id: user.id, user_id_target: id))
        total = matches.count
        results << {total: total, matches: matches, user: user} if user.id != id
      end
      results.sort_by { |i| i[:total] }.reverse
  end

end
